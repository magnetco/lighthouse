import SwiftUI

struct LogViewerSheet: View {
    let port: PortInfo
    @Environment(\.dismiss) private var dismiss
    @State private var logs: [String] = []
    @State private var isLoading = true
    @State private var autoScroll = true
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ship's Log")
                        .font(.system(size: 16, weight: .semibold))
                    
                    HStack(spacing: 8) {
                        Text(port.displayName)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .foregroundColor(.secondary.opacity(0.5))
                        
                        Text("Port \(port.port)")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .foregroundColor(.secondary.opacity(0.5))
                        
                        Text("PID \(port.pid)")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Toggle(isOn: $autoScroll) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.down.to.line")
                            .font(.system(size: 10))
                        Text("Auto-scroll")
                            .font(.system(size: 11))
                    }
                }
                .toggleStyle(.switch)
                .controlSize(.mini)
                
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(16)
            
            Divider()
            
            // Log content
            if isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Loading logs...")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if logs.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 32))
                        .foregroundColor(.secondary.opacity(0.5))
                    
                    Text("No logs available")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text("System logs for this process may not be accessible")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            ForEach(Array(logs.enumerated()), id: \.offset) { index, line in
                                LogLineView(line: line, index: index)
                                    .id(index)
                            }
                        }
                        .padding(12)
                    }
                    .background(Color(nsColor: .textBackgroundColor))
                    .onChange(of: logs.count) { _ in
                        if autoScroll && !logs.isEmpty {
                            withAnimation {
                                proxy.scrollTo(logs.count - 1, anchor: .bottom)
                            }
                        }
                    }
                }
            }
            
            Divider()
            
            // Footer
            HStack {
                Text("\(logs.count) lines")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary.opacity(0.7))
                
                Spacer()
                
                Button("Refresh") {
                    Task {
                        await loadLogs()
                    }
                }
                .buttonStyle(.plain)
                .font(.system(size: 11))
                
                Button("Copy All") {
                    let text = logs.joined(separator: "\n")
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(text, forType: .string)
                }
                .buttonStyle(.plain)
                .font(.system(size: 11))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .frame(width: 700, height: 500)
        .task {
            await loadLogs()
        }
    }
    
    private func loadLogs() async {
        isLoading = true
        logs = await ProcessLogReader.getRecentLogs(for: port.pid, processName: port.processName)
        isLoading = false
    }
}

struct LogLineView: View {
    let line: String
    let index: Int
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("\(index + 1)")
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.secondary.opacity(0.5))
                .frame(width: 40, alignment: .trailing)
            
            Text(line)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(lineColor)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 2)
    }
    
    private var lineColor: Color {
        let lowercased = line.lowercased()
        if lowercased.contains("error") || lowercased.contains("fail") {
            return .red
        } else if lowercased.contains("warn") {
            return .orange
        } else if lowercased.contains("info") {
            return .blue
        } else {
            return .primary
        }
    }
}
