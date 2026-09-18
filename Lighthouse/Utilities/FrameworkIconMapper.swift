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
        // isAsset is false until PNG files are added to the matching imageset
        // (see Assets.xcassets/README-ICONS.md). UI falls back to SF Symbols.
        case .nextjs:
            return ("nextjs-icon", false, "arrow.triangle.2.circlepath")
        case .vite:
            return ("vite-icon", false, "bolt.fill")
        case .react:
            return ("react-icon", false, "atom")
        case .vue:
            return ("vue-icon", false, "v.square.fill")
        case .angular:
            return ("angular-icon", false, "a.square.fill")
        case .svelte:
            return ("svelte-icon", false, "s.square.fill")
        case .nuxt:
            return ("nuxt-icon", false, "n.square.fill")
        case .remix:
            return ("remix-icon", false, "music.note")
        case .astro:
            return ("astro-icon", false, "sparkles")
        case .gatsby:
            return ("gatsby-icon", false, "g.square.fill")
        case .django:
            return ("django-icon", false, "d.square.fill")
        case .flask:
            return ("flask-icon", false, "flask.fill")
        case .fastapi:
            return ("fastapi-icon", false, "bolt.horizontal.fill")
        case .rails:
            return ("rails-icon", false, "r.square.fill")
        case .laravel:
            return ("laravel-icon", false, "l.square.fill")
        case .prisma:
            return ("prisma-icon", false, "cylinder.fill")
        case .docker:
            return ("docker-icon", false, "shippingbox.fill")
        case .node:
            return ("node-icon", false, "terminal.fill")
        case .python:
            return ("python-icon", false, "p.square.fill")
        case .rust:
            return ("rust-icon", false, "gearshape.fill")
        case .go:
            return ("go-icon", false, "g.circle.fill")
        case .bun:
            return ("bun-icon", false, "b.square.fill")
        case .deno:
            return ("deno-icon", false, "d.circle.fill")
        case .webpack:
            return ("webpack-icon", false, "cube.fill")
        case .parcel:
            return ("parcel-icon", false, "shippingbox")
        case .turbopack:
            return ("turbopack-icon", false, "bolt.square.fill")
        case .storybook:
            return ("storybook-icon", false, "book.fill")
        case .docusaurus:
            return ("docusaurus-icon", false, "doc.text.fill")
        case .jekyll:
            return ("jekyll-icon", false, "j.square.fill")
        case .hugo:
            return ("hugo-icon", false, "h.square.fill")
        case .php:
            return ("php-icon", false, "p.circle.fill")
        case .gunicorn:
            return ("gunicorn-icon", false, "g.square.fill")
        case .puma:
            return ("puma-icon", false, "pawprint.fill")
        case .uvicorn:
            return ("uvicorn-icon", false, "u.square.fill")
        // Databases
        case .postgresql:
            return ("postgresql-icon", false, "cylinder.split.1x2")
        case .mysql:
            return ("mysql-icon", false, "cylinder")
        case .mongodb:
            return ("mongodb-icon", false, "leaf.fill")
        case .redis:
            return ("redis-icon", false, "square.stack.3d.up.fill")
        case .memcached:
            return ("memcached-icon", false, "memorychip.fill")
        case .elasticsearch:
            return ("elasticsearch-icon", false, "magnifyingglass.circle.fill")
        }
    }
}
