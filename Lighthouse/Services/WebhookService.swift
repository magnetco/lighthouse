import Foundation

enum WebhookError: Error {
    case deliveryFailed
    case invalidURL
    case encodingFailed
}

class WebhookService {
    static let shared = WebhookService()
    private let rateLimiter = WebhookRateLimiter()
    
    private init() {}
    
    func send(event: WebhookEvent, to config: WebhookConfig) async throws {
        // Check rate limiting
        guard rateLimiter.shouldSend(webhookId: config.id.uuidString) else {
            return
        }
        
        // Check if this event type should trigger
        if event.isDown && !config.triggerOnDown {
            return
        }
        if !event.isDown && !config.triggerOnRecovery {
            return
        }
        
        guard let url = URL(string: config.url) else {
            throw WebhookError.invalidURL
        }
        
        let payload = try formatPayload(event: event, type: config.type)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = payload
        request.timeoutInterval = 10
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw WebhookError.deliveryFailed
        }
        
        // Record successful send
        rateLimiter.recordSend(webhookId: config.id.uuidString)
    }
    
    private func formatPayload(event: WebhookEvent, type: WebhookType) throws -> Data {
        let dict: [String: Any]
        
        switch type {
        case .slack:
            dict = formatSlackPayload(event)
        case .discord:
            dict = formatDiscordPayload(event)
        case .generic:
            dict = formatGenericPayload(event)
        }
        
        return try JSONSerialization.data(withJSONObject: dict)
    }
    
    private func formatSlackPayload(_ event: WebhookEvent) -> [String: Any] {
        let emoji = event.isDown ? "🔴" : "🟢"
        let statusText = event.isDown ? "is DOWN" : "has recovered"
        let color = event.isDown ? "#FF0000" : "#00FF00"
        
        var contextText = "URL: \(event.url)"
        if let responseTime = event.responseTime {
            contextText += " | Response: \(String(format: "%.0fms", responseTime * 1000))"
        }
        if let statusCode = event.statusCode {
            contextText += " | Status: \(statusCode)"
        }
        
        return [
            "blocks": [
                [
                    "type": "section",
                    "text": [
                        "type": "mrkdwn",
                        "text": "\(emoji) *\(event.websiteName)* \(statusText)"
                    ]
                ],
                [
                    "type": "context",
                    "elements": [
                        [
                            "type": "mrkdwn",
                            "text": contextText
                        ]
                    ]
                ]
            ],
            "attachments": [
                [
                    "color": color
                ]
            ]
        ]
    }
    
    private func formatDiscordPayload(_ event: WebhookEvent) -> [String: Any] {
        let title = event.isDown ? "🔴 Site Down" : "🟢 Site Recovered"
        let color = event.isDown ? 0xFF0000 : 0x00FF00
        
        var fields: [[String: Any]] = [
            ["name": "URL", "value": event.url, "inline": true]
        ]
        
        if let responseTime = event.responseTime {
            fields.append([
                "name": "Response Time",
                "value": "\(String(format: "%.0fms", responseTime * 1000))",
                "inline": true
            ])
        }
        
        if let statusCode = event.statusCode {
            fields.append([
                "name": "Status Code",
                "value": "\(statusCode)",
                "inline": true
            ])
        }
        
        let formatter = ISO8601DateFormatter()
        
        return [
            "embeds": [
                [
                    "title": title,
                    "description": event.websiteName,
                    "color": color,
                    "fields": fields,
                    "timestamp": formatter.string(from: event.timestamp)
                ]
            ]
        ]
    }
    
    private func formatGenericPayload(_ event: WebhookEvent) -> [String: Any] {
        let formatter = ISO8601DateFormatter()
        
        var payload: [String: Any] = [
            "event": event.isDown ? "site_down" : "site_up",
            "website": [
                "name": event.websiteName,
                "url": event.url
            ],
            "timestamp": formatter.string(from: event.timestamp),
            "source": "lighthouse"
        ]
        
        var status: [String: Any] = [:]
        if let code = event.statusCode {
            status["code"] = code
        }
        if let responseTime = event.responseTime {
            status["responseTime"] = responseTime * 1000 // Convert to ms
        }
        
        if !status.isEmpty {
            payload["status"] = status
        }
        
        return payload
    }
}

class WebhookRateLimiter {
    private var lastSent: [String: Date] = [:]
    private let minimumInterval: TimeInterval = 60 // 1 minute
    private let lock = NSLock()
    
    func shouldSend(webhookId: String) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        
        guard let last = lastSent[webhookId] else {
            return true
        }
        return Date().timeIntervalSince(last) >= minimumInterval
    }
    
    func recordSend(webhookId: String) {
        lock.lock()
        defer { lock.unlock() }
        
        lastSent[webhookId] = Date()
    }
}
