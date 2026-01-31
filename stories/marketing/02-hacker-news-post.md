# Hacker News Post

**Category:** Marketing
**Priority:** P2 Medium
**Effort:** S
**Status:** Not Started

## Summary

Write and submit a "Show HN" post to Hacker News. HN is highly influential in the developer community and can drive significant traffic and adoption for developer tools.

## Acceptance Criteria

- [ ] HN account in good standing (some karma, no recent bans)
- [ ] "Show HN" post title crafted
- [ ] Submission text drafted
- [ ] Post submitted at optimal time
- [ ] Comments monitored and responded to
- [ ] Feedback documented for future improvements

## Technical Notes

### Hacker News Guidelines

**Show HN Requirements:**
- Must be something you made
- Must be something people can try out
- No crowdfunding campaigns
- Be transparent about commercial aspects

### Post Format

#### Title (80 chars max)
```
Show HN: Lighthouse – See what's running on your Mac from the menu bar
```

Alternative titles:
```
Show HN: Lighthouse – Menu bar app to monitor local ports, Docker, and websites
Show HN: I built a menu bar app to replace "lsof | grep LISTEN"
Show HN: Lighthouse – Local service monitoring for Mac developers
```

#### Submission Text

```
I built Lighthouse because I got tired of running "lsof -i" every time 
I needed to figure out what was using port 3000.

Lighthouse sits in your menu bar and shows:

- All listening TCP ports with process info and framework detection 
  (it recognizes Next.js, Vite, Django, Rails, etc.)
- Docker containers with start/stop/restart controls
- Website uptime monitoring with response times

The menu bar icon changes color based on overall health (green/orange/red), 
so you can tell at a glance if something's wrong.

It's free, open source (MIT), and privacy-focused—no accounts, no analytics, 
no data collection.

GitHub: [link]
Mac App Store: [link]

Built with Swift and SwiftUI. Would love feedback on what features would 
make this more useful for your workflow.
```

### Optimal Posting Times

**Best times (PST):**
- 6-8 AM PST (catches US morning + Europe evening)
- 9-11 AM PST (peak US traffic)

**Best days:**
- Tuesday through Thursday
- Avoid: Fridays, weekends, holidays, major news days

### Engagement Strategy

#### First 2 Hours (Critical)
- Stay logged in and refresh constantly
- Respond to every comment within 10 minutes
- Be humble, acknowledge valid criticism
- Don't argue, ask clarifying questions instead

#### Hours 2-24
- Check every 30-60 minutes
- Continue responding thoughtfully
- Thank people for feedback
- Note feature suggestions

### Response Templates

**For feature requests:**
```
Great idea! That's actually on the roadmap [link to ROADMAP.md]. 
Would be curious how you'd prioritize it vs [other feature].
```

**For criticism:**
```
Fair point. The current implementation [explanation]. 
What would work better for your use case?
```

**For "why not just use X?":**
```
Good question! Lighthouse focuses specifically on [differentiation]. 
If you need [X's feature], X is definitely the better choice. 
Lighthouse is for people who want [specific use case].
```

### What HN Likes

✅ Technical depth
✅ Honest about limitations
✅ Open source
✅ Privacy-respecting
✅ Solves a real problem
✅ Clean, simple design

### What HN Dislikes

❌ Marketing speak
❌ Overpromising
❌ Defensive responses
❌ Vote manipulation
❌ Multiple accounts
❌ "Killing it" / hype language

### Handling Success

If the post hits the front page:
1. GitHub will get traffic spike—ensure README is polished
2. App Store may see surge—have it ready
3. Prepare for both praise and harsh criticism
4. Don't let negative comments derail you

### Handling Failure

If the post doesn't gain traction:
1. Don't delete and repost (against rules)
2. Wait at least a month before trying again
3. Analyze what might have gone wrong
4. Consider posting at a different time

### Follow-up Post Ideas

For future HN submissions:
- Technical deep-dive: "How I built X feature"
- Lessons learned: "What I learned launching a Mac app"
- Progress update: "Lighthouse 6 months later"

## Dependencies

- App must be publicly available
- GitHub repository public and polished
- README should be comprehensive

## Resources

- [Show HN Guidelines](https://news.ycombinator.com/showhn.html)
- [Hacker News FAQ](https://news.ycombinator.com/newsfaq.html)
- [MARKETING.md](../../MARKETING.md) - Messaging and positioning
