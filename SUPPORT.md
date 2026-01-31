# Lighthouse Support

## Getting Help

### Documentation
- [README](./README.md) — Overview and features
- [CHANGELOG](./CHANGELOG.md) — Version history
- [ROADMAP](./ROADMAP.md) — Planned features

### Common Issues

#### Port scanning not working
**Symptom:** "In the Harbor" section is empty even though services are running.

**Solutions:**
1. Ensure Lighthouse has necessary permissions in System Settings > Privacy & Security
2. Try running `lsof -iTCP -sTCP:LISTEN -n -P` in Terminal to verify ports are detectable
3. Restart Lighthouse

#### Docker containers not appearing
**Symptom:** "Container Ships" section shows "Docker not available" or is empty.

**Solutions:**
1. Ensure Docker Desktop is running
2. Verify Docker CLI works: run `docker ps` in Terminal
3. Restart Docker Desktop, then restart Lighthouse

#### Website monitoring shows incorrect status
**Symptom:** Website shows as down but it's actually up (or vice versa).

**Solutions:**
1. Check if the URL is correct (including https://)
2. Some sites block HEAD requests—Lighthouse will retry with GET
3. Check if the site requires authentication (monitoring won't work for auth-protected sites)
4. Verify your network connection

#### Notifications not appearing
**Symptom:** No desktop notifications when status changes.

**Solutions:**
1. Check System Settings > Notifications > Lighthouse
2. Ensure notifications are enabled and not set to "None"
3. Check Focus mode isn't blocking notifications

#### High CPU or memory usage
**Symptom:** Lighthouse using excessive resources.

**Solutions:**
1. Reduce the number of monitored websites
2. Increase refresh intervals in profile settings
3. File a bug report with details

### Feature Requests
Have an idea for Lighthouse? We'd love to hear it!

1. Check [ROADMAP.md](./ROADMAP.md) to see if it's already planned
2. Search [existing issues](https://github.com/yourusername/lighthouse/issues) for similar requests
3. Open a new [feature request](https://github.com/yourusername/lighthouse/issues/new?template=feature_request.md)

### Bug Reports
Found a bug? Help us fix it!

1. Search [existing issues](https://github.com/yourusername/lighthouse/issues) to avoid duplicates
2. Open a new [bug report](https://github.com/yourusername/lighthouse/issues/new?template=bug_report.md)
3. Include: macOS version, Lighthouse version, steps to reproduce

### Contact

- **GitHub Issues:** [Open an issue](https://github.com/yourusername/lighthouse/issues) (preferred)
- **Email:** [your-email@example.com]

### Response Time
We aim to respond to:
- **Critical bugs:** Within 24 hours
- **General bugs:** Within 1 week
- **Feature requests:** Reviewed monthly

---

## FAQ

### Is Lighthouse free?
Yes, Lighthouse is free and open source under the MIT license.

### Does Lighthouse collect any data?
No. Lighthouse runs entirely on your Mac and collects zero data. See our [Privacy Policy](./PRIVACY.md).

### Why does Lighthouse need network access?
Network access is used only for:
1. Website monitoring (HTTP/HTTPS requests to URLs you configure)
2. Docker communication (local Unix socket)

No data is sent to any external servers we control.

### Can I use Lighthouse without Docker?
Absolutely! Docker integration is optional. Port monitoring and website monitoring work independently.

### Does Lighthouse work with Podman?
Not currently, but it's on the roadmap. The Docker CLI interface is similar enough that support could be added.

### Can I monitor internal/VPN-only sites?
Yes, as long as your Mac can reach them. Lighthouse makes requests from your Mac's network context.

### Why is a website showing as "down" when I can access it?
Some possibilities:
- The site blocks HEAD requests (we'll fall back to GET in a future update)
- DNS resolution issues
- The site requires authentication
- Rate limiting

### How do I completely uninstall Lighthouse?
1. Quit Lighthouse
2. Delete the app from Applications
3. Remove data: `rm -rf ~/Library/Application\ Support/Lighthouse`
4. Remove preferences: `defaults delete com.yourcompany.Lighthouse`

---

## Troubleshooting Checklist

If something isn't working:

- [ ] Is Lighthouse the latest version?
- [ ] Have you tried quitting and restarting Lighthouse?
- [ ] Is your Mac running macOS 13.0 or later?
- [ ] Do the relevant commands work in Terminal? (`lsof`, `docker`)
- [ ] Have you checked System Settings for any permission issues?

If you've tried all of these and still have issues, please open a bug report with:
- macOS version
- Lighthouse version
- Exact steps to reproduce
- What you expected vs. what happened
