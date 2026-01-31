# Lighthouse - App Store Submission Guide

## App Information

### App Name
**Lighthouse** — Service Monitor for Mac

### Subtitle (30 characters max)
See what's running, everywhere

### Category
- **Primary:** Developer Tools
- **Secondary:** Utilities

### Keywords (100 characters max)
port monitor, docker, uptime, dev server, process manager, website monitor, localhost, containers

---

## App Store Description

### Short Description (170 characters)
Lighthouse keeps watch over your local services, Docker containers, and websites. One glance at your menu bar shows if everything's running smoothly.

### Full Description

**Your Mac's service control center, right in the menu bar.**

Lighthouse is the missing dashboard for anyone who runs services on their Mac. Whether you're a developer with multiple projects, a DevOps engineer monitoring containers, or simply someone who wants to know "what's using port 3000?"—Lighthouse has you covered.

**🏠 Local Services ("In the Harbor")**
• See every TCP service running on your Mac
• Instantly identify which app owns each port
• Smart framework detection: Next.js, Vite, Django, Rails, and 30+ more
• One-click: open in browser, kill process, reveal in Finder
• Jump straight to your code in VS Code, Cursor, or Zed

**🐳 Docker Containers ("Container Ships")**
• View all running and stopped containers
• Start, stop, restart, or remove with one click
• See port mappings and open containerized services instantly
• Works with Docker Desktop and CLI

**🌐 Website Monitoring ("Out at Sea")**
• Monitor any HTTP/HTTPS endpoint
• Response time tracking and uptime percentage
• Instant notifications when sites go down
• Organize sites by environment: Dev, Staging, Production

**📊 Health at a Glance**
• Menu bar icon changes color based on overall health
• Green = all systems go
• Orange = something needs attention
• Red = critical issues detected

**🔔 Smart Notifications**
• Get notified when your dev server starts or stops
• Alerts when monitored websites become unreachable
• Non-spammy: intelligent deduplication

**Perfect for:**
• Developers running multiple local projects
• DevOps engineers monitoring containers
• QA teams checking environment status
• Freelancers juggling client projects
• Anyone curious about what's running on their Mac

**Privacy First**
Lighthouse runs entirely on your Mac. No accounts, no cloud, no telemetry. Your data stays yours.

---

## What's New (Version History Template)

### Version 1.0.0
Initial release featuring:
- Local port monitoring with framework detection
- Docker container management
- Website uptime monitoring
- Environment profiles (Dev/Staging/Production)
- Desktop notifications
- Menu bar health indicator

---

## Screenshots Required

1. **Menu bar overview** - Full menu expanded showing all sections
2. **Local ports** - Services detected with framework icons
3. **Docker containers** - Container management view
4. **Website monitoring** - Sites with status and response times
5. **Notifications** - Desktop notification examples
6. **Profiles** - Environment switching

### Screenshot Sizes (Mac App Store)
- 1280 x 800 pixels
- 1440 x 900 pixels
- 2560 x 1600 pixels
- 2880 x 1800 pixels

---

## Pricing Strategy

### Recommended: Freemium
- **Free tier:** Monitor up to 5 websites, 1 profile
- **Pro ($4.99 one-time):** Unlimited websites, unlimited profiles, priority support

### Alternative: Paid Upfront
- **$4.99** one-time purchase
- No subscriptions, no IAP complexity
- Lower support burden

### Rationale
One-time purchase aligns with Mac App Store user expectations and reduces friction. Price point is accessible while valuing the utility provided.

---

## App Review Preparation

### Potential Review Concerns

1. **Shell command execution**
   - Lighthouse uses `lsof` and `docker` CLI
   - All commands are read-only or user-initiated
   - No arbitrary code execution

2. **Network access**
   - HTTP/HTTPS requests for website monitoring only
   - Local network scanning via lsof (system utility)
   - No data leaves the device except explicit health checks

3. **Process management**
   - Kill process feature requires user confirmation
   - Only affects processes owned by current user

### Demo Account
Not applicable—Lighthouse requires no accounts.

### Review Notes
"Lighthouse monitors local TCP services using macOS's built-in `lsof` utility, manages Docker containers via the Docker CLI (if installed), and performs HTTP HEAD requests to monitor website availability. All features work offline except website monitoring. No user data is collected or transmitted."

---

## Technical Requirements

### System Requirements
- macOS 13.0 (Ventura) or later
- Apple Silicon or Intel Mac
- Docker Desktop (optional, for container features)

### Entitlements Required
- `com.apple.security.network.client` — Website monitoring
- `com.apple.security.files.user-selected.read-write` — Log file access

### Sandbox Compatibility
Full App Sandbox compatible. All features work within sandbox restrictions.

---

## Support Resources

### Support URL
https://github.com/[username]/lighthouse/issues

### Privacy Policy URL
https://github.com/[username]/lighthouse/blob/main/PRIVACY.md

### Marketing URL (optional)
https://github.com/[username]/lighthouse

---

## Localization

### Initial Release
- English (US)
- English (UK)

### Future Releases
- Spanish
- German
- French
- Japanese
- Chinese (Simplified)

---

## App Store Optimization (ASO)

### Competitor Analysis
- **iStatistica** — System monitoring (broader, less focused)
- **Stats** — System resources (no service monitoring)
- **Proxyman** — Network debugging (different use case)

### Differentiation
Lighthouse is the only menu bar app that combines:
- Local port/process monitoring
- Docker container management  
- Website uptime tracking
- Framework-aware developer tools

### Target Search Terms
- "port monitor mac"
- "docker menu bar"
- "localhost monitor"
- "dev server manager"
- "website uptime mac"
- "what's running on my mac"
