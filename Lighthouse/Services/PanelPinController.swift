import AppKit
import Combine

/// Keeps the MenuBarExtra panel open as a floating window while pinned.
final class PanelPinController: ObservableObject {
    static let shared = PanelPinController()

    private static let defaultsKey = "lighthouse.panelPinned"

    @Published var isPinned: Bool {
        didSet {
            guard oldValue != isPinned else { return }
            UserDefaults.standard.set(isPinned, forKey: Self.defaultsKey)
            applyPinState()
        }
    }

    private weak var panelWindow: NSWindow?
    private var closeObserver: NSObjectProtocol?

    private init() {
        isPinned = UserDefaults.standard.bool(forKey: Self.defaultsKey)
    }

    func toggle() {
        isPinned.toggle()
    }

    /// Bind to the live MenuBarExtra window whenever it appears.
    func attach(to window: NSWindow?) {
        guard let window else { return }

        if panelWindow !== window {
            detachCloseObserver()
            panelWindow = window
            observeClose(of: window)
        }

        applyPinState()
    }

    private func applyPinState() {
        guard let window = panelWindow else { return }

        if isPinned {
            promoteToFloatingPanel(window)
        } else {
            restoreMenuBarBehavior(window)
        }
    }

    private func promoteToFloatingPanel(_ window: NSWindow) {
        window.hidesOnDeactivate = false
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .moveToActiveSpace]
        window.isMovableByWindowBackground = true
        window.styleMask.insert([.titled, .closable, .fullSizeContentView])
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.title = "Lighthouse"

        if let panel = window as? NSPanel {
            panel.isFloatingPanel = true
            panel.becomesKeyOnlyIfNeeded = false
        }

        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func restoreMenuBarBehavior(_ window: NSWindow) {
        window.hidesOnDeactivate = true
        window.level = .statusBar
        window.collectionBehavior = [.transient, .ignoresCycle]
        window.isMovableByWindowBackground = false
        window.styleMask.remove([.titled, .closable])
        window.titleVisibility = .visible
        window.titlebarAppearsTransparent = false

        if let panel = window as? NSPanel {
            panel.isFloatingPanel = false
            panel.becomesKeyOnlyIfNeeded = true
        }
    }

    private func observeClose(of window: NSWindow) {
        closeObserver = NotificationCenter.default.addObserver(
            forName: NSWindow.willCloseNotification,
            object: window,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            // Closing a pinned panel should clear pin so the next open is a normal popover.
            if self.isPinned {
                self.isPinned = false
            }
            self.panelWindow = nil
            self.detachCloseObserver()
        }
    }

    private func detachCloseObserver() {
        if let closeObserver {
            NotificationCenter.default.removeObserver(closeObserver)
            self.closeObserver = nil
        }
    }
}
