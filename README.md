# Lighthouse

**Your Mac's service control center, right in the menu bar.**

See what's running locally, monitor your websites, and manage Docker containers—all from a single, elegant menu bar app.

![macOS](https://img.shields.io/badge/macOS-13.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Privacy](https://img.shields.io/badge/privacy-no_tracking-brightgreen.svg)

## Who It's For

| You Are | Lighthouse Helps You |
|---------|---------------------|
| **Developer** | See all your dev servers, jump to code, kill runaway processes |
| **DevOps Engineer** | Monitor containers, check service health, manage environments |
| **Sysadmin** | Know what's running on any port, instant process identification |
| **QA Engineer** | Quick environment status checks before testing |
| **Freelancer** | Manage multiple client projects with environment profiles |
| **Curious User** | "What's using port 3000?" — answered instantly |

## Features

### 🏮 In the Harbor (Local Development)
- **Real-time Port Monitoring**: Scans and displays all listening TCP ports on your Mac
- **Dev Server Detection**: Automatically identifies and highlights common development servers (Node.js, Python, Ruby, Go, Rust, and more)
- **Database Detection**: Recognizes PostgreSQL, MySQL, MongoDB, Redis, Memcached, and Elasticsearch with quick-copy connection strings
- **Framework Icons**: Visual indicators for Next.js, Vite, React, Django, Flask, and more
- **Process Information**: Shows process name, PID, user, and working directory for each port
- **Log Viewing**: View process logs directly from the menu bar with color-coded output
- **Favorites**: Star frequently-used ports to keep them at the top
- **Quick Actions**: Kill processes directly from the menu bar interface

### ⚓ Out at Sea (Remote Monitoring)
- **Website Monitoring**: Track HTTP/HTTPS endpoints with automatic ping checks
- **Status Tracking**: Visual indicators for healthy, warning, and error states
- **Response Time Metrics**: See latency and response times for each website
- **Ping History**: View last 5 pings with detailed tooltip information
- **Uptime Tracking**: Monitor uptime percentage over time
- **Favorites**: Star important websites for quick access
- **Webhook Integrations**: Send notifications to Slack, Discord, or custom endpoints when sites go down

### 🚢 Container Ships (Docker Integration)
- **Container Management**: View, start, stop, restart, and remove Docker containers
- **Port Mapping**: See and click port mappings to open in browser
- **Real-time Status**: Auto-refreshing container status with color indicators
- **Quick Access**: Manage containers without leaving your menu bar

### 🚦 Smart Monitoring
- **Menu Bar Status Indicator**: Icon color changes based on overall system health (green/orange/red)
- **Desktop Notifications**: Get alerted when websites go down or dev servers change state
- **Global Keyboard Shortcut**: Press ⌃⌥L from anywhere to open Lighthouse
- **Environment Profiles**: Switch between Dev/Staging/Production monitoring configurations
- **Auto-refresh**: Configurable refresh intervals per environment

## Screenshots

The app appears in your menu bar with a lighthouse beacon icon, showing all active ports with their associated processes and working directories.

## Installation

### Building from Source

1. Clone the repository:
```bash
git clone https://github.com/yourusername/lighthouse.git
cd lighthouse
```

2. Open the project in Xcode:
```bash
open Lighthouse.xcodeproj
```

3. Build and run (⌘R)

### Requirements

- macOS 13.0 or later
- Xcode 15.0 or later
- Swift 5.9 or later

## Usage

1. Launch Lighthouse
2. Click the lighthouse icon in your menu bar (or press **⌃⌥L** from anywhere)
3. View all active TCP ports and their details
4. Click on any port to see options (copy port, kill process, etc.)
5. Star your favorite ports and websites to keep them at the top
6. Configure webhooks in settings (⚙️) to get notified in Slack/Discord

### Quick Actions

- **⌃⌥L** - Open Lighthouse from anywhere
- **Click star icon** - Add to favorites
- **Click link icon** - Copy database connection string
- **Click settings** - Configure webhooks and preferences

### Detected Development Servers

Lighthouse automatically recognizes these development tools and frameworks:

- **JavaScript/Node.js**: node, npm, npx, yarn, pnpm, bun, deno, next-server, vite, webpack, esbuild, parcel, turbopack
- **Python**: python, python3, uvicorn, gunicorn, flask, django
- **Ruby**: ruby, rails, puma, unicorn
- **PHP**: php, artisan
- **Java**: java, gradle, mvn
- **Go**: go, air
- **Rust**: cargo
- **Databases**: PostgreSQL, MySQL, MongoDB, Redis, Memcached, Elasticsearch

## Architecture

The app is built with SwiftUI and follows the MVVM pattern:

- **Models**: 
  - `PortInfo` - Local port data structure (with favorites)
  - `WebsiteInfo` - Remote website data structure (with favorites)
  - `DockerContainer` - Docker container data structure
  - `EnvironmentProfile` - Profile configuration
  - `PingResult` - Website ping results
  - `WebhookConfig` - Webhook configuration
- **Services**: 
  - `PortScanner` - Scans system ports using `lsof`
  - `ProcessManager` - Manages process operations
  - `WebsiteMonitor` - HTTP/HTTPS endpoint monitoring
  - `DockerManager` - Docker CLI integration
  - `NotificationManager` - Desktop notification handling
  - `LogTailer` - Process log reading
  - `ProfileStorage` - Environment profile persistence
  - `WebsiteStorage` - Website list persistence
  - `ProjectDetector` - Framework detection
  - `ShellExecutor` - Executes shell commands safely
  - `FavoritesStorage` - Favorites persistence
  - `WebhookService` - Webhook delivery
  - `WebhookStorage` - Webhook configuration persistence
  - `ShortcutManager` - Global keyboard shortcuts
- **ViewModels**: `PortViewModel` - Manages state and business logic
- **Views**: 
  - `MenuBarView` - Main menu bar interface
  - `PortRowView` - Individual port row display (with star button)
  - `WebsiteRowView` - Website status display (with star button)
  - `DockerContainerRow` - Container row display
  - `LogViewerSheet` - Log viewer interface
  - `AddWebsiteForm` - Website addition form
  - `WebhookSettingsView` - Webhook management interface
- **Utilities**:
  - `FrameworkIconMapper` - Maps frameworks to icons (with database support)

## How It Works

Lighthouse uses macOS's `lsof` command to scan for listening TCP ports:

```bash
lsof -iTCP -sTCP:LISTEN -n -P
```

For each port, it retrieves:
- Port number
- Process ID (PID)
- Process name
- User running the process
- Working directory (via additional `lsof` queries)

The app refreshes automatically to keep the port list up to date.

## Development

### Project Structure

```
Lighthouse/
├── LighthouseApp.swift      # App entry point
├── Models/
│   ├── PortInfo.swift        # Port data model
│   ├── WebsiteInfo.swift     # Website data model
│   ├── DockerContainer.swift # Docker container model
│   ├── EnvironmentProfile.swift # Profile model
│   └── PingResult.swift      # Ping result model
├── Services/
│   ├── PortScanner.swift     # Port scanning logic
│   ├── ProcessManager.swift  # Process management
│   ├── WebsiteMonitor.swift  # Website monitoring
│   ├── DockerManager.swift   # Docker integration
│   ├── NotificationManager.swift # Notifications
│   ├── LogTailer.swift       # Log reading
│   ├── ProfileStorage.swift  # Profile persistence
│   ├── WebsiteStorage.swift  # Website persistence
│   ├── ProjectDetector.swift # Framework detection
│   └── ShellExecutor.swift   # Shell command execution
├── Utilities/
│   └── FrameworkIconMapper.swift # Icon mapping
├── ViewModels/
│   └── PortViewModel.swift   # State management
└── Views/
    ├── MenuBarView.swift     # Main menu bar UI
    ├── PortRowView.swift     # Port row UI component
    ├── WebsiteRowView.swift  # Website row UI
    ├── DockerContainerRow.swift # Container row UI
    ├── LogViewerSheet.swift  # Log viewer UI
    └── AddWebsiteForm.swift  # Website form UI
```

### Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Built with SwiftUI and modern Swift concurrency
- Inspired by the need for a simple, native port monitoring tool on macOS

## Implementation Notes

### Framework Icon System
The app includes a comprehensive framework detection system that displays appropriate icons for:
- **Frontend**: Next.js, Vite, React, Vue, Angular, Svelte, Nuxt, Remix, Astro, Gatsby
- **Backend**: Django, Flask, FastAPI, Rails, Laravel, Node.js
- **Tools**: Prisma, Docker, Webpack, Parcel, Turbopack, Storybook
- **Languages**: Python, Rust, Go, Bun, Deno, PHP

Icons can be added to `Assets.xcassets` or the app falls back to SF Symbols. See `download-icons.md` for instructions on adding custom framework icons.

### Storage Locations
- **Websites**: `~/Library/Application Support/Lighthouse/websites.json`
- **Profiles**: `~/Library/Application Support/Lighthouse/profiles.json`
- **Webhooks**: `~/Library/Application Support/Lighthouse/webhooks.json`
- **Favorites**: `~/Library/Preferences/com.lighthouse.app.plist` (UserDefaults)

### Performance Characteristics
- **Local Ports**: Refresh every 5 seconds
- **Remote Websites**: Refresh every 15-60 seconds (profile-dependent)
- **Docker Containers**: Refresh every 10 seconds
- **Concurrent Operations**: Non-blocking async/await throughout
- **Memory**: Efficient state management with minimal footprint

### Nautical Theme
The app uses a cohesive nautical metaphor throughout:
- **Local Ports**: "In the Harbor" 🏮 (warm amber/orange tones)
- **Remote Websites**: "Out at Sea" ⚓ (cool blue/teal tones)
- **Notifications**: "Signal Flares" 🔥
- **Logs**: "Ship's Log" 📖
- **Profiles**: "Navigation Charts" 🗺️
- **Docker**: "Container Ships" 🚢

## Support

If you encounter any issues or have suggestions, please [open an issue](https://github.com/yourusername/lighthouse/issues).

## Privacy

Lighthouse is built with privacy as a core principle:

- **No accounts** — Works entirely offline (except website monitoring)
- **No analytics** — Zero telemetry, tracking, or data collection
- **No cloud** — All data stored locally on your Mac
- **Open source** — Verify our claims by reading the code

See [PRIVACY.md](./PRIVACY.md) for our complete privacy policy.

## Documentation

- [APP_STORE.md](./APP_STORE.md) — App Store submission details
- [CHANGELOG.md](./CHANGELOG.md) — Version history
- [FEATURES.md](./FEATURES.md) — Detailed feature documentation
- [PRIVACY.md](./PRIVACY.md) — Privacy policy
- [ROADMAP.md](./ROADMAP.md) — Feature roadmap

---

**Lighthouse** — All signal, no noise.
