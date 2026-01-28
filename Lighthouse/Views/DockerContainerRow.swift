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
            
            VStack(alignment: .leading, spacing: 4) {
                // Container name
                Text(container.displayName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.primary)
                
                // Image name
                Text(container.shortImage)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary.opacity(0.7))
                
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
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
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
                    IconButton(icon: "stop.fill", help: "Stop", color: .orange, action: onStop)
                    IconButton(icon: "arrow.clockwise", help: "Restart", action: onRestart)
                } else {
                    IconButton(icon: "play.fill", help: "Start", color: .green, action: onStart)
                }
                IconButton(icon: "trash", help: "Remove", color: .red, action: onRemove)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(isHovering ? Color.primary.opacity(0.03) : Color.clear)
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
        case .running: return .green
        case .paused: return .yellow
        case .exited, .dead: return .red
        case .restarting: return .orange
        default: return .gray
        }
    }
}
