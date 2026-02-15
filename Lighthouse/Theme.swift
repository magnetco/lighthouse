import SwiftUI
import AppKit

// MARK: - GitHub Desktop-inspired solid theme
// Strong, opaque colors with clear visual hierarchy

enum Theme {
    // MARK: - Background Colors (Solid, no transparency)
    
    /// Main window background - dark charcoal
    static let windowBackground = Color(nsColor: NSColor(red: 0.13, green: 0.14, blue: 0.15, alpha: 1.0))
    
    /// Slightly lighter background for sections
    static let sectionBackground = Color(nsColor: NSColor(red: 0.15, green: 0.16, blue: 0.17, alpha: 1.0))
    
    /// Header/footer background - slightly darker
    static let headerBackground = Color(nsColor: NSColor(red: 0.11, green: 0.12, blue: 0.13, alpha: 1.0))
    
    /// Hover state background
    static let hoverBackground = Color(nsColor: NSColor(red: 0.18, green: 0.19, blue: 0.21, alpha: 1.0))
    
    /// Selected/active state background
    static let selectedBackground = Color(nsColor: NSColor(red: 0.20, green: 0.22, blue: 0.25, alpha: 1.0))
    
    /// Input field background
    static let inputBackground = Color(nsColor: NSColor(red: 0.10, green: 0.11, blue: 0.12, alpha: 1.0))
    
    // MARK: - Text Colors
    
    /// Primary text - bright white
    static let textPrimary = Color(nsColor: NSColor(red: 0.93, green: 0.94, blue: 0.95, alpha: 1.0))
    
    /// Secondary text - muted gray
    static let textSecondary = Color(nsColor: NSColor(red: 0.60, green: 0.62, blue: 0.65, alpha: 1.0))
    
    /// Tertiary/hint text - dimmer gray
    static let textTertiary = Color(nsColor: NSColor(red: 0.45, green: 0.47, blue: 0.50, alpha: 1.0))
    
    /// Muted text for less important info
    static let textMuted = Color(nsColor: NSColor(red: 0.35, green: 0.37, blue: 0.40, alpha: 1.0))
    
    // MARK: - Border Colors
    
    /// Standard border
    static let border = Color(nsColor: NSColor(red: 0.22, green: 0.24, blue: 0.26, alpha: 1.0))
    
    /// Subtle border for dividers
    static let borderSubtle = Color(nsColor: NSColor(red: 0.18, green: 0.20, blue: 0.22, alpha: 1.0))
    
    // MARK: - Accent Colors
    
    /// GitHub-style blue accent
    static let accent = Color(nsColor: NSColor(red: 0.34, green: 0.61, blue: 0.98, alpha: 1.0))
    
    /// Success green
    static let success = Color(nsColor: NSColor(red: 0.24, green: 0.75, blue: 0.42, alpha: 1.0))
    
    /// Warning orange
    static let warning = Color(nsColor: NSColor(red: 0.90, green: 0.62, blue: 0.22, alpha: 1.0))
    
    /// Error red
    static let error = Color(nsColor: NSColor(red: 0.94, green: 0.34, blue: 0.36, alpha: 1.0))
    
    /// Star yellow
    static let star = Color(nsColor: NSColor(red: 0.95, green: 0.78, blue: 0.25, alpha: 1.0))
    
    // MARK: - Icon Colors
    
    /// Default icon color
    static let iconDefault = Color(nsColor: NSColor(red: 0.55, green: 0.57, blue: 0.60, alpha: 1.0))
    
    /// Icon color on hover
    static let iconHover = Color(nsColor: NSColor(red: 0.80, green: 0.82, blue: 0.85, alpha: 1.0))
    
    // MARK: - Gradients (GitHub Desktop style header gradients)
    
    static let headerGradient = LinearGradient(
        colors: [
            Color(nsColor: NSColor(red: 0.14, green: 0.15, blue: 0.16, alpha: 1.0)),
            Color(nsColor: NSColor(red: 0.12, green: 0.13, blue: 0.14, alpha: 1.0))
        ],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let sectionHeaderGradient = LinearGradient(
        colors: [
            Color(nsColor: NSColor(red: 0.16, green: 0.17, blue: 0.18, alpha: 1.0)),
            Color(nsColor: NSColor(red: 0.14, green: 0.15, blue: 0.16, alpha: 1.0))
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - Window Configuration Helper

class WindowConfigurator {
    static func configureSolidBackground(for window: NSWindow?) {
        guard let window = window else { return }
        
        // Make window opaque
        window.isOpaque = true
        window.backgroundColor = NSColor(red: 0.13, green: 0.14, blue: 0.15, alpha: 1.0)
        
        // Remove vibrancy/blur effect
        if let contentView = window.contentView {
            // Remove any visual effect views
            for subview in contentView.subviews {
                if let effectView = subview as? NSVisualEffectView {
                    effectView.state = .inactive
                    effectView.material = .windowBackground
                }
            }
        }
    }
    
    /// Find and configure the MenuBarExtra window
    static func configureMenuBarWindow() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            for window in NSApp.windows {
                // MenuBarExtra windows have specific characteristics
                if window.level == .popUpMenu || window.className.contains("MenuBarExtra") {
                    configureSolidBackground(for: window)
                }
            }
        }
    }
}

// MARK: - View Extensions

extension View {
    /// Apply the standard solid background
    func solidBackground() -> some View {
        self.background(Theme.windowBackground)
    }
    
    /// Apply hover-aware background
    func hoverBackground(_ isHovering: Bool) -> some View {
        self.background(isHovering ? Theme.hoverBackground : Color.clear)
    }
    
    /// Apply section background
    func sectionBackground() -> some View {
        self.background(Theme.sectionBackground)
    }
}
