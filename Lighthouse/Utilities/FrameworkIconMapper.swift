import Foundation

/// Framework types with their canonical names
enum FrameworkType: String, CaseIterable {
    case nextjs = "Next.js"
    case vite = "Vite"
    case react = "React"
    case vue = "Vue"
    case angular = "Angular"
    case svelte = "Svelte"
    case nuxt = "Nuxt"
    case remix = "Remix"
    case astro = "Astro"
    case gatsby = "Gatsby"
    case django = "Django"
    case flask = "Flask"
    case fastapi = "FastAPI"
    case rails = "Rails"
    case laravel = "Laravel"
    case prisma = "Prisma"
    case docker = "Docker"
    case node = "Node.js"
    case python = "Python"
    case rust = "Rust"
    case go = "Go"
    case bun = "Bun"
    case deno = "Deno"
    case webpack = "Webpack"
    case parcel = "Parcel"
    case turbopack = "Turbopack"
    case storybook = "Storybook"
    case docusaurus = "Docusaurus"
    case jekyll = "Jekyll"
    case hugo = "Hugo"
    case php = "PHP"
    case gunicorn = "Gunicorn"
    case puma = "Puma"
    case uvicorn = "Uvicorn"
    // Databases
    case postgresql = "PostgreSQL"
    case mysql = "MySQL"
    case mongodb = "MongoDB"
    case redis = "Redis"
    case memcached = "Memcached"
    case elasticsearch = "Elasticsearch"
}

/// Maps framework names to icon identifiers
struct FrameworkIconMapper {
    
    /// Get the icon name (asset name or SF Symbol) for a given framework
    /// Returns tuple: (iconName, isAsset, fallbackSymbol) where isAsset indicates if it's a custom asset or SF Symbol
    /// fallbackSymbol is the SF Symbol to use if the asset is missing
    static func iconInfo(for framework: String?) -> (name: String, isAsset: Bool, fallbackSymbol: String) {
        guard let framework = framework else {
            return ("laptopcomputer", false, "laptopcomputer") // Default SF Symbol
        }
        
        // Try to match to a known framework type
        if let frameworkType = frameworkType(from: framework) {
            return iconInfoForType(frameworkType)
        }
        
        // Fallback to generic icon
        return ("laptopcomputer", false, "laptopcomputer")
    }
    
    /// Detect database type from process name and port
    static func detectDatabase(processName: String, port: Int) -> FrameworkType? {
        let normalized = processName.lowercased()
        
        // Check by process name first
        if normalized.contains("postgres") || normalized.contains("postmaster") {
            return .postgresql
        }
        if normalized.contains("mysqld") || normalized.contains("mariadbd") {
            return .mysql
        }
        if normalized.contains("mongod") {
            return .mongodb
        }
        if normalized.contains("redis") {
            return .redis
        }
        if normalized.contains("memcached") {
            return .memcached
        }
        if normalized.contains("elasticsearch") {
            return .elasticsearch
        }
        
        // Fallback to port-based detection
        switch port {
        case 5432:
            return .postgresql
        case 3306:
            return .mysql
        case 27017:
            return .mongodb
        case 6379:
            return .redis
        case 11211:
            return .memcached
        case 9200, 9300:
            return .elasticsearch
        default:
            return nil
        }
    }
    
    /// Get connection string for a database
    static func connectionString(for database: FrameworkType, port: Int, host: String = "localhost") -> String? {
        switch database {
        case .postgresql:
            return "postgresql://\(host):\(port)/database"
        case .mysql:
            return "mysql://\(host):\(port)/database"
        case .mongodb:
            return "mongodb://\(host):\(port)"
        case .redis:
            return "redis://\(host):\(port)"
        case .memcached:
            return "\(host):\(port)"
        case .elasticsearch:
            return "http://\(host):\(port)"
        default:
            return nil
        }
    }
    
    /// Get icon info for external websites
    static func externalWebsiteIcon() -> (name: String, isAsset: Bool, fallbackSymbol: String) {
        return ("globe", false, "globe") // SF Symbol
    }
    
    /// Parse detected framework string to enum
    static func frameworkType(from detectedString: String) -> FrameworkType? {
        let normalized = detectedString.lowercased()
        
        // Next.js
        if normalized.contains("next") {
            return .nextjs
        }
        
        // Vite
        if normalized.contains("vite") {
            return .vite
        }
        
        // React
        if normalized.contains("react") {
            return .react
        }
        
        // Vue
        if normalized.contains("vue") {
            return .vue
        }
        
        // Angular
        if normalized.contains("angular") {
            return .angular
        }
        
        // Svelte
        if normalized.contains("svelte") {
            return .svelte
        }
        
        // Nuxt
        if normalized.contains("nuxt") {
            return .nuxt
        }
        
        // Remix
        if normalized.contains("remix") {
            return .remix
        }
        
        // Astro
        if normalized.contains("astro") {
            return .astro
        }
        
        // Gatsby
        if normalized.contains("gatsby") {
            return .gatsby
        }
        
        // Django
        if normalized.contains("django") {
            return .django
        }
        
        // Flask
        if normalized.contains("flask") {
            return .flask
        }
        
        // FastAPI / Uvicorn
        if normalized.contains("fastapi") || normalized.contains("uvicorn") {
            return .fastapi
        }
        
        // Rails / Puma
        if normalized.contains("rails") || normalized.contains("puma") {
            return .rails
        }
        
        // Laravel
        if normalized.contains("laravel") {
            return .laravel
        }
        
        // Prisma
        if normalized.contains("prisma") {
            return .prisma
        }
        
        // Docker
        if normalized.contains("docker") {
            return .docker
        }
        
        // Bun
        if normalized.contains("bun") {
            return .bun
        }
        
        // Deno
        if normalized.contains("deno") {
            return .deno
        }
        
        // Webpack
        if normalized.contains("webpack") {
            return .webpack
        }
        
        // Parcel
        if normalized.contains("parcel") {
            return .parcel
        }
        
        // Turbopack
        if normalized.contains("turbopack") {
            return .turbopack
        }
        
        // Storybook
        if normalized.contains("storybook") {
            return .storybook
        }
        
        // Docusaurus
        if normalized.contains("docusaurus") {
            return .docusaurus
        }
        
        // Jekyll
        if normalized.contains("jekyll") {
            return .jekyll
        }
        
        // Hugo
        if normalized.contains("hugo") {
            return .hugo
        }
        
        // PHP
        if normalized.contains("php") {
            return .php
        }
        
        // Gunicorn
        if normalized.contains("gunicorn") {
            return .gunicorn
        }
        
        // Python (general)
        if normalized.contains("python") {
            return .python
        }
        
        // Rust / Cargo
        if normalized.contains("rust") || normalized.contains("cargo") {
            return .rust
        }
        
        // Go
        if normalized.contains("go") || normalized.contains("air") {
            return .go
        }
        
        // Node.js (general)
        if normalized.contains("node") {
            return .node
        }
        
        // Databases
        if normalized.contains("postgres") {
            return .postgresql
        }
        if normalized.contains("mysql") {
            return .mysql
        }
        if normalized.contains("mongo") {
            return .mongodb
        }
        if normalized.contains("redis") {
            return .redis
        }
        if normalized.contains("memcached") {
            return .memcached
        }
        if normalized.contains("elasticsearch") {
            return .elasticsearch
        }
        
        return nil
    }
    
    /// Get icon info for a specific framework type
    /// Returns (assetName, isAsset, fallbackSFSymbol)
    private static func iconInfoForType(_ type: FrameworkType) -> (name: String, isAsset: Bool, fallbackSymbol: String) {
        switch type {
        case .nextjs:
            return ("nextjs-icon", true, "arrow.triangle.2.circlepath")
        case .vite:
            return ("vite-icon", true, "bolt.fill")
        case .react:
            return ("react-icon", true, "atom")
        case .vue:
            return ("vue-icon", true, "v.square.fill")
        case .angular:
            return ("angular-icon", true, "a.square.fill")
        case .svelte:
            return ("svelte-icon", true, "s.square.fill")
        case .nuxt:
            return ("nuxt-icon", true, "n.square.fill")
        case .remix:
            return ("remix-icon", true, "music.note")
        case .astro:
            return ("astro-icon", true, "sparkles")
        case .gatsby:
            return ("gatsby-icon", true, "g.square.fill")
        case .django:
            return ("django-icon", true, "d.square.fill")
        case .flask:
            return ("flask-icon", true, "flask.fill")
        case .fastapi:
            return ("fastapi-icon", true, "bolt.horizontal.fill")
        case .rails:
            return ("rails-icon", true, "r.square.fill")
        case .laravel:
            return ("laravel-icon", true, "l.square.fill")
        case .prisma:
            return ("prisma-icon", true, "cylinder.fill")
        case .docker:
            return ("docker-icon", true, "shippingbox.fill")
        case .node:
            return ("node-icon", true, "terminal.fill")
        case .python:
            return ("python-icon", true, "p.square.fill")
        case .rust:
            return ("rust-icon", true, "gearshape.fill")
        case .go:
            return ("go-icon", true, "g.circle.fill")
        case .bun:
            return ("bun-icon", true, "b.square.fill")
        case .deno:
            return ("deno-icon", true, "d.circle.fill")
        case .webpack:
            return ("webpack-icon", true, "cube.fill")
        case .parcel:
            return ("parcel-icon", true, "shippingbox")
        case .turbopack:
            return ("turbopack-icon", true, "bolt.square.fill")
        case .storybook:
            return ("storybook-icon", true, "book.fill")
        case .docusaurus:
            return ("docusaurus-icon", true, "doc.text.fill")
        case .jekyll:
            return ("jekyll-icon", true, "j.square.fill")
        case .hugo:
            return ("hugo-icon", true, "h.square.fill")
        case .php:
            return ("php-icon", true, "p.circle.fill")
        case .gunicorn:
            return ("gunicorn-icon", true, "g.square.fill")
        case .puma:
            return ("puma-icon", true, "pawprint.fill")
        case .uvicorn:
            return ("uvicorn-icon", true, "u.square.fill")
        // Databases
        case .postgresql:
            return ("postgresql-icon", true, "cylinder.split.1x2")
        case .mysql:
            return ("mysql-icon", true, "cylinder")
        case .mongodb:
            return ("mongodb-icon", true, "leaf.fill")
        case .redis:
            return ("redis-icon", true, "square.stack.3d.up.fill")
        case .memcached:
            return ("memcached-icon", true, "memorychip.fill")
        case .elasticsearch:
            return ("elasticsearch-icon", true, "magnifyingglass.circle.fill")
        }
    }
}
