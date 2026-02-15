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
                        .foregroundColor(Theme.textPrimary)
                    
                    HStack(spacing: 8) {
                        Text(port.displayName)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Theme.textSecondary)
                        
                        Text("•")
                            .foregroundColor(Theme.textMuted)
                        
                        Text("Port \(port.port)")
                            .font(.system(size: 12))
                            .foregroundColor(Theme.textSecondary)
                        
                        Text("•")
                            .foregroundColor(Theme.textMuted)
                        
                        Text("PID \(port.pid)")
                            .font(.system(size: 12))
                            .foregroundColor(Theme.textSecondary)
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
                    .foregroundColor(Theme.textSecondary)
                }
                .toggleStyle(.switch)
                .controlSize(.mini)
                
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Theme.iconDefault)
                }
                .buttonStyle(.plain)
            }
            .padding(16)
            .background(Theme.headerGradient)
            
            SolidDivider()
            
            // Log content
            if isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Loading logs...")
                        .font(.system(size: 12))
                        .foregroundColor(Theme.textSecondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if logs.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 32))
                        .foregroundColor(Theme.textMuted)
                    
                    Text("No logs available")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Theme.textSecondary)
                    
                    Text("System logs for this process may not be accessible")
                        .font(.system(size: 11))
                        .foregroundColor(Theme.textTertiary)
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
                    .background(Theme.inputBackground)
                    .onChange(of: logs.count) { _ in
                        if autoScroll && !logs.isEmpty {
                            withAnimation {
                                proxy.scrollTo(logs.count - 1, anchor: .bottom)
                            }
                        }
                    }
                }
            }
            
            SolidDivider()
            
            // Footer
            HStack {
                Text("\(logs.count) lines")
                    .font(.system(size: 10))
                    .foregroundColor(Theme.textTertiary)
                
                Spacer()
                
                Button("Refresh") {
                    Task {
                        await loadLogs()
                    }
                }
                .buttonStyle(.plain)
                .font(.system(size: 11))
                .foregroundColor(Theme.textSecondary)
                
                Button("Copy All") {
                    let text = logs.joined(separator: "\n")
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(text, forType: .string)
                }
                .buttonStyle(.plain)
                .font(.system(size: 11))
                .foregroundColor(Theme.textSecondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Theme.headerBackground)
        }
        .frame(width: 700, height: 500)
        .background(Theme.windowBackground)
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
                .foregroundColor(Theme.textMuted)
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
            return Theme.error
        } else if lowercased.contains("warn") {
            return Theme.warning
        } else if lowercased.contains("info") {
            return Theme.accent
        } else {
            return Theme.textPrimary
        }
    }
}
