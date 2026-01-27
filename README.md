# Lighthouse 🚨

A macOS menu bar app that monitors and displays all active TCP ports on your system, with special highlighting for development servers.

![macOS](https://img.shields.io/badge/macOS-13.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

## Features

- **Real-time Port Monitoring**: Scans and displays all listening TCP ports on your Mac
- **Dev Server Detection**: Automatically identifies and highlights common development servers (Node.js, Python, Ruby, Go, Rust, and more)
- **Process Information**: Shows process name, PID, user, and working directory for each port
- **Menu Bar Integration**: Lives in your menu bar for quick access without cluttering your dock
- **Quick Actions**: Kill processes directly from the menu bar interface

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

- **Models**: `PortInfo` - Data structure for port information
- **Services**: 
  - `PortScanner` - Scans system ports using `lsof`
  - `ProcessManager` - Manages process operations (kill, etc.)
  - `ShellExecutor` - Executes shell commands safely
- **ViewModels**: `PortViewModel` - Manages state and business logic
- **Views**: 
  - `MenuBarView` - Main menu bar interface
  - `PortRowView` - Individual port row display

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
│   └── PortInfo.swift        # Port data model
├── Services/
│   ├── PortScanner.swift     # Port scanning logic
│   ├── ProcessManager.swift  # Process management
│   └── ShellExecutor.swift   # Shell command execution
├── ViewModels/
│   └── PortViewModel.swift   # State management
└── Views/
    ├── MenuBarView.swift     # Main menu bar UI
    └── PortRowView.swift     # Port row UI component
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

## Support

If you encounter any issues or have suggestions, please [open an issue](https://github.com/yourusername/lighthouse/issues).

---

Made with ❤️ for macOS developers
