# Social Media Campaign

**Category:** Marketing
**Priority:** P2 Medium
**Effort:** S
**Status:** Not Started

## Summary

Execute a coordinated social media campaign across Twitter/X, Reddit, and developer communities to announce Lighthouse and drive downloads. Focus on platforms where Mac developers and DevOps engineers are active.

## Acceptance Criteria

- [ ] Twitter/X launch thread posted
- [ ] Reddit posts in relevant subreddits
- [ ] Dev community posts (Discord, Slack)
- [ ] Engagement with responses for 48 hours
- [ ] Results tracked and documented
- [ ] Follow-up posts planned

## Technical Notes

### Platform Strategy

| Platform | Audience | Content Type |
|----------|----------|--------------|
| Twitter/X | Developers, tech influencers | Thread, GIF |
| Reddit | Niche communities | Text post |
| Discord | Developer communities | Announcement |
| LinkedIn | Professional devs | Article |

### Twitter/X Launch Thread

**Tweet 1 (Hook):**
```
I built a Mac menu bar app that shows you everything 
running on your machine.

No more "lsof | grep LISTEN" 🎉

Lighthouse shows:
• Local dev servers (with framework detection)
• Docker containers (with controls)
• Website uptime

Free and open source. 🧵
```

**Tweet 2 (Local ports):**
```
See every TCP port in use and which process owns it.

Lighthouse detects 35+ frameworks:
• Next.js, Vite, React
• Django, Flask, Rails
• And more

One click to open in browser, kill process, 
or jump to code in VS Code.

[Screenshot of port view]
```

**Tweet 3 (Docker):**
```
Docker containers at your fingertips.

• Start/stop/restart with one click
• See port mappings
• Works with Docker Desktop or CLI

No more switching to Docker Desktop 
just to restart a container.

[Screenshot of Docker view]
```

**Tweet 4 (Website monitoring):**
```
Monitor your websites without another SaaS subscription.

• Response time tracking
• Uptime percentage
• Notifications when sites go down
• Dev/Staging/Prod profiles

Runs entirely on your Mac. No cloud, no accounts.

[Screenshot of website view]
```

**Tweet 5 (CTA):**
```
Lighthouse is:
✅ Free
✅ Open source (MIT)
✅ Privacy-first (zero tracking)
✅ Native macOS (Swift/SwiftUI)

Download: [Mac App Store link]
Star on GitHub: [GitHub link]

Would love your feedback! What features 
would make this more useful?
```

### Reddit Strategy

**Subreddits to post in:**

| Subreddit | Subscribers | Post Type |
|-----------|-------------|-----------|
| r/macapps | 200k+ | Primary target |
| r/programming | 5M+ | Show-off post |
| r/webdev | 2M+ | For web devs |
| r/devops | 400k+ | Docker angle |
| r/node | 200k+ | Node.js focus |
| r/swift | 100k+ | Technical implementation |

**r/macapps post:**
```
Title: Lighthouse - Menu bar app to monitor local ports, 
Docker containers, and website uptime

I built Lighthouse because I was tired of constantly running 
terminal commands to check what's running on my Mac.

Features:
- See all TCP ports with process info and framework detection
- Docker container management (start/stop/restart)
- Website uptime monitoring with notifications
- Menu bar icon changes color based on health

Free, open source, no tracking.

[App Store link] | [GitHub link]

Would love feedback on what features to add next!
```

**r/devops post (Docker angle):**
```
Title: Made a menu bar app for quick Docker container 
management on Mac

Got tired of opening Docker Desktop just to restart containers.

Lighthouse shows all your containers in the menu bar with 
one-click start/stop/restart. Also shows port mappings 
so you can click to open in browser.

Plus: local port monitoring and website uptime tracking.

Free and open source.
```

### Timing

**Twitter:**
- Post thread in morning (8-10 AM PST)
- Best days: Tuesday-Thursday

**Reddit:**
- Post when subreddit is active (check sidebar)
- r/macapps: Morning PST
- Avoid posting to multiple subs at same time (looks spammy)
- Space posts 24 hours apart

### Engagement Rules

**Do:**
- Respond to every comment
- Thank people for feedback
- Acknowledge valid criticism
- Add feature requests to roadmap

**Don't:**
- Self-promote excessively
- Argue with critics
- Post the same content everywhere
- Use alt accounts

### Discord/Slack Communities

Post in:
- Reactiflux (React developers)
- Python Discord
- Swift community servers
- Local tech Slack groups

**Format:**
```
Hey all! Just released Lighthouse, a free menu bar app 
for monitoring what's running on your Mac.

If you're constantly checking what's on port 3000 or 
restarting Docker containers, this might help.

[Short feature list]
[Links]

Happy to answer questions!
```

### Content Calendar

| Day | Platform | Action |
|-----|----------|--------|
| Day 1 | Twitter | Launch thread |
| Day 1 | r/macapps | Main post |
| Day 2 | r/programming | Show post |
| Day 2 | Discord | Announcements |
| Day 3 | r/webdev | Web dev focus |
| Day 4 | r/devops | Docker focus |
| Day 7 | Twitter | Follow-up thread |

### Tracking

Create simple tracking spreadsheet:

| Platform | Post URL | Upvotes/Likes | Comments | Clicks |
|----------|----------|---------------|----------|--------|
| Twitter | ... | ... | ... | ... |
| r/macapps | ... | ... | ... | ... |

### GIF/Video Assets

Create short GIFs showing:
1. Opening menu bar and scrolling through
2. Framework detection in action
3. Starting/stopping Docker container
4. Website status change notification

Tools: Cleanshot X, Gifox, or Kap (free)

## Dependencies

- App must be live and downloadable
- Screenshots ready
- GIF/video assets created

## Resources

- [MARKETING.md](../../MARKETING.md) - Full marketing strategy
- [APP_STORE.md](../../APP_STORE.md) - App Store description for reference
