# SSL Certificate Monitoring

**Category:** Feature
**Priority:** P2 Medium
**Effort:** M
**Status:** Not Started

## Summary

Add SSL certificate expiration monitoring to the website monitoring feature. Users should be warned when certificates are approaching expiration (30, 14, 7 days) so they can renew before sites become inaccessible.

## Acceptance Criteria

- [ ] SSL certificate expiration date retrieved for HTTPS sites
- [ ] Warning indicator when certificate expires within 30 days
- [ ] Critical indicator when certificate expires within 7 days
- [ ] Certificate info visible in website details/tooltip
- [ ] Desktop notification when certificate is expiring soon
- [ ] Invalid/expired certificates flagged immediately

## Technical Notes

### Implementation Approach

Use `URLSession` with a custom `URLSessionDelegate` to access the server's certificate chain during HTTPS connections.

### Code Location

Modify: `Lighthouse/Services/WebsiteMonitor.swift`

### Key Implementation

```swift
// Add to WebsiteMonitor.swift

struct SSLCertificateInfo {
    let expirationDate: Date
    let issuer: String
    let isValid: Bool
    let daysUntilExpiry: Int
}

class SSLCertificateChecker: NSObject, URLSessionDelegate {
    var certificateInfo: SSLCertificateInfo?
    
    func urlSession(_ session: URLSession, 
                    didReceive challenge: URLAuthenticationChallenge, 
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        
        // Extract certificate info
        if let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {
            // Parse certificate for expiration date
            // Store in certificateInfo
        }
        
        completionHandler(.performDefaultHandling, nil)
    }
}
```

### Model Updates

Add to `WebsiteInfo.swift`:

```swift
struct WebsiteInfo {
    // ... existing properties
    var sslExpirationDate: Date?
    var sslDaysUntilExpiry: Int?
    var sslIssuer: String?
}
```

### UI Updates

In `WebsiteRowView.swift`, add certificate status indicator:

```swift
// Show warning icon if expiring soon
if let days = website.sslDaysUntilExpiry, days < 30 {
    Image(systemName: days < 7 ? "lock.trianglebadge.exclamationmark" : "lock.badge.clock")
        .foregroundColor(days < 7 ? .red : .orange)
}
```

### Tooltip Enhancement

Add to website tooltip:
```
SSL Certificate
Expires: March 15, 2026 (43 days)
Issuer: Let's Encrypt
```

### Notification Triggers

| Days Until Expiry | Action |
|-------------------|--------|
| 30 days | First warning notification |
| 14 days | Second warning notification |
| 7 days | Critical notification |
| 0 days | Expired notification |

### Edge Cases

- HTTP-only sites: Skip SSL check
- Self-signed certificates: Flag as warning but allow monitoring
- Certificate chain issues: Report but don't block
- Connection failures: Don't report SSL status

### Testing

1. Test with Let's Encrypt sites (real certs)
2. Test with self-signed certificates
3. Test with expired certificates (badssl.com)
4. Test with sites using different issuers

### Test URLs

- `https://expired.badssl.com/` - Expired certificate
- `https://wrong.host.badssl.com/` - Wrong host
- `https://self-signed.badssl.com/` - Self-signed

## Dependencies

None - can be implemented independently.

## Resources

- [SecTrust Reference](https://developer.apple.com/documentation/security/sectrust)
- [URLAuthenticationChallenge](https://developer.apple.com/documentation/foundation/urlauthenticationchallenge)
- [badssl.com](https://badssl.com/) - Test certificates
