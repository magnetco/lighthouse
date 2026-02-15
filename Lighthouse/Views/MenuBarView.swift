import SwiftUI

struct MenuBarView: View {
    @ObservedObject var viewModel: PortViewModel
    @State private var isAddingWebsite = false
    @State private var showingWebhookSettings = false
    @State private var showingProjectMappings = false

    var body: some View {
        VStack(spacing: 0) {
            // Local Ports Header
            HStack(spacing: 12) {
                Text("LOCAL")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Theme.textSecondary)
                    .tracking(0.5)

                Spacer()

                Button {
                    Task { await viewModel.refresh() }
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                            .scaleEffect(0.5)
                            .frame(width: 10, height: 10)
                    } else {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Theme.iconDefault)
                    }
                }
                .buttonStyle(.plain)
                .help("Refresh")
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 8)
            .background(Theme.headerGradient)

            SolidDivider()

            // Local Ports Content (Grouped by Project)
            if viewModel.isLoading && viewModel.ports.isEmpty {
                loadingView
            } else if viewModel.groupedPorts.isEmpty {
                emptyView
            } else {
                groupedPortList
            }

            // Nautical Separator
            nauticalSeparator
            
            // Profile Switcher
            if !viewModel.profiles.isEmpty {
                profileSwitcher
            }
            
            // Distant Ports Section
            distantPortsSection
            
            // Docker Section
            if viewModel.dockerAvailable {
                dockerSection
            }
            
            SolidDivider()

            // Footer
            HStack {
                Button {
                    showingWebhookSettings = true
                } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 11))
                }
                .buttonStyle(.plain)
                .foregroundColor(Theme.iconDefault)
                .help("Settings")
                
                Button {
                    showingProjectMappings = true
                } label: {
                    Image(systemName: "folder.badge.gearshape")
                        .font(.system(size: 11))
                }
                .buttonStyle(.plain)
                .foregroundColor(Theme.iconDefault)
                .help("Project Mappings")
                
                Spacer()
                
                Text("⌃⌥L")
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundColor(Theme.textMuted)
                    .help("Global shortcut")
                
                Spacer()
                
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
                .font(.system(size: 10))
                .foregroundColor(Theme.textSecondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(Theme.headerBackground)
        }
        .frame(width: 520)
        .background(Theme.windowBackground)
        .onAppear {
            viewModel.loadWebsites()
            viewModel.startAutoRefresh()
            Task {
                await viewModel.refresh()
                await viewModel.refreshWebsites()
                await viewModel.refreshContainers()
            }
        }
        .onDisappear {
            viewModel.stopAutoRefresh()
        }
        .sheet(isPresented: $showingWebhookSettings) {
            WebhookSettingsView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingProjectMappings) {
            ProjectMappingsView(viewModel: viewModel)
        }
    }

    private var loadingView: some View {
        HStack(spacing: 10) {
            ProgressView()
                .scaleEffect(0.6)
            Text("Scanning...")
                .font(.system(size: 12))
                .foregroundColor(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 60)
    }

    private var emptyView: some View {
        VStack(spacing: 4) {
            Text("No dev servers running")
                .font(.system(size: 12))
                .foregroundColor(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 60)
    }

    private var groupedPortList: some View {
        GroupedPortListView(viewModel: viewModel)
    }
    
    private var nauticalSeparator: some View {
        VStack(spacing: 0) {
            SolidDivider()
            
            HStack(spacing: 12) {
                Text("REMOTE")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Theme.textSecondary)
                    .tracking(0.5)
                
                Spacer()
                
                Button {
                    Task { await viewModel.refreshWebsites() }
                } label: {
                    if viewModel.isLoadingWebsites {
                        ProgressView()
                            .scaleEffect(0.5)
                            .frame(width: 10, height: 10)
                    } else {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Theme.iconDefault)
                    }
                }
                .buttonStyle(.plain)
                .help("Refresh websites")
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(Theme.sectionHeaderGradient)
            
            SolidDivider()
        }
    }
    
    private var profileSwitcher: some View {
        HStack(spacing: 8) {
            Image(systemName: "map.fill")
                .font(.system(size: 10))
                .foregroundColor(Theme.iconDefault)
            
            Menu {
                ForEach(viewModel.profiles) { profile in
                    Button {
                        viewModel.switchProfile(to: profile)
                    } label: {
                        HStack {
                            Image(systemName: profile.icon)
                            Text(profile.name)
                            if profile.id == viewModel.activeProfile?.id {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    if let active = viewModel.activeProfile {
                        Image(systemName: active.icon)
                            .font(.system(size: 10))
                        Text(active.name)
                            .font(.system(size: 11, weight: .medium))
                    } else {
                        Text("Select Profile")
                            .font(.system(size: 11, weight: .medium))
                    }
                    Image(systemName: "chevron.down")
                        .font(.system(size: 8))
                }
                .foregroundColor(Theme.textPrimary)
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            if let interval = viewModel.activeProfile?.refreshInterval {
                HStack(spacing: 3) {
                    Image(systemName: "clock")
                        .font(.system(size: 8))
                        .foregroundColor(Theme.textMuted)
                    Text("\(Int(interval))s")
                        .font(.system(size: 9))
                        .foregroundColor(Theme.textMuted)
                }
                .help("Refresh interval")
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(Theme.sectionBackground)
    }
    
    private var distantPortsSection: some View {
        VStack(spacing: 0) {
            if viewModel.websites.isEmpty {
                distantPortsEmptyView
            } else {
                distantPortsList
            }
            
            // Add website form
            AddWebsiteForm(isExpanded: $isAddingWebsite) { url, name, isInternal, framework in
                await viewModel.addWebsite(url: url, name: name, isInternal: isInternal, framework: framework)
            }
        }
    }
    
    private var distantPortsEmptyView: some View {
        VStack(spacing: 6) {
            Image(systemName: "binoculars.fill")
                .font(.system(size: 18))
                .foregroundColor(Theme.textMuted)
            
            Text("No ships at sea")
                .font(.system(size: 11))
                .foregroundColor(Theme.textSecondary)
            
            Text("Add websites to monitor their status")
                .font(.system(size: 10))
                .foregroundColor(Theme.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }
    
    private var distantPortsList: some View {
        LazyVStack(spacing: 0) {
            ForEach(viewModel.sortedWebsites) { website in
                WebsiteRowView(
                    website: website,
                    onOpen: { viewModel.openWebsite(website) },
                    onCopy: { viewModel.copyWebsiteURL(website) },
                    onRemove: { viewModel.removeWebsite(id: website.id) },
                    onSave: { newName in
                        var updated = website
                        updated.displayName = newName
                        viewModel.updateWebsite(updated)
                    },
                    onToggleStar: { viewModel.toggleWebsiteStar(website) }
                )
                
                if website.id != viewModel.sortedWebsites.last?.id {
                    SolidDivider()
                }
            }
        }
    }
    
    private var dockerSection: some View {
        VStack(spacing: 0) {
            SolidDivider()
            
            HStack(spacing: 12) {
                Image(systemName: "shippingbox.fill")
                    .font(.system(size: 11))
                    .foregroundColor(Theme.iconDefault)
                
                Text("CONTAINER SHIPS")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Theme.textSecondary)
                    .tracking(0.5)
                
                Spacer()
                
                Button {
                    Task { await viewModel.refreshContainers() }
                } label: {
                    if viewModel.isLoadingContainers {
                        ProgressView()
                            .scaleEffect(0.5)
                            .frame(width: 10, height: 10)
                    } else {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Theme.iconDefault)
                    }
                }
                .buttonStyle(.plain)
                .help("Refresh containers")
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(Theme.sectionHeaderGradient)
            
            SolidDivider()
            
            if viewModel.containers.isEmpty {
                VStack(spacing: 6) {
                    Image(systemName: "shippingbox")
                        .font(.system(size: 18))
                        .foregroundColor(Theme.textMuted)
                    
                    Text("No containers")
                        .font(.system(size: 11))
                        .foregroundColor(Theme.textSecondary)
                    
                    Text("Docker containers will appear here")
                        .font(.system(size: 10))
                        .foregroundColor(Theme.textTertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.containers) { container in
                            DockerContainerRow(
                                container: container,
                                onStart: { Task { await viewModel.startContainer(container) } },
                                onStop: { Task { await viewModel.stopContainer(container) } },
                                onRestart: { Task { await viewModel.restartContainer(container) } },
                                onRemove: { Task { await viewModel.removeContainer(container) } },
                                onOpenPort: { port in viewModel.openContainerPort(container, port: port) }
                            )
                            
                            if container.id != viewModel.containers.last?.id {
                                SolidDivider()
                            }
                        }
                    }
                }
                .frame(height: 200)
            }
        }
    }
}

// MARK: - Solid Divider Component

struct SolidDivider: View {
    var body: some View {
        Rectangle()
            .fill(Theme.border)
            .frame(height: 1)
    }
}
