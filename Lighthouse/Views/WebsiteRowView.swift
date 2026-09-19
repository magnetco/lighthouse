import SwiftUI

struct WebsiteRowView: View {
    let website: WebsiteInfo
    let onOpen: () -> Void
    let onCopy: () -> Void
    let onRemove: () -> Void
    let onSave: (String) -> Void
    let onToggleStar: () -> Void
    
    @State private var isHovering = false
    @State private var showingTooltip = false
    @State private var isEditing = false
    @State private var editingName = ""
    @State private var showSuccess = false
    @State private var showError = false
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            // Star — keep filled always; empty only on hover to reduce chrome
            Button(action: onToggleStar) {
                Image(systemName: website.isStarred ? "star.fill" : "star")
                    .font(.system(size: 11))
                    .foregroundColor(website.isStarred ? Theme.star : Theme.textMuted)
                    .opacity(website.isStarred || isHovering ? 1 : 0)
            }
            .buttonStyle(.plain)
            .frame(width: 18)
            .help(website.isStarred ? "Remove from favorites" : "Add to favorites")
            
            // Framework/Globe icon
            frameworkIcon
                .frame(width: 20, alignment: .center)
            
            // Status + latency
            HStack(spacing: 6) {
                Circle()
                    .fill(statusDotColor)
                    .frame(width: 7, height: 7)
                    .shadow(color: statusDotColor.opacity(0.4), radius: 2, x: 0, y: 0)
                
                Group {
                    if let latestPing = website.latestPing, latestPing.isReachable {
                        Text(latestPing.responseTimeMs)
                            .font(.system(size: Theme.secondaryLabelSize, design: .monospaced))
                            .foregroundColor(responseTimeColor(latestPing.responseTime))
                    } else {
                        Text("--")
                            .font(.system(size: Theme.secondaryLabelSize, design: .monospaced))
                            .foregroundColor(Theme.textMuted)
                    }
                }
                .frame(minWidth: 44, alignment: .leading)
            }
            .onHover { hovering in
                showingTooltip = hovering
            }
            .popover(isPresented: $showingTooltip, arrowEdge: .trailing) {
                pingTooltip
                    .padding(12)
            }
            
            // Site name — flexible, primary hierarchy
            Group {
                if isEditing {
                    HStack(spacing: 4) {
                        TextField("Display name", text: $editingName)
                            .textFieldStyle(.plain)
                            .font(.system(size: Theme.primaryLabelSize, weight: .medium))
                            .foregroundColor(Theme.textPrimary)
                            .focused($isTextFieldFocused)
                            .onSubmit {
                                saveEdit()
                            }
                        
                        Button {
                            saveEdit()
                        } label: {
                            Image(systemName: "checkmark")
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundColor(Theme.success)
                        }
                        .buttonStyle(.plain)
                        .help("Save")
                        
                        Button {
                            cancelEdit()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 8, weight: .semibold))
                                .foregroundColor(Theme.textTertiary)
                        }
                        .buttonStyle(.plain)
                        .help("Cancel")
                    }
                } else {
                    HStack(spacing: 4) {
                        Text(website.effectiveDisplayName)
                            .font(.system(size: Theme.primaryLabelSize, weight: .semibold))
                            .foregroundColor(Theme.textPrimary)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        
                        if showSuccess {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 10))
                                .foregroundColor(Theme.success)
                                .transition(.scale.combined(with: .opacity))
                        }
                        
                        if showError {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 10))
                                .foregroundColor(Theme.warning)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                }
            }
            .frame(minWidth: 100, maxWidth: 200, alignment: .leading)
            .layoutPriority(2)
            
            // Hostname — flexible; prefer showing the start of the host
            Text(website.cleanedURL)
                .font(.system(size: Theme.secondaryLabelSize))
                .foregroundColor(Theme.textSecondary)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(minWidth: 100, maxWidth: .infinity, alignment: .leading)
                .layoutPriority(1)
            
            // Actions — hover (or edit) only to reduce competing chrome
            HStack(spacing: 4) {
                if !isEditing && isHovering {
                    IconButton(icon: "safari", help: "Open in browser", action: onOpen)
                    IconButton(icon: "doc.on.doc", help: "Copy URL", action: onCopy)
                    IconButton(icon: "pencil", help: "Edit", action: startEdit)
                    IconButton(icon: "xmark.circle.fill", help: "Remove", color: Theme.error, action: onRemove)
                }
            }
            .frame(width: isHovering || isEditing ? 108 : 0, alignment: .trailing)
            .animation(.easeInOut(duration: 0.12), value: isHovering)
        }
        .padding(.horizontal, Theme.panelHorizontalPadding)
        .padding(.vertical, Theme.rowVerticalPadding)
        .background(isHovering ? Theme.hoverBackground : Color.clear)
        .contentShape(Rectangle())
        .onHover { isHovering = $0 }
        .contextMenu {
            Button(action: onToggleStar) {
                Label(
                    website.isStarred ? "Remove from Favorites" : "Add to Favorites",
                    systemImage: website.isStarred ? "star.slash" : "star"
                )
            }
            Divider()
            Button("Open in Browser") { onOpen() }
            Button("Copy URL") { onCopy() }
            Divider()
            Button("Edit Name") { startEdit() }
            Button("Remove", role: .destructive) { onRemove() }
        }
    }
    
    private var statusDotColor: Color {
        guard let status = website.lastPingStatus else {
            return Theme.textMuted
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
                        .opacity(0.85)
                } else {
                    // Use SF Symbol
                    Image(systemName: iconInfo.fallbackSymbol)
                        .font(.system(size: 12))
                        .foregroundColor(Theme.iconDefault)
                }
            } else {
                // External website - show globe icon
                let iconInfo = FrameworkIconMapper.externalWebsiteIcon()
                Image(systemName: iconInfo.name)
                    .font(.system(size: 12))
                    .foregroundColor(Theme.iconDefault)
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
                                .foregroundColor(index == 0 ? Theme.textPrimary : Theme.textSecondary)
                                .frame(width: 60, alignment: .leading)
                            
                            Text(ping.statusDescription)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(ping.isReachable ? Theme.textPrimary : Theme.error)
                            
                            Text("•")
                                .foregroundColor(Theme.textSecondary)
                                .font(.system(size: 11))
                            
                            Text(ping.responseTimeMs)
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(Theme.textSecondary)
                        }
                    }
                }
                
                if website.recentPings.count > 1 {
                    SolidDivider()
                        .padding(.vertical, 4)
                    
                    // Summary stats
                    HStack(spacing: 12) {
                        if let avgTime = website.averageResponseTimeMs {
                            HStack(spacing: 4) {
                                Text("Avg:")
                                    .font(.system(size: 11))
                                    .foregroundColor(Theme.textSecondary)
                                Text(avgTime)
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(Theme.textPrimary)
                            }
                        }
                        
                        if let uptime = website.uptimeString {
                            HStack(spacing: 4) {
                                Text("•")
                                    .foregroundColor(Theme.textSecondary)
                                Text("Uptime:")
                                    .font(.system(size: 11))
                                    .foregroundColor(Theme.textSecondary)
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
                    .foregroundColor(Theme.textSecondary)
            }
        }
        .frame(minWidth: 250)
        .background(Theme.windowBackground)
    }
    
    private func statusColor(_ status: PingStatus) -> Color {
        switch status {
        case .healthy:
            return Theme.success
        case .warning:
            return Theme.warning
        case .error:
            return Theme.error
        case .unknown:
            return Theme.textMuted
        }
    }
    
    private func uptimeColor(_ percentage: Double) -> Color {
        if percentage >= 95 {
            return Theme.success
        } else if percentage >= 80 {
            return Theme.warning
        } else {
            return Theme.error
        }
    }
    
    private func responseTimeColor(_ responseTime: TimeInterval) -> Color {
        let ms = responseTime * 1000
        if ms < 200 {
            return Theme.textSecondary
        } else if ms < 500 {
            return Theme.warning
        } else {
            return Theme.error
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
