# First Run Experience

**Category:** Polish
**Priority:** P3 Low
**Effort:** M
**Status:** Not Started

## Summary

Create a welcoming first-run experience for new users that introduces Lighthouse's features, helps them configure initial settings, and optionally guides them through adding their first monitored website.

## Acceptance Criteria

- [ ] Welcome screen appears on first launch
- [ ] Brief feature overview (3-4 screens max)
- [ ] Option to choose Simplified vs Developer mode
- [ ] Option to add first monitored website
- [ ] "Don't show again" option
- [ ] First-run state tracked (only shows once)

## Technical Notes

### Detection of First Run

```swift
// Utilities/FirstRunManager.swift
class FirstRunManager {
    private static let hasLaunchedKey = "hasLaunchedBefore"
    
    static var isFirstRun: Bool {
        !UserDefaults.standard.bool(forKey: hasLaunchedKey)
    }
    
    static func markAsLaunched() {
        UserDefaults.standard.set(true, forKey: hasLaunchedKey)
    }
}
```

### Welcome Flow Structure

```
1. Welcome Screen
   ↓
2. Feature Overview (optional carousel)
   ↓
3. Choose Mode (Simplified/Developer)
   ↓
4. Add First Website (optional)
   ↓
5. Done! → Normal app view
```

### View Implementation

```swift
// Views/Onboarding/OnboardingView.swift
struct OnboardingView: View {
    @State private var currentPage = 0
    @Binding var isPresented: Bool
    
    var body: some View {
        TabView(selection: $currentPage) {
            WelcomePageView(onNext: { currentPage = 1 })
                .tag(0)
            
            FeaturesPageView(onNext: { currentPage = 2 })
                .tag(1)
            
            ModeSelectionPageView(onNext: { currentPage = 3 })
                .tag(2)
            
            AddWebsitePageView(onComplete: { 
                FirstRunManager.markAsLaunched()
                isPresented = false 
            })
                .tag(3)
        }
        .tabViewStyle(.page)
        .frame(width: 400, height: 500)
    }
}
```

### Welcome Page

```swift
struct WelcomePageView: View {
    var onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lighthouse.fill")
                .font(.system(size: 64))
                .foregroundColor(.blue)
            
            Text("Welcome to Lighthouse")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Your Mac's service control center")
                .font(.title3)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button("Get Started") {
                onNext()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            
            Button("Skip Introduction") {
                FirstRunManager.markAsLaunched()
                // Close onboarding
            }
            .buttonStyle(.plain)
            .foregroundColor(.secondary)
        }
        .padding(40)
    }
}
```

### Features Overview Page

```swift
struct FeaturesPageView: View {
    var onNext: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("What Lighthouse Does")
                .font(.title)
                .fontWeight(.bold)
            
            FeatureRow(
                icon: "antenna.radiowaves.left.and.right",
                title: "Local Services",
                description: "See every TCP port in use and which app owns it"
            )
            
            FeatureRow(
                icon: "shippingbox",
                title: "Docker Containers",
                description: "Start, stop, and restart containers with one click"
            )
            
            FeatureRow(
                icon: "globe",
                title: "Website Monitoring",
                description: "Track uptime and get notified when sites go down"
            )
            
            Spacer()
            
            Button("Continue") { onNext() }
                .buttonStyle(.borderedProminent)
        }
        .padding(40)
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(.blue)
                .frame(width: 40)
            
            VStack(alignment: .leading) {
                Text(title)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}
```

### Mode Selection Page

```swift
struct ModeSelectionPageView: View {
    @State private var selectedMode: ViewMode = .developer
    var onNext: () -> Void
    
    enum ViewMode {
        case simplified, developer
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Choose Your View")
                .font(.title)
                .fontWeight(.bold)
            
            Text("You can change this anytime in settings")
                .foregroundColor(.secondary)
            
            VStack(spacing: 12) {
                ModeButton(
                    title: "Simple View",
                    description: "Clean interface showing just the essentials",
                    icon: "square.grid.2x2",
                    isSelected: selectedMode == .simplified
                ) {
                    selectedMode = .simplified
                }
                
                ModeButton(
                    title: "Developer View",
                    description: "Full details including PIDs, paths, and commands",
                    icon: "terminal",
                    isSelected: selectedMode == .developer
                ) {
                    selectedMode = .developer
                }
            }
            
            Spacer()
            
            Button("Continue") {
                UserPreference.isSimplifiedMode = (selectedMode == .simplified)
                onNext()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(40)
    }
}
```

### Integration Point

In `LighthouseApp.swift`:

```swift
@main
struct LighthouseApp: App {
    @State private var showOnboarding = FirstRunManager.isFirstRun
    
    var body: some Scene {
        MenuBarExtra("Lighthouse", systemImage: "lighthouse.fill") {
            MenuBarView()
        }
        .menuBarExtraStyle(.window)
        
        // Show onboarding window on first run
        Window("Welcome", id: "onboarding") {
            OnboardingView(isPresented: $showOnboarding)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 400, height: 500)
    }
}
```

### Skip Functionality

Always provide a way to skip:
- "Skip" button on each page
- "Don't show this again" checkbox
- Command+W closes the window

## Dependencies

- [03-simplified-mode](../features/03-simplified-mode.md) - If mode selection is included

## Resources

- [Apple HIG - Onboarding](https://developer.apple.com/design/human-interface-guidelines/onboarding)
- [SwiftUI TabView](https://developer.apple.com/documentation/swiftui/tabview)
