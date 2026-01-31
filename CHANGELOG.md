# Changelog

All notable changes to Lighthouse will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Planned
- SSL certificate expiration monitoring
- Database connection monitoring (PostgreSQL, MySQL, Redis)
- Custom health check endpoints with JSON validation
- Global keyboard shortcuts
- Homebrew Cask distribution

---

## [1.0.0] - 2026-01-31

### Added

#### Local Port Monitoring ("In the Harbor")
- Real-time TCP port scanning using `lsof`
- Automatic detection of 35+ frameworks (Next.js, Vite, Django, Rails, etc.)
- Project name detection from package.json, pyproject.toml, Cargo.toml, go.mod
- Process details: PID, user, working directory, command line
- Quick actions: open in browser, copy URL, kill process, reveal in Finder
- Editor integration: open in Cursor, Zed, VS Code
- Log viewer with color-coded output
- Auto-refresh every 5 seconds

#### Website Monitoring ("Out at Sea")
- HTTP/HTTPS endpoint monitoring with HEAD requests
- Response time tracking in milliseconds
- Uptime percentage calculation
- Ping history (last 10 checks with timestamps)
- Status indicators: healthy (green), warning (orange), error (red)
- Internal/external website detection
- Auto-refresh with configurable intervals (15-60 seconds)
- Desktop notifications for status changes

#### Docker Integration ("Container Ships")
- Container listing (running and stopped)
- Container management: start, stop, restart, remove
- Port mapping display with clickable links
- Real-time status updates
- Auto-refresh every 10 seconds

#### Environment Profiles
- Multiple profiles: Development, Staging, Production
- Per-profile website lists
- Per-profile refresh intervals
- Quick profile switching from menu bar
- Persistent storage across app restarts

#### System Health Indicator
- Menu bar icon color reflects overall health
- Green: all healthy
- Orange: warnings detected
- Red: critical issues
- Gray: no data/unknown

#### Smart Notifications
- Website status change alerts
- Dev server start/stop notifications
- Intelligent deduplication (no spam)
- Native macOS notification center integration

### Technical
- Swift 5.9+ with SwiftUI
- MVVM architecture
- Async/await concurrency
- macOS 13.0+ support
- Universal binary (Apple Silicon + Intel)
- Full App Sandbox compatibility

---

## Version History Template

### [X.Y.Z] - YYYY-MM-DD

#### Added
- New features

#### Changed
- Changes to existing features

#### Deprecated
- Features that will be removed

#### Removed
- Features that were removed

#### Fixed
- Bug fixes

#### Security
- Security-related changes

---

## Migration Notes

### From Pre-1.0 Development Builds
If you used development builds before 1.0:
1. Your websites.json will be preserved
2. Your profiles.json will be preserved
3. No migration required

---

## Roadmap Preview

See [ROADMAP.md](./ROADMAP.md) for detailed feature plans.

**Coming in 1.1:**
- Favorites and starred services
- Search and filter
- Custom grouping

**Coming in 1.2:**
- SSL certificate monitoring
- Database connections
- API endpoint testing

**Coming in 2.0:**
- Team sharing (optional cloud sync)
- Webhook integrations
- Custom themes
