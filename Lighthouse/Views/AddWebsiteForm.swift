import SwiftUI

struct AddWebsiteForm: View {
    @Binding var isExpanded: Bool
    let onAdd: (String, String, Bool?, String?) async -> Void // url, name, isInternal, framework
    
    @State private var urlText = ""
    @State private var nameText = ""
    @State private var isAdding = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isInternalOverride: Bool? = nil // nil = auto-detect
    @State private var selectedFramework: String? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            if isExpanded {
                expandedForm
            } else {
                collapsedButton
            }
        }
    }
    
    private var collapsedButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                isExpanded = true
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "plus.circle")
                    .font(.system(size: 11))
                    .foregroundColor(.primary.opacity(0.4))
                
                Text("Add Site")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.primary.opacity(0.5))
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(Color.primary.opacity(0.02))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    private var expandedForm: some View {
        VStack(spacing: 10) {
            // URL and Name in one row
            HStack(spacing: 12) {
                TextField("https://example.com", text: $urlText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 11))
                    .disabled(isAdding)
                    .frame(maxWidth: .infinity)
                
                TextField("Display name (optional)", text: $nameText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 11))
                    .disabled(isAdding)
                    .frame(width: 150)
                
                // Action buttons inline
                HStack(spacing: 6) {
                    Button {
                        Task {
                            await addWebsite()
                        }
                    } label: {
                        if isAdding {
                            ProgressView()
                                .scaleEffect(0.5)
                                .frame(width: 16, height: 16)
                        } else {
                            Image(systemName: "checkmark")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.primary.opacity(0.6))
                        }
                    }
                    .buttonStyle(.plain)
                    .disabled(isAdding || !isValidInput)
                    .help("Add")
                    
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            resetForm()
                            isExpanded = false
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(.primary.opacity(0.4))
                    }
                    .buttonStyle(.plain)
                    .disabled(isAdding)
                    .help("Cancel")
                }
            }
            
            // Internal website options
            if isDetectedAsInternal && !urlText.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 9))
                        .foregroundColor(.blue.opacity(0.6))
                    
                    Text("Internal website detected")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Menu {
                        Button("Auto-detect") { selectedFramework = nil }
                        Divider()
                        Button("Next.js") { selectedFramework = "Next.js" }
                        Button("Vite") { selectedFramework = "Vite" }
                        Button("React") { selectedFramework = "React" }
                        Button("Django") { selectedFramework = "Django" }
                        Button("Flask") { selectedFramework = "Flask" }
                        Button("Node.js") { selectedFramework = "Node.js" }
                        Button("Other") { selectedFramework = nil }
                    } label: {
                        HStack(spacing: 4) {
                            Text(selectedFramework ?? "Framework")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 8))
                                .foregroundColor(.secondary)
                        }
                    }
                    .menuStyle(.borderlessButton)
                }
            }
            
            // Error message
            if showError {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 9))
                        .foregroundColor(.orange.opacity(0.7))
                    
                    Text(errorMessage)
                        .font(.system(size: 10))
                        .foregroundColor(.orange.opacity(0.7))
                    
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(Color.primary.opacity(0.02))
    }
    
    private var isValidInput: Bool {
        !urlText.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private var isDetectedAsInternal: Bool {
        let normalizedURL = WebsiteMonitor.normalizeURL(urlText.trimmingCharacters(in: .whitespaces))
        let lowercased = normalizedURL.lowercased()
        return lowercased.contains("localhost") || 
               lowercased.contains("127.0.0.1") ||
               lowercased.contains("192.168.") ||
               lowercased.contains("10.") ||
               lowercased.range(of: "172\\.(1[6-9]|2[0-9]|3[0-1])\\.", options: .regularExpression) != nil
    }
    
    private func addWebsite() async {
        let trimmedURL = urlText.trimmingCharacters(in: .whitespaces)
        let trimmedName = nameText.trimmingCharacters(in: .whitespaces)
        
        // Validate URL
        let normalizedURL = WebsiteMonitor.normalizeURL(trimmedURL)
        guard WebsiteMonitor.isValidURL(normalizedURL) else {
            errorMessage = "Please enter a valid URL"
            showError = true
            return
        }
        
        showError = false
        isAdding = true
        
        await onAdd(trimmedURL, trimmedName, isInternalOverride, selectedFramework)
        
        isAdding = false
        
        // Reset and collapse
        withAnimation(.easeInOut(duration: 0.2)) {
            resetForm()
            isExpanded = false
        }
    }
    
    private func resetForm() {
        urlText = ""
        nameText = ""
        showError = false
        errorMessage = ""
        isInternalOverride = nil
        selectedFramework = nil
    }
}
