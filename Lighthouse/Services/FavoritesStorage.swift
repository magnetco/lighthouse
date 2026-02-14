import Foundation

class FavoritesStorage {
    private let portsKey = "starredPorts"
    private let userDefaults = UserDefaults.standard
    
    // Store by unique identifier (port + process name combo)
    var starredPortIdentifiers: Set<String> {
        get {
            Set(userDefaults.stringArray(forKey: portsKey) ?? [])
        }
        set {
            userDefaults.set(Array(newValue), forKey: portsKey)
        }
    }
    
    func isPortStarred(_ port: PortInfo) -> Bool {
        starredPortIdentifiers.contains(port.uniqueIdentifier)
    }
    
    func togglePortStar(_ port: PortInfo) {
        var identifiers = starredPortIdentifiers
        if identifiers.contains(port.uniqueIdentifier) {
            identifiers.remove(port.uniqueIdentifier)
        } else {
            identifiers.insert(port.uniqueIdentifier)
        }
        starredPortIdentifiers = identifiers
    }
    
    func setPortStarred(_ port: PortInfo, starred: Bool) {
        var identifiers = starredPortIdentifiers
        if starred {
            identifiers.insert(port.uniqueIdentifier)
        } else {
            identifiers.remove(port.uniqueIdentifier)
        }
        starredPortIdentifiers = identifiers
    }
}
