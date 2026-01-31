# Favorites and Starring

**Category:** Feature
**Priority:** P2 Medium
**Effort:** M
**Status:** Not Started

## Summary

Add the ability to "star" or "favorite" frequently used ports and websites. Starred items appear at the top of their respective sections, making it faster to access the services you use most often.

## Acceptance Criteria

- [ ] Star button/toggle on each port and website row
- [ ] Starred items sorted to top of their section
- [ ] Visual indicator (star icon) for starred items
- [ ] Favorites persist across app restarts
- [ ] Option to hide non-starred items (focus mode)
- [ ] Quick-filter to show only favorites

## Technical Notes

### Data Model Updates

#### PortInfo.swift

```swift
struct PortInfo: Identifiable, Codable {
    // ... existing properties
    var isStarred: Bool = false
}
```

#### WebsiteInfo.swift

```swift
struct WebsiteInfo: Identifiable, Codable {
    // ... existing properties
    var isStarred: Bool = false
}
```

### Storage

Starred ports need persistent storage (ports are ephemeral):

```swift
// Services/FavoritesStorage.swift
class FavoritesStorage {
    private let portsKey = "starredPorts"
    private let userDefaults = UserDefaults.standard
    
    // Store by unique identifier (port + process name combo)
    var starredPortIdentifiers: Set<String> {
        get {
            Set(userDefaults.stringArray(forKey: portsKey) ?? [])
        }
        set {
            userDefaults.set(Array(newValue), forKey: portsKey)
        }
    }
    
    func isPortStarred(_ port: PortInfo) -> Bool {
        starredPortIdentifiers.contains(port.uniqueIdentifier)
    }
    
    func togglePortStar(_ port: PortInfo) {
        var identifiers = starredPortIdentifiers
        if identifiers.contains(port.uniqueIdentifier) {
            identifiers.remove(port.uniqueIdentifier)
        } else {
            identifiers.insert(port.uniqueIdentifier)
        }
        starredPortIdentifiers = identifiers
    }
}

extension PortInfo {
    var uniqueIdentifier: String {
        // Use port + project path or port + process name
        "\(port)-\(workingDirectory ?? processName)"
    }
}
```

Websites already have persistent storage, just add `isStarred` to `WebsiteInfo`.

### Sorting Logic

In `PortViewModel.swift`:

```swift
var sortedPorts: [PortInfo] {
    ports.sorted { lhs, rhs in
        // Starred items first
        if lhs.isStarred != rhs.isStarred {
            return lhs.isStarred
        }
        // Then by port number
        return lhs.port < rhs.port
    }
}

var sortedWebsites: [WebsiteInfo] {
    websites.sorted { lhs, rhs in
        if lhs.isStarred != rhs.isStarred {
            return lhs.isStarred
        }
        return lhs.name < rhs.name
    }
}
```

### UI Changes

#### Star Button in PortRowView

```swift
struct PortRowView: View {
    @EnvironmentObject var viewModel: PortViewModel
    let port: PortInfo
    
    var body: some View {
        HStack {
            // Star button
            Button(action: { viewModel.toggleStar(for: port) }) {
                Image(systemName: port.isStarred ? "star.fill" : "star")
                    .foregroundColor(port.isStarred ? .yellow : .secondary)
            }
            .buttonStyle(.plain)
            
            // ... rest of row
        }
    }
}
```

#### Star Button in WebsiteRowView

```swift
struct WebsiteRowView: View {
    @EnvironmentObject var viewModel: PortViewModel
    let website: WebsiteInfo
    
    var body: some View {
        HStack {
            Button(action: { viewModel.toggleStar(for: website) }) {
                Image(systemName: website.isStarred ? "star.fill" : "star")
                    .foregroundColor(website.isStarred ? .yellow : .secondary)
            }
            .buttonStyle(.plain)
            
            // ... rest of row
        }
    }
}
```

### Filter Toggle

Add filter option in section header:

```swift
Section {
    // ... port rows
} header: {
    HStack {
        Text("In the Harbor")
        Spacer()
        Toggle("", isOn: $viewModel.showOnlyStarredPorts)
            .toggleStyle(.checkbox)
            .labelsHidden()
        Image(systemName: "star.fill")
            .foregroundColor(.yellow)
            .font(.caption)
    }
}
```

### Context Menu Integration

Add to existing context menus:

```swift
.contextMenu {
    Button(action: { viewModel.toggleStar(for: port) }) {
        Label(
            port.isStarred ? "Remove from Favorites" : "Add to Favorites",
            systemImage: port.isStarred ? "star.slash" : "star"
        )
    }
    // ... other menu items
}
```

### Keyboard Shortcut

Add ⌘S to toggle star on focused item (if keyboard navigation is implemented).

### Visual Hierarchy

Starred items could have subtle visual distinction:
- Yellow star icon
- Slightly bolder text
- Optional: light yellow background tint

## Dependencies

None - can be implemented independently.

## Resources

- [SF Symbols - star variations](https://developer.apple.com/sf-symbols/)
- [UserDefaults for Sets](https://developer.apple.com/documentation/foundation/userdefaults)
