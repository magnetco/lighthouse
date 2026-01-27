import Foundation

struct PortInfo: Identifiable, Hashable {
    let id = UUID()
    let port: Int
    let pid: Int
    let processName: String
    let user: String
    var workingDirectory: String?

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
}
