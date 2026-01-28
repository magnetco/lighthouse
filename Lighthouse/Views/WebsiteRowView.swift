import SwiftUI

struct WebsiteRowView: View {
    let website: WebsiteInfo
    let onOpen: () -> Void
    let onCopy: () -> Void
    let onRemove: () -> Void
    let onSave: (String) -> Void
    
    @State private var isHovering = false
    @State private var showingTooltip = false
    @State private var isEditing = false
    @State private var editingName = ""
    @State private var showSuccess = false
    @State private var showError = false
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            // Framework/Globe icon - fixed width
            frameworkIcon
                .frame(width: 24, alignment: .center)
            
            // Status indicator dot - fixed position
            Circle()
                .fill(statusDotColor)
                .frame(width: 7, height: 7)
                .shadow(color: statusDotColor.opacity(0.3), radius: 1.5, x: 0, y: 0)
                .frame(width: 18)
            
            // Response time - fixed width (matches port number position)
            Group {
                if let latestPing = website.latestPing, latestPing.isReachable {
                    Text(latestPing.responseTimeMs)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(responseTimeColor(latestPing.responseTime))
                } else {
                    Text("--")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.primary.opacity(0.3))
                }
            }
            .frame(width: 60, alignment: .leading)
            .onHover { hovering in
                showingTooltip = hovering
            }
            .popover(isPresented: $showingTooltip, arrowEdge: .trailing) {
                pingTooltip
                    .padding(12)
            }
            
            // Website name - fixed width with inline editing
            Group {
                if isEditing {
                    HStack(spacing: 4) {
                        TextField("Display name", text: $editingName)
                            .textFieldStyle(.plain)
                            .font(.system(size: 12, weight: .medium))
                            .focused($isTextFieldFocused)
                            .onSubmit {
                                saveEdit()
                            }
                            .frame(width: 130)
                        
                        // Save button
                        Button {
                            saveEdit()
                        } label: {
                            Image(systemName: "checkmark")
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundColor(.green.opacity(0.8))
                        }
                        .buttonStyle(.plain)
                        .help("Save")
                        
                        // Cancel button
                        Button {
                            cancelEdit()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 8, weight: .semibold))
                                .foregroundColor(.primary.opacity(0.5))
                        }
                        .buttonStyle(.plain)
                        .help("Cancel")
                    }
                    .frame(width: 180, alignment: .leading)
                } else {
                    HStack(spacing: 4) {
                        Text(website.effectiveDisplayName)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        
                        if showSuccess {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.green.opacity(0.7))
                                .transition(.scale.combined(with: .opacity))
                        }
                        
                        if showError {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.orange.opacity(0.7))
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .frame(width: 180, alignment: .leading)
                }
            }
            
            // URL - fixed width
            Text(website.cleanedURL)
                .font(.system(size: 11))
                .foregroundColor(.secondary.opacity(0.8))
                .frame(width: 120, alignment: .leading)
                .lineLimit(1)
                .truncationMode(.middle)
            
            Spacer()
            
            // Actions - always visible, fixed width
            HStack(spacing: 6) {
                if !isEditing {
                    IconButton(icon: "safari", help: "Open in browser", action: onOpen)
                    IconButton(icon: "doc.on.doc", help: "Copy URL", action: onCopy)
                    IconButton(icon: "pencil", help: "Edit", action: startEdit)
                    IconButton(icon: "xmark.circle.fill", help: "Remove", color: .red, action: onRemove)
                }
            }
            .frame(width: 110, alignment: .trailing)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(isHovering ? Color.primary.opacity(0.03) : Color.clear)
        .contentShape(Rectangle())
        .onHover { isHovering = $0 }
        .contextMenu {
            Button("Open in Browser") { onOpen() }
            Button("Copy URL") { onCopy() }
            Divider()
            Button("Edit Name") { startEdit() }
            Button("Remove", role: .destructive) { onRemove() }
        }
    }
    
    private var statusDotColor: Color {
        guard let status = website.lastPingStatus else {
            return .gray.opacity(0.3)
        }
        return statusColor(status)
    }
    
    private var frameworkIcon: some View {
        Group {
            if website.isInternalWebsite {
                // Internal website - show framework icon
                let iconInfo = FrameworkIconMapper.iconInfo(for: website.detectedFramework)
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
            } else {
                // External website - show globe icon
                let iconInfo = FrameworkIconMapper.externalWebsiteIcon()
                Image(systemName: iconInfo.name)
                    .font(.system(size: 12))
                    .foregroundColor(.primary.opacity(0.5))
            }
        }
    }
    
    private func animatedOpacity(for status: PingStatus) -> Double {
        switch status {
        case .error:
            return 0.6 // Will pulse between 0.6 and 1.0
        case .warning:
            return 0.7 // Will pulse between 0.7 and 1.0
        default:
            return 1.0 // Steady
        }
    }
    
    private var pingTooltip: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Recent pings
            if !website.recentPings.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(website.recentPings.enumerated()), id: \.offset) { index, ping in
                        HStack(spacing: 8) {
                            Text(index == 0 ? "Latest:" : ping.timeAgo)
                                .font(.system(size: 11, weight: index == 0 ? .semibold : .regular))
                                .foregroundColor(index == 0 ? .primary : .secondary)
                                .frame(width: 60, alignment: .leading)
                            
                            Text(ping.statusDescription)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(ping.isReachable ? .primary : .red)
                            
                            Text("•")
                                .foregroundColor(.secondary)
                                .font(.system(size: 11))
                            
                            Text(ping.responseTimeMs)
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                if website.recentPings.count > 1 {
                    Divider()
                        .padding(.vertical, 4)
                    
                    // Summary stats
                    HStack(spacing: 12) {
                        if let avgTime = website.averageResponseTimeMs {
                            HStack(spacing: 4) {
                                Text("Avg:")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                                Text(avgTime)
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(.primary)
                            }
                        }
                        
                        if let uptime = website.uptimeString {
                            HStack(spacing: 4) {
                                Text("•")
                                    .foregroundColor(.secondary)
                                Text("Uptime:")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                                Text(uptime)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(uptimeColor(website.uptimePercentage ?? 0))
                            }
                        }
                    }
                }
            } else {
                Text("No ping data yet")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
        }
        .frame(minWidth: 250)
    }
    
    private func statusColor(_ status: PingStatus) -> Color {
        switch status {
        case .healthy:
            return .green
        case .warning:
            return .orange
        case .error:
            return .red
        case .unknown:
            return .gray
        }
    }
    
    private func uptimeColor(_ percentage: Double) -> Color {
        if percentage >= 95 {
            return .green
        } else if percentage >= 80 {
            return .orange
        } else {
            return .red
        }
    }
    
    private func responseTimeColor(_ responseTime: TimeInterval) -> Color {
        let ms = responseTime * 1000
        if ms < 200 {
            return .primary.opacity(0.6)
        } else if ms < 500 {
            return .orange.opacity(0.8)
        } else {
            return .red.opacity(0.8)
        }
    }
    
    private func startEdit() {
        editingName = website.displayName
        isEditing = true
        isTextFieldFocused = true
    }
    
    private func cancelEdit() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isEditing = false
            editingName = ""
            showError = false
        }
    }
    
    private func saveEdit() {
        let trimmedName = editingName.trimmingCharacters(in: .whitespaces)
        
        withAnimation(.easeInOut(duration: 0.2)) {
            isEditing = false
            onSave(trimmedName)
            
            // Show success indicator
            showSuccess = true
            showError = false
        }
        
        // Hide success indicator after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showSuccess = false
            }
        }
    }
}
