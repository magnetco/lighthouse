import SwiftUI

struct WebhookSettingsView: View {
    @ObservedObject var viewModel: PortViewModel
    @State private var showingAddWebhook = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Webhook Integrations")
                    .font(.system(size: 14, weight: .semibold))
                
                Spacer()
                
                Button {
                    showingAddWebhook = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 16))
                }
                .buttonStyle(.plain)
                .help("Add webhook")
            }
            .padding()
            
            Divider()
            
            // Webhooks list
            if viewModel.webhooks.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "link.badge.plus")
                        .font(.system(size: 32))
                        .foregroundColor(.secondary.opacity(0.5))
                    
                    Text("No webhooks configured")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    Text("Add webhooks to receive notifications in Slack, Discord, or custom endpoints")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.vertical, 40)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.webhooks) { webhook in
                            WebhookRowView(
                                webhook: webhook,
                                onToggle: {
                                    var updated = webhook
                                    updated.isEnabled.toggle()
                                    viewModel.updateWebhook(updated)
                                },
                                onTest: {
                                    Task {
                                        _ = await viewModel.testWebhook(webhook)
                                    }
                                },
                                onRemove: {
                                    viewModel.removeWebhook(id: webhook.id)
                                }
                            )
                            
                            if webhook.id != viewModel.webhooks.last?.id {
                                Divider()
                            }
                        }
                    }
                }
            }
        }
        .frame(width: 500, height: 400)
        .sheet(isPresented: $showingAddWebhook) {
            AddWebhookSheet { webhook in
                viewModel.addWebhook(webhook)
                showingAddWebhook = false
            }
        }
    }
}

struct WebhookRowView: View {
    let webhook: WebhookConfig
    let onToggle: () -> Void
    let onTest: () -> Void
    let onRemove: () -> Void
    
    @State private var isHovering = false
    @State private var isTesting = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Type icon
            Image(systemName: typeIcon)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(webhook.name)
                    .font(.system(size: 12, weight: .medium))
                
                Text(webhook.url)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            
            Spacer()
            
            // Actions
            HStack(spacing: 8) {
                Button {
                    isTesting = true
                    onTest()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        isTesting = false
                    }
                } label: {
                    if isTesting {
                        ProgressView()
                            .scaleEffect(0.6)
                            .frame(width: 16, height: 16)
                    } else {
                        Image(systemName: "paperplane")
                            .font(.system(size: 11))
                    }
                }
                .buttonStyle(.plain)
                .help("Test webhook")
                
                Toggle("", isOn: Binding(
                    get: { webhook.isEnabled },
                    set: { _ in onToggle() }
                ))
                .toggleStyle(.switch)
                .labelsHidden()
                .scaleEffect(0.7)
                
                Button {
                    onRemove()
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 11))
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
                .help("Remove webhook")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(isHovering ? Color.primary.opacity(0.03) : Color.clear)
        .onHover { isHovering = $0 }
    }
    
    private var typeIcon: String {
        switch webhook.type {
        case .slack:
            return "message.fill"
        case .discord:
            return "bubble.left.and.bubble.right.fill"
        case .generic:
            return "link.circle.fill"
        }
    }
}

struct AddWebhookSheet: View {
    let onAdd: (WebhookConfig) -> Void
    
    @State private var name = ""
    @State private var url = ""
    @State private var type: WebhookType = .slack
    @State private var triggerOnDown = true
    @State private var triggerOnRecovery = true
    @State private var triggerOnWarning = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Add Webhook")
                    .font(.system(size: 14, weight: .semibold))
                
                Spacer()
                
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.plain)
                .font(.system(size: 11))
            }
            .padding()
            
            Divider()
            
            // Form
            Form {
                Section {
                    TextField("Name", text: $name)
                        .textFieldStyle(.roundedBorder)
                    
                    Picker("Type", selection: $type) {
                        ForEach(WebhookType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    TextField("Webhook URL", text: $url)
                        .textFieldStyle(.roundedBorder)
                }
                
                Section("Trigger Events") {
                    Toggle("Site goes down", isOn: $triggerOnDown)
                    Toggle("Site recovers", isOn: $triggerOnRecovery)
                    Toggle("Site has warnings", isOn: $triggerOnWarning)
                }
            }
            .formStyle(.grouped)
            .padding()
            
            Divider()
            
            // Footer
            HStack {
                Spacer()
                
                Button("Add Webhook") {
                    let webhook = WebhookConfig(
                        name: name,
                        url: url,
                        type: type,
                        triggerOnDown: triggerOnDown,
                        triggerOnRecovery: triggerOnRecovery,
                        triggerOnWarning: triggerOnWarning
                    )
                    onAdd(webhook)
                }
                .buttonStyle(.borderedProminent)
                .disabled(name.isEmpty || url.isEmpty)
            }
            .padding()
        }
        .frame(width: 450, height: 400)
    }
}
