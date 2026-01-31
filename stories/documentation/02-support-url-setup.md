# Support URL Setup

**Category:** Documentation
**Priority:** P1 High
**Effort:** XS
**Status:** Not Started

## Summary

Configure a public support URL for App Store submission. This is where users can go to get help, report bugs, or request features. GitHub Issues is the recommended approach for open-source projects.

## Acceptance Criteria

- [ ] Support URL is publicly accessible
- [ ] URL loads without authentication required to view
- [ ] Clear instructions for users on how to get help
- [ ] Issue templates configured for bug reports and feature requests
- [ ] URL entered in App Store Connect

## Technical Notes

### Option 1: GitHub Issues (Recommended)

Use the repository's Issues page:
```
https://github.com/[username]/lighthouse/issues
```

**Pros:**
- Already set up
- Issue templates exist
- Public and searchable
- Free

**Verification:**
1. Go to URL in incognito window
2. Verify issues list is visible
3. Verify "New Issue" button works

### Option 2: GitHub Discussions

If you want a more community-focused approach:
```
https://github.com/[username]/lighthouse/discussions
```

Enable in: Repository > Settings > Features > Discussions

### Option 3: Custom Support Page

Create a dedicated support page:
```
https://[username].github.io/lighthouse/support
```

Or use the SUPPORT.md file:
```
https://github.com/[username]/lighthouse/blob/main/SUPPORT.md
```

### Option 4: Email Support

If you prefer email:
```
mailto:support@yourcompany.com
```

**Note:** Apple accepts mailto: URLs but GitHub Issues is better for transparency.

### Issue Templates Verification

Verify issue templates are working:

```
.github/
└── ISSUE_TEMPLATE/
    ├── bug_report.md
    └── feature_request.md
```

Test by:
1. Go to Issues > New Issue
2. Verify templates appear
3. Templates should be pre-filled with structure

### App Store Connect Entry

In App Store Connect:
- Field: "Support URL"
- Value: `https://github.com/[username]/lighthouse/issues`

### Repository Settings Check

Ensure repository is configured correctly:

1. **Repository is Public**
   - Settings > Danger Zone > Visibility should be "Public"

2. **Issues are Enabled**
   - Settings > Features > Issues should be checked

3. **Issue Templates Work**
   - Test creating a new issue
   - Templates should appear

## Dependencies

- Repository must be public
- GitHub Issues must be enabled
- [Issue templates already created in .github/ISSUE_TEMPLATE/]

## Resources

- [SUPPORT.md](../../SUPPORT.md) - Support documentation
- [.github/ISSUE_TEMPLATE/](../../.github/ISSUE_TEMPLATE/) - Issue templates
- [GitHub Issues Documentation](https://docs.github.com/en/issues)
