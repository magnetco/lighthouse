import SwiftUI

struct PortRowView: View {
    let port: PortInfo
    let onOpen: () -> Void
    let onCopy: () -> Void
    let onKill: () -> Void
    let onOpenFolder: () -> Void
    let onOpenInEditor: (String) -> Void
    let onOpenInTerminal: () -> Void
    let onToggleStar: () -> Void

    @State private var isHovering = false
    @State private var showingLogs = false

    var body: some View {
        HStack(spacing: 0) {
            // Star button - fixed width
            Button(action: onToggleStar) {
                Image(systemName: port.isStarred ? "star.fill" : "star")
                    .font(.system(size: 11))
                    .foregroundColor(port.isStarred ? Theme.star : Theme.textMuted)
            }
            .buttonStyle(.plain)
            .frame(width: 20)
            .help(port.isStarred ? "Remove from favorites" : "Add to favorites")
            
            // Framework icon - fixed width
            frameworkIcon
                .frame(width: 24, alignment: .center)
            
            // Status indicator - fixed position
            Circle()
                .fill(Theme.success)
                .frame(width: 7, height: 7)
                .shadow(color: Theme.success.opacity(0.4), radius: 2, x: 0, y: 0)
                .frame(width: 18)
            
            // Port number (like response time) - fixed width
            Text(port.portString)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(Theme.textSecondary)
                .frame(width: 60, alignment: .leading)

            // Project/folder name - fixed width
            Group {
                if port.workingDirectory != nil {
                    projectButton
                } else {
                    Text(port.displayName)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Theme.textPrimary)
                }
            }
            .frame(width: 200, alignment: .leading)
            
            // Framework/app type - fixed width
            Text(port.secondaryInfo ?? "Server")
                .font(.system(size: 11))
                .foregroundColor(Theme.textSecondary)
                .frame(width: 120, alignment: .leading)

            Spacer()
            
            // Actions - always visible, fixed width
            HStack(spacing: 6) {
                // Show connection string button for databases
                if isDatabasePort {
                    IconButton(icon: "link", help: "Copy connection string", action: copyConnectionString)
                }
                IconButton(icon: "doc.text", help: "View logs", action: { showingLogs = true })
                IconButton(icon: "safari", help: "Open in browser", action: onOpen)
                IconButton(icon: "doc.on.doc", help: "Copy URL", action: onCopy)
                IconButton(icon: "xmark.circle.fill", help: "Stop server", color: Theme.error, action: onKill)
            }
            .frame(width: isDatabasePort ? 135 : 110, alignment: .trailing)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(isHovering ? Theme.hoverBackground : Color.clear)
        .contentShape(Rectangle())
        .onHover { isHovering = $0 }
        .help(port.commandLine ?? "")
        .contextMenu {
            Button(action: onToggleStar) {
                Label(
                    port.isStarred ? "Remove from Favorites" : "Add to Favorites",
                    systemImage: port.isStarred ? "star.slash" : "star"
                )
            }
            Divider()
            Button("View Logs") { showingLogs = true }
            Divider()
            Button("Open in Browser") { onOpen() }
            Button("Copy URL") { onCopy() }
            if isDatabasePort {
                Button("Copy Connection String") { copyConnectionString() }
            }
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
                    .foregroundColor(Theme.textPrimary)
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 8, weight: .semibold))
                    .foregroundColor(Theme.textMuted)
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
                    .opacity(0.85)
            } else {
                // Use SF Symbol
                Image(systemName: iconInfo.fallbackSymbol)
                    .font(.system(size: 12))
                    .foregroundColor(Theme.iconDefault)
            }
        }
    }
    
    private var isDatabasePort: Bool {
        guard let framework = port.detectedFramework else { return false }
        let dbType = FrameworkIconMapper.frameworkType(from: framework)
        return [.postgresql, .mysql, .mongodb, .redis, .memcached, .elasticsearch].contains(dbType)
    }
    
    private func copyConnectionString() {
        guard let framework = port.detectedFramework,
              let dbType = FrameworkIconMapper.frameworkType(from: framework),
              let connString = FrameworkIconMapper.connectionString(for: dbType, port: port.port) else {
            return
        }
        
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(connString, forType: .string)
    }

}

struct IconButton: View {
    let icon: String
    let help: String
    var color: Color = Theme.textPrimary
    let action: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 11.5))
                .foregroundColor(isHovering ? color : Theme.iconDefault)
                .frame(width: 24, height: 24)
                .background(isHovering ? color.opacity(0.15) : Color.clear)
                .cornerRadius(4)
                .scaleEffect(isHovering ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 0.15), value: isHovering)
        }
        .buttonStyle(.plain)
        .help(help)
        .onHover { isHovering = $0 }
    }
}
