# Lighthouse 🚨

A macOS menu bar app that monitors local development servers, remote websites, and Docker containers - all from your menu bar.

![macOS](https://img.shields.io/badge/macOS-13.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

## Features

### 🏮 In the Harbor (Local Development)
- **Real-time Port Monitoring**: Scans and displays all listening TCP ports on your Mac
- **Dev Server Detection**: Automatically identifies and highlights common development servers (Node.js, Python, Ruby, Go, Rust, and more)
- **Framework Icons**: Visual indicators for Next.js, Vite, React, Django, Flask, and more
- **Process Information**: Shows process name, PID, user, and working directory for each port
- **Log Viewing**: View process logs directly from the menu bar with color-coded output
- **Quick Actions**: Kill processes directly from the menu bar interface

### ⚓ Out at Sea (Remote Monitoring)
- **Website Monitoring**: Track HTTP/HTTPS endpoints with automatic ping checks
- **Status Tracking**: Visual indicators for healthy, warning, and error states
- **Response Time Metrics**: See latency and response times for each website
- **Ping History**: View last 5 pings with detailed tooltip information
- **Uptime Tracking**: Monitor uptime percentage over time

### 🚢 Container Ships (Docker Integration)
- **Container Management**: View, start, stop, restart, and remove Docker containers
- **Port Mapping**: See and click port mappings to open in browser
- **Real-time Status**: Auto-refreshing container status with color indicators
- **Quick Access**: Manage containers without leaving your menu bar

### 🚦 Smart Monitoring
- **Menu Bar Status Indicator**: Icon color changes based on overall system health (green/orange/red)
- **Desktop Notifications**: Get alerted when websites go down or dev servers change state
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
2. Click the lighthouse icon in your menu bar
3. View all active TCP ports and their details
4. Click on any port to see options (copy port, kill process, etc.)

### Detected Development Servers

Lighthouse automatically recognizes these development tools and frameworks:

- **JavaScript/Node.js**: node, npm, npx, yarn, pnpm, bun, deno, next-server, vite, webpack, esbuild, parcel, turbopack
- **Python**: python, python3, uvicorn, gunicorn, flask, django
- **Ruby**: ruby, rails, puma, unicorn
- **PHP**: php, artisan
- **Java**: java, gradle, mvn
- **Go**: go, air
- **Rust**: cargo

## Architecture

The app is built with SwiftUI and follows the MVVM pattern:

- **Models**: 
  - `PortInfo` - Local port data structure
  - `WebsiteInfo` - Remote website data structure
  - `DockerContainer` - Docker container data structure
  - `EnvironmentProfile` - Profile configuration
  - `PingResult` - Website ping results
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
- **ViewModels**: `PortViewModel` - Manages state and business logic
- **Views**: 
  - `MenuBarView` - Main menu bar interface
  - `PortRowView` - Individual port row display
  - `WebsiteRowView` - Website status display
  - `DockerContainerRow` - Container row display
  - `LogViewerSheet` - Log viewer interface
  - `AddWebsiteForm` - Website addition form
- **Utilities**:
  - `FrameworkIconMapper` - Maps frameworks to icons

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

---

Made with ❤️ for macOS developers
