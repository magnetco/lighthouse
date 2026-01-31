# Screenshots and Previews

**Category:** App Store
**Priority:** P0 Critical
**Effort:** S
**Status:** Not Started

## Summary

Capture high-quality screenshots of Lighthouse in action for the Mac App Store listing. Screenshots should showcase all major features: local port monitoring, website status, Docker containers, and the menu bar health indicator.

## Acceptance Criteria

- [ ] 5 screenshots captured at correct resolution
- [ ] Screenshots show real, realistic data (not empty states)
- [ ] Each major feature is represented in at least one screenshot
- [ ] Screenshots work in both light and dark mode (choose one or provide both)
- [ ] Screenshots are saved in PNG format
- [ ] Optional: App preview video (15-30 seconds)

## Technical Notes

### Required Screenshot Sizes

Mac App Store accepts these sizes (provide at least one):

| Resolution | Display |
|------------|---------|
| 1280 x 800 | MacBook Air 11" |
| 1440 x 900 | MacBook Air 13" |
| 2560 x 1600 | MacBook Pro 13" Retina |
| 2880 x 1800 | MacBook Pro 15" Retina |

**Recommended:** 2880 x 1800 (highest quality, scales down well)

### Screenshot Checklist

1. **Menu Bar Overview**
   - Full menu expanded
   - Show all three sections visible
   - Health indicator in green state

2. **Local Ports ("In the Harbor")**
   - Multiple dev servers running
   - Framework icons visible (Next.js, Vite, Django)
   - Project names detected

3. **Website Monitoring ("Out at Sea")**
   - Mix of healthy and monitored sites
   - Response times visible
   - Uptime percentages shown

4. **Docker Containers ("Container Ships")**
   - Running and stopped containers
   - Port mappings visible
   - Status indicators

5. **Notifications/Alerts**
   - Desktop notification example
   - Or profile switching UI

### Capture Commands

```bash
# macOS screenshot of specific window
# Press Cmd+Shift+4, then Space, then click the menu

# Or use screencapture CLI
screencapture -w screenshot.png
```

### Tips for Great Screenshots

1. **Prepare sample data:**
   - Run 3-4 dev servers on different ports
   - Add 4-5 websites to monitor
   - Start some Docker containers

2. **Clean up the display:**
   - Hide other menu bar items if possible
   - Use a clean desktop background
   - Ensure no sensitive data visible

3. **Timing:**
   - Capture when all services show "healthy"
   - Ensure response times are realistic (50-200ms)

### Storage Location

Create a folder for App Store assets:
```
marketing/
└── screenshots/
    ├── 01-menu-overview.png
    ├── 02-local-ports.png
    ├── 03-website-monitoring.png
    ├── 04-docker-containers.png
    └── 05-notifications.png
```

## Dependencies

- App must be running with sample data
- [01-app-icon-finalization](01-app-icon-finalization.md) - Icon should be finalized first

## Resources

- [App Store Screenshot Specifications](https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications)
- [Screenshot Best Practices](https://developer.apple.com/app-store/product-page/)
