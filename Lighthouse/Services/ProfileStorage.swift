import Foundation

class ProfileStorage {
    private let fileURL: URL
    
    init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDir = appSupport.appendingPathComponent("Lighthouse", isDirectory: true)
        
        // Create directory if it doesn't exist
        try? FileManager.default.createDirectory(at: appDir, withIntermediateDirectories: true)
        
        fileURL = appDir.appendingPathComponent("profiles.json")
    }
    
    func load() -> [EnvironmentProfile] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            // Return default profiles if file doesn't exist
            return EnvironmentProfile.defaults
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let profiles = try decoder.decode([EnvironmentProfile].self, from: data)
            return profiles.isEmpty ? EnvironmentProfile.defaults : profiles
        } catch {
            print("Failed to load profiles: \(error)")
            return EnvironmentProfile.defaults
        }
    }
    
    func save(_ profiles: [EnvironmentProfile]) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(profiles)
        try data.write(to: fileURL)
    }
    
    func getActiveProfile(from profiles: [EnvironmentProfile]) -> EnvironmentProfile? {
        return profiles.first(where: { $0.isActive })
    }
}
