# Contributing to Lighthouse

Thank you for your interest in contributing to Lighthouse! This document provides guidelines and information for contributors.

## Code of Conduct

Be respectful, inclusive, and constructive. We're all here to build something useful.

## How to Contribute

### Reporting Bugs

1. **Search existing issues** to avoid duplicates
2. **Use the bug report template** when creating a new issue
3. **Include details:**
   - macOS version
   - Lighthouse version
   - Steps to reproduce
   - Expected vs actual behavior
   - Screenshots if applicable

### Suggesting Features

1. **Check the [ROADMAP.md](./ROADMAP.md)** to see if it's already planned
2. **Open a feature request issue** with:
   - Clear description of the feature
   - Use case: who benefits and how
   - Potential implementation approach (optional)

### Pull Requests

1. **Fork the repository**
2. **Create a feature branch** from `main`:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes** following the code style guidelines below
4. **Test your changes** on macOS 13.0+
5. **Commit with clear messages**:
   ```bash
   git commit -m "Add: description of what you added"
   git commit -m "Fix: description of what you fixed"
   git commit -m "Change: description of what you changed"
   ```
6. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```
7. **Open a Pull Request** against `main`

## Development Setup

### Prerequisites

- macOS 13.0 (Ventura) or later
- Xcode 15.0 or later
- Swift 5.9 or later
- Docker Desktop (optional, for testing container features)

### Building

```bash
git clone https://github.com/yourusername/lighthouse.git
cd lighthouse
open Lighthouse.xcodeproj
# Press ⌘R to build and run
```

### Project Structure

```
Lighthouse/
├── LighthouseApp.swift      # App entry point
├── Models/                  # Data structures
├── Services/                # Business logic
├── ViewModels/              # State management
├── Views/                   # SwiftUI views
├── Utilities/               # Helper functions
└── Assets.xcassets/         # Icons and images
```

## Code Style Guidelines

### Swift Style

- **SwiftUI declarative patterns**: Use `@State`, `@Published`, `@ObservedObject` appropriately
- **Async/await**: Prefer modern concurrency over callbacks
- **Error handling**: Use `do-catch` and provide meaningful error messages
- **Naming**: Clear, descriptive names over comments

### Architecture

- **MVVM pattern**: Views → ViewModels → Services → Models
- **Separation of concerns**: Services handle one responsibility
- **Testability**: Services should be injectable and mockable

### Examples

**Good:**
```swift
// Clear naming, single responsibility
func fetchRunningContainers() async throws -> [DockerContainer] {
    let output = try await ShellExecutor.execute("docker ps --format json")
    return try parseContainers(from: output)
}
```

**Avoid:**
```swift
// Vague naming, multiple responsibilities
func getData() async -> Any? {
    // ...
}
```

## Testing

### Manual Testing Checklist

Before submitting a PR, verify:

- [ ] App launches without crashes
- [ ] Local port scanning works
- [ ] Website monitoring adds/removes sites correctly
- [ ] Docker integration works (if Docker is installed)
- [ ] Notifications fire appropriately
- [ ] Menu bar icon reflects health status
- [ ] Profile switching works
- [ ] No memory leaks during extended use

### Test Environments

- [ ] macOS 13.0 (Ventura)
- [ ] macOS 14.0 (Sonoma)
- [ ] macOS 15.0 (Sequoia)
- [ ] Apple Silicon Mac
- [ ] Intel Mac

## Documentation

- Update README.md if adding user-facing features
- Update CHANGELOG.md with your changes
- Add code comments for complex logic only
- Prefer self-documenting code

## Commit Message Format

```
Type: Short description (50 chars max)

Longer description if needed. Wrap at 72 characters.
Explain what and why, not how.

Closes #123
```

**Types:**
- `Add:` New feature
- `Fix:` Bug fix
- `Change:` Modification to existing feature
- `Remove:` Removed feature
- `Docs:` Documentation only
- `Refactor:` Code change that doesn't add features or fix bugs
- `Style:` Formatting, whitespace, etc.

## Release Process

1. Update version in Xcode project
2. Update CHANGELOG.md
3. Create a git tag: `git tag v1.0.0`
4. Push tag: `git push origin v1.0.0`
5. Create GitHub release with changelog excerpt

## Getting Help

- **Questions:** Open a Discussion on GitHub
- **Bugs:** Open an Issue
- **Chat:** [Link to Discord/Slack if applicable]

## Recognition

Contributors are recognized in:
- GitHub contributors list
- Release notes (for significant contributions)

---

Thank you for helping make Lighthouse better!
