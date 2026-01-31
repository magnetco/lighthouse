# Database Detection

**Category:** Feature
**Priority:** P2 Medium
**Effort:** S
**Status:** Not Started

## Summary

Enhance port detection to recognize common database servers (PostgreSQL, MySQL, MongoDB, Redis) and display them with appropriate icons and connection information. This broadens appeal to backend developers and DevOps engineers.

## Acceptance Criteria

- [ ] PostgreSQL servers detected and labeled (port 5432)
- [ ] MySQL servers detected and labeled (port 3306)
- [ ] MongoDB servers detected and labeled (port 27017)
- [ ] Redis servers detected and labeled (port 6379)
- [ ] Database-specific icons displayed
- [ ] Quick-copy connection string button
- [ ] Works alongside existing framework detection

## Technical Notes

### Default Database Ports

| Database | Default Port | Process Names |
|----------|--------------|---------------|
| PostgreSQL | 5432 | postgres, postmaster |
| MySQL | 3306 | mysqld, mariadbd |
| MongoDB | 27017 | mongod |
| Redis | 6379 | redis-server |
| Memcached | 11211 | memcached |
| Elasticsearch | 9200, 9300 | java (elasticsearch) |

### Code Modifications

#### 1. Update FrameworkIconMapper.swift

```swift
// Add database cases
enum ServiceType {
    // ... existing cases
    case postgresql
    case mysql
    case mongodb
    case redis
    case memcached
    case elasticsearch
}

static func detectDatabase(processName: String, port: Int) -> ServiceType? {
    switch processName.lowercased() {
    case "postgres", "postmaster":
        return .postgresql
    case "mysqld", "mariadbd":
        return .mysql
    case "mongod":
        return .mongodb
    case "redis-server":
        return .redis
    case "memcached":
        return .memcached
    default:
        // Check by port as fallback
        switch port {
        case 5432: return .postgresql
        case 3306: return .mysql
        case 27017: return .mongodb
        case 6379: return .redis
        default: return nil
        }
    }
}
```

#### 2. Add Database Icons

Use SF Symbols for databases:
- PostgreSQL: `cylinder.split.1x2` (or custom icon)
- MySQL: `cylinder` (or custom icon)
- MongoDB: `leaf` (MongoDB's logo is a leaf)
- Redis: `square.stack.3d.up` (key-value store metaphor)

Or add custom icons to Assets.xcassets:
```
Assets.xcassets/
├── postgresql-icon.imageset/
├── mysql-icon.imageset/
├── mongodb-icon.imageset/
└── redis-icon.imageset/
```

#### 3. Connection String Generation

Add to PortInfo or create DatabaseInfo helper:

```swift
func connectionString(for database: ServiceType, port: Int, host: String = "localhost") -> String {
    switch database {
    case .postgresql:
        return "postgresql://localhost:\(port)/database"
    case .mysql:
        return "mysql://localhost:\(port)/database"
    case .mongodb:
        return "mongodb://localhost:\(port)"
    case .redis:
        return "redis://localhost:\(port)"
    default:
        return ""
    }
}
```

#### 4. UI Enhancement

In `PortRowView.swift`:

```swift
// Add copy connection string button for databases
if let dbType = FrameworkIconMapper.detectDatabase(processName: port.processName, port: port.port) {
    Button(action: {
        let connString = connectionString(for: dbType, port: port.port)
        NSPasteboard.general.setString(connString, forType: .string)
    }) {
        Image(systemName: "doc.on.clipboard")
    }
    .help("Copy connection string")
}
```

### Display in "In the Harbor"

```
🐘 PostgreSQL          5432    postgres
   postgresql://localhost:5432
   
🍃 MongoDB             27017   mongod  
   mongodb://localhost:27017
```

### Integration with Docker

Database containers should also be detected. Check container names/images for:
- `postgres`, `postgresql`
- `mysql`, `mariadb`
- `mongo`, `mongodb`
- `redis`

## Dependencies

None - extends existing port detection.

## Resources

- [PostgreSQL Connection Strings](https://www.postgresql.org/docs/current/libpq-connect.html)
- [MySQL Connection URLs](https://dev.mysql.com/doc/connector-j/8.0/en/connector-j-reference-jdbc-url-format.html)
- [MongoDB Connection String](https://www.mongodb.com/docs/manual/reference/connection-string/)
