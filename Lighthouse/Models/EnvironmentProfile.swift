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
    
    /// Magnet Desk live client sites → Production
    static let productionSeedSites: [(name: String, url: String)] = [
        ("Magnet", "https://magnet.co"),
        ("BSI Engineering", "https://bsiengr.com"),
        ("Commonwealth", "https://commonwealthinc.com"),
        ("Deseret First", "https://dfcu.com"),
        ("Directions Group", "https://directionsgroup.com"),
        ("Enthusiast Auto", "https://enthusiastauto.com"),
        ("Gorilla Glue", "https://gorillatough.com"),
        ("Inglis Digital", "https://inglisdigitalusa.com"),
        ("Nexterra Environmental", "https://nexterraenvironmental.com"),
        ("O'Keeffe's", "https://okeeffescompany.com"),
        ("Ocean City", "https://oceancity.com"),
        ("Vitis Tech", "https://vitistech.com"),
        ("Waites", "https://waites.net"),
        ("Washing Systems", "https://washingsystems.com"),
    ]
    
    /// K&P preview → Staging
    static let stagingSeedSites: [(name: String, url: String)] = [
        ("Kohnen & Patton (preview)", "https://kplaw-web.vercel.app/"),
    ]
    
    // Predefined profiles
    static let development = EnvironmentProfile(
        name: "Development",
        icon: "hammer.fill",
        refreshInterval: 15
    )
    
    static let staging = EnvironmentProfile(
        name: "Staging",
        icon: "wrench.and.screwdriver.fill",
        websites: seedWebsites(stagingSeedSites),
        refreshInterval: 30
    )
    
    static let production = EnvironmentProfile(
        name: "Production",
        icon: "checkmark.seal.fill",
        websites: seedWebsites(productionSeedSites),
        refreshInterval: 60,
        isActive: true
    )
    
    static let defaults: [EnvironmentProfile] = [
        .development,
        .staging,
        .production
    ]
    
    /// Seed URLs for a profile name, if any.
    static func seedSites(forProfileName name: String) -> [(name: String, url: String)] {
        switch name.lowercased() {
        case "production":
            return productionSeedSites
        case "staging":
            return stagingSeedSites
        default:
            return []
        }
    }
    
    private static func seedWebsites(_ sites: [(name: String, url: String)]) -> [WebsiteInfo] {
        sites.map { site in
            WebsiteInfo(url: site.url, displayName: site.name, isInternal: false)
        }
    }
    
    /// Canonical URL key for merge-by-URL seeding.
    static func canonicalURL(_ url: String) -> String {
        var normalized = url.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if normalized.hasSuffix("/") {
            normalized = String(normalized.dropLast())
        }
        return normalized
    }
}
