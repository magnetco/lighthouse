import Foundation
import Carbon
import AppKit

class ShortcutManager: ObservableObject {
    static let shared = ShortcutManager()
    
    @Published var currentShortcut: (keyCode: UInt32, modifiers: UInt32)?
    
    private var hotKeyRef: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?
    private let userDefaultsKey = "globalShortcut"
    
    var onShortcutPressed: (() -> Void)?
    
    private init() {
        loadShortcut()
    }
    
    func registerDefaultShortcut() {
        // Default: Control + Option + L
        let keyCode: UInt32 = 0x25 // L key
        let modifiers: UInt32 = UInt32(controlKey | optionKey)
        registerShortcut(keyCode: keyCode, modifiers: modifiers)
    }
    
    func registerShortcut(keyCode: UInt32, modifiers: UInt32) {
        // Unregister existing shortcut
        unregisterShortcut()
        
        // Register new shortcut
        var hotKeyID = EventHotKeyID()
        hotKeyID.signature = OSType(("LHSE" as NSString).utf8String!.withMemoryRebound(to: Int8.self, capacity: 4) { $0.pointee })
        hotKeyID.id = 1
        
        var gMyHotKeyRef: EventHotKeyRef?
        let status = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &gMyHotKeyRef
        )
        
        if status == noErr {
            hotKeyRef = gMyHotKeyRef
            currentShortcut = (keyCode, modifiers)
            saveShortcut(keyCode: keyCode, modifiers: modifiers)
            
            // Install event handler if not already installed
            if eventHandler == nil {
                installEventHandler()
            }
        } else {
            print("Failed to register hotkey: \(status)")
        }
    }
    
    func unregisterShortcut() {
        if let hotKey = hotKeyRef {
            UnregisterEventHotKey(hotKey)
            hotKeyRef = nil
        }
    }
    
    private func installEventHandler() {
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )
        
        let callback: EventHandlerUPP = { _, event, userData in
            // Trigger the callback
            if let manager = userData?.assumingMemoryBound(to: ShortcutManager.self).pointee {
                DispatchQueue.main.async {
                    manager.onShortcutPressed?()
                }
            }
            return noErr
        }
        
        var handler: EventHandlerRef?
        let selfPtr = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        
        InstallEventHandler(
            GetApplicationEventTarget(),
            callback,
            1,
            &eventType,
            selfPtr,
            &handler
        )
        
        eventHandler = handler
    }
    
    private func saveShortcut(keyCode: UInt32, modifiers: UInt32) {
        UserDefaults.standard.set([
            "keyCode": keyCode,
            "modifiers": modifiers
        ], forKey: userDefaultsKey)
    }
    
    private func loadShortcut() {
        guard let dict = UserDefaults.standard.dictionary(forKey: userDefaultsKey),
              let keyCode = dict["keyCode"] as? UInt32,
              let modifiers = dict["modifiers"] as? UInt32 else {
            return
        }
        
        registerShortcut(keyCode: keyCode, modifiers: modifiers)
    }
    
    func shortcutDescription() -> String {
        guard let shortcut = currentShortcut else {
            return "Not set"
        }
        
        var parts: [String] = []
        
        if shortcut.modifiers & UInt32(controlKey) != 0 {
            parts.append("⌃")
        }
        if shortcut.modifiers & UInt32(optionKey) != 0 {
            parts.append("⌥")
        }
        if shortcut.modifiers & UInt32(shiftKey) != 0 {
            parts.append("⇧")
        }
        if shortcut.modifiers & UInt32(cmdKey) != 0 {
            parts.append("⌘")
        }
        
        // Map key code to character
        let keyChar = keyCodeToString(shortcut.keyCode)
        parts.append(keyChar)
        
        return parts.joined()
    }
    
    private func keyCodeToString(_ keyCode: UInt32) -> String {
        switch keyCode {
        case 0x00: return "A"
        case 0x0B: return "B"
        case 0x08: return "C"
        case 0x02: return "D"
        case 0x0E: return "E"
        case 0x03: return "F"
        case 0x05: return "G"
        case 0x04: return "H"
        case 0x22: return "I"
        case 0x26: return "J"
        case 0x28: return "K"
        case 0x25: return "L"
        case 0x2E: return "M"
        case 0x2D: return "N"
        case 0x1F: return "O"
        case 0x23: return "P"
        case 0x0C: return "Q"
        case 0x0F: return "R"
        case 0x01: return "S"
        case 0x11: return "T"
        case 0x20: return "U"
        case 0x09: return "V"
        case 0x0D: return "W"
        case 0x07: return "X"
        case 0x10: return "Y"
        case 0x06: return "Z"
        default: return "?"
        }
    }
    
    deinit {
        unregisterShortcut()
        if let handler = eventHandler {
            RemoveEventHandler(handler)
        }
    }
}

extension Notification.Name {
    static let openLighthouseMenu = Notification.Name("openLighthouseMenu")
}
