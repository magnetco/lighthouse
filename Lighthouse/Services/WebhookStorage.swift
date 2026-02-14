import Foundation

class WebhookStorage {
    private let fileURL: URL
    
    init() {
        // Get Application Support directory
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let lighthouseDir = appSupport.appendingPathComponent("Lighthouse", isDirectory: true)
        
        // Create directory if it doesn't exist
        try? FileManager.default.createDirectory(at: lighthouseDir, withIntermediateDirectories: true)
        
        self.fileURL = lighthouseDir.appendingPathComponent("webhooks.json")
    }
    
    func load() -> [WebhookConfig] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            let webhooks = try decoder.decode([WebhookConfig].self, from: data)
            return webhooks
        } catch {
            print("Failed to load webhooks: \(error)")
            return []
        }
    }
    
    func save(_ webhooks: [WebhookConfig]) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(webhooks)
        try data.write(to: fileURL, options: .atomic)
    }
}
