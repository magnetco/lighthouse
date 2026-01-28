import Foundation

class DockerManager {
    private let dockerPath: String
    
    init() {
        // Try common Docker paths
        let possiblePaths = [
            "/usr/local/bin/docker",
            "/opt/homebrew/bin/docker",
            "/usr/bin/docker"
        ]
        
        dockerPath = possiblePaths.first { FileManager.default.fileExists(atPath: $0) } ?? "/usr/local/bin/docker"
    }
    
    var isDockerAvailable: Bool {
        FileManager.default.fileExists(atPath: dockerPath)
    }
    
    func listContainers() async throws -> [DockerContainer] {
        guard isDockerAvailable else {
            throw DockerError.dockerNotInstalled
        }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: dockerPath)
        process.arguments = [
            "ps",
            "-a", // All containers
            "--format", "{{.ID}}|{{.Names}}|{{.Image}}|{{.Status}}|{{.Ports}}|{{.CreatedAt}}"
        ]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()
        
        try process.run()
        process.waitUntilExit()
        
        guard process.terminationStatus == 0 else {
            throw DockerError.commandFailed
        }
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(data: data, encoding: .utf8) else {
            return []
        }
        
        return parseContainers(output)
    }
    
    func startContainer(id: String) async throws {
        try await runDockerCommand(["start", id])
    }
    
    func stopContainer(id: String) async throws {
        try await runDockerCommand(["stop", id])
    }
    
    func restartContainer(id: String) async throws {
        try await runDockerCommand(["restart", id])
    }
    
    func removeContainer(id: String, force: Bool = false) async throws {
        var args = ["rm"]
        if force {
            args.append("-f")
        }
        args.append(id)
        try await runDockerCommand(args)
    }
    
    func getContainerLogs(id: String, tail: Int = 100) async throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: dockerPath)
        process.arguments = ["logs", "--tail", "\(tail)", id]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        try process.run()
        process.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8) ?? "No logs available"
    }
    
    private func runDockerCommand(_ args: [String]) async throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: dockerPath)
        process.arguments = args
        
        let pipe = Pipe()
        process.standardError = pipe
        
        try process.run()
        process.waitUntilExit()
        
        guard process.terminationStatus == 0 else {
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let error = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw DockerError.commandFailed
        }
    }
    
    private func parseContainers(_ output: String) -> [DockerContainer] {
        let lines = output.components(separatedBy: .newlines).filter { !$0.isEmpty }
        
        return lines.compactMap { line in
            let parts = line.components(separatedBy: "|")
            guard parts.count >= 5 else { return nil }
            
            let id = parts[0].trimmingCharacters(in: .whitespaces)
            let name = parts[1].trimmingCharacters(in: .whitespaces)
            let image = parts[2].trimmingCharacters(in: .whitespaces)
            let statusString = parts[3].trimmingCharacters(in: .whitespaces)
            let portsString = parts[4].trimmingCharacters(in: .whitespaces)
            
            let status = parseStatus(statusString)
            let ports = parsePorts(portsString)
            
            return DockerContainer(
                id: id,
                name: name,
                image: image,
                status: status,
                ports: ports,
                createdAt: nil
            )
        }
    }
    
    private func parseStatus(_ statusString: String) -> DockerContainer.ContainerStatus {
        let lowercased = statusString.lowercased()
        if lowercased.contains("up") {
            return .running
        } else if lowercased.contains("paused") {
            return .paused
        } else if lowercased.contains("exited") {
            return .exited
        } else if lowercased.contains("created") {
            return .created
        } else if lowercased.contains("restarting") {
            return .restarting
        } else if lowercased.contains("removing") {
            return .removing
        } else if lowercased.contains("dead") {
            return .dead
        }
        return .unknown
    }
    
    private func parsePorts(_ portsString: String) -> [DockerContainer.PortMapping] {
        guard !portsString.isEmpty else { return [] }
        
        var mappings: [DockerContainer.PortMapping] = []
        
        // Format: "0.0.0.0:8080->80/tcp, 443/tcp"
        let portSpecs = portsString.components(separatedBy: ", ")
        
        for spec in portSpecs {
            if spec.contains("->") {
                // Mapped port: "0.0.0.0:8080->80/tcp"
                let parts = spec.components(separatedBy: "->")
                if parts.count == 2 {
                    let hostPart = parts[0].components(separatedBy: ":").last ?? ""
                    let containerPart = parts[1]
                    
                    if let hostPort = Int(hostPart) {
                        let containerComponents = containerPart.components(separatedBy: "/")
                        if let containerPort = Int(containerComponents[0]) {
                            let proto = containerComponents.count > 1 ? containerComponents[1] : "tcp"
                            mappings.append(DockerContainer.PortMapping(
                                containerPort: containerPort,
                                hostPort: hostPort,
                                protocolType: proto
                            ))
                        }
                    }
                }
            } else {
                // Exposed but not mapped: "443/tcp"
                let components = spec.components(separatedBy: "/")
                if let port = Int(components[0]) {
                    let proto = components.count > 1 ? components[1] : "tcp"
                    mappings.append(DockerContainer.PortMapping(
                        containerPort: port,
                        hostPort: nil,
                        protocolType: proto
                    ))
                }
            }
        }
        
        return mappings
    }
}

enum DockerError: LocalizedError {
    case dockerNotInstalled
    case commandFailed
    
    var errorDescription: String? {
        switch self {
        case .dockerNotInstalled:
            return "Docker is not installed or not found in PATH"
        case .commandFailed:
            return "Docker command failed"
        }
    }
}
