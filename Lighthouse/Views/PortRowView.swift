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
        HStack(spacing: 8) {
            // Star — filled always; empty only on hover
            Button(action: onToggleStar) {
                Image(systemName: port.isStarred ? "star.fill" : "star")
                    .font(.system(size: 11))
                    .foregroundColor(port.isStarred ? Theme.star : Theme.textMuted)
                    .opacity(port.isStarred || isHovering ? 1 : 0)
            }
            .buttonStyle(.plain)
            .frame(width: 18)
            .help(port.isStarred ? "Remove from favorites" : "Add to favorites")
            
            // Framework icon
            frameworkIcon
                .frame(width: 20, alignment: .center)
            
            // Status + port
            HStack(spacing: 6) {
                Circle()
                    .fill(Theme.success)
                    .frame(width: 7, height: 7)
                    .shadow(color: Theme.success.opacity(0.4), radius: 2, x: 0, y: 0)
                
                Text(port.portString)
                    .font(.system(size: Theme.secondaryLabelSize, design: .monospaced))
                    .foregroundColor(Theme.textSecondary)
                    .frame(minWidth: 40, alignment: .leading)
            }

            // Project/folder name — primary
            Group {
                if port.workingDirectory != nil {
                    projectButton
                } else {
                    Text(port.displayName)
                        .font(.system(size: Theme.primaryLabelSize, weight: .semibold))
                        .foregroundColor(Theme.textPrimary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }
            .frame(minWidth: 100, maxWidth: 220, alignment: .leading)
            .layoutPriority(2)
            
            // Framework/app type — secondary, flexible
            Text(port.secondaryInfo ?? "Server")
                .font(.system(size: Theme.secondaryLabelSize))
                .foregroundColor(Theme.textSecondary)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(minWidth: 60, maxWidth: .infinity, alignment: .leading)
                .layoutPriority(1)

            // Actions — hover only
            HStack(spacing: 4) {
                if isHovering {
                    if isDatabasePort {
                        IconButton(icon: "link", help: "Copy connection string", action: copyConnectionString)
                    }
                    IconButton(icon: "doc.text", help: "View logs", action: { showingLogs = true })
                    IconButton(icon: "safari", help: "Open in browser", action: onOpen)
                    IconButton(icon: "doc.on.doc", help: "Copy URL", action: onCopy)
                    IconButton(icon: "xmark.circle.fill", help: "Stop server", color: Theme.error, action: onKill)
                }
            }
            .frame(width: isHovering ? (isDatabasePort ? 132 : 108) : 0, alignment: .trailing)
            .animation(.easeInOut(duration: 0.12), value: isHovering)
        }
        .padding(.horizontal, Theme.panelHorizontalPadding)
        .padding(.vertical, Theme.rowVerticalPadding)
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
                    .font(.system(size: Theme.primaryLabelSize, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
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
