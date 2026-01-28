import SwiftUI

struct MenuBarView: View {
    @ObservedObject var viewModel: PortViewModel
    @State private var isAddingWebsite = false

    var body: some View {
        VStack(spacing: 0) {
            // Local Ports Header
            HStack(spacing: 12) {
                Text("LOCAL")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.secondary)
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
                            .foregroundColor(.primary.opacity(0.5))
                    }
                }
                .buttonStyle(.plain)
                .help("Refresh")
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 8)

            Divider()

            // Local Ports Content
            if viewModel.isLoading && viewModel.ports.isEmpty {
                loadingView
            } else if viewModel.devPorts.isEmpty {
                emptyView
            } else {
                portList
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
            
            Divider()

            // Footer
            HStack {
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
                .font(.system(size: 10))
                .foregroundColor(.secondary.opacity(0.6))

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
        }
        .frame(width: 520)
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
    }

    private var loadingView: some View {
        HStack(spacing: 10) {
            ProgressView()
                .scaleEffect(0.6)
            Text("Scanning...")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 60)
    }

    private var emptyView: some View {
        VStack(spacing: 4) {
            Text("No dev servers running")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 60)
    }

    private var portList: some View {
        LazyVStack(spacing: 0) {
            ForEach(viewModel.devPorts) { port in
                PortRowView(
                    port: port,
                    onOpen: { viewModel.openInBrowser(port: port) },
                    onCopy: { viewModel.copyURL(port: port) },
                    onKill: { Task { await viewModel.killProcess(port: port) } },
                    onOpenFolder: { viewModel.openInFinder(port: port) },
                    onOpenInEditor: { app in viewModel.openInEditor(port: port, app: app) },
                    onOpenInTerminal: { viewModel.openInTerminal(port: port) }
                )

                if port.id != viewModel.devPorts.last?.id {
                    Divider()
                        .opacity(0.3)
                }
            }
        }
    }
    
    private var nauticalSeparator: some View {
        VStack(spacing: 0) {
            Divider()
                .padding(.vertical, 8)
            
            HStack(spacing: 12) {
                Text("REMOTE")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.secondary)
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
                            .foregroundColor(.primary.opacity(0.5))
                    }
                }
                .buttonStyle(.plain)
                .help("Refresh websites")
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
            
            Divider()
        }
    }
    
    private var profileSwitcher: some View {
        HStack(spacing: 8) {
            Image(systemName: "map.fill")
                .font(.system(size: 10))
                .foregroundColor(.secondary.opacity(0.6))
            
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
                .foregroundColor(.primary.opacity(0.7))
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            if let interval = viewModel.activeProfile?.refreshInterval {
                HStack(spacing: 3) {
                    Image(systemName: "clock")
                        .font(.system(size: 8))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text("\(Int(interval))s")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary.opacity(0.5))
                }
                .help("Refresh interval")
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(Color.primary.opacity(0.03))
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
                .foregroundColor(.primary.opacity(0.2))
            
            Text("No ships at sea")
                .font(.system(size: 11))
                .foregroundColor(.secondary.opacity(0.7))
            
            Text("Add websites to monitor their status")
                .font(.system(size: 10))
                .foregroundColor(.secondary.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }
    
    private var distantPortsList: some View {
        LazyVStack(spacing: 0) {
            ForEach(viewModel.websites) { website in
                WebsiteRowView(
                    website: website,
                    onOpen: { viewModel.openWebsite(website) },
                    onCopy: { viewModel.copyWebsiteURL(website) },
                    onRemove: { viewModel.removeWebsite(id: website.id) },
                    onSave: { newName in
                        var updated = website
                        updated.displayName = newName
                        viewModel.updateWebsite(updated)
                    }
                )
                
                if website.id != viewModel.websites.last?.id {
                    Divider()
                        .opacity(0.3)
                }
            }
        }
    }
    
    private var dockerSection: some View {
        VStack(spacing: 0) {
            Divider()
                .padding(.vertical, 8)
            
            HStack(spacing: 12) {
                Image(systemName: "shippingbox.fill")
                    .font(.system(size: 11))
                    .foregroundColor(.primary.opacity(0.6))
                
                Text("CONTAINER SHIPS")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.secondary)
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
                            .foregroundColor(.primary.opacity(0.5))
                    }
                }
                .buttonStyle(.plain)
                .help("Refresh containers")
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
            
            Divider()
            
            if viewModel.containers.isEmpty {
                VStack(spacing: 6) {
                    Image(systemName: "shippingbox")
                        .font(.system(size: 18))
                        .foregroundColor(.primary.opacity(0.2))
                    
                    Text("No containers")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary.opacity(0.7))
                    
                    Text("Docker containers will appear here")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary.opacity(0.5))
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
                                Divider()
                                    .opacity(0.3)
                            }
                        }
                    }
                }
                .frame(height: 200)
            }
        }
    }
}
