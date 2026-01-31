# Global Keyboard Shortcuts

**Category:** Feature
**Priority:** P2 Medium
**Effort:** S
**Status:** Not Started

## Summary

Add global keyboard shortcuts to quickly open the Lighthouse menu from anywhere in macOS. This improves power user workflow and makes the app more accessible without requiring mouse interaction.

## Acceptance Criteria

- [ ] Default shortcut (e.g., ⌃⌥L) opens the Lighthouse menu
- [ ] Shortcut works from any application
- [ ] Shortcut is customizable in preferences
- [ ] Shortcut persists across app restarts
- [ ] Conflict detection if shortcut is already in use
- [ ] Works when menu bar is hidden (auto-hide enabled)

## Technical Notes

### Implementation Approach

Use `MASShortcut` library or implement native `CGEvent` monitoring.

### Option 1: Native Implementation (No Dependencies)

```swift
import Carbon

class GlobalShortcutManager {
    private var hotKeyRef: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?
    
    func registerShortcut() {
        // Register for Control+Option+L
        var hotKeyID = EventHotKeyID()
        hotKeyID.signature = OSType("LHSE".fourCharCode)
        hotKeyID.id = 1
        
        var keyCode: UInt32 = 0x25 // L key
        var modifiers: UInt32 = controlKey | optionKey
        
        RegisterEventHotKey(keyCode, modifiers, hotKeyID, 
                           GetApplicationEventTarget(), 0, &hotKeyRef)
        
        // Install handler
        var eventSpec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard),
                                       eventKind: UInt32(kEventHotKeyPressed))
        InstallEventHandler(GetApplicationEventTarget(), 
                           hotKeyHandler, 1, &eventSpec, nil, &eventHandler)
    }
    
    func handleHotKey() {
        // Open the menu bar popover
        NotificationCenter.default.post(name: .openLighthouseMenu, object: nil)
    }
}
```

### Option 2: Using MASShortcut (Recommended)

Add dependency:
```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/shpakovski/MASShortcut.git", from: "2.4.0")
]
```

Usage:
```swift
import MASShortcut

class ShortcutManager {
    static let shared = ShortcutManager()
    
    func setup() {
        MASShortcutBinder.shared().bindShortcut(
            withDefaultsKey: "GlobalShortcut",
            toAction: {
                NotificationCenter.default.post(name: .openLighthouseMenu, object: nil)
            }
        )
    }
}
```

### Default Shortcut

Recommended default: **⌃⌥L** (Control + Option + L)

- **L** for Lighthouse
- ⌃⌥ prefix is rarely used by system or other apps
- Easy to remember and type

Alternative options:
- ⌃⌥⇧L (with Shift)
- ⌘⌥L (might conflict with other apps)
- F13-F19 (if available)

### Settings UI

Add shortcut recorder to preferences:

```swift
struct ShortcutSettingsView: View {
    @State private var shortcut: MASShortcut?
    
    var body: some View {
        HStack {
            Text("Open Lighthouse:")
            MASShortcutView(shortcutValue: $shortcut, 
                           shortcutValueChange: { newShortcut in
                // Save to UserDefaults
            })
        }
    }
}
```

### App Entry Point Changes

In `LighthouseApp.swift`:

```swift
@main
struct LighthouseApp: App {
    @StateObject private var shortcutManager = ShortcutManager()
    
    var body: some Scene {
        MenuBarExtra("Lighthouse", systemImage: "lighthouse.fill") {
            MenuBarView()
        }
        .menuBarExtraStyle(.window)
    }
    
    init() {
        ShortcutManager.shared.setup()
    }
}
```

### Handling the Shortcut

When shortcut is pressed:

```swift
extension Notification.Name {
    static let openLighthouseMenu = Notification.Name("openLighthouseMenu")
}

// In MenuBarView or App
.onReceive(NotificationCenter.default.publisher(for: .openLighthouseMenu)) { _ in
    // Programmatically open the menu bar popover
    NSApp.activate(ignoringOtherApps: true)
    // Trigger menu bar click
}
```

### Entitlements

No additional entitlements needed for global shortcuts in sandboxed apps, but test thoroughly.

### Accessibility Permissions

Global shortcuts may require Accessibility permissions on some macOS versions. Handle gracefully:

```swift
func checkAccessibilityPermissions() -> Bool {
    let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
    return AXIsProcessTrustedWithOptions(options as CFDictionary)
}
```

## Dependencies

None for native implementation. Optional: MASShortcut library.

## Resources

- [MASShortcut GitHub](https://github.com/shpakovski/MASShortcut)
- [Carbon Events Reference](https://developer.apple.com/documentation/carbon/carbon_events)
- [HotKey Swift Package](https://github.com/soffes/HotKey) (alternative)
