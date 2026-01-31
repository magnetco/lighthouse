# GitHub Pages Site

**Category:** Documentation
**Priority:** P1 High
**Effort:** M
**Status:** Not Started

## Summary

Create a simple landing page for Lighthouse using GitHub Pages. This provides a professional marketing URL, hosts the privacy policy in formatted HTML, and gives users a place to learn about the app before downloading.

## Acceptance Criteria

- [ ] GitHub Pages enabled on repository
- [ ] Landing page accessible at `https://[username].github.io/lighthouse/`
- [ ] Page includes app description and features
- [ ] Download link to Mac App Store
- [ ] Privacy policy accessible at `/privacy`
- [ ] Support link accessible at `/support`
- [ ] Mobile-responsive design

## Technical Notes

### Option 1: Minimal Setup (README as Homepage)

GitHub Pages can serve your README.md as the homepage:

1. Go to Repository > Settings > Pages
2. Source: Deploy from branch
3. Branch: `main`, folder: `/ (root)`
4. Save

Your README.md becomes the homepage automatically.

### Option 2: Dedicated docs/ Folder

Create a `docs/` folder with custom pages:

```
docs/
├── index.md          # Landing page
├── privacy.md        # Privacy policy (copy from PRIVACY.md)
├── support.md        # Support info (copy from SUPPORT.md)
└── _config.yml       # Jekyll configuration
```

**_config.yml:**
```yaml
title: Lighthouse
description: Your Mac's service control center
theme: jekyll-theme-cayman
```

Then in Settings > Pages:
- Source: Deploy from branch
- Branch: `main`, folder: `/docs`

### Option 3: Custom Landing Page

Create a polished `docs/index.md`:

```markdown
---
layout: default
title: Lighthouse - Service Monitor for Mac
---

# Lighthouse

**Your Mac's service control center, right in the menu bar.**

See what's running locally, monitor your websites, and manage Docker containers—all from a single, elegant menu bar app.

## Features

- **Local Port Monitoring** - See every service running on your Mac
- **Docker Integration** - Manage containers without leaving your workflow
- **Website Uptime** - Know when your sites go down before your users do
- **Privacy First** - No accounts, no cloud, no tracking

## Download

[Download on the Mac App Store](#) <!-- Update with real link -->

## Links

- [Privacy Policy](./privacy)
- [Support](./support)
- [GitHub](https://github.com/[username]/lighthouse)

---

© 2026 [Your Name]. All rights reserved.
```

### Jekyll Theme Options

GitHub Pages supports these themes:
- `jekyll-theme-cayman` (blue header, clean)
- `jekyll-theme-minimal` (very simple)
- `jekyll-theme-slate` (dark header)
- `jekyll-theme-hacker` (terminal-style)

### Custom Domain (Optional)

If you own a domain:

1. Create `docs/CNAME` file:
   ```
   lighthouse.yoursite.com
   ```

2. Configure DNS:
   - CNAME record: `lighthouse` → `[username].github.io`

3. Enable HTTPS in GitHub Pages settings

### Testing Locally

```bash
# Install Jekyll
gem install bundler jekyll

# Navigate to docs folder
cd docs

# Serve locally
bundle exec jekyll serve

# Visit http://localhost:4000
```

### URLs After Setup

| Page | URL |
|------|-----|
| Home | `https://[username].github.io/lighthouse/` |
| Privacy | `https://[username].github.io/lighthouse/privacy` |
| Support | `https://[username].github.io/lighthouse/support` |

## Dependencies

- Repository must be public
- [01-privacy-policy-hosting](01-privacy-policy-hosting.md) - Can be combined with this story

## Resources

- [GitHub Pages Documentation](https://docs.github.com/en/pages)
- [Jekyll Themes](https://pages.github.com/themes/)
- [MARKETING.md](../../MARKETING.md) - Content for landing page
