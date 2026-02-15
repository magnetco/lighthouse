import SwiftUI

@main
struct LighthouseApp: App {
    @StateObject private var viewModel = PortViewModel()
    @StateObject private var shortcutManager = ShortcutManager.shared

    init() {
        // Register default global shortcut (Control + Option + L)
        ShortcutManager.shared.registerDefaultShortcut()
        
        // Set up shortcut callback
        ShortcutManager.shared.onShortcutPressed = {
            // Activate the app and show menu bar
            NSApp.activate(ignoringOtherApps: true)
            // Post notification to open menu
            NotificationCenter.default.post(name: .openLighthouseMenu, object: nil)
        }
    }

    var body: some Scene {
        MenuBarExtra {
            MenuBarView(viewModel: viewModel)
                .background(WindowAccessor { window in
                    // Configure solid background when window becomes available
                    window?.isOpaque = true
                    window?.backgroundColor = NSColor(red: 0.13, green: 0.14, blue: 0.15, alpha: 1.0)
                    
                    // Remove vibrancy from content view
                    if let contentView = window?.contentView {
                        contentView.wantsLayer = true
                        contentView.layer?.backgroundColor = NSColor(red: 0.13, green: 0.14, blue: 0.15, alpha: 1.0).cgColor
                        
                        // Disable any visual effect views
                        disableVisualEffects(in: contentView)
                    }
                })
        } label: {
            Image(systemName: "light.beacon.max.fill")
                .foregroundColor(viewModel.systemHealth.iconColor)
        }
        .menuBarExtraStyle(.window)
    }
    
    private func disableVisualEffects(in view: NSView) {
        if let effectView = view as? NSVisualEffectView {
            effectView.state = .inactive
            effectView.material = .windowBackground
            effectView.isEmphasized = false
        }
        for subview in view.subviews {
            disableVisualEffects(in: subview)
        }
    }
}

// MARK: - Window Accessor for configuring NSWindow from SwiftUI

struct WindowAccessor: NSViewRepresentable {
    let callback: (NSWindow?) -> Void
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            self.callback(view.window)
        }
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            self.callback(nsView.window)
        }
    }
}
