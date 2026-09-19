import SwiftUI

struct MenuBarView: View {
    @ObservedObject var viewModel: PortViewModel
    @ObservedObject private var pinController = PanelPinController.shared
    @State private var isAddingWebsite = false
    @State private var showingProjectMappings = false
    @State private var addTargetProfileId: UUID?

    var body: some View {
        VStack(spacing: 0) {
            // Local Ports Header
            HStack(spacing: 12) {
                Text("LOCAL")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Theme.textSecondary)
                    .tracking(0.5)

                Spacer()

                Button {
                    Task { await viewModel.refresh() }
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                            .scaleEffect(0.5)
                            .frame(width: 12, height: 12)
                    } else {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Theme.iconDefault)
                    }
                }
                .buttonStyle(.plain)
                .help("Refresh")
            }
            .padding(.horizontal, Theme.panelHorizontalPadding)
            .padding(.top, 14)
            .padding(.bottom, 10)
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

            // Nautical Separator + REMOTE (all envs at once)
            nauticalSeparator
            
            // Distant Ports Section — Development / Staging / Production
            distantPortsSection
            
            // Docker Section
            if viewModel.dockerAvailable {
                dockerSection
            }
            
            SolidDivider()

            // Footer
            HStack(spacing: 12) {
                Button {
                    pinController.toggle()
                } label: {
                    Image(systemName: pinController.isPinned ? "pin.fill" : "pin")
                        .font(.system(size: 12))
                }
                .buttonStyle(.plain)
                .foregroundColor(pinController.isPinned ? Theme.accent : Theme.iconDefault)
                .help(pinController.isPinned ? "Unpin panel" : "Pin panel open")
                
                Button {
                    showingProjectMappings = true
                } label: {
                    Image(systemName: "folder.badge.gearshape")
                        .font(.system(size: 12))
                }
                .buttonStyle(.plain)
                .foregroundColor(Theme.iconDefault)
                .help("Project Mappings")
                
                Spacer()
                
                Text("⌃⌥L")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(Theme.textMuted)
                    .help("Global shortcut")
                
                Spacer()
                
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
                .font(.system(size: 11))
                .foregroundColor(Theme.textSecondary)
            }
            .padding(.horizontal, Theme.panelHorizontalPadding)
            .padding(.vertical, 10)
            .background(Theme.headerBackground)
        }
        .frame(width: Theme.panelWidth)
        .frame(minHeight: Theme.panelMinHeight, alignment: .top)
        .background(Theme.windowBackground)
        .onAppear {
            viewModel.loadWebsites()
            if addTargetProfileId == nil {
                addTargetProfileId = viewModel.profiles.first(where: { $0.name == "Production" })?.id
                    ?? viewModel.activeProfile?.id
                    ?? viewModel.profiles.first?.id
            }
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
        .frame(height: 72)
    }

    private var emptyView: some View {
        VStack(spacing: 4) {
            Text("No dev servers running")
                .font(.system(size: 13))
                .foregroundColor(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 72)
    }

    private var groupedPortList: some View {
        GroupedPortListView(viewModel: viewModel)
    }
    
    private var nauticalSeparator: some View {
        VStack(spacing: 0) {
            SolidDivider()
            
            HStack(spacing: 12) {
                Text("REMOTE")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Theme.textSecondary)
                    .tracking(0.5)
                
                Spacer()
                
                Button {
                    Task { await viewModel.refreshWebsites() }
                } label: {
                    if viewModel.isLoadingWebsites {
                        ProgressView()
                            .scaleEffect(0.5)
                            .frame(width: 12, height: 12)
                    } else {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Theme.iconDefault)
                    }
                }
                .buttonStyle(.plain)
                .help("Refresh websites")
            }
            .padding(.horizontal, Theme.panelHorizontalPadding)
            .padding(.vertical, 10)
            .background(Theme.sectionHeaderGradient)
            
            SolidDivider()
        }
    }
    
    private var distantPortsSection: some View {
        VStack(spacing: 0) {
            if viewModel.orderedProfiles.isEmpty {
                distantPortsEmptyView
            } else {
                ScrollView {
                    LazyVStack(spacing: 0, pinnedViews: []) {
                        ForEach(viewModel.orderedProfiles) { profile in
                            environmentSection(for: profile)
                        }
                    }
                }
                .frame(maxHeight: 440)
            }
            
            addSiteTargetPicker
            
            AddWebsiteForm(isExpanded: $isAddingWebsite) { url, name, isInternal, framework in
                await viewModel.addWebsite(
                    url: url,
                    name: name,
                    isInternal: isInternal,
                    framework: framework,
                    toProfileId: addTargetProfileId
                )
            }
        }
    }
    
    private var addSiteTargetPicker: some View {
        HStack(spacing: 8) {
            Text("Add to")
                .font(.system(size: 10))
                .foregroundColor(Theme.textMuted)
            
            Menu {
                ForEach(viewModel.orderedProfiles) { profile in
                    Button {
                        addTargetProfileId = profile.id
                        viewModel.switchProfile(to: profile)
                    } label: {
                        HStack {
                            Image(systemName: profile.icon)
                            Text(profile.name)
                            if profile.id == addTargetProfileId {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    if let profile = viewModel.orderedProfiles.first(where: { $0.id == addTargetProfileId }) {
                        Image(systemName: profile.icon)
                            .font(.system(size: 9))
                        Text(profile.name)
                            .font(.system(size: 11, weight: .medium))
                    } else {
                        Text("Production")
                            .font(.system(size: 11, weight: .medium))
                    }
                    Image(systemName: "chevron.down")
                        .font(.system(size: 8))
                }
                .foregroundColor(Theme.textSecondary)
            }
            .buttonStyle(.plain)
            
            Spacer()
        }
        .padding(.horizontal, Theme.panelHorizontalPadding)
        .padding(.top, 8)
        .padding(.bottom, 2)
        .background(Theme.sectionBackground)
    }
    
    private func environmentSection(for profile: EnvironmentProfile) -> some View {
        let sites = viewModel.sortedWebsites(for: profile)
        
        return VStack(spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: profile.icon)
                    .font(.system(size: 10))
                    .foregroundColor(Theme.iconDefault)
                
                Text(profile.name.uppercased())
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Theme.textSecondary)
                    .tracking(0.4)
                
                Text("\(sites.count)")
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundColor(Theme.textMuted)
                
                Spacer()
                
                HStack(spacing: 3) {
                    Image(systemName: "clock")
                        .font(.system(size: 8))
                        .foregroundColor(Theme.textMuted)
                    Text("\(Int(profile.refreshInterval))s")
                        .font(.system(size: 9))
                        .foregroundColor(Theme.textMuted)
                }
                .help("Refresh interval for this environment")
            }
            .padding(.horizontal, Theme.panelHorizontalPadding)
            .padding(.vertical, 7)
            .background(Theme.sectionBackground)
            
            SolidDivider()
            
            if sites.isEmpty {
                HStack {
                    Text("No sites")
                        .font(.system(size: 11))
                        .foregroundColor(Theme.textTertiary)
                    Spacer()
                }
                .padding(.horizontal, Theme.panelHorizontalPadding)
                .padding(.vertical, 10)
            } else {
                ForEach(sites) { website in
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
                    
                    if website.id != sites.last?.id {
                        SolidDivider()
                    }
                }
            }
            
            SolidDivider()
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
    
    private var dockerSection: some View {
        VStack(spacing: 0) {
            SolidDivider()
            
            HStack(spacing: 12) {
                Image(systemName: "shippingbox.fill")
                    .font(.system(size: 11))
                    .foregroundColor(Theme.iconDefault)
                
                Text("CONTAINER SHIPS")
                    .font(.system(size: 11, weight: .semibold))
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
            .padding(.horizontal, Theme.panelHorizontalPadding)
            .padding(.vertical, 10)
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
