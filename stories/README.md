# Lighthouse Stories

This folder contains actionable work items for improving Lighthouse and deploying to the App Store.

## Quick Reference

| Status | Meaning |
|--------|---------|
| Not Started | Work has not begun |
| In Progress | Currently being worked on |
| Complete | Done and verified |
| Blocked | Waiting on dependency or decision |

## Priority Levels

| Priority | Meaning | Timeline |
|----------|---------|----------|
| **P0 Critical** | Must have for App Store launch | This week |
| **P1 High** | Needed before public launch | Before launch |
| **P2 Medium** | Broadens appeal significantly | Post-launch sprint |
| **P3 Low** | Nice to have, polish items | Backlog |

## Effort Estimates

| Size | Time | Examples |
|------|------|----------|
| **XS** | < 30 min | Config changes, simple edits |
| **S** | 1-2 hours | Single-file features, documentation |
| **M** | 2-4 hours | Multi-file features, integrations |
| **L** | 4-8 hours | Complex features, new systems |
| **XL** | 8+ hours | Major features, architecture changes |

---

## Critical Path: 1-Hour App Store Deploy

Complete these stories in order for fastest App Store submission:

1. [Xcode Signing Setup](app-store/03-xcode-signing-setup.md) (XS)
2. [App Icon Finalization](app-store/01-app-icon-finalization.md) (XS)
3. [Screenshots and Previews](app-store/02-screenshots-and-previews.md) (S)
4. [Privacy Policy Hosting](documentation/01-privacy-policy-hosting.md) (XS)
5. [Archive and Upload](app-store/04-archive-and-upload.md) (S)
6. [App Store Listing](app-store/05-app-store-listing.md) (S)
7. [Submit for Review](app-store/06-submit-for-review.md) (XS)

**Total estimated time: 45-60 minutes**

---

## All Stories by Category

### App Store (P0 Critical)

| # | Story | Effort | Status |
|---|-------|--------|--------|
| 1 | [App Icon Finalization](app-store/01-app-icon-finalization.md) | XS | Not Started |
| 2 | [Screenshots and Previews](app-store/02-screenshots-and-previews.md) | S | Not Started |
| 3 | [Xcode Signing Setup](app-store/03-xcode-signing-setup.md) | XS | Not Started |
| 4 | [Archive and Upload](app-store/04-archive-and-upload.md) | S | Not Started |
| 5 | [App Store Listing](app-store/05-app-store-listing.md) | S | Not Started |
| 6 | [Submit for Review](app-store/06-submit-for-review.md) | XS | Not Started |

### Documentation (P1 High)

| # | Story | Effort | Status |
|---|-------|--------|--------|
| 1 | [Privacy Policy Hosting](documentation/01-privacy-policy-hosting.md) | XS | Not Started |
| 2 | [Support URL Setup](documentation/02-support-url-setup.md) | XS | Not Started |
| 3 | [GitHub Pages Site](documentation/03-github-pages-site.md) | M | Not Started |

### Features (P2 Medium)

| # | Story | Effort | Status |
|---|-------|--------|--------|
| 1 | [SSL Certificate Monitoring](features/01-ssl-certificate-monitoring.md) | M | Not Started |
| 2 | [Database Detection](features/02-database-detection.md) | S | Not Started |
| 3 | [Simplified Mode](features/03-simplified-mode.md) | M | Not Started |
| 4 | [Global Keyboard Shortcuts](features/04-global-keyboard-shortcuts.md) | S | Not Started |
| 5 | [Favorites and Starring](features/05-favorites-and-starring.md) | M | Not Started |
| 6 | [Webhook Integrations](features/06-webhook-integrations.md) | L | Not Started |

### Marketing (P2 Medium)

| # | Story | Effort | Status |
|---|-------|--------|--------|
| 1 | [Product Hunt Launch](marketing/01-product-hunt-launch.md) | M | Not Started |
| 2 | [Hacker News Post](marketing/02-hacker-news-post.md) | S | Not Started |
| 3 | [Social Media Campaign](marketing/03-social-media-campaign.md) | S | Not Started |

### Polish (P3 Low)

| # | Story | Effort | Status |
|---|-------|--------|--------|
| 1 | [First Run Experience](polish/01-first-run-experience.md) | M | Not Started |
| 2 | [Onboarding Tooltips](polish/02-onboarding-tooltips.md) | S | Not Started |
| 3 | [Empty States](polish/03-empty-states.md) | S | Not Started |

---

## Sprint Planning Suggestions

### MVP Launch Sprint (P0 + P1)
- All App Store stories (6 stories, ~3 hours)
- Privacy Policy Hosting
- Support URL Setup
- **Total: 8 stories, ~4 hours**

### Broader Appeal Sprint (P2 Features)
- SSL Certificate Monitoring
- Database Detection
- Simplified Mode
- **Total: 3 stories, ~6 hours**

### Growth Sprint (P2 Marketing)
- Product Hunt Launch
- Hacker News Post
- Social Media Campaign
- **Total: 3 stories, ~4 hours**

---

## How to Use These Stories

1. Pick a story from the appropriate priority level
2. Read the full story file for context and acceptance criteria
3. Update the story status as you work
4. Check off acceptance criteria as you complete them
5. Update this README's status column when done
