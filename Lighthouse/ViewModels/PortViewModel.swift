import Foundation
import SwiftUI
import Combine
import UserNotifications

enum SystemHealth {
    case healthy      // All systems operational
    case warning      // Some warnings detected
    case critical     // Critical issues detected
    case unknown      // No data yet
    
    var iconColor: Color {
        switch self {
        case .healthy: return .green
        case .warning: return .orange
        case .critical: return .red
        case .unknown: return .primary
        }
    }
}

@MainActor
class PortViewModel: ObservableObject {
    @Published var ports: [PortInfo] = []
    @Published var isLoading = false
    @Published var searchText = ""
    
    // Website tracking
    @Published var websites: [WebsiteInfo] = []
    @Published var isAddingWebsite = false
    @Published var isLoadingWebsites = false
    
    // Environment profiles
    @Published var profiles: [EnvironmentProfile] = []
    @Published var activeProfile: EnvironmentProfile?
    
    // Docker containers
    @Published var containers: [DockerContainer] = []
    @Published var isLoadingContainers = false
    @Published var dockerAvailable = false
    
    // System health status
    @Published var systemHealth: SystemHealth = .unknown

    private let scanner = PortScanner()
    private let processManager = ProcessManager()
    private let websiteMonitor = WebsiteMonitor()
    private let websiteStorage = WebsiteStorage()
    private let profileStorage = ProfileStorage()
    private let dockerManager = DockerManager()
    private let notificationManager = NotificationManager.shared

    private var refreshTimer: AnyCancellable?
    private var websiteRefreshTimer: AnyCancellable?
    private var containerRefreshTimer: AnyCancellable?
    
    // Track previous state for change detection
    private var previousPortPIDs: Set<Int> = []
    private var previousWebsiteStatuses: [UUID: PingStatus] = [:]

    // Only show dev servers
    var devPorts: [PortInfo] {
        var result = ports.filter { $0.isDevServer }

        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter { port in
                port.portString.contains(query) ||
                port.processName.lowercased().contains(query) ||
                port.displayName.lowercased().contains(query) ||
                (port.detectedFramework?.lowercased().contains(query) ?? false) ||
                (port.projectName?.lowercased().contains(query) ?? false) ||
                (port.folderName?.lowercased().contains(query) ?? false)
            }
        }

        return result
    }

    // MARK: - Scanning

    func refresh() async {
        isLoading = true
        
        // Track previous state
        let oldPIDs = Set(ports.map { $0.pid })
        
        do {
            ports = try await scanner.scanPorts()
        } catch {
            ports = []
        }
        
        // Detect port changes
        let newPIDs = Set(ports.map { $0.pid })
        let stoppedPIDs = oldPIDs.subtracting(newPIDs)
        let startedPIDs = newPIDs.subtracting(oldPIDs)
        
        // Notify about stopped dev servers
        if !previousPortPIDs.isEmpty { // Don't notify on first scan
            for pid in stoppedPIDs {
                if let port = previousPortPIDs.contains(pid) ? ports.first(where: { $0.pid == pid }) : nil {
                    notificationManager.notifyPortDown(port: port.port, processName: port.processName)
                }
            }
            
            // Notify about started dev servers
            for pid in startedPIDs {
                if let port = ports.first(where: { $0.pid == pid }), port.isDevServer {
                    notificationManager.notifyPortStarted(port: port.port, processName: port.processName)
                }
            }
        }
        
        previousPortPIDs = newPIDs
        isLoading = false
        updateSystemHealth()
    }

    func startAutoRefresh() {
        stopAutoRefresh()
        refreshTimer = Timer.publish(every: 5.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task { await self?.refresh() }
            }
        
        // Start website monitoring with profile-specific interval
        let interval = activeProfile?.refreshInterval ?? 30.0
        websiteRefreshTimer = Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task { await self?.refreshWebsites() }
            }
        
        // Start container monitoring (every 10 seconds)
        containerRefreshTimer = Timer.publish(every: 10.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task { await self?.refreshContainers() }
            }
    }

    func stopAutoRefresh() {
        refreshTimer?.cancel()
        refreshTimer = nil
        websiteRefreshTimer?.cancel()
        websiteRefreshTimer = nil
        containerRefreshTimer?.cancel()
        containerRefreshTimer = nil
    }

    // MARK: - Actions

    func killProcess(port: PortInfo) async {
        _ = try? await processManager.killAndVerify(pid: port.pid)
        ports.removeAll { $0.pid == port.pid }
    }

    func openInBrowser(port: PortInfo) {
        if let url = URL(string: "http://localhost:\(port.port)") {
            NSWorkspace.shared.open(url)
        }
    }

    func copyURL(port: PortInfo) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString("http://localhost:\(port.port)", forType: .string)
    }

    func openInFinder(port: PortInfo) {
        guard let dir = port.workingDirectory else { return }
        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: dir)
    }

    func openInEditor(port: PortInfo, app: String) {
        guard let dir = port.workingDirectory else { return }
        let url = URL(fileURLWithPath: dir)
        let appURL = URL(fileURLWithPath: "/Applications/\(app).app")
        let config = NSWorkspace.OpenConfiguration()
        NSWorkspace.shared.open([url], withApplicationAt: appURL, configuration: config)
    }

    func openInTerminal(port: PortInfo) {
        guard let dir = port.workingDirectory else { return }
        let script = "tell application \"Terminal\" to do script \"cd '\(dir)'\""
        NSAppleScript(source: script)?.executeAndReturnError(nil)
    }
    
    // MARK: - Website Tracking
    
    func loadWebsites() {
        // Load profiles
        profiles = profileStorage.load()
        activeProfile = profileStorage.getActiveProfile(from: profiles)
        
        // If no active profile, activate the first one
        if activeProfile == nil && !profiles.isEmpty {
            profiles[0].isActive = true
            activeProfile = profiles[0]
            try? profileStorage.save(profiles)
        }
        
        // Load websites from active profile or legacy storage
        if let profile = activeProfile {
            websites = profile.websites
        } else {
            websites = websiteStorage.load()
        }
        
        // Initialize previous statuses
        for website in websites {
            if let status = website.lastPingStatus {
                previousWebsiteStatuses[website.id] = status
            }
        }
        
        // Check Docker availability
        dockerAvailable = dockerManager.isDockerAvailable
        
        // Request notification permissions on first launch
        Task {
            _ = await notificationManager.requestAuthorization()
        }
    }
    
    func refreshWebsites() async {
        guard !websites.isEmpty else { return }
        
        isLoadingWebsites = true
        let results = await websiteMonitor.monitorWebsites(websites)
        
        // Update websites with new ping results and detect status changes
        for i in websites.indices {
            if let result = results[websites[i].id] {
                let oldStatus = websites[i].lastPingStatus
                websites[i].addPingResult(result)
                let newStatus = websites[i].lastPingStatus
                
                // Notify on status change (skip first check)
                if let old = oldStatus, let new = newStatus, !previousWebsiteStatuses.isEmpty {
                    if old != new {
                        notificationManager.notifyWebsiteStatusChange(
                            website: websites[i].effectiveDisplayName,
                            oldStatus: old,
                            newStatus: new
                        )
                    }
                }
                
                // Track status
                if let status = newStatus {
                    previousWebsiteStatuses[websites[i].id] = status
                }
            }
        }
        
        // Save updated websites
        saveCurrentProfile()
        isLoadingWebsites = false
        updateSystemHealth()
    }
    
    func addWebsite(url: String, name: String, isInternal: Bool? = nil, framework: String? = nil) async {
        // Normalize URL
        let normalizedURL = WebsiteMonitor.normalizeURL(url)
        
        // Validate URL
        guard WebsiteMonitor.isValidURL(normalizedURL) else {
            return
        }
        
        // Create new website
        var website = WebsiteInfo(
            url: normalizedURL,
            displayName: name.isEmpty ? "" : name,
            isInternal: isInternal,
            detectedFramework: framework
        )
        
        // Perform initial ping
        let result = await websiteMonitor.ping(url: normalizedURL)
        website.addPingResult(result)
        
        // Add to list
        websites.append(website)
        
        // Save to storage
        saveCurrentProfile()
        
        isAddingWebsite = false
    }
    
    func removeWebsite(id: UUID) {
        websites.removeAll { $0.id == id }
        saveCurrentProfile()
    }
    
    func updateWebsite(_ website: WebsiteInfo) {
        if let index = websites.firstIndex(where: { $0.id == website.id }) {
            websites[index] = website
            saveCurrentProfile()
        }
    }
    
    private func saveCurrentProfile() {
        if let profileIndex = profiles.firstIndex(where: { $0.id == activeProfile?.id }) {
            profiles[profileIndex].websites = websites
            try? profileStorage.save(profiles)
        } else {
            // Fallback to legacy storage
            try? websiteStorage.save(websites)
        }
    }
    
    func toggleWebsiteMonitoring(id: UUID) {
        if let index = websites.firstIndex(where: { $0.id == id }) {
            websites[index].isEnabled.toggle()
            saveCurrentProfile()
        }
    }
    
    // MARK: - Profile Management
    
    func switchProfile(to profile: EnvironmentProfile) {
        // Deactivate current profile
        if let currentIndex = profiles.firstIndex(where: { $0.isActive }) {
            profiles[currentIndex].isActive = false
        }
        
        // Activate new profile
        if let newIndex = profiles.firstIndex(where: { $0.id == profile.id }) {
            profiles[newIndex].isActive = true
            activeProfile = profiles[newIndex]
            websites = profiles[newIndex].websites
            
            // Save profiles
            try? profileStorage.save(profiles)
            
            // Restart timers with new interval
            startAutoRefresh()
            
            // Refresh websites immediately
            Task {
                await refreshWebsites()
            }
        }
    }
    
    func createProfile(name: String, icon: String, refreshInterval: TimeInterval) {
        let profile = EnvironmentProfile(
            name: name,
            icon: icon,
            refreshInterval: refreshInterval
        )
        profiles.append(profile)
        try? profileStorage.save(profiles)
    }
    
    func deleteProfile(id: UUID) {
        guard profiles.count > 1 else { return } // Keep at least one profile
        
        // If deleting active profile, switch to another first
        if activeProfile?.id == id {
            if let nextProfile = profiles.first(where: { $0.id != id }) {
                switchProfile(to: nextProfile)
            }
        }
        
        profiles.removeAll { $0.id == id }
        try? profileStorage.save(profiles)
    }
    
    // MARK: - Docker Management
    
    func refreshContainers() async {
        guard dockerAvailable else { return }
        
        isLoadingContainers = true
        do {
            containers = try await dockerManager.listContainers()
        } catch {
            containers = []
        }
        isLoadingContainers = false
    }
    
    func startContainer(_ container: DockerContainer) async {
        do {
            try await dockerManager.startContainer(id: container.id)
            await refreshContainers()
        } catch {
            print("Failed to start container: \(error)")
        }
    }
    
    func stopContainer(_ container: DockerContainer) async {
        do {
            try await dockerManager.stopContainer(id: container.id)
            await refreshContainers()
        } catch {
            print("Failed to stop container: \(error)")
        }
    }
    
    func restartContainer(_ container: DockerContainer) async {
        do {
            try await dockerManager.restartContainer(id: container.id)
            await refreshContainers()
        } catch {
            print("Failed to restart container: \(error)")
        }
    }
    
    func removeContainer(_ container: DockerContainer) async {
        do {
            try await dockerManager.removeContainer(id: container.id, force: true)
            await refreshContainers()
        } catch {
            print("Failed to remove container: \(error)")
        }
    }
    
    func openContainerPort(_ container: DockerContainer, port: Int) {
        if let url = URL(string: "http://localhost:\(port)") {
            NSWorkspace.shared.open(url)
        }
    }
    
    // Website actions
    func openWebsite(_ website: WebsiteInfo) {
        if let url = URL(string: website.url) {
            NSWorkspace.shared.open(url)
        }
    }
    
    func copyWebsiteURL(_ website: WebsiteInfo) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(website.url, forType: .string)
    }
    
    // MARK: - System Health
    
    private func updateSystemHealth() {
        var hasCritical = false
        var hasWarning = false
        
        // Check websites for issues
        for website in websites where website.isEnabled {
            if let status = website.lastPingStatus {
                switch status {
                case .error:
                    hasCritical = true
                case .warning:
                    hasWarning = true
                default:
                    break
                }
            }
        }
        
        // Determine overall health
        if hasCritical {
            systemHealth = .critical
        } else if hasWarning {
            systemHealth = .warning
        } else if !websites.isEmpty || !ports.isEmpty {
            systemHealth = .healthy
        } else {
            systemHealth = .unknown
        }
    }
}
