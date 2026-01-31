# Privacy Policy Hosting

**Category:** Documentation
**Priority:** P1 High
**Effort:** XS
**Status:** Not Started

## Summary

Host the PRIVACY.md file at a publicly accessible URL. This is required by Apple for App Store submission. The URL must be stable and always accessible.

## Acceptance Criteria

- [ ] Privacy policy accessible at a public URL
- [ ] URL loads without authentication
- [ ] Content matches PRIVACY.md in repository
- [ ] URL is HTTPS (not HTTP)
- [ ] Page loads quickly and reliably

## Technical Notes

### Option 1: GitHub Raw URL (Quickest)

Use the raw GitHub URL:
```
https://raw.githubusercontent.com/[username]/lighthouse/main/PRIVACY.md
```

**Pros:** Instant, no setup
**Cons:** Shows raw markdown, not formatted

### Option 2: GitHub Pages (Recommended)

1. Enable GitHub Pages in repository settings
2. Privacy policy available at:
```
https://[username].github.io/lighthouse/PRIVACY
```

**Steps:**
1. Go to Repository > Settings > Pages
2. Source: "Deploy from a branch"
3. Branch: main, folder: / (root)
4. Save

The markdown will render as HTML automatically.

### Option 3: GitHub Blob URL

Link to the formatted view:
```
https://github.com/[username]/lighthouse/blob/main/PRIVACY.md
```

**Pros:** Formatted, always up-to-date
**Cons:** Shows GitHub UI around it

### Option 4: Custom Domain

If you have a website:
```
https://yoursite.com/lighthouse/privacy
```

Copy PRIVACY.md content to your site.

### Verification

After setting up, verify:

```bash
# Check URL is accessible
curl -I "https://[your-privacy-url]"
# Should return HTTP 200
```

### App Store Connect Entry

In App Store Connect:
- Field: "Privacy Policy URL"
- Value: Your chosen URL

### URL Requirements

Apple requires:
- Must be publicly accessible (no login)
- Must be HTTPS
- Must contain actual privacy policy content
- Should not redirect excessively

## Dependencies

- Repository must be public (for GitHub options)
- Or: Custom domain configured

## Resources

- [PRIVACY.md](../../PRIVACY.md) - Source content
- [GitHub Pages Setup](https://docs.github.com/en/pages/getting-started-with-github-pages)
- [App Store Privacy Policy Requirements](https://developer.apple.com/app-store/review/guidelines/#privacy)
