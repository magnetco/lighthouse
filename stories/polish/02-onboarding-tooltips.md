# Onboarding Tooltips

**Category:** Polish
**Priority:** P3 Low
**Effort:** S
**Status:** Not Started

## Summary

Add contextual tooltips that appear on first use of specific features to help users understand functionality. Tooltips should be subtle, dismissible, and only appear once per feature.

## Acceptance Criteria

- [ ] Tooltips appear on first hover/interaction with key elements
- [ ] Each tooltip only appears once (tracked per feature)
- [ ] Tooltips are dismissible with click or Escape
- [ ] Tooltips have clear, concise text
- [ ] Option to reset tooltips in preferences
- [ ] Tooltips don't obstruct functionality

## Technical Notes

### Tooltip Tracking

```swift
// Utilities/TooltipManager.swift
class TooltipManager {
    static let shared = TooltipManager()
    
    private let shownTooltipsKey = "shownTooltips"
    
    private var shownTooltips: Set<String> {
        get {
            Set(UserDefaults.standard.stringArray(forKey: shownTooltipsKey) ?? [])
        }
        set {
            UserDefaults.standard.set(Array(newValue), forKey: shownTooltipsKey)
        }
    }
    
    func shouldShow(_ tooltipId: String) -> Bool {
        !shownTooltips.contains(tooltipId)
    }
    
    func markAsShown(_ tooltipId: String) {
        var tooltips = shownTooltips
        tooltips.insert(tooltipId)
        shownTooltips = tooltips
    }
    
    func resetAll() {
        shownTooltips = []
    }
}
```

### Tooltip IDs

```swift
enum TooltipID {
    static let portRowClick = "tooltip.portRow.click"
    static let portRowContextMenu = "tooltip.portRow.contextMenu"
    static let websiteAdd = "tooltip.website.add"
    static let dockerRestart = "tooltip.docker.restart"
    static let profileSwitch = "tooltip.profile.switch"
    static let statusIndicator = "tooltip.status.indicator"
    static let starFavorite = "tooltip.star.favorite"
}
```

### Tooltip View Component

```swift
// Views/Components/OnboardingTooltip.swift
struct OnboardingTooltip: View {
    let id: String
    let text: String
    let arrowEdge: Edge
    
    @State private var isVisible: Bool
    
    init(id: String, text: String, arrowEdge: Edge = .top) {
        self.id = id
        self.text = text
        self.arrowEdge = arrowEdge
        self._isVisible = State(initialValue: TooltipManager.shared.shouldShow(id))
    }
    
    var body: some View {
        if isVisible {
            VStack(spacing: 4) {
                if arrowEdge == .bottom {
                    arrow
                }
                
                HStack {
                    Text(text)
                        .font(.callout)
                        .foregroundColor(.white)
                    
                    Button(action: dismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .buttonStyle(.plain)
                }
                .padding(12)
                .background(Color.blue)
                .cornerRadius(8)
                
                if arrowEdge == .top {
                    arrow
                }
            }
            .transition(.opacity.combined(with: .scale))
        }
    }
    
    private var arrow: some View {
        Image(systemName: arrowEdge == .top ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill")
            .foregroundColor(.blue)
            .font(.caption)
    }
    
    private func dismiss() {
        withAnimation {
            isVisible = false
            TooltipManager.shared.markAsShown(id)
        }
    }
}
```

### Tooltip Content

| Location | ID | Text |
|----------|-----|------|
| Port row | portRowClick | "Click to open in browser, or right-click for more options" |
| Website section | websiteAdd | "Add a website to monitor its uptime and response time" |
| Docker container | dockerRestart | "Click the buttons to start, stop, or restart containers" |
| Profile selector | profileSwitch | "Switch profiles to monitor different environments" |
| Menu bar icon | statusIndicator | "Icon color shows overall health: green = all good" |
| Star button | starFavorite | "Star your frequently used services to pin them to the top" |

### Usage in Views

```swift
// In PortRowView.swift
struct PortRowView: View {
    @State private var showTooltip = false
    
    var body: some View {
        HStack {
            // ... row content
        }
        .overlay(alignment: .top) {
            if showTooltip {
                OnboardingTooltip(
                    id: TooltipID.portRowClick,
                    text: "Click to open in browser, right-click for more options",
                    arrowEdge: .bottom
                )
                .offset(y: -50)
            }
        }
        .onAppear {
            // Show tooltip on first appearance
            if TooltipManager.shared.shouldShow(TooltipID.portRowClick) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation { showTooltip = true }
                }
            }
        }
    }
}
```

### Alternative: View Modifier

```swift
extension View {
    func onboardingTooltip(
        id: String,
        text: String,
        edge: Edge = .top
    ) -> some View {
        self.overlay(alignment: edge == .top ? .top : .bottom) {
            OnboardingTooltip(id: id, text: text, arrowEdge: edge)
                .offset(y: edge == .top ? -40 : 40)
        }
    }
}

// Usage
PortRowView()
    .onboardingTooltip(
        id: TooltipID.portRowClick,
        text: "Click to open in browser"
    )
```

### Settings Integration

Add to settings/preferences:

```swift
Button("Reset All Tips") {
    TooltipManager.shared.resetAll()
}
.help("Show onboarding tooltips again")
```

### Timing Considerations

- Don't show all tooltips at once
- Add slight delay (0.3-0.5s) before showing
- Allow dismissal via click anywhere or Escape key
- Consider showing only when app is foregrounded

## Dependencies

None - can be implemented independently.

## Resources

- [Apple HIG - Help](https://developer.apple.com/design/human-interface-guidelines/help)
- [SwiftUI Overlay](https://developer.apple.com/documentation/swiftui/view/overlay(alignment:content:))
