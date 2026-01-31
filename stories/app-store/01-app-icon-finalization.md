# App Icon Finalization

**Category:** App Store
**Priority:** P0 Critical
**Effort:** XS
**Status:** Not Started

## Summary

Verify that all required app icon sizes are present in `Assets.xcassets/AppIcon.appiconset` and meet Apple's requirements for Mac App Store submission. The icon should be a high-quality lighthouse beacon that works well at all sizes from 16x16 to 1024x1024.

## Acceptance Criteria

- [ ] Icon exists at all required sizes (16, 32, 64, 128, 256, 512, 1024 at 1x and 2x)
- [ ] `Contents.json` references all icon files correctly
- [ ] Icon is visually clear at smallest size (16x16)
- [ ] Icon has no transparency issues (macOS icons should have transparency)
- [ ] Icon passes Xcode validation (no yellow warnings in asset catalog)
- [ ] Icon looks good in both light and dark menu bar

## Technical Notes

### Required Icon Sizes for macOS

| Size | Scale | Filename Convention |
|------|-------|---------------------|
| 16x16 | 1x | icon_16x16.png |
| 16x16 | 2x | icon_16x16@2x.png |
| 32x32 | 1x | icon_32x32.png |
| 32x32 | 2x | icon_32x32@2x.png |
| 128x128 | 1x | icon_128x128.png |
| 128x128 | 2x | icon_128x128@2x.png |
| 256x256 | 1x | icon_256x256.png |
| 256x256 | 2x | icon_256x256@2x.png |
| 512x512 | 1x | icon_512x512.png |
| 512x512 | 2x | icon_512x512@2x.png |

### File Location

```
Lighthouse/Assets.xcassets/AppIcon.appiconset/
├── Contents.json
└── [icon files]
```

### Verification Commands

```bash
# Check what's in the appiconset
ls -la Lighthouse/Assets.xcassets/AppIcon.appiconset/

# Validate Contents.json
cat Lighthouse/Assets.xcassets/AppIcon.appiconset/Contents.json | python3 -m json.tool
```

### Icon Design Guidelines

- Use a simple, recognizable lighthouse silhouette
- Ensure the beacon/light element is visible even at small sizes
- Consider the nautical theme (blue, amber, white)
- Test against both light and dark backgrounds

## Dependencies

None - this can be done first.

## Resources

- [Apple Human Interface Guidelines - App Icons](https://developer.apple.com/design/human-interface-guidelines/app-icons)
- [App Icon Sizes Reference](https://developer.apple.com/design/human-interface-guidelines/foundations/app-icons/)
- [Icon Generator Tools](https://appicon.co/)
