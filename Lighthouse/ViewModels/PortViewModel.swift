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
    
    // Favorites
    @Published var showOnlyStarredPorts = false
    @Published var showOnlyStarredWebsites = false
    
    // Webhooks
    @Published var webhooks: [WebhookConfig] = []
    
    // Project mappings
    @Published var projectMappings: [ProjectMapping] = []
    @Published var groupedPorts: [ProjectGroup] = []
    @Published var expandedGroups: Set<String> = []  // Track which groups are expanded

    private let scanner = PortScanner()
    private let processManager = ProcessManager()
    private let websiteMonitor = WebsiteMonitor()
    private let websiteStorage = WebsiteStorage()
    private let profileStorage = ProfileStorage()
    private let dockerManager = DockerManager()
    private let notificationManager = NotificationManager.shared
    private let favoritesStorage = FavoritesStorage()
    private let webhookStorage = WebhookStorage()
    private let webhookService = WebhookService.shared
    private let projectMappingStorage = ProjectMappingStorage()

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
        
        // Filter by starred if enabled
        if showOnlyStarredPorts {
            result = result.filter { $0.isStarred }
        }

        // Sort: starred items first, then by port number
        return result.sorted { lhs, rhs in
            if lhs.isStarred != rhs.isStarred {
                return lhs.isStarred
            }
            return lhs.port < rhs.port
        }
    }
    
    // MARK: - Project Grouping
    
    /// Group ports by project mapping
    func updateGroupedPorts() {
        let devPortsList = devPorts
        var groups: [String: ProjectGroup] = [:]
        var unknownCounter = 1
        var unmatchedPorts: [PortInfo] = []
        
        // First, try to match each port to a known project
        for port in devPortsList {
            var matched = false
            
            for mapping in projectMappings where mapping.isEnabled {
                if mapping.matches(
                    folderName: port.folderName,
                    workingDirectory: port.workingDirectory,
                    projectName: port.projectName
                ) {
                    let groupId = mapping.id.uuidString
                    if var group = groups[groupId] {
                        group.ports.append(port)
                        groups[groupId] = group
                    } else {
                        groups[groupId] = ProjectGroup(
                            id: groupId,
                            name: mapping.name,
                            mapping: mapping,
                            ports: [port],
                            isExpanded: expandedGroups.contains(groupId) || expandedGroups.isEmpty
                        )
                    }
                    matched = true
                    break
                }
            }
            
            if !matched {
                unmatchedPorts.append(port)
            }
        }
        
        // Group unmatched ports by their folder/project name
        var unknownGroups: [String: [PortInfo]] = [:]
        for port in unmatchedPorts {
            let key = port.folderName ?? port.projectName ?? port.processName
            if unknownGroups[key] == nil {
                unknownGroups[key] = []
            }
            unknownGroups[key]?.append(port)
        }
        
        // Create unknown project groups
        for (_, ports) in unknownGroups.sorted(by: { $0.key < $1.key }) {
            let groupId = "unknown-\(unknownCounter)"
            let groupName = "Unknown Project \(unknownCounter)"
            groups[groupId] = ProjectGroup(
                id: groupId,
                name: groupName,
                mapping: nil,
                ports: ports,
                isExpanded: expandedGroups.contains(groupId) || expandedGroups.isEmpty
            )
            unknownCounter += 1
        }
        
        // Sort groups: known projects first (alphabetically), then unknown projects
        groupedPorts = groups.values.sorted { lhs, rhs in
            // Known projects come first
            if lhs.isUnknown != rhs.isUnknown {
                return !lhs.isUnknown
            }
            // Then sort alphabetically
            return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
        }
        
        // Initialize expanded state for new groups
        if expandedGroups.isEmpty {
            expandedGroups = Set(groupedPorts.map { $0.id })
        }
    }
    
    func toggleGroupExpanded(_ groupId: String) {
        if expandedGroups.contains(groupId) {
            expandedGroups.remove(groupId)
        } else {
            expandedGroups.insert(groupId)
        }
        updateGroupedPorts()
    }
    
    func isGroupExpanded(_ groupId: String) -> Bool {
        expandedGroups.contains(groupId)
    }
    
    // Sorted websites with favorites first (flat across profiles; prefer per-profile helper)
    var sortedWebsites: [WebsiteInfo] {
        sortedWebsites(in: websites)
    }
    
    /// Sorted websites for a single environment profile.
    func sortedWebsites(for profile: EnvironmentProfile) -> [WebsiteInfo] {
        sortedWebsites(in: profile.websites)
    }
    
    private func sortedWebsites(in list: [WebsiteInfo]) -> [WebsiteInfo] {
        var result = list
        
        if showOnlyStarredWebsites {
            result = result.filter { $0.isStarred }
        }
        
        return result.sorted { lhs, rhs in
            if lhs.isStarred != rhs.isStarred {
                return lhs.isStarred
            }
            return lhs.displayName.localizedCaseInsensitiveCompare(rhs.displayName) == .orderedAscending
        }
    }
    
    /// Profiles in Development → Staging → Production order when possible.
    var orderedProfiles: [EnvironmentProfile] {
        let preferred = ["Development", "Staging", "Production"]
        return profiles.sorted { lhs, rhs in
            let li = preferred.firstIndex(of: lhs.name) ?? preferred.count
            let ri = preferred.firstIndex(of: rhs.name) ?? preferred.count
            if li != ri { return li < ri }
            return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
        }
    }

    // MARK: - Scanning

    func refresh() async {
        isLoading = true
        
        // Track previous state
        let oldPIDs = Set(ports.map { $0.pid })
        
        do {
            var scannedPorts = try await scanner.scanPorts()
            
            // Apply starred status from storage
            for i in scannedPorts.indices {
                scannedPorts[i].isStarred = favoritesStorage.isPortStarred(scannedPorts[i])
                
                // Check for database detection
                if let dbType = FrameworkIconMapper.detectDatabase(
                    processName: scannedPorts[i].processName,
                    port: scannedPorts[i].port
                ) {
                    // If not already detected as a framework, set it as database
                    if scannedPorts[i].detectedFramework == nil {
                        scannedPorts[i].detectedFramework = dbType.rawValue
                    }
                }
            }
            
            ports = scannedPorts
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
        updateGroupedPorts()
    }

    func startAutoRefresh() {
        stopAutoRefresh()
        refreshTimer = Timer.publish(every: 5.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task { await self?.refresh() }
            }
        
        // Refresh all remote envs on the shortest configured interval among profiles with sites
        let intervals = profiles.filter { !$0.websites.isEmpty }.map(\.refreshInterval)
        let interval = intervals.min() ?? activeProfile?.refreshInterval ?? 30.0
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
        // Load profiles from Application Support (or in-memory defaults on first launch)
        profiles = profileStorage.load()
        ensureStandardProfilesExist()
        
        activeProfile = profileStorage.getActiveProfile(from: profiles)
        
        // Prefer Production as the default active profile when none is set
        if activeProfile == nil && !profiles.isEmpty {
            if let prodIndex = profiles.firstIndex(where: { $0.name == "Production" }) {
                profiles[prodIndex].isActive = true
                activeProfile = profiles[prodIndex]
            } else {
                profiles[0].isActive = true
                activeProfile = profiles[0]
            }
        }
        
        // Migrate legacy websites.json into Production (or active) when that profile is empty
        migrateLegacyWebsitesIfNeeded()
        
        // Seed Desk / K&P defaults into empty profiles; merge-by-URL for known seeds on first empty fill
        seedDefaultSitesIfNeeded()
        
        // Persist immediately so remote URLs survive restart (defaults were previously in-memory only)
        syncWebsitesFromProfiles()
        saveAllProfiles()
        
        // Initialize previous statuses
        for website in websites {
            if let status = website.lastPingStatus {
                previousWebsiteStatuses[website.id] = status
            }
        }
        
        // Load webhooks
        webhooks = webhookStorage.load()
        
        // Load project mappings
        projectMappings = projectMappingStorage.load()
        
        // Check Docker availability
        dockerAvailable = dockerManager.isDockerAvailable
        
        // Request notification permissions on first launch
        Task {
            _ = await notificationManager.requestAuthorization()
        }
    }
    
    /// Ensure Development / Staging / Production profiles exist.
    private func ensureStandardProfilesExist() {
        let required: [(name: String, icon: String, interval: TimeInterval)] = [
            ("Development", "hammer.fill", 15),
            ("Staging", "wrench.and.screwdriver.fill", 30),
            ("Production", "checkmark.seal.fill", 60),
        ]
        for spec in required {
            guard !profiles.contains(where: { $0.name == spec.name }) else { continue }
            profiles.append(EnvironmentProfile(
                name: spec.name,
                icon: spec.icon,
                refreshInterval: spec.interval
            ))
        }
    }
    
    /// Move legacy single-list websites into Production when that profile has no sites yet.
    private func migrateLegacyWebsitesIfNeeded() {
        let legacyWebsites = websiteStorage.load()
        guard !legacyWebsites.isEmpty else { return }
        
        guard let prodIndex = profiles.firstIndex(where: { $0.name == "Production" }),
              profiles[prodIndex].websites.isEmpty else { return }
        
        profiles[prodIndex].websites = legacyWebsites
    }
    
    /// Seed Magnet Desk live sites into Production and K&P preview into Staging.
    /// Only fills empty profiles (merge-by-URL when applying seeds so duplicates are skipped).
    /// Does not wipe user-added sites on later launches.
    private func seedDefaultSitesIfNeeded() {
        for i in profiles.indices {
            let seeds = EnvironmentProfile.seedSites(forProfileName: profiles[i].name)
            guard !seeds.isEmpty else { continue }
            
            // Only seed when this environment has no sites yet
            guard profiles[i].websites.isEmpty else { continue }
            
            let existingKeys = Set(profiles[i].websites.map { EnvironmentProfile.canonicalURL($0.url) })
            for seed in seeds {
                let key = EnvironmentProfile.canonicalURL(seed.url)
                guard !existingKeys.contains(key) else { continue }
                profiles[i].websites.append(
                    WebsiteInfo(url: seed.url, displayName: seed.name, isInternal: false)
                )
            }
        }
    }
    
    private func syncWebsitesFromProfiles() {
        websites = profiles.flatMap(\.websites)
        if let activeId = activeProfile?.id,
           let refreshed = profiles.first(where: { $0.id == activeId }) {
            activeProfile = refreshed
        }
    }
    
    private func saveAllProfiles() {
        syncWebsitesFromProfiles()
        do {
            try profileStorage.save(profiles)
        } catch {
            print("Failed to save profiles: \(error)")
            // Fallback: persist flat list so remote URLs are not lost
            try? websiteStorage.save(websites)
        }
    }
    
    func refreshWebsites() async {
        let allSites = profiles.flatMap(\.websites)
        guard !allSites.isEmpty else { return }
        
        isLoadingWebsites = true
        let results = await websiteMonitor.monitorWebsites(allSites)
        
        // Update each profile's websites with new ping results
        for profileIndex in profiles.indices {
            for siteIndex in profiles[profileIndex].websites.indices {
                let siteId = profiles[profileIndex].websites[siteIndex].id
                guard let result = results[siteId] else { continue }
                
                let oldStatus = profiles[profileIndex].websites[siteIndex].lastPingStatus
                profiles[profileIndex].websites[siteIndex].addPingResult(result)
                let newStatus = profiles[profileIndex].websites[siteIndex].lastPingStatus
                
                if let old = oldStatus, let new = newStatus, !previousWebsiteStatuses.isEmpty, old != new {
                    let site = profiles[profileIndex].websites[siteIndex]
                    notificationManager.notifyWebsiteStatusChange(
                        website: site.effectiveDisplayName,
                        oldStatus: old,
                        newStatus: new
                    )
                    
                    if site.webhooksEnabled {
                        sendWebhooks(for: site, oldStatus: old, newStatus: new)
                    }
                }
                
                if let status = newStatus {
                    previousWebsiteStatuses[siteId] = status
                }
            }
        }
        
        saveAllProfiles()
        isLoadingWebsites = false
        updateSystemHealth()
    }
    
    func addWebsite(url: String, name: String, isInternal: Bool? = nil, framework: String? = nil, toProfileId: UUID? = nil) async {
        let normalizedURL = WebsiteMonitor.normalizeURL(url)
        guard WebsiteMonitor.isValidURL(normalizedURL) else { return }
        
        var website = WebsiteInfo(
            url: normalizedURL,
            displayName: name.isEmpty ? "" : name,
            isInternal: isInternal,
            detectedFramework: framework
        )
        
        let result = await websiteMonitor.ping(url: normalizedURL)
        website.addPingResult(result)
        
        let targetId = toProfileId
            ?? activeProfile?.id
            ?? profiles.first(where: { $0.name == "Production" })?.id
            ?? profiles.first?.id
        
        guard let targetId,
              let profileIndex = profiles.firstIndex(where: { $0.id == targetId }) else {
            return
        }
        
        profiles[profileIndex].websites.append(website)
        saveAllProfiles()
        isAddingWebsite = false
    }
    
    func removeWebsite(id: UUID) {
        for i in profiles.indices {
            profiles[i].websites.removeAll { $0.id == id }
        }
        saveAllProfiles()
    }
    
    func updateWebsite(_ website: WebsiteInfo) {
        for i in profiles.indices {
            if let index = profiles[i].websites.firstIndex(where: { $0.id == website.id }) {
                profiles[i].websites[index] = website
                saveAllProfiles()
                return
            }
        }
    }
    
    private func saveCurrentProfile() {
        // Keep name for call sites; persist all profiles (multi-env source of truth)
        saveAllProfiles()
    }
    
    func toggleWebsiteMonitoring(id: UUID) {
        for i in profiles.indices {
            if let index = profiles[i].websites.firstIndex(where: { $0.id == id }) {
                profiles[i].websites[index].isEnabled.toggle()
                saveAllProfiles()
                return
            }
        }
    }
    
    // MARK: - Profile Management
    
    func switchProfile(to profile: EnvironmentProfile) {
        // Kept for compatibility; UI now shows all envs at once.
        // Still tracks active profile as the default Add-Site target.
        if let currentIndex = profiles.firstIndex(where: { $0.isActive }) {
            profiles[currentIndex].isActive = false
        }
        
        if let newIndex = profiles.firstIndex(where: { $0.id == profile.id }) {
            profiles[newIndex].isActive = true
            activeProfile = profiles[newIndex]
            saveAllProfiles()
            startAutoRefresh()
        }
    }
    
    func createProfile(name: String, icon: String, refreshInterval: TimeInterval) {
        let profile = EnvironmentProfile(
            name: name,
            icon: icon,
            refreshInterval: refreshInterval
        )
        profiles.append(profile)
        saveAllProfiles()
    }
    
    func deleteProfile(id: UUID) {
        guard profiles.count > 1 else { return } // Keep at least one profile
        
        if activeProfile?.id == id {
            if let nextProfile = profiles.first(where: { $0.id != id }) {
                switchProfile(to: nextProfile)
            }
        }
        
        profiles.removeAll { $0.id == id }
        saveAllProfiles()
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
        
        let allSites = profiles.flatMap(\.websites)
        
        // Check websites for issues across all environments
        for website in allSites where website.isEnabled {
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
        } else if !allSites.isEmpty || !ports.isEmpty {
            systemHealth = .healthy
        } else {
            systemHealth = .unknown
        }
    }
    
    // MARK: - Favorites
    
    func togglePortStar(_ port: PortInfo) {
        favoritesStorage.togglePortStar(port)
        // Update in current ports array
        if let index = ports.firstIndex(where: { $0.id == port.id }) {
            ports[index].isStarred.toggle()
        }
    }
    
    func toggleWebsiteStar(_ website: WebsiteInfo) {
        for i in profiles.indices {
            if let index = profiles[i].websites.firstIndex(where: { $0.id == website.id }) {
                profiles[i].websites[index].isStarred.toggle()
                saveAllProfiles()
                return
            }
        }
    }
    
    // MARK: - Webhooks
    
    func addWebhook(_ webhook: WebhookConfig) {
        webhooks.append(webhook)
        try? webhookStorage.save(webhooks)
    }
    
    func removeWebhook(id: UUID) {
        webhooks.removeAll { $0.id == id }
        try? webhookStorage.save(webhooks)
    }
    
    func updateWebhook(_ webhook: WebhookConfig) {
        if let index = webhooks.firstIndex(where: { $0.id == webhook.id }) {
            webhooks[index] = webhook
            try? webhookStorage.save(webhooks)
        }
    }
    
    func testWebhook(_ webhook: WebhookConfig) async -> Bool {
        // Create a test event
        let testWebsite = WebsiteInfo(
            url: "https://example.com",
            displayName: "Test Website"
        )
        let testEvent = WebhookEvent(website: testWebsite, isDown: false)
        
        do {
            try await webhookService.send(event: testEvent, to: webhook)
            return true
        } catch {
            print("Webhook test failed: \(error)")
            return false
        }
    }
    
    private func sendWebhooks(for website: WebsiteInfo, oldStatus: PingStatus, newStatus: PingStatus) {
        let isDown = newStatus == .error
        let isRecovery = oldStatus == .error && newStatus == .healthy
        let isWarning = newStatus == .warning
        
        let event = WebhookEvent(website: website, isDown: isDown)
        
        Task {
            for webhook in webhooks where webhook.isEnabled {
                // Check if this webhook should trigger for this event type
                let shouldTrigger = (isDown && webhook.triggerOnDown) ||
                                   (isRecovery && webhook.triggerOnRecovery) ||
                                   (isWarning && webhook.triggerOnWarning)
                
                if shouldTrigger {
                    do {
                        try await webhookService.send(event: event, to: webhook)
                    } catch {
                        print("Failed to send webhook: \(error)")
                    }
                }
            }
        }
    }
    
    // MARK: - Project Mapping Management
    
    func addProjectMapping(_ mapping: ProjectMapping) {
        projectMappings.append(mapping)
        try? projectMappingStorage.save(projectMappings)
        updateGroupedPorts()
    }
    
    func removeProjectMapping(id: UUID) {
        projectMappings.removeAll { $0.id == id }
        try? projectMappingStorage.save(projectMappings)
        updateGroupedPorts()
    }
    
    func updateProjectMapping(_ mapping: ProjectMapping) {
        if let index = projectMappings.firstIndex(where: { $0.id == mapping.id }) {
            projectMappings[index] = mapping
            try? projectMappingStorage.save(projectMappings)
            updateGroupedPorts()
        }
    }
    
    func reloadProjectMappings() {
        projectMappings = projectMappingStorage.load()
        updateGroupedPorts()
    }
}
