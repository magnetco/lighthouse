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

    var body: some View {
        HStack(spacing: 16) {
            // Port number - clean, no formatting
            Text(port.portString)
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                .foregroundColor(.primary)
                .frame(width: 50, alignment: .trailing)

            // Project folder (if available)
            if let folder = port.folderName {
                folderButton(folder)
            } else {
                Text(port.processName)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            // Actions on hover
            if isHovering {
                HStack(spacing: 6) {
                    IconButton(icon: "safari", help: "Open in browser", action: onOpen)
                    IconButton(icon: "doc.on.doc", help: "Copy URL", action: onCopy)
                    IconButton(icon: "xmark.circle.fill", help: "Stop server", color: .red, action: onKill)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(isHovering ? Color.primary.opacity(0.04) : Color.clear)
        .contentShape(Rectangle())
        .onHover { isHovering = $0 }
        .contextMenu {
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
    }

    private func folderButton(_ folder: String) -> some View {
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
                Image(systemName: "folder.fill")
                    .font(.system(size: 11))
                    .foregroundColor(.blue.opacity(0.7))
                Text(folder)
                    .font(.system(size: 13))
                    .foregroundColor(.primary)
                Image(systemName: "chevron.down")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(.secondary.opacity(0.6))
            }
        }
        .menuStyle(.borderlessButton)
        .fixedSize()
        .frame(maxWidth: .infinity, alignment: .leading)
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
                .font(.system(size: 12))
                .foregroundColor(isHovering ? color : .secondary)
                .frame(width: 24, height: 24)
                .background(isHovering ? color.opacity(0.1) : Color.clear)
                .cornerRadius(6)
        }
        .buttonStyle(.plain)
        .help(help)
        .onHover { isHovering = $0 }
    }
}
