import SwiftUI

struct ProjectGroupView: View {
    let group: ProjectGroup
    let isExpanded: Bool
    let onToggleExpand: () -> Void
    let onOpen: (PortInfo) -> Void
    let onCopy: (PortInfo) -> Void
    let onKill: (PortInfo) -> Void
    let onOpenFolder: (PortInfo) -> Void
    let onOpenInEditor: (PortInfo, String) -> Void
    let onOpenInTerminal: (PortInfo) -> Void
    let onToggleStar: (PortInfo) -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Group header
            Button(action: onToggleExpand) {
                HStack(spacing: 8) {
                    // Expand/collapse chevron
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(Theme.textMuted)
                        .frame(width: 12)
                    
                    // Project icon
                    if let icon = group.mapping?.icon {
                        Image(systemName: icon)
                            .font(.system(size: 11))
                            .foregroundColor(group.isUnknown ? Theme.textMuted : Theme.accent)
                    } else {
                        Image(systemName: group.isUnknown ? "questionmark.folder" : "folder.fill")
                            .font(.system(size: 11))
                            .foregroundColor(group.isUnknown ? Theme.textMuted : Theme.accent)
                    }
                    
                    // Project name
                    Text(group.name)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(group.isUnknown ? Theme.textSecondary : Theme.textPrimary)
                    
                    // Port count badge
                    Text("\(group.ports.count)")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(Theme.textMuted)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Theme.sectionBackground)
                        .cornerRadius(4)
                    
                    Spacer()
                    
                    // Status indicators
                    HStack(spacing: 4) {
                        ForEach(group.ports.prefix(5)) { port in
                            Circle()
                                .fill(Theme.success)
                                .frame(width: 5, height: 5)
                        }
                        if group.ports.count > 5 {
                            Text("+\(group.ports.count - 5)")
                                .font(.system(size: 8))
                                .foregroundColor(Theme.textMuted)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(isHovering ? Theme.hoverBackground : Theme.sectionBackground)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .onHover { isHovering = $0 }
            
            // Expanded port list
            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(group.ports) { port in
                        PortRowView(
                            port: port,
                            onOpen: { onOpen(port) },
                            onCopy: { onCopy(port) },
                            onKill: { onKill(port) },
                            onOpenFolder: { onOpenFolder(port) },
                            onOpenInEditor: { app in onOpenInEditor(port, app) },
                            onOpenInTerminal: { onOpenInTerminal(port) },
                            onToggleStar: { onToggleStar(port) }
                        )
                        
                        if port.id != group.ports.last?.id {
                            SolidDivider()
                                .padding(.leading, 44)
                        }
                    }
                }
            }
        }
    }
}

struct GroupedPortListView: View {
    @ObservedObject var viewModel: PortViewModel
    
    var body: some View {
        LazyVStack(spacing: 0) {
            ForEach(viewModel.groupedPorts) { group in
                ProjectGroupView(
                    group: group,
                    isExpanded: viewModel.isGroupExpanded(group.id),
                    onToggleExpand: { viewModel.toggleGroupExpanded(group.id) },
                    onOpen: { viewModel.openInBrowser(port: $0) },
                    onCopy: { viewModel.copyURL(port: $0) },
                    onKill: { port in Task { await viewModel.killProcess(port: port) } },
                    onOpenFolder: { viewModel.openInFinder(port: $0) },
                    onOpenInEditor: { port, app in viewModel.openInEditor(port: port, app: app) },
                    onOpenInTerminal: { viewModel.openInTerminal(port: $0) },
                    onToggleStar: { viewModel.togglePortStar($0) }
                )
                
                if group.id != viewModel.groupedPorts.last?.id {
                    SolidDivider()
                }
            }
        }
    }
}
