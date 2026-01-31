# Lighthouse Roadmap 🗺️

This document outlines potential features and enhancements for Lighthouse, organized by category and priority.

## Current State

Lighthouse is a macOS menu bar app that monitors:
- **Local Development Servers** ("In the Harbor") - Active TCP ports with process information
- **Remote Websites** ("Out at Sea") - HTTP/HTTPS endpoints with ping monitoring
- **Docker Containers** ("Container Ships") - Full Docker container management

### ✅ Completed Features

#### Menu Bar Status Indicator
- Icon color changes based on overall system health (green/orange/red/gray)
- Provides at-a-glance status without opening the menu

#### Desktop Notifications
- Alerts when websites go down or recover
- Notifications when dev servers start or stop
- Smart notification system prevents spam
- Uses native macOS notification system

#### Environment Profiles
- Switch between Dev/Staging/Production configurations
- Each profile has its own website list and refresh interval
- Quick profile switching from menu bar
- Persists across app restarts

#### Log Viewing
- View process logs directly in the app
- Color-coded log levels (error, warning, info)
- Auto-scroll toggle and copy to clipboard
- Shows last 100 lines from system logs

#### Docker Integration
- List all containers (running and stopped)
- Start/stop/restart/remove containers
- View and click port mappings
- Real-time status updates with color indicators

#### Framework Icon System
- Automatic framework detection for 35+ frameworks
- Visual icons for Next.js, Vite, React, Django, Flask, Node.js, Docker, Python, Prisma
- Fallback to SF Symbols when custom icons unavailable
- Internal/external website detection

---

## Monitoring & Alerting

### Desktop Notifications ✅
**Status: Completed**

- ✅ Alert when a dev server goes down unexpectedly
- ✅ Notify when a website's status changes (healthy → error)
- ✅ Smart notification system prevents spam
- ⏳ Configurable notification preferences per port/website (future)
- ⏳ Sound alerts for critical failures (future)

**Nautical Theme**: "Signal Flares" 🔥

### Status History & Analytics
**Priority: Medium | Effort: Medium-High**

- Graphs showing uptime trends over time
- Response time charts for websites
- Port usage patterns (which ports are used most frequently)
- Historical data retention settings (7 days, 30 days, etc.)
- Export history data as CSV/JSON

**Nautical Theme**: "Captain's Charts" 📊

### Custom Health Checks
**Priority: Medium | Effort: Medium**

- Beyond HTTP HEAD requests: check for specific response content
- Custom success criteria (e.g., "response must contain 'OK'")
- API endpoint testing with expected JSON responses
- SSL certificate expiration warnings
- Custom timeout values per website
- Support for authenticated endpoints (API keys, basic auth)

**Nautical Theme**: "Deep Sea Soundings" 🌊

---

## Developer Workflow Integration

### Project Context Awareness
**Priority: High | Effort: Medium**

- Auto-detect project type from working directory (extend existing `ProjectDetector`)
- Show relevant documentation links per framework
- Display environment variables for each process
- Show git branch/status for the project directory
- Package.json/requirements.txt version display
- Quick links to localhost alternatives (127.0.0.1, local IP)

**Nautical Theme**: "Ship's Manifest" 📋

### Quick Actions & Shortcuts
**Priority: High | Effort: Low-Medium**

- Global keyboard shortcuts to open the menu
- Quick port forwarding setup
- One-click restart of dev servers
- Copy formatted markdown with port info for documentation
- Copy curl commands for testing
- QR code generation for mobile testing

**Nautical Theme**: "Signal Flags" 🚩

### Log Viewing ✅
**Status: Completed**

- ✅ Tail logs for running processes directly in the menu
- ✅ Color-coded log levels (error, warning, info)
- ✅ Auto-scroll toggle
- ✅ Copy logs to clipboard
- ✅ Last 100 lines displayed
- ⏳ Filter/search through process output (future)
- ⏳ Save logs to file (future)

**Nautical Theme**: "Ship's Log" 📖

---

## Team & Collaboration

### Shared Monitoring
**Priority: Low-Medium | Effort: Low**

- Export/import website lists
- Team presets (staging, production, QA environments)
- Slack/Discord webhook integration for status updates
- JSON/YAML configuration files for version control
- Share via URL or file

**Nautical Theme**: "Fleet Coordination" ⚓

### Environment Profiles ✅
**Status: Completed**

- ✅ Switch between different sets of monitored websites (dev/staging/prod)
- ✅ Per-profile refresh intervals
- ✅ Quick profile switching from menu bar
- ✅ Persists across app restarts
- ⏳ Profile-specific notification settings (future)
- ⏳ Color coding per environment (future)

**Nautical Theme**: "Navigation Charts" 🗺️

---

## Advanced Port Features

### Network Traffic Monitoring
**Priority: Low | Effort: High**

- Show bandwidth usage per port
- Request count tracking
- Connection count for each port
- Real-time traffic graphs
- Peak usage indicators

**Nautical Theme**: "Cargo Manifest" 📦

### Port Conflict Detection
**Priority: Medium | Effort: Medium**

- Warn when trying to start a server on an occupied port
- Suggest alternative ports
- History of port conflicts
- Auto-resolution suggestions
- Integration with common dev tools (npm, yarn, etc.)

**Nautical Theme**: "Harbor Master Alerts" 🚨

### Docker/Container Integration ✅
**Status: Completed**

- ✅ Detect ports from Docker containers
- ✅ Show container names and images
- ✅ Start/stop/restart containers from the menu
- ✅ Remove containers
- ✅ Container health status with color indicators
- ✅ Show mapped ports (clickable to open in browser)
- ⏳ Quick access to container logs (future)
- ⏳ Docker Compose support (future)

**Nautical Theme**: "Container Ships" 🚢

---

## UI/UX Enhancements

### Favorites & Organization
**Priority: Medium | Effort: Low-Medium**

- Star/favorite frequently used ports or websites
- Custom grouping/categories
- Collapsible sections
- Search/filter functionality
- Drag-and-drop reordering
- Tags for better organization

**Nautical Theme**: "Marked Buoys" 🎯

### Themes & Customization
**Priority: Low | Effort: Medium**

- Light/dark mode preferences
- Custom color schemes for different project types
- Adjustable refresh intervals per item
- Compact vs. detailed view modes
- Font size preferences
- Icon customization

**Nautical Theme**: "Ship's Colors" 🎨

### Menu Bar Status Indicator ✅
**Status: Completed**

- ✅ Change icon color based on overall health (green/orange/red/gray)
- ✅ Automatic updates when status changes
- ⏳ Show count of active dev servers in menu bar (future)
- ⏳ Badge for critical alerts (future)
- ⏳ Animated icon for active monitoring (future)
- ⏳ Click-through to specific issues (future)

**Nautical Theme**: "Lighthouse Beacon States" 💡

---

## Implementation Phases

### ✅ Phase 1: Core Enhancements (Completed)
1. ✅ **Desktop Notifications** - Alerts for status changes
2. ✅ **Environment Profiles** - Multi-environment support
3. ✅ **Menu Bar Status Indicator** - At-a-glance health status

### ✅ Phase 2: Developer Experience (Completed)
4. ✅ **Log Viewing** - Process log inspection
5. ✅ **Docker Integration** - Container management
6. ✅ **Framework Icons** - Visual framework detection

### 🚧 Phase 3: Advanced Features (Next Priority)
7. **Status History Graphs** - Long-term monitoring trends
8. **Project Context Awareness** - Enhanced workflow integration
9. **Custom Health Checks** - Power user features
10. **Quick Actions & Shortcuts** - Global keyboard shortcuts

### 📋 Phase 4: Polish & Scale (Future)
11. **Favorites & Organization** - Better UX for many items
12. **Port Conflict Detection** - Proactive problem solving
13. **Shared Monitoring** - Team collaboration
14. **Network Traffic Monitoring** - Bandwidth and request tracking

---

## Technical Considerations

### Performance
- Keep memory footprint low (important for menu bar apps)
- Efficient polling strategies (don't hammer endpoints)
- Background thread management for monitoring
- Lazy loading for historical data

### Security
- Secure storage for API keys and credentials
- Sandboxing considerations for macOS
- User permission requests (network, file system)
- Safe handling of shell commands

### Compatibility
- Maintain macOS 13.0+ support
- Test on Apple Silicon and Intel Macs
- Consider future SwiftUI API changes
- Backward compatibility for stored data

---

## Community & Distribution

### Future Considerations
- App Store distribution
- Homebrew cask support
- Auto-update mechanism
- Crash reporting and analytics (opt-in)
- User feedback system
- Documentation site
- Video tutorials

---

## Nautical Theme Extensions

As features are implemented, maintain the cohesive nautical metaphor:

- **Local Ports**: "In the Harbor" (warm amber/orange) 🏮
- **Remote Websites**: "Out at Sea" (cool blue/teal) ⚓
- **Notifications**: "Signal Flares" 🔥
- **Logs**: "Ship's Log" 📖
- **Profiles**: "Navigation Charts" 🗺️
- **Docker**: "Container Ships" 🚢
- **History**: "Captain's Charts" 📊
- **Favorites**: "Marked Buoys" 🎯
- **Health Checks**: "Deep Sea Soundings" 🌊

---

## Broadening Appeal (v2.0+)

Features to expand beyond developers to DevOps, sysadmins, and general users:

### Simplified Mode
**Priority: Medium | Effort: Medium**

- First-run wizard for different user types (Developer, DevOps, General)
- Streamlined UI hiding technical details for non-developers
- "Just tell me if my sites are up" mode
- Contextual help and tooltips

**Target Audience**: Tech-savvy business owners, beginners

### Database Monitoring
**Priority: Medium | Effort: Medium**

- Detect running database servers (PostgreSQL, MySQL, MongoDB, Redis)
- Connection status and basic health
- Quick connection string copying
- Integration with common database tools

**Nautical Theme**: "Deep Anchorage" ⚓

### SSL Certificate Monitoring
**Priority: High | Effort: Low**

- Certificate expiration warnings (30, 14, 7 days)
- Certificate chain validation
- Push notifications before expiration
- Quick renewal reminders

**Nautical Theme**: "Signal Integrity" 🔐

### System Services Overview
**Priority: Low | Effort: Medium**

- Beyond TCP: show all network services
- UDP services visibility
- macOS launch daemons/agents awareness
- Service dependency mapping

**Target Audience**: Sysadmins, IT professionals

### Webhook Integrations
**Priority: Low | Effort: Medium**

- Slack/Discord notifications
- Generic webhook support
- PagerDuty/OpsGenie integration
- Custom HTTP callbacks

**Target Audience**: DevOps, on-call engineers

### Multi-Machine Support (v3.0)
**Priority: Low | Effort: High**

- Monitor services on remote machines via SSH
- Agent-based monitoring for servers
- Aggregate view across machines
- Team dashboard view

**Target Audience**: DevOps teams, enterprise users

---

*Built for developers. Ready for everyone.*
