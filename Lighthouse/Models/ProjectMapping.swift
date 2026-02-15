import Foundation

/// A saved project mapping that associates folder/path patterns with a friendly project name
struct ProjectMapping: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String  // Display name like "Enthusiast Auto"
    var patterns: [String]  // Folder name patterns to match (e.g., "enthusiastauto", "enthusiast-auto")
    var color: String?  // Optional hex color for the project
    var icon: String?  // Optional SF Symbol name
    let createdDate: Date
    var isEnabled: Bool
    
    init(
        id: UUID = UUID(),
        name: String,
        patterns: [String] = [],
        color: String? = nil,
        icon: String? = nil,
        createdDate: Date = Date(),
        isEnabled: Bool = true
    ) {
        self.id = id
        self.name = name
        self.patterns = patterns.isEmpty ? [Self.generatePattern(from: name)] : patterns
        self.color = color
        self.icon = icon
        self.createdDate = createdDate
        self.isEnabled = isEnabled
    }
    
    /// Generate a default pattern from the project name
    static func generatePattern(from name: String) -> String {
        name.lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: "'", with: "")
    }
    
    /// Check if a folder name or path matches this project
    func matches(folderName: String?, workingDirectory: String?, projectName: String?) -> Bool {
        let candidates = [folderName, projectName].compactMap { $0?.lowercased() }
        let pathLower = workingDirectory?.lowercased() ?? ""
        
        for pattern in patterns {
            let patternLower = pattern.lowercased()
            
            // Check folder name and project name
            for candidate in candidates {
                if candidate.contains(patternLower) || patternLower.contains(candidate) {
                    return true
                }
            }
            
            // Check if pattern appears in the full path
            if !pathLower.isEmpty && pathLower.contains(patternLower) {
                return true
            }
        }
        
        return false
    }
}

/// A group of ports belonging to the same project
struct ProjectGroup: Identifiable {
    let id: String  // Project name or "unknown-N"
    let name: String
    let mapping: ProjectMapping?  // nil for unknown projects
    var ports: [PortInfo]
    var isExpanded: Bool = true
    
    var isUnknown: Bool {
        mapping == nil
    }
}
