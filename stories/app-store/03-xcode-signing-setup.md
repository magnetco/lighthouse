# Xcode Signing Setup

**Category:** App Store
**Priority:** P0 Critical
**Effort:** XS
**Status:** Not Started

## Summary

Configure Xcode project signing settings for App Store distribution. This includes setting up your Apple Developer Team ID, configuring automatic signing, and ensuring the bundle identifier is unique and registered.

## Acceptance Criteria

- [ ] Apple Developer Team selected in Xcode
- [ ] Automatic signing enabled
- [ ] Bundle identifier is unique (e.g., `com.yourname.lighthouse`)
- [ ] Signing certificate valid for Mac App Store distribution
- [ ] No signing errors or warnings in Xcode
- [ ] App builds successfully with Release configuration

## Technical Notes

### Prerequisites

- Active Apple Developer Program membership ($99/year)
- Xcode signed into your Apple ID (Xcode > Settings > Accounts)

### Configuration Steps

1. **Open Project Settings**
   ```
   Open Lighthouse.xcodeproj
   Select "Lighthouse" target
   Go to "Signing & Capabilities" tab
   ```

2. **Configure Signing**
   - Check "Automatically manage signing"
   - Select your Team from dropdown
   - Verify bundle identifier is unique

3. **Verify Bundle Identifier**
   
   Current: Check `Lighthouse.xcodeproj/project.pbxproj` for `PRODUCT_BUNDLE_IDENTIFIER`
   
   Recommended format: `com.yourcompany.Lighthouse` or `com.yourname.Lighthouse`

4. **Update ExportOptions.plist**
   
   File: `ExportOptions.plist`
   
   Replace `YOUR_TEAM_ID` with your actual team ID:
   ```xml
   <key>teamID</key>
   <string>ABCD1234EF</string>
   ```

### Finding Your Team ID

1. Go to [Apple Developer Portal](https://developer.apple.com/account)
2. Click "Membership" in sidebar
3. Team ID is listed there (10-character alphanumeric)

### Entitlements Check

Verify `Lighthouse/Lighthouse.entitlements` contains required entitlements:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key>
    <true/>
    <key>com.apple.security.network.client</key>
    <true/>
</dict>
</plist>
```

### Common Issues

| Issue | Solution |
|-------|----------|
| "No signing certificate" | Download certificates in Xcode > Settings > Accounts |
| "Bundle ID already in use" | Choose a different bundle identifier |
| "Provisioning profile" errors | Let Xcode manage automatically |
| Team not appearing | Ensure Developer Program membership is active |

### Verification

```bash
# Build for release to verify signing
xcodebuild -project Lighthouse.xcodeproj \
  -scheme Lighthouse \
  -configuration Release \
  build
```

## Dependencies

None - this should be done first in the critical path.

## Resources

- [Apple Developer Program](https://developer.apple.com/programs/)
- [Code Signing Guide](https://developer.apple.com/support/code-signing/)
- [Distributing Your App](https://developer.apple.com/documentation/xcode/distributing-your-app-for-beta-testing-and-releases)
