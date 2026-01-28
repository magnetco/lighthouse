import Foundation

class ProjectDetector {
    
    /// Detect framework/tool from command line
    func detectFramework(from commandLine: String) -> String? {
        let cmd = commandLine.lowercased()
        
        // Prisma Studio
        if cmd.contains("prisma studio") || cmd.contains("prisma-studio") {
            return "Prisma Studio"
        }
        
        // Next.js
        if cmd.contains("next dev") || cmd.contains("next-server") {
            return "Next.js Dev Server"
        }
        if cmd.contains("next start") {
            return "Next.js"
        }
        
        // Vite
        if cmd.contains("vite") && !cmd.contains("vitest") {
            if cmd.contains("vite preview") {
                return "Vite Preview"
            }
            return "Vite Dev Server"
        }
        
        // Create React App
        if cmd.contains("react-scripts start") {
            return "Create React App"
        }
        
        // Webpack Dev Server
        if cmd.contains("webpack-dev-server") || cmd.contains("webpack serve") {
            return "Webpack Dev Server"
        }
        
        // Parcel
        if cmd.contains("parcel") {
            return "Parcel Dev Server"
        }
        
        // Turbopack
        if cmd.contains("turbopack") {
            return "Turbopack Dev Server"
        }
        
        // Django
        if cmd.contains("manage.py runserver") || cmd.contains("django") {
            return "Django Dev Server"
        }
        
        // Flask
        if cmd.contains("flask run") {
            return "Flask Dev Server"
        }
        
        // FastAPI / Uvicorn
        if cmd.contains("uvicorn") {
            // Try to extract app name
            if let appName = extractUvicornApp(from: commandLine) {
                return "FastAPI (\(appName))"
            }
            return "FastAPI/Uvicorn"
        }
        
        // Gunicorn
        if cmd.contains("gunicorn") {
            return "Gunicorn"
        }
        
        // Rails
        if cmd.contains("rails server") || cmd.contains("rails s") {
            return "Rails Server"
        }
        if cmd.contains("puma") {
            return "Puma (Rails)"
        }
        
        // PHP
        if cmd.contains("php artisan serve") {
            return "Laravel Dev Server"
        }
        if cmd.contains("php -s") || cmd.contains("php -s") {
            return "PHP Dev Server"
        }
        
        // Go
        if cmd.contains("air") && cmd.contains(".go") {
            return "Air (Go)"
        }
        
        // Rust
        if cmd.contains("cargo run") || cmd.contains("cargo watch") {
            return "Cargo (Rust)"
        }
        
        // Bun
        if cmd.contains("bun dev") || cmd.contains("bun run dev") {
            return "Bun Dev Server"
        }
        
        // Deno
        if cmd.contains("deno run") && cmd.contains("--watch") {
            return "Deno Dev Server"
        }
        
        // Nuxt
        if cmd.contains("nuxt dev") {
            return "Nuxt Dev Server"
        }
        
        // SvelteKit
        if cmd.contains("svelte-kit dev") || cmd.contains("vite") && cmd.contains("svelte") {
            return "SvelteKit Dev Server"
        }
        
        // Remix
        if cmd.contains("remix dev") {
            return "Remix Dev Server"
        }
        
        // Astro
        if cmd.contains("astro dev") {
            return "Astro Dev Server"
        }
        
        // Gatsby
        if cmd.contains("gatsby develop") {
            return "Gatsby Dev Server"
        }
        
        // Angular
        if cmd.contains("ng serve") {
            return "Angular Dev Server"
        }
        
        // Vue CLI
        if cmd.contains("vue-cli-service serve") {
            return "Vue Dev Server"
        }
        
        // Storybook
        if cmd.contains("storybook") {
            return "Storybook"
        }
        
        // Docusaurus
        if cmd.contains("docusaurus start") {
            return "Docusaurus"
        }
        
        // Jekyll
        if cmd.contains("jekyll serve") {
            return "Jekyll"
        }
        
        // Hugo
        if cmd.contains("hugo server") {
            return "Hugo"
        }
        
        return nil
    }
    
    /// Extract app name from uvicorn command
    private func extractUvicornApp(from commandLine: String) -> String? {
        // Pattern: uvicorn main:app or uvicorn app.main:app
        let pattern = #"uvicorn\s+([a-zA-Z0-9_.]+):.*"#
        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
           let match = regex.firstMatch(in: commandLine, range: NSRange(commandLine.startIndex..., in: commandLine)),
           let range = Range(match.range(at: 1), in: commandLine) {
            let appPath = String(commandLine[range])
            // Return just the last part (e.g., "main" from "app.main")
            return appPath.components(separatedBy: ".").last
        }
        return nil
    }
    
    /// Read project name from package.json
    func readProjectName(from workingDirectory: String) async -> String? {
        // Try package.json (Node.js)
        if let name = await readPackageJson(at: workingDirectory) {
            return name
        }
        
        // Try pyproject.toml (Python)
        if let name = await readPyprojectToml(at: workingDirectory) {
            return name
        }
        
        // Try Cargo.toml (Rust)
        if let name = await readCargoToml(at: workingDirectory) {
            return name
        }
        
        // Try go.mod (Go)
        if let name = await readGoMod(at: workingDirectory) {
            return name
        }
        
        return nil
    }
    
    /// Read package.json name field
    private func readPackageJson(at directory: String) async -> String? {
        let path = "\(directory)/package.json"
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let name = json["name"] as? String else {
            return nil
        }
        return name
    }
    
    /// Read pyproject.toml name field
    private func readPyprojectToml(at directory: String) async -> String? {
        let path = "\(directory)/pyproject.toml"
        guard let content = try? String(contentsOfFile: path) else {
            return nil
        }
        
        // Simple TOML parsing for name field
        let lines = content.components(separatedBy: .newlines)
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.starts(with: "name") && trimmed.contains("=") {
                let parts = trimmed.components(separatedBy: "=")
                if parts.count >= 2 {
                    let name = parts[1].trimmingCharacters(in: .whitespaces)
                        .trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
                    return name
                }
            }
        }
        return nil
    }
    
    /// Read Cargo.toml name field
    private func readCargoToml(at directory: String) async -> String? {
        let path = "\(directory)/Cargo.toml"
        guard let content = try? String(contentsOfFile: path) else {
            return nil
        }
        
        // Simple TOML parsing for name field in [package] section
        let lines = content.components(separatedBy: .newlines)
        var inPackageSection = false
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed == "[package]" {
                inPackageSection = true
                continue
            }
            if trimmed.starts(with: "[") {
                inPackageSection = false
            }
            if inPackageSection && trimmed.starts(with: "name") && trimmed.contains("=") {
                let parts = trimmed.components(separatedBy: "=")
                if parts.count >= 2 {
                    let name = parts[1].trimmingCharacters(in: .whitespaces)
                        .trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
                    return name
                }
            }
        }
        return nil
    }
    
    /// Read go.mod module name
    private func readGoMod(at directory: String) async -> String? {
        let path = "\(directory)/go.mod"
        guard let content = try? String(contentsOfFile: path) else {
            return nil
        }
        
        // First line should be: module github.com/user/project
        let lines = content.components(separatedBy: .newlines)
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.starts(with: "module ") {
                let modulePath = trimmed.replacingOccurrences(of: "module ", with: "")
                // Return just the last component
                return modulePath.components(separatedBy: "/").last
            }
        }
        return nil
    }
}
