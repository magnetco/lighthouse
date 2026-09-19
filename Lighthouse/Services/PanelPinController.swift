import AppKit
import Combine

/// Keeps the MenuBarExtra panel open as a floating window while pinned.
///
/// Critical: do **not** rewrite MenuBarExtra window chrome while unpinned.
/// `WindowAccessor.updateNSView` fires on every SwiftUI refresh; mutating
/// styleMask/level/hidesOnDeactivate in that path fights `.window` presentation
/// and causes an open → dismiss flash loop.
final class PanelPinController: ObservableObject {
    static let shared = PanelPinController()

    private static let defaultsKey = "lighthouse.panelPinned"

    @Published var isPinned: Bool {
        didSet {
            guard oldValue != isPinned else { return }
            UserDefaults.standard.set(isPinned, forKey: Self.defaultsKey)
            applyPinTransition(from: oldValue, to: isPinned)
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
    /// Safe to call on every `updateNSView` — only acts on window identity change.
    func attach(to window: NSWindow?) {
        guard let window else { return }

        // Same window: ignore spam from SwiftUI refreshes. Pin transitions
        // are handled exclusively via `isPinned` didSet.
        if panelWindow === window {
            return
        }

        detachCloseObserver()
        panelWindow = window
        observeClose(of: window)

        // Re-open while already pinned: promote after presentation settles.
        // Unpinned: leave MenuBarExtra behavior completely untouched.
        if isPinned {
            DispatchQueue.main.async { [weak self] in
                guard let self, self.panelWindow === window, self.isPinned else { return }
                self.promoteToFloatingPanel(window)
            }
        }
    }

    /// Apply window mutations only on explicit pin/unpin transitions.
    private func applyPinTransition(from oldValue: Bool, to newValue: Bool) {
        guard let window = panelWindow else { return }

        if newValue && !oldValue {
            promoteToFloatingPanel(window)
        } else if !newValue && oldValue {
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
            // Drop the window ref first so clearing pin does not rewrite a closing window.
            self.panelWindow = nil
            self.detachCloseObserver()
            if self.isPinned {
                self.isPinned = false
            }
        }
    }

    private func detachCloseObserver() {
        if let closeObserver {
            NotificationCenter.default.removeObserver(closeObserver)
            self.closeObserver = nil
        }
    }
}
