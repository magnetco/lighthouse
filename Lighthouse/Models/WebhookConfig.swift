import Foundation

struct WebhookConfig: Codable, Identifiable {
    var id: UUID
    var name: String
    var url: String
    var type: WebhookType
    var isEnabled: Bool
    var triggerOnDown: Bool
    var triggerOnRecovery: Bool
    var triggerOnWarning: Bool
    
    init(id: UUID = UUID(), name: String, url: String, type: WebhookType, isEnabled: Bool = true, triggerOnDown: Bool = true, triggerOnRecovery: Bool = true, triggerOnWarning: Bool = false) {
        self.id = id
        self.name = name
        self.url = url
        self.type = type
        self.isEnabled = isEnabled
        self.triggerOnDown = triggerOnDown
        self.triggerOnRecovery = triggerOnRecovery
        self.triggerOnWarning = triggerOnWarning
    }
}

enum WebhookType: String, Codable, CaseIterable {
    case slack = "Slack"
    case discord = "Discord"
    case generic = "Generic JSON"
}

struct WebhookEvent {
    let websiteName: String
    let url: String
    let isDown: Bool
    let statusCode: Int?
    let responseTime: TimeInterval?
    let timestamp: Date
    
    init(website: WebsiteInfo, isDown: Bool) {
        self.websiteName = website.effectiveDisplayName
        self.url = website.url
        self.isDown = isDown
        self.statusCode = website.latestPing?.statusCode
        self.responseTime = website.latestPing?.responseTime
        self.timestamp = Date()
    }
}
