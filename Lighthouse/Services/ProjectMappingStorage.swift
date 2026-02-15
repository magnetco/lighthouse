import Foundation

class ProjectMappingStorage {
    private let fileURL: URL
    
    init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDir = appSupport.appendingPathComponent("Lighthouse", isDirectory: true)
        
        // Create directory if it doesn't exist
        try? FileManager.default.createDirectory(at: appDir, withIntermediateDirectories: true)
        
        fileURL = appDir.appendingPathComponent("project_mappings.json")
    }
    
    /// Load project mappings from disk
    func load() -> [ProjectMapping] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            // Return default mappings if file doesn't exist
            return Self.defaultMappings
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let mappings = try decoder.decode([ProjectMapping].self, from: data)
            return mappings.isEmpty ? Self.defaultMappings : mappings
        } catch {
            print("Failed to load project mappings: \(error)")
            return Self.defaultMappings
        }
    }
    
    /// Save project mappings to disk
    func save(_ mappings: [ProjectMapping]) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(mappings)
        try data.write(to: fileURL, options: .atomic)
    }
    
    /// Add a new project mapping
    func add(_ mapping: ProjectMapping) throws {
        var mappings = load()
        mappings.append(mapping)
        try save(mappings)
    }
    
    /// Remove a project mapping by ID
    func remove(id: UUID) throws {
        var mappings = load()
        mappings.removeAll { $0.id == id }
        try save(mappings)
    }
    
    /// Update an existing project mapping
    func update(_ mapping: ProjectMapping) throws {
        var mappings = load()
        if let index = mappings.firstIndex(where: { $0.id == mapping.id }) {
            mappings[index] = mapping
            try save(mappings)
        }
    }
    
    /// Default project mappings
    static let defaultMappings: [ProjectMapping] = [
        ProjectMapping(
            name: "Enthusiast Auto",
            patterns: ["enthusiastauto", "enthusiast-auto", "enthusiast_auto", "ea-"]
        ),
        ProjectMapping(
            name: "Deseret First Credit Union",
            patterns: ["deseret", "dfcu", "deseret-first"]
        ),
        ProjectMapping(
            name: "Magnet",
            patterns: ["magnet"]
        ),
        ProjectMapping(
            name: "Gorilla Glue",
            patterns: ["gorilla", "gorilla-glue", "gorillaglue"]
        ),
        ProjectMapping(
            name: "O'Keeffe's",
            patterns: ["okeeffe", "okeeffes", "o-keeffe"]
        ),
        ProjectMapping(
            name: "Commonwealth",
            patterns: ["commonwealth", "cwlth"]
        ),
        ProjectMapping(
            name: "WSI",
            patterns: ["wsi", "wsi-"]
        )
    ]
}
