# Webhook Integrations

**Category:** Feature
**Priority:** P2 Medium
**Effort:** L
**Status:** Not Started

## Summary

Add webhook integration to send notifications to external services (Slack, Discord, custom URLs) when website status changes or services go down. This enables team visibility and integration with existing alerting workflows.

## Acceptance Criteria

- [ ] Configure webhook URL in preferences
- [ ] Support for Slack webhook format
- [ ] Support for Discord webhook format
- [ ] Support for generic JSON webhook
- [ ] Test webhook button to verify configuration
- [ ] Webhook triggers on website status changes
- [ ] Webhook triggers on critical errors
- [ ] Rate limiting to prevent spam
- [ ] Option to enable/disable per website

## Technical Notes

### Webhook Types

| Service | Webhook Format | Endpoint |
|---------|----------------|----------|
| Slack | Slack Block Kit | `https://hooks.slack.com/services/...` |
| Discord | Discord Embeds | `https://discord.com/api/webhooks/...` |
| Generic | Custom JSON | Any HTTPS endpoint |

### Data Model

```swift
// Models/WebhookConfig.swift
struct WebhookConfig: Codable, Identifiable {
    var id: UUID
    var name: String
    var url: String
    var type: WebhookType
    var isEnabled: Bool
    var triggerOnDown: Bool
    var triggerOnRecovery: Bool
    var triggerOnWarning: Bool
}

enum WebhookType: String, Codable {
    case slack
    case discord
    case generic
}
```

### Webhook Service

```swift
// Services/WebhookService.swift
class WebhookService {
    static let shared = WebhookService()
    
    func send(event: WebhookEvent, to config: WebhookConfig) async throws {
        let payload = formatPayload(event: event, type: config.type)
        
        var request = URLRequest(url: URL(string: config.url)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(payload)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw WebhookError.deliveryFailed
        }
    }
    
    private func formatPayload(event: WebhookEvent, type: WebhookType) -> Data {
        switch type {
        case .slack:
            return formatSlackPayload(event)
        case .discord:
            return formatDiscordPayload(event)
        case .generic:
            return formatGenericPayload(event)
        }
    }
}
```

### Slack Payload Format

```swift
func formatSlackPayload(_ event: WebhookEvent) -> [String: Any] {
    [
        "blocks": [
            [
                "type": "section",
                "text": [
                    "type": "mrkdwn",
                    "text": event.isDown 
                        ? "🔴 *\(event.websiteName)* is DOWN"
                        : "🟢 *\(event.websiteName)* has recovered"
                ]
            ],
            [
                "type": "context",
                "elements": [
                    [
                        "type": "mrkdwn",
                        "text": "URL: \(event.url) | Response: \(event.responseTime ?? "N/A")ms"
                    ]
                ]
            ]
        ]
    ]
}
```

### Discord Payload Format

```swift
func formatDiscordPayload(_ event: WebhookEvent) -> [String: Any] {
    [
        "embeds": [
            [
                "title": event.isDown ? "🔴 Site Down" : "🟢 Site Recovered",
                "description": event.websiteName,
                "color": event.isDown ? 0xFF0000 : 0x00FF00,
                "fields": [
                    ["name": "URL", "value": event.url, "inline": true],
                    ["name": "Response", "value": "\(event.responseTime ?? 0)ms", "inline": true]
                ],
                "timestamp": ISO8601DateFormatter().string(from: Date())
            ]
        ]
    ]
}
```

### Generic JSON Format

```swift
func formatGenericPayload(_ event: WebhookEvent) -> [String: Any] {
    [
        "event": event.isDown ? "site_down" : "site_up",
        "website": [
            "name": event.websiteName,
            "url": event.url
        ],
        "status": [
            "code": event.statusCode,
            "responseTime": event.responseTime
        ],
        "timestamp": ISO8601DateFormatter().string(from: Date()),
        "source": "lighthouse"
    ]
}
```

### Integration Points

In `NotificationManager.swift`, add webhook calls:

```swift
func notifyStatusChange(website: WebsiteInfo, isDown: Bool) {
    // Existing desktop notification
    sendDesktopNotification(...)
    
    // New: webhook notifications
    Task {
        for webhook in enabledWebhooks {
            try? await WebhookService.shared.send(
                event: WebhookEvent(website: website, isDown: isDown),
                to: webhook
            )
        }
    }
}
```

### Settings UI

```swift
struct WebhookSettingsView: View {
    @State private var webhooks: [WebhookConfig] = []
    
    var body: some View {
        List {
            ForEach(webhooks) { webhook in
                WebhookRowView(webhook: webhook)
            }
            
            Button("Add Webhook") {
                // Show add webhook sheet
            }
        }
    }
}

struct AddWebhookSheet: View {
    @State private var name = ""
    @State private var url = ""
    @State private var type: WebhookType = .slack
    
    var body: some View {
        Form {
            TextField("Name", text: $name)
            TextField("Webhook URL", text: $url)
            Picker("Type", selection: $type) {
                Text("Slack").tag(WebhookType.slack)
                Text("Discord").tag(WebhookType.discord)
                Text("Generic JSON").tag(WebhookType.generic)
            }
            
            Button("Test Webhook") {
                // Send test payload
            }
        }
    }
}
```

### Rate Limiting

Prevent webhook spam:

```swift
class WebhookRateLimiter {
    private var lastSent: [String: Date] = [:]
    private let minimumInterval: TimeInterval = 60 // 1 minute
    
    func shouldSend(webhookId: String) -> Bool {
        guard let last = lastSent[webhookId] else {
            return true
        }
        return Date().timeIntervalSince(last) >= minimumInterval
    }
    
    func recordSend(webhookId: String) {
        lastSent[webhookId] = Date()
    }
}
```

### Storage

Save webhooks to:
```
~/Library/Application Support/Lighthouse/webhooks.json
```

## Dependencies

- Website monitoring must be working
- `NotificationManager` needs modification

## Resources

- [Slack Incoming Webhooks](https://api.slack.com/messaging/webhooks)
- [Discord Webhooks](https://discord.com/developers/docs/resources/webhook)
- [Block Kit Builder](https://app.slack.com/block-kit-builder) (Slack payload testing)
