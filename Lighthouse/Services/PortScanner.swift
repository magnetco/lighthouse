import Foundation

class PortScanner {

    /// Scan for all listening TCP ports
    func scanPorts() async throws -> [PortInfo] {
        let command = "lsof -iTCP -sTCP:LISTEN -n -P 2>/dev/null"
        let output = try await ShellExecutor.execute(command)
        var ports = parseOutput(output)

        // Fetch working directories for each process
        await withTaskGroup(of: (Int, String?).self) { group in
            for port in ports {
                group.addTask {
                    let cwd = await self.getWorkingDirectory(pid: port.pid)
                    return (port.pid, cwd)
                }
            }

            var cwdMap: [Int: String] = [:]
            for await (pid, cwd) in group {
                if let cwd = cwd {
                    cwdMap[pid] = cwd
                }
            }

            for i in ports.indices {
                ports[i].workingDirectory = cwdMap[ports[i].pid]
            }
        }

        return ports
    }

    /// Get working directory for a process
    private func getWorkingDirectory(pid: Int) async -> String? {
        do {
            let output = try await ShellExecutor.execute("lsof -p \(pid) -Fn 2>/dev/null | grep '^n/' | grep 'cwd' -A1 | tail -1 | cut -c2-")
            let cwd = output.trimmingCharacters(in: .whitespacesAndNewlines)

            // If that didn't work, try pwdx equivalent on macOS
            if cwd.isEmpty {
                let output2 = try await ShellExecutor.execute("lsof -a -p \(pid) -d cwd -Fn 2>/dev/null | grep '^n' | cut -c2-")
                let cwd2 = output2.trimmingCharacters(in: .whitespacesAndNewlines)
                return cwd2.isEmpty ? nil : cwd2
            }

            return cwd.isEmpty ? nil : cwd
        } catch {
            return nil
        }
    }

    private func parseOutput(_ output: String) -> [PortInfo] {
        let lines = output.components(separatedBy: "\n")
        let dataLines = lines.dropFirst().filter { !$0.isEmpty }

        var ports: [PortInfo] = []
        var seenPorts: Set<Int> = []

        for line in dataLines {
            if let portInfo = parseLine(line) {
                if !seenPorts.contains(portInfo.port) {
                    seenPorts.insert(portInfo.port)
                    ports.append(portInfo)
                }
            }
        }

        return ports.sorted { $0.port < $1.port }
    }

    private func parseLine(_ line: String) -> PortInfo? {
        let components = line.split(whereSeparator: { $0.isWhitespace }).map { String($0) }
        guard components.count >= 9 else { return nil }

        let processName = components[0]
        guard let pid = Int(components[1]) else { return nil }
        let user = components[2]

        var nameField: String
        if components.count >= 10 {
            nameField = components[8]
        } else {
            nameField = components.last ?? ""
        }

        guard let port = extractPort(from: nameField) else { return nil }

        return PortInfo(
            port: port,
            pid: pid,
            processName: processName,
            user: user,
            workingDirectory: nil
        )
    }

    private func extractPort(from nameField: String) -> Int? {
        let cleaned = nameField.replacingOccurrences(of: "(LISTEN)", with: "").trimmingCharacters(in: .whitespaces)

        if cleaned.contains("]:") {
            let parts = cleaned.components(separatedBy: "]:")
            if parts.count >= 2 {
                return Int(parts[1])
            }
        }

        let parts = cleaned.components(separatedBy: ":")
        if let lastPart = parts.last {
            return Int(lastPart)
        }

        return nil
    }

}
