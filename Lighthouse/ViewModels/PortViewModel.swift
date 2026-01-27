import Foundation
import SwiftUI
import Combine

@MainActor
class PortViewModel: ObservableObject {
    @Published var ports: [PortInfo] = []
    @Published var isLoading = false
    @Published var searchText = ""

    private let scanner = PortScanner()
    private let processManager = ProcessManager()

    private var refreshTimer: AnyCancellable?

    // Only show dev servers
    var devPorts: [PortInfo] {
        var result = ports.filter { $0.isDevServer }

        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter { port in
                port.portString.contains(query) ||
                port.processName.lowercased().contains(query) ||
                (port.folderName?.lowercased().contains(query) ?? false)
            }
        }

        return result
    }

    // MARK: - Scanning

    func refresh() async {
        isLoading = true
        do {
            ports = try await scanner.scanPorts()
        } catch {
            ports = []
        }
        isLoading = false
    }

    func startAutoRefresh() {
        stopAutoRefresh()
        refreshTimer = Timer.publish(every: 5.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task { await self?.refresh() }
            }
    }

    func stopAutoRefresh() {
        refreshTimer?.cancel()
        refreshTimer = nil
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
}
