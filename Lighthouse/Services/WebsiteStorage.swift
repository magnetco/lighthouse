import Foundation

enum WebsiteStorageError: Error, LocalizedError {
    case fileNotFound
    case encodingFailed(Error)
    case decodingFailed(Error)
    case directoryCreationFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "Websites file not found"
        case .encodingFailed(let error):
            return "Failed to encode websites: \(error.localizedDescription)"
        case .decodingFailed(let error):
            return "Failed to decode websites: \(error.localizedDescription)"
        case .directoryCreationFailed(let error):
            return "Failed to create directory: \(error.localizedDescription)"
        }
    }
}

class WebsiteStorage {
    private let fileURL: URL
    
    init() {
        // Get Application Support directory
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let lighthouseDir = appSupport.appendingPathComponent("Lighthouse", isDirectory: true)
        
        // Create directory if it doesn't exist
        try? FileManager.default.createDirectory(at: lighthouseDir, withIntermediateDirectories: true)
        
        self.fileURL = lighthouseDir.appendingPathComponent("websites.json")
    }
    
    /// Load websites from disk
    func load() -> [WebsiteInfo] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let websites = try decoder.decode([WebsiteInfo].self, from: data)
            return websites
        } catch {
            print("Failed to load websites: \(error)")
            return []
        }
    }
    
    /// Save websites to disk
    func save(_ websites: [WebsiteInfo]) throws {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(websites)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            throw WebsiteStorageError.encodingFailed(error)
        }
    }
    
    /// Add a new website
    func add(_ website: WebsiteInfo) throws {
        var websites = load()
        websites.append(website)
        try save(websites)
    }
    
    /// Remove a website by ID
    func remove(id: UUID) throws {
        var websites = load()
        websites.removeAll { $0.id == id }
        try save(websites)
    }
    
    /// Update an existing website
    func update(_ website: WebsiteInfo) throws {
        var websites = load()
        if let index = websites.firstIndex(where: { $0.id == website.id }) {
            websites[index] = website
            try save(websites)
        }
    }
    
    /// Check if storage file exists
    var fileExists: Bool {
        return FileManager.default.fileExists(atPath: fileURL.path)
    }
    
    /// Get file path for debugging
    var filePath: String {
        return fileURL.path
    }
}
