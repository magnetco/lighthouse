# App Store Listing

**Category:** App Store
**Priority:** P0 Critical
**Effort:** S
**Status:** Not Started

## Summary

Create the App Store Connect listing for Lighthouse including app name, description, keywords, categories, and all required metadata. This is what users will see when they find your app in the Mac App Store.

## Acceptance Criteria

- [ ] App name set: "Lighthouse — Service Monitor"
- [ ] Subtitle added (30 chars max)
- [ ] Full description written
- [ ] Keywords optimized (100 chars max)
- [ ] Categories selected (Primary + Secondary)
- [ ] Privacy Policy URL added
- [ ] Support URL added
- [ ] Screenshots uploaded
- [ ] Age rating questionnaire completed

## Technical Notes

### App Store Connect Setup

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Click "My Apps" > "+" > "New App"
3. Fill in:
   - Platform: macOS
   - Name: Lighthouse — Service Monitor
   - Primary Language: English (US)
   - Bundle ID: (select from dropdown)
   - SKU: lighthouse-mac-001

### Metadata to Enter

#### App Name
```
Lighthouse — Service Monitor
```
(30 character limit)

#### Subtitle
```
See what's running, everywhere
```
(30 character limit)

#### Keywords
```
port monitor,docker,uptime,dev server,website monitor,localhost,containers,process
```
(100 character limit, comma-separated)

#### Categories
- **Primary:** Developer Tools
- **Secondary:** Utilities

#### Description

Copy from `APP_STORE.md`:

```
Your Mac's service control center, right in the menu bar.

Lighthouse is the missing dashboard for anyone who runs services on their Mac. Whether you're a developer with multiple projects, a DevOps engineer monitoring containers, or simply someone who wants to know "what's using port 3000?"—Lighthouse has you covered.

LOCAL SERVICES ("In the Harbor")
• See every TCP service running on your Mac
• Instantly identify which app owns each port
• Smart framework detection: Next.js, Vite, Django, Rails, and 30+ more
• One-click: open in browser, kill process, reveal in Finder
• Jump straight to your code in VS Code, Cursor, or Zed

DOCKER CONTAINERS ("Container Ships")
• View all running and stopped containers
• Start, stop, restart, or remove with one click
• See port mappings and open containerized services instantly
• Works with Docker Desktop and CLI

WEBSITE MONITORING ("Out at Sea")
• Monitor any HTTP/HTTPS endpoint
• Response time tracking and uptime percentage
• Instant notifications when sites go down
• Organize sites by environment: Dev, Staging, Production

HEALTH AT A GLANCE
• Menu bar icon changes color based on overall health
• Green = all systems go
• Orange = something needs attention
• Red = critical issues detected

PRIVACY FIRST
Lighthouse runs entirely on your Mac. No accounts, no cloud, no telemetry. Your data stays yours.
```

#### URLs Required

| Field | Value |
|-------|-------|
| Privacy Policy URL | https://github.com/[user]/lighthouse/blob/main/PRIVACY.md |
| Support URL | https://github.com/[user]/lighthouse/issues |
| Marketing URL | https://github.com/[user]/lighthouse (optional) |

### Age Rating

Answer questionnaire:
- Cartoon or Fantasy Violence: None
- Realistic Violence: None
- Profanity or Crude Humor: None
- ... (all None)

Result should be: **4+**

### Copyright

```
© 2026 [Your Name or Company]
```

### What's New (Version 1.0.0)

```
Initial release featuring:
• Local port monitoring with framework detection
• Docker container management
• Website uptime monitoring
• Environment profiles
• Desktop notifications
```

### Pricing

- Price: Free (or $4.99 if paid)
- Availability: All territories

## Dependencies

- [02-screenshots-and-previews](02-screenshots-and-previews.md) - Screenshots needed
- [../documentation/01-privacy-policy-hosting](../documentation/01-privacy-policy-hosting.md) - Privacy URL needed
- [../documentation/02-support-url-setup](../documentation/02-support-url-setup.md) - Support URL needed

## Resources

- [APP_STORE.md](../../APP_STORE.md) - Pre-written content
- [App Store Product Page Guidelines](https://developer.apple.com/app-store/product-page/)
- [Writing Great App Store Descriptions](https://developer.apple.com/app-store/app-description/)
