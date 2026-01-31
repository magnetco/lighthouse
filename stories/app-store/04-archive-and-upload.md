# Archive and Upload

**Category:** App Store
**Priority:** P0 Critical
**Effort:** S
**Status:** Not Started

## Summary

Build a release archive of Lighthouse and upload it to App Store Connect. This creates the distributable binary that will be reviewed by Apple and eventually published to the Mac App Store.

## Acceptance Criteria

- [ ] Release archive created successfully
- [ ] Archive passes Xcode validation
- [ ] Archive uploaded to App Store Connect
- [ ] Build appears in App Store Connect within 30 minutes
- [ ] No errors or warnings during upload

## Technical Notes

### Method 1: Xcode GUI (Recommended)

1. **Create Archive**
   ```
   Product > Archive
   ```
   Wait for build to complete (2-5 minutes)

2. **Open Organizer**
   ```
   Window > Organizer
   ```
   Or it opens automatically after archive

3. **Validate Archive**
   - Select the new archive
   - Click "Validate App"
   - Sign in with Apple ID if prompted
   - Wait for validation (1-2 minutes)

4. **Distribute to App Store**
   - Click "Distribute App"
   - Select "App Store Connect"
   - Choose "Upload"
   - Follow prompts
   - Wait for upload (2-5 minutes)

### Method 2: Command Line

```bash
# Create archive
xcodebuild -project Lighthouse.xcodeproj \
  -scheme Lighthouse \
  -configuration Release \
  -archivePath build/Lighthouse.xcarchive \
  archive

# Export for App Store
xcodebuild -exportArchive \
  -archivePath build/Lighthouse.xcarchive \
  -exportPath build/export \
  -exportOptionsPlist ExportOptions.plist

# Upload using altool (deprecated) or notarytool
xcrun altool --upload-app \
  -f build/export/Lighthouse.app \
  -t macos \
  -u "your@email.com" \
  -p "@keychain:AC_PASSWORD"
```

### Using the Makefile

```bash
# Create archive
make archive

# Note: Upload still requires Xcode Organizer or altool
```

### Pre-Archive Checklist

- [ ] Version number set correctly (e.g., 1.0.0)
- [ ] Build number incremented (e.g., 1)
- [ ] Signing configured (see story 03)
- [ ] All code changes committed
- [ ] App tested in Release configuration

### Version Number Location

In Xcode:
```
Target > General > Identity
- Version: 1.0.0 (MARKETING_VERSION)
- Build: 1 (CURRENT_PROJECT_VERSION)
```

Or in `project.pbxproj`:
```
MARKETING_VERSION = 1.0.0;
CURRENT_PROJECT_VERSION = 1;
```

### Common Issues

| Issue | Solution |
|-------|----------|
| "Archive not showing" | Ensure scheme is set to Release |
| "Validation failed" | Check signing, entitlements, bundle ID |
| "Upload failed" | Check network, try again, check Apple status |
| "Processing" for hours | Normal for first upload, wait up to 24h |

### Post-Upload

After upload:
1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Select your app
3. Check "TestFlight" or "App Store" tab
4. Build should appear within 30 minutes
5. May show "Processing" for up to 24 hours

## Dependencies

- [03-xcode-signing-setup](03-xcode-signing-setup.md) - Signing must be configured first
- [01-app-icon-finalization](01-app-icon-finalization.md) - Icon should be ready

## Resources

- [Uploading Your App](https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds)
- [App Store Connect](https://appstoreconnect.apple.com)
- [Transporter App](https://apps.apple.com/app/transporter/id1450874784) (alternative uploader)
