import SwiftUI

struct PortRowView: View {
    let port: PortInfo
    let onOpen: () -> Void
    let onCopy: () -> Void
    let onKill: () -> Void
    let onOpenFolder: () -> Void
    let onOpenInEditor: (String) -> Void
    let onOpenInTerminal: () -> Void

    @State private var isHovering = false
    @State private var showingLogs = false

    var body: some View {
        HStack(spacing: 0) {
            // Framework icon - fixed width
            frameworkIcon
                .frame(width: 24, alignment: .center)
            
            // Status indicator - fixed position
            Circle()
                .fill(Color.green)
                .frame(width: 7, height: 7)
                .shadow(color: Color.green.opacity(0.3), radius: 1.5, x: 0, y: 0)
                .frame(width: 18)
            
            // Port number (like response time) - fixed width
            Text(port.portString)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.primary.opacity(0.6))
                .frame(width: 60, alignment: .leading)

            // Project/folder name - fixed width
            Group {
                if port.workingDirectory != nil {
                    projectButton
                } else {
                    Text(port.displayName)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.primary)
                }
            }
            .frame(width: 200, alignment: .leading)
            
            // Framework/app type - fixed width
            Text(port.secondaryInfo ?? "Server")
                .font(.system(size: 11))
                .foregroundColor(.secondary.opacity(0.8))
                .frame(width: 120, alignment: .leading)

            Spacer()
            
            // Actions - always visible, fixed width
            HStack(spacing: 6) {
                IconButton(icon: "doc.text", help: "View logs", action: { showingLogs = true })
                IconButton(icon: "safari", help: "Open in browser", action: onOpen)
                IconButton(icon: "doc.on.doc", help: "Copy URL", action: onCopy)
                IconButton(icon: "xmark.circle.fill", help: "Stop server", color: .red, action: onKill)
            }
            .frame(width: 110, alignment: .trailing)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(isHovering ? Color.primary.opacity(0.03) : Color.clear)
        .contentShape(Rectangle())
        .onHover { isHovering = $0 }
        .help(port.commandLine ?? "")
        .contextMenu {
            Button("View Logs") { showingLogs = true }
            Divider()
            Button("Open in Browser") { onOpen() }
            Button("Copy URL") { onCopy() }
            Divider()
            if port.workingDirectory != nil {
                Button("Reveal in Finder") { onOpenFolder() }
                Button("Open in Cursor") { onOpenInEditor("Cursor") }
                Button("Open in Zed") { onOpenInEditor("Zed") }
                Button("Open in VS Code") { onOpenInEditor("Visual Studio Code") }
                Button("Open in Terminal") { onOpenInTerminal() }
                Divider()
            }
            Button("Stop Server", role: .destructive) { onKill() }
        }
        .sheet(isPresented: $showingLogs) {
            LogViewerSheet(port: port)
        }
    }
    
    private var projectButton: some View {
        Menu {
            Button { onOpenFolder() } label: {
                Label("Reveal in Finder", systemImage: "folder")
            }
            Divider()
            Button { onOpenInEditor("Cursor") } label: {
                Label("Open in Cursor", systemImage: "cursorarrow.rays")
            }
            Button { onOpenInEditor("Zed") } label: {
                Label("Open in Zed", systemImage: "chevron.left.forwardslash.chevron.right")
            }
            Button { onOpenInEditor("Visual Studio Code") } label: {
                Label("Open in VS Code", systemImage: "chevron.left.forwardslash.chevron.right")
            }
            Divider()
            Button { onOpenInTerminal() } label: {
                Label("Open in Terminal", systemImage: "terminal")
            }
        } label: {
            HStack(spacing: 6) {
                Text(port.displayName)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.primary)
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 8, weight: .semibold))
                    .foregroundColor(.primary.opacity(0.3))
            }
        }
        .menuStyle(.borderlessButton)
        .fixedSize()
    }
    
    private var frameworkIcon: some View {
        Group {
            let iconInfo = FrameworkIconMapper.iconInfo(for: port.detectedFramework)
            if iconInfo.isAsset {
                // Try to use custom asset, fallback to SF Symbol if not available
                Image(iconInfo.name)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 14, height: 14)
                    .opacity(0.7)
            } else {
                // Use SF Symbol
                Image(systemName: iconInfo.fallbackSymbol)
                    .font(.system(size: 12))
                    .foregroundColor(.primary.opacity(0.5))
            }
        }
    }

}

struct IconButton: View {
    let icon: String
    let help: String
    var color: Color = .primary
    let action: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 11.5))
                .foregroundColor(isHovering ? color : .primary.opacity(0.35))
                .frame(width: 24, height: 24)
                .background(isHovering ? color.opacity(0.1) : Color.clear)
                .cornerRadius(4)
                .scaleEffect(isHovering ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 0.15), value: isHovering)
        }
        .buttonStyle(.plain)
        .help(help)
        .onHover { isHovering = $0 }
    }
}
