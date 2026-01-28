import Foundation

struct PingResult: Codable, Hashable {
    let timestamp: Date
    let statusCode: Int?
    let responseTime: TimeInterval
    let latency: TimeInterval
    let isReachable: Bool
    let errorMessage: String?
    
    /// Human-readable status description
    var statusDescription: String {
        if let code = statusCode {
            return "\(code) \(httpStatusText(code))"
        } else if let error = errorMessage {
            return error
        } else {
            return "Unknown"
        }
    }
    
    /// Time ago string for display
    var timeAgo: String {
        let interval = Date().timeIntervalSince(timestamp)
        
        if interval < 60 {
            return "Just now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes) min ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h ago"
        } else {
            let days = Int(interval / 86400)
            return "\(days)d ago"
        }
    }
    
    /// Response time in milliseconds for display
    var responseTimeMs: String {
        return String(format: "%.0fms", responseTime * 1000)
    }
    
    /// HTTP status text
    private func httpStatusText(_ code: Int) -> String {
        switch code {
        case 200: return "OK"
        case 201: return "Created"
        case 204: return "No Content"
        case 301: return "Moved"
        case 302: return "Found"
        case 304: return "Not Modified"
        case 400: return "Bad Request"
        case 401: return "Unauthorized"
        case 403: return "Forbidden"
        case 404: return "Not Found"
        case 500: return "Server Error"
        case 502: return "Bad Gateway"
        case 503: return "Unavailable"
        default: return ""
        }
    }
}

enum PingStatus: String, Codable {
    case healthy
    case warning
    case error
    case unknown
    
    /// Determine status from ping result
    static func from(result: PingResult) -> PingStatus {
        guard result.isReachable else {
            return .error
        }
        
        guard let code = result.statusCode else {
            return .unknown
        }
        
        // Check status code
        if code >= 200 && code < 300 {
            // Check response time (slow = warning)
            if result.responseTime > 2.0 {
                return .warning
            }
            return .healthy
        } else if code >= 300 && code < 400 {
            return .warning
        } else {
            return .error
        }
    }
    
    /// Color for UI display
    var color: String {
        switch self {
        case .healthy: return "green"
        case .warning: return "orange"
        case .error: return "red"
        case .unknown: return "gray"
        }
    }
    
    /// Icon name for display
    var iconName: String {
        switch self {
        case .healthy: return "light.beacon.max.fill"
        case .warning: return "light.beacon.max"
        case .error: return "light.beacon.min"
        case .unknown: return "questionmark.circle"
        }
    }
}
