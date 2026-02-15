import SwiftUI

struct DockerContainerRow: View {
    let container: DockerContainer
    let onStart: () -> Void
    let onStop: () -> Void
    let onRestart: () -> Void
    let onRemove: () -> Void
    let onOpenPort: (Int) -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Status indicator
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
                .shadow(color: statusColor.opacity(0.4), radius: 2, x: 0, y: 0)
            
            VStack(alignment: .leading, spacing: 4) {
                // Container name
                Text(container.displayName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Theme.textPrimary)
                
                // Image name
                Text(container.shortImage)
                    .font(.system(size: 10))
                    .foregroundColor(Theme.textSecondary)
                
                // Ports
                if !container.ports.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(container.ports.filter { $0.hostPort != nil }, id: \.self) { port in
                            if let hostPort = port.hostPort {
                                Button {
                                    onOpenPort(hostPort)
                                } label: {
                                    HStack(spacing: 3) {
                                        Image(systemName: "network")
                                            .font(.system(size: 8))
                                        Text("\(hostPort)")
                                            .font(.system(size: 10, design: .monospaced))
                                    }
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Theme.accent.opacity(0.2))
                                    .foregroundColor(Theme.accent)
                                    .cornerRadius(4)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            
            Spacer()
            
            // Actions
            HStack(spacing: 4) {
                if container.isRunning {
                    IconButton(icon: "stop.fill", help: "Stop", color: Theme.warning, action: onStop)
                    IconButton(icon: "arrow.clockwise", help: "Restart", action: onRestart)
                } else {
                    IconButton(icon: "play.fill", help: "Start", color: Theme.success, action: onStart)
                }
                IconButton(icon: "trash", help: "Remove", color: Theme.error, action: onRemove)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(isHovering ? Theme.hoverBackground : Color.clear)
        .onHover { isHovering = $0 }
        .contextMenu {
            if container.isRunning {
                Button("Stop Container") { onStop() }
                Button("Restart Container") { onRestart() }
            } else {
                Button("Start Container") { onStart() }
            }
            Divider()
            Button("Remove Container", role: .destructive) { onRemove() }
        }
    }
    
    private var statusColor: Color {
        switch container.status {
        case .running: return Theme.success
        case .paused: return Theme.star
        case .exited, .dead: return Theme.error
        case .restarting: return Theme.warning
        default: return Theme.textMuted
        }
    }
}
