# Privacy Policy

**Effective Date:** January 31, 2026  
**App:** Lighthouse — Service Monitor for Mac

---

## Our Commitment

Lighthouse is designed with privacy as a core principle. We believe monitoring tools should work for you, not collect data about you.

**The short version:** Lighthouse collects nothing. Your data stays on your Mac.

---

## Data Collection

### What We Collect
**Nothing.**

Lighthouse does not collect, store, or transmit any personal information, usage data, analytics, crash reports, or telemetry of any kind.

### What Stays on Your Device

All Lighthouse data is stored locally on your Mac and never leaves your device:

| Data Type | Storage Location | Purpose |
|-----------|------------------|---------|
| Website list | `~/Library/Application Support/Lighthouse/websites.json` | Your monitored websites |
| Profiles | `~/Library/Application Support/Lighthouse/profiles.json` | Environment configurations |
| Preferences | macOS User Defaults | App settings |

You can delete all Lighthouse data at any time by removing the app and its support folder.

---

## Network Activity

Lighthouse makes the following network requests:

### Website Monitoring
- **What:** HTTP/HTTPS HEAD requests to URLs you configure
- **Why:** To check if your websites are responding
- **Data sent:** Standard HTTP headers only
- **Data received:** HTTP status code and response time

### Local Port Scanning
- **What:** Queries the local system using `lsof`
- **Why:** To identify running services on your Mac
- **Network impact:** None (local system call only)

### Docker Integration
- **What:** Communicates with local Docker daemon
- **Why:** To list and manage containers
- **Network impact:** Local Unix socket only

---

## Third-Party Services

Lighthouse uses **no third-party services**:

- ❌ No analytics (Google Analytics, Mixpanel, etc.)
- ❌ No crash reporting (Crashlytics, Sentry, etc.)
- ❌ No advertising
- ❌ No social media integration
- ❌ No cloud sync
- ❌ No user accounts

---

## Data Sharing

We do not share any data because we do not collect any data.

---

## Children's Privacy

Lighthouse does not collect information from anyone, including children under 13.

---

## Security

Since Lighthouse stores data only on your device:
- Your data is protected by your Mac's security features
- FileVault encryption protects your data at rest
- No cloud breaches are possible because there is no cloud

---

## Your Rights

You have complete control over your data:

- **Access:** Your data is in plain JSON files you can read anytime
- **Export:** Copy the JSON files to back up or transfer your configuration
- **Delete:** Remove `~/Library/Application Support/Lighthouse/` to delete all data
- **Portability:** JSON format ensures your data is never locked in

---

## Changes to This Policy

If we ever change this policy, we will:
1. Update the "Effective Date" above
2. Describe changes in the app's release notes
3. Continue our commitment to collecting nothing

---

## Open Source

Lighthouse is open source. You can verify our privacy claims by reviewing the code yourself.

---

## Contact

Questions about this privacy policy?

- **GitHub Issues:** [Repository Issues Page]
- **Email:** [Your Contact Email]

---

## Summary

| Question | Answer |
|----------|--------|
| Do you collect personal data? | No |
| Do you use analytics? | No |
| Do you show ads? | No |
| Do you sell data? | No (we have none to sell) |
| Can I verify this? | Yes, the code is open source |

**Lighthouse: All signal, no surveillance.**
