import SwiftUI

struct MenuBarView: View {
    @ObservedObject var viewModel: PortViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Dev Servers")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)

                Spacer()

                Button {
                    Task { await viewModel.refresh() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(viewModel.isLoading ? 360 : 0))
                        .animation(
                            viewModel.isLoading ? .linear(duration: 0.8).repeatForever(autoreverses: false) : .default,
                            value: viewModel.isLoading
                        )
                }
                .buttonStyle(.plain)
                .help("Refresh")
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 10)

            Divider()

            // Content
            if viewModel.isLoading && viewModel.ports.isEmpty {
                loadingView
            } else if viewModel.devPorts.isEmpty {
                emptyView
            } else {
                portList
            }

            Divider()

            // Footer
            HStack {
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
                .font(.system(size: 11))
                .foregroundColor(.secondary)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .frame(width: 340)
        .onAppear {
            viewModel.startAutoRefresh()
            Task { await viewModel.refresh() }
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
        ScrollView {
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
                            .padding(.leading, 66)
                    }
                }
            }
        }
        .frame(maxHeight: 300)
    }
}
