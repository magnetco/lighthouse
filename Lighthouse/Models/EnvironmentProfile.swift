import Foundation

struct EnvironmentProfile: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var icon: String
    var websites: [WebsiteInfo]
    var refreshInterval: TimeInterval // in seconds
    var isActive: Bool
    
    init(
        id: UUID = UUID(),
        name: String,
        icon: String = "globe",
        websites: [WebsiteInfo] = [],
        refreshInterval: TimeInterval = 30,
        isActive: Bool = false
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.websites = websites
        self.refreshInterval = refreshInterval
        self.isActive = isActive
    }
    
    // Predefined profiles
    static let development = EnvironmentProfile(
        name: "Development",
        icon: "hammer.fill",
        refreshInterval: 15
    )
    
    static let staging = EnvironmentProfile(
        name: "Staging",
        icon: "wrench.and.screwdriver.fill",
        refreshInterval: 30
    )
    
    static let production = EnvironmentProfile(
        name: "Production",
        icon: "checkmark.seal.fill",
        refreshInterval: 60
    )
    
    static let defaults: [EnvironmentProfile] = [
        .development,
        .staging,
        .production
    ]
}
