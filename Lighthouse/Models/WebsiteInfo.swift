import Foundation

struct WebsiteInfo: Identifiable, Codable, Hashable {
    let id: UUID
    var url: String
    var displayName: String
    var lastPingStatus: PingStatus?
    var pingHistory: [PingResult]
    let addedDate: Date
    var isEnabled: Bool
    var isInternal: Bool? // Optional to allow auto-detection
    var detectedFramework: String? // Framework/stack name (e.g., "Next.js", "Django")
    
    init(id: UUID = UUID(), url: String, displayName: String, addedDate: Date = Date(), isEnabled: Bool = true, isInternal: Bool? = nil, detectedFramework: String? = nil) {
        self.id = id
        self.url = url
        self.displayName = displayName
        self.lastPingStatus = .unknown
        self.pingHistory = []
        self.addedDate = addedDate
        self.isEnabled = isEnabled
        self.isInternal = isInternal
        self.detectedFramework = detectedFramework
    }
    
    /// The name to display in the UI
    var effectiveDisplayName: String {
        if displayName.isEmpty {
            return cleanedURL
        }
        return displayName
    }
    
    /// Determine if this is an internal website (localhost or local network)
    var isInternalWebsite: Bool {
        // Manual override takes precedence
        if let manual = isInternal {
            return manual
        }
        
        // Auto-detect from URL
        let lowercasedURL = url.lowercased()
        
        // Check for localhost
        if lowercasedURL.contains("localhost") {
            return true
        }
        
        // Check for 127.0.0.1
        if lowercasedURL.contains("127.0.0.1") {
            return true
        }
        
        // Check for local IP ranges (192.168.x.x, 10.x.x.x, 172.16-31.x.x)
        if lowercasedURL.contains("192.168.") || 
           lowercasedURL.contains("10.") ||
           lowercasedURL.range(of: "172\\.(1[6-9]|2[0-9]|3[0-1])\\.", options: .regularExpression) != nil {
            return true
        }
        
        // Check for [::1] (IPv6 localhost)
        if lowercasedURL.contains("[::1]") {
            return true
        }
        
        return false
    }
    
    /// Cleaned URL for display (without protocol)
    var cleanedURL: String {
        var cleaned = url
        cleaned = cleaned.replacingOccurrences(of: "https://", with: "")
        cleaned = cleaned.replacingOccurrences(of: "http://", with: "")
        cleaned = cleaned.replacingOccurrences(of: "www.", with: "")
        if cleaned.hasSuffix("/") {
            cleaned = String(cleaned.dropLast())
        }
        return cleaned
    }
    
    /// Most recent ping result
    var latestPing: PingResult? {
        return pingHistory.first
    }
    
    /// Average response time from history
    var averageResponseTime: TimeInterval? {
        let reachable = pingHistory.filter { $0.isReachable }
        guard !reachable.isEmpty else { return nil }
        let sum = reachable.reduce(0.0) { $0 + $1.responseTime }
        return sum / Double(reachable.count)
    }
    
    /// Average response time in milliseconds for display
    var averageResponseTimeMs: String? {
        guard let avg = averageResponseTime else { return nil }
        return String(format: "%.0fms", avg * 1000)
    }
    
    /// Uptime percentage from history
    var uptimePercentage: Double? {
        guard !pingHistory.isEmpty else { return nil }
        let successful = pingHistory.filter { $0.isReachable && ($0.statusCode ?? 0) >= 200 && ($0.statusCode ?? 0) < 300 }.count
        return Double(successful) / Double(pingHistory.count) * 100
    }
    
    /// Uptime percentage formatted for display
    var uptimeString: String? {
        guard let uptime = uptimePercentage else { return nil }
        return String(format: "%.0f%%", uptime)
    }
    
    /// Add a new ping result to history (keeps last 10)
    mutating func addPingResult(_ result: PingResult) {
        pingHistory.insert(result, at: 0)
        if pingHistory.count > 10 {
            pingHistory = Array(pingHistory.prefix(10))
        }
        lastPingStatus = PingStatus.from(result: result)
    }
    
    /// Recent ping results for tooltip (last 5)
    var recentPings: [PingResult] {
        return Array(pingHistory.prefix(5))
    }
}
