import Foundation
import UserNotifications

@MainActor
class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    
    private override init() {
        super.init()
        Task {
            await checkAuthorizationStatus()
        }
    }
    
    func requestAuthorization() async -> Bool {
        // UserNotifications requires a proper app bundle
        guard Bundle.main.bundleIdentifier != nil else {
            return false
        }
        
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            isAuthorized = granted
            return granted
        } catch {
            print("Failed to request notification authorization: \(error)")
            return false
        }
    }
    
    func checkAuthorizationStatus() async {
        // UserNotifications requires a proper app bundle, skip if running from command line
        guard Bundle.main.bundleIdentifier != nil else {
            isAuthorized = false
            return
        }
        
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
    }
    
    // MARK: - Website Notifications
    
    func notifyWebsiteStatusChange(website: String, oldStatus: PingStatus?, newStatus: PingStatus) {
        // UserNotifications requires a proper app bundle
        guard Bundle.main.bundleIdentifier != nil else { return }
        
        // Only notify on significant changes
        guard let old = oldStatus, old != newStatus else { return }
        
        let content = UNMutableNotificationContent()
        content.sound = .default
        
        switch newStatus {
        case .healthy:
            // Only notify recovery if it was previously in error state
            guard old == .error else { return }
            content.title = "🟢 \(website) is back online"
            content.body = "The website has recovered and is now healthy"
            
        case .warning:
            content.title = "🟡 \(website) has warnings"
            content.body = "The website is responding slowly or has redirects"
            
        case .error:
            content.title = "🔴 \(website) is down"
            content.body = "The website is unreachable or returning errors"
            
        case .unknown:
            return // Don't notify for unknown status
        }
        
        let request = UNNotificationRequest(
            identifier: "website-\(website)-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil // Deliver immediately
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to send notification: \(error)")
            }
        }
    }
    
    func notifyPortDown(port: Int, processName: String) {
        // UserNotifications requires a proper app bundle
        guard Bundle.main.bundleIdentifier != nil else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "⚓ Dev server stopped"
        content.body = "\(processName) on port \(port) has stopped"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "port-\(port)-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to send notification: \(error)")
            }
        }
    }
    
    func notifyPortStarted(port: Int, processName: String) {
        // UserNotifications requires a proper app bundle
        guard Bundle.main.bundleIdentifier != nil else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "⚓ Dev server started"
        content.body = "\(processName) is now running on port \(port)"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "port-\(port)-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to send notification: \(error)")
            }
        }
    }
}
