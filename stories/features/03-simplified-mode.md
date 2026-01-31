# Simplified Mode

**Category:** Feature
**Priority:** P2 Medium
**Effort:** M
**Status:** Not Started

## Summary

Add a "Simplified Mode" preference that hides technical details (PIDs, process names, working directories) for users who just want to see "what's running" without developer-focused information. This broadens appeal to non-developers and business users.

## Acceptance Criteria

- [ ] Toggle in preferences to enable/disable Simplified Mode
- [ ] In Simplified Mode, ports show only: name/description, port number, status
- [ ] In Simplified Mode, websites show only: name, status, response time
- [ ] Technical details hidden: PID, process name, working directory, command line
- [ ] "Kill process" renamed to "Stop" in Simplified Mode
- [ ] First-run option to choose mode
- [ ] Mode persists across app restarts

## Technical Notes

### User Preference Storage

Add to UserDefaults:

```swift
enum UserPreference {
    static let simplifiedModeKey = "simplifiedMode"
    
    static var isSimplifiedMode: Bool {
        get { UserDefaults.standard.bool(forKey: simplifiedModeKey) }
        set { UserDefaults.standard.set(newValue, forKey: simplifiedModeKey) }
    }
}
```

### ViewModel Changes

Add to `PortViewModel.swift`:

```swift
@Published var isSimplifiedMode: Bool = UserPreference.isSimplifiedMode {
    didSet {
        UserPreference.isSimplifiedMode = isSimplifiedMode
    }
}
```

### UI Changes - PortRowView

```swift
struct PortRowView: View {
    @EnvironmentObject var viewModel: PortViewModel
    
    var body: some View {
        HStack {
            // Always show
            frameworkIcon
            Text(displayName)
            Spacer()
            Text(":\(port.port)")
            
            // Only in detailed mode
            if !viewModel.isSimplifiedMode {
                Text("PID: \(port.pid)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    var displayName: String {
        if viewModel.isSimplifiedMode {
            // User-friendly name
            return port.projectName ?? port.frameworkName ?? "Service"
        } else {
            // Technical name
            return port.processName
        }
    }
}
```

### Simplified vs Detailed Comparison

| Element | Detailed Mode | Simplified Mode |
|---------|---------------|-----------------|
| Port entry | `node (PID: 12345) - Next.js` | `My Project - Next.js` |
| Working dir | `/Users/dev/projects/app` | Hidden |
| Kill button | "Kill Process" | "Stop" |
| Website entry | `example.com - 200 OK (52ms)` | `example.com - Online` |
| Docker | `container_abc123 - nginx:latest` | `Web Server - Running` |

### Settings UI

Add to menu or preferences:

```swift
Menu("Settings") {
    Toggle("Simplified Mode", isOn: $viewModel.isSimplifiedMode)
        .help("Hide technical details for a cleaner view")
    
    Divider()
    
    // Other settings...
}
```

### First-Run Experience

On first launch, show a choice:

```swift
struct WelcomeView: View {
    var body: some View {
        VStack {
            Text("Welcome to Lighthouse")
                .font(.title)
            
            Text("How would you like to use Lighthouse?")
            
            Button("Simple View") {
                UserPreference.isSimplifiedMode = true
                dismiss()
            }
            .help("Best for monitoring websites and seeing what's running")
            
            Button("Developer View") {
                UserPreference.isSimplifiedMode = false
                dismiss()
            }
            .help("Full details including PIDs, paths, and process info")
        }
    }
}
```

### Language Adjustments

| Technical Term | Simplified Term |
|----------------|-----------------|
| Kill Process | Stop |
| PID | (hidden) |
| Working Directory | (hidden) |
| HEAD Request | Health Check |
| TCP Port | Service |
| Container | App |

### Context Menu Adjustments

In Simplified Mode, reduce context menu options:
- Keep: Open in Browser, Copy URL
- Rename: Kill Process → Stop Service
- Hide: Reveal in Finder, Open in Editor, Copy PID

## Dependencies

None - can be implemented independently.

## Resources

- [UserDefaults](https://developer.apple.com/documentation/foundation/userdefaults)
- [Apple HIG - Terminology](https://developer.apple.com/design/human-interface-guidelines/accessibility#Text-display)
