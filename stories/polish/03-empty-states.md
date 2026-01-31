# Empty States

**Category:** Polish
**Priority:** P3 Low
**Effort:** S
**Status:** Not Started

## Summary

Design and implement helpful empty state messages for each section when there's no data to display. Empty states should explain what the section shows and guide users on how to populate it.

## Acceptance Criteria

- [ ] Empty state for "In the Harbor" (no ports detected)
- [ ] Empty state for "Out at Sea" (no websites configured)
- [ ] Empty state for "Container Ships" (Docker not running/no containers)
- [ ] Each empty state has helpful text and optional action button
- [ ] Empty states match the app's visual style
- [ ] Empty states don't look like errors

## Technical Notes

### Empty State Component

```swift
// Views/Components/EmptyStateView.swift
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(.secondary)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 200)
            
            if let actionTitle = actionTitle, let action = action {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
            }
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
    }
}
```

### Empty State Configurations

#### Local Ports ("In the Harbor")

```swift
EmptyStateView(
    icon: "antenna.radiowaves.left.and.right.slash",
    title: "No Services Detected",
    message: "Start a development server to see it here. Lighthouse monitors all TCP ports on your Mac."
)
```

**Alternative messages based on context:**
- Default: "No services detected on any ports"
- If system is busy: "Scanning for services..."
- If permission issue: "Unable to scan ports. Check System Preferences."

#### Websites ("Out at Sea")

```swift
EmptyStateView(
    icon: "globe.badge.chevron.backward",
    title: "No Websites Monitored",
    message: "Add a website to track its uptime and response time.",
    actionTitle: "Add Website",
    action: { showAddWebsiteSheet = true }
)
```

#### Docker Containers ("Container Ships")

**When Docker is not installed/running:**
```swift
EmptyStateView(
    icon: "shippingbox.slash",
    title: "Docker Not Available",
    message: "Install Docker Desktop or start the Docker daemon to manage containers here."
)
```

**When Docker is running but no containers:**
```swift
EmptyStateView(
    icon: "shippingbox",
    title: "No Containers",
    message: "No Docker containers found. Create a container to manage it here."
)
```

### Usage in MenuBarView

```swift
// In MenuBarView.swift
Section {
    if viewModel.ports.isEmpty {
        EmptyStateView(
            icon: "antenna.radiowaves.left.and.right.slash",
            title: "No Services Detected",
            message: "Start a development server to see it here."
        )
    } else {
        ForEach(viewModel.ports) { port in
            PortRowView(port: port)
        }
    }
} header: {
    Text("In the Harbor")
}
```

### Contextual Empty States

The empty state should change based on why it's empty:

```swift
enum EmptyStateReason {
    case noData
    case loading
    case error(String)
    case permissionDenied
    case serviceUnavailable
}

struct ContextualEmptyState: View {
    let section: AppSection
    let reason: EmptyStateReason
    
    var body: some View {
        switch reason {
        case .noData:
            defaultEmptyState
        case .loading:
            loadingState
        case .error(let message):
            errorState(message)
        case .permissionDenied:
            permissionState
        case .serviceUnavailable:
            unavailableState
        }
    }
}
```

### Loading States

While scanning/fetching:

```swift
struct LoadingStateView: View {
    let message: String
    
    var body: some View {
        HStack(spacing: 8) {
            ProgressView()
                .scaleEffect(0.7)
            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
    }
}

// Usage
if viewModel.isScanning {
    LoadingStateView(message: "Scanning ports...")
} else if viewModel.ports.isEmpty {
    EmptyStateView(...)
}
```

### Error States

When something goes wrong:

```swift
EmptyStateView(
    icon: "exclamationmark.triangle",
    title: "Unable to Scan",
    message: "Could not access port information. Try restarting Lighthouse.",
    actionTitle: "Retry",
    action: { viewModel.refresh() }
)
```

### Visual Design Guidelines

1. **Icon**: SF Symbol, 32pt, secondary color
2. **Title**: Headline weight, primary color
3. **Message**: Caption size, secondary color, centered
4. **Button**: Small bordered prominent style (optional)
5. **Spacing**: 12pt between elements, 20pt padding

### Animation

Add subtle fade-in for empty states:

```swift
EmptyStateView(...)
    .transition(.opacity)
    .animation(.easeInOut(duration: 0.2), value: viewModel.ports.isEmpty)
```

### Copy Guidelines

| Section | Tone | Example |
|---------|------|---------|
| No data | Helpful | "Start a server to see it here" |
| Loading | Informative | "Scanning ports..." |
| Error | Reassuring | "Something went wrong. Try again." |
| Unavailable | Explanatory | "Docker not installed" |

## Dependencies

None - can be implemented independently.

## Resources

- [Apple HIG - Empty States](https://developer.apple.com/design/human-interface-guidelines/patterns/empty-states)
- [SF Symbols](https://developer.apple.com/sf-symbols/)
