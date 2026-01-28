import Foundation

struct DockerContainer: Identifiable, Hashable {
    let id: String // Container ID
    let name: String
    let image: String
    let status: ContainerStatus
    let ports: [PortMapping]
    let createdAt: Date?
    
    enum ContainerStatus: String, Codable {
        case running
        case paused
        case exited
        case created
        case restarting
        case removing
        case dead
        case unknown
        
        var displayName: String {
            rawValue.capitalized
        }
        
        var color: String {
            switch self {
            case .running: return "green"
            case .paused: return "yellow"
            case .exited, .dead: return "red"
            case .restarting: return "orange"
            default: return "gray"
            }
        }
    }
    
    struct PortMapping: Hashable, Codable {
        let containerPort: Int
        let hostPort: Int?
        let protocolType: String // tcp or udp
        
        var displayString: String {
            if let host = hostPort {
                return "\(host) → \(containerPort)/\(protocolType)"
            } else {
                return "\(containerPort)/\(protocolType)"
            }
        }
    }
    
    var displayName: String {
        // Remove leading slash if present
        let cleaned = name.hasPrefix("/") ? String(name.dropFirst()) : name
        return cleaned.isEmpty ? id.prefix(12).description : cleaned
    }
    
    var shortImage: String {
        // Remove registry and just show image:tag
        let components = image.split(separator: "/")
        return String(components.last ?? "")
    }
    
    var isRunning: Bool {
        status == .running
    }
}
