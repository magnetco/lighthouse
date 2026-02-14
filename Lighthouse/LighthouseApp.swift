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
        } label: {
            Image(systemName: "light.beacon.max.fill")
                .foregroundColor(viewModel.systemHealth.iconColor)
        }
        .menuBarExtraStyle(.window)
    }
}
