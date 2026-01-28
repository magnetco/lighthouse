import Foundation

struct PortInfo: Identifiable, Hashable {
    let id = UUID()
    let port: Int
    let pid: Int
    let processName: String
    let user: String
    var workingDirectory: String?
    var commandLine: String?
    var projectName: String?
    var detectedFramework: String?

    /// Is this a web development server?
    var isDevServer: Bool {
        let devProcesses = [
            "node", "npm", "npx", "yarn", "pnpm", "bun", "deno",
            "python", "python3", "uvicorn", "gunicorn", "flask", "django",
            "ruby", "rails", "puma", "unicorn",
            "php", "artisan",
            "java", "gradle", "mvn",
            "go", "air",
            "cargo", "rust",
            "next-server", "vite", "webpack", "esbuild", "parcel", "turbopack"
        ]

        let proc = processName.lowercased()

        // Check if it's a known dev process
        if devProcesses.contains(proc) {
            return true
        }

        // Check for node-based tools that might have different names
        if proc.contains("node") || proc.contains("next") || proc.contains("vite") {
            return true
        }

        return false
    }

    /// Folder name from working directory
    var folderName: String? {
        guard let dir = workingDirectory else { return nil }
        let folder = URL(fileURLWithPath: dir).lastPathComponent
        // Don't show root or home
        if folder == "/" || folder == NSUserName() {
            return nil
        }
        return folder
    }

    /// Port as string without formatting
    var portString: String {
        return String(port)
    }
    
    /// Intelligent display name with priority:
    /// 1. Project name from metadata (e.g., "gorilla-assets")
    /// 2. Folder name (e.g., "my-project")
    /// 3. Detected framework/tool (e.g., "Next.js Dev Server")
    /// 4. Process name (last resort)
    var displayName: String {
        // Priority 1: Project name from package.json, etc.
        if let project = projectName, !project.isEmpty {
            return project
        }
        
        // Priority 2: Folder name
        if let folder = folderName {
            return folder
        }
        
        // Priority 3: Framework/tool name
        if let framework = detectedFramework {
            return framework
        }
        
        // Priority 4: Process name
        return processName
    }
    
    /// Secondary info line (framework/app type shown inline)
    var secondaryInfo: String? {
        // Show framework as secondary if we have a project/folder name
        if (projectName != nil || folderName != nil), let framework = detectedFramework {
            return framework
        }
        return nil
    }
}
