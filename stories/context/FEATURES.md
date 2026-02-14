# Lighthouse Features

This document describes the key features implemented in Lighthouse.

## Database Detection

Lighthouse automatically detects common database servers running on your machine and displays them with appropriate icons and connection information.

### Supported Databases

- **PostgreSQL** (port 5432) - `postgresql://localhost:5432/database`
- **MySQL/MariaDB** (port 3306) - `mysql://localhost:3306/database`
- **MongoDB** (port 27017) - `mongodb://localhost:27017`
- **Redis** (port 6379) - `redis://localhost:6379`
- **Memcached** (port 11211) - `localhost:11211`
- **Elasticsearch** (ports 9200, 9300) - `http://localhost:9200`

### Features

- Automatic detection by process name and port number
- Database-specific icons (SF Symbols fallback)
- Quick-copy connection strings via dedicated button
- Works alongside existing framework detection

### Usage

1. Start a database server (e.g., `postgres`, `mongod`, `redis-server`)
2. Lighthouse will automatically detect it in the "LOCAL" section
3. Click the link icon to copy the connection string to clipboard
4. Use the connection string in your application

## Favorites and Starring

Star your frequently-used ports and websites to keep them at the top of their sections for quick access.

### Features

- Star/unstar ports and websites with a single click
- Starred items automatically sort to the top
- Stars persist across app restarts
- Visual indicator (yellow star icon)
- Context menu integration

### Usage

**Starring Items:**
1. Click the star icon next to any port or website
2. The item will move to the top of its section
3. Click again to unstar

**Filtering:**
- Future enhancement: Toggle to show only starred items

### Storage

- **Ports**: Stored in UserDefaults by unique identifier (port + path/process)
- **Websites**: Stored in website configuration files

## Global Keyboard Shortcuts

Access Lighthouse from anywhere in macOS using a global keyboard shortcut.

### Default Shortcut

**⌃⌥L** (Control + Option + L)

### Features

- System-wide hotkey activation
- Works from any application
- Shortcut persists across app restarts
- Customizable (future enhancement)
- No accessibility permissions required

### Usage

1. Press **⌃⌥L** from anywhere in macOS
2. Lighthouse menu bar will open immediately
3. Navigate using mouse or keyboard

### Customization

The default shortcut is **Control + Option + L**. To customize:
- Future enhancement: Settings panel for shortcut configuration
- Current: Modify `ShortcutManager.swift` to change default

## Webhook Integrations

Send notifications to external services when website status changes.

### Supported Services

1. **Slack** - Incoming Webhooks with Block Kit formatting
2. **Discord** - Webhook embeds with color-coded status
3. **Generic JSON** - Custom endpoints with standard JSON payload

### Features

- Multiple webhook configurations
- Per-webhook enable/disable toggle
- Configurable trigger events:
  - Site goes down (error state)
  - Site recovers (back to healthy)
  - Site has warnings (slow response/redirects)
- Rate limiting (1 minute minimum between notifications)
- Test webhook button
- Per-website webhook enable/disable

### Setup

**Adding a Webhook:**

1. Click the settings icon (⚙️) in the footer
2. Click "Add Webhook" (+)
3. Configure:
   - **Name**: Friendly name for the webhook
   - **Type**: Slack, Discord, or Generic JSON
   - **URL**: Webhook endpoint URL
   - **Triggers**: Select which events should trigger notifications
4. Click "Add Webhook"

**Testing a Webhook:**

1. Open webhook settings
2. Click the paper plane icon next to any webhook
3. A test notification will be sent immediately

### Webhook Formats

**Slack Payload:**
```json
{
  "blocks": [
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "🔴 *example.com* is DOWN"
      }
    },
    {
      "type": "context",
      "elements": [
        {
          "type": "mrkdwn",
          "text": "URL: https://example.com | Response: 0ms | Status: 500"
        }
      ]
    }
  ]
}
```

**Discord Payload:**
```json
{
  "embeds": [
    {
      "title": "🔴 Site Down",
      "description": "example.com",
      "color": 16711680,
      "fields": [
        {"name": "URL", "value": "https://example.com", "inline": true},
        {"name": "Response Time", "value": "0ms", "inline": true},
        {"name": "Status Code", "value": "500", "inline": true}
      ],
      "timestamp": "2026-01-31T12:00:00Z"
    }
  ]
}
```

**Generic JSON Payload:**
```json
{
  "event": "site_down",
  "website": {
    "name": "example.com",
    "url": "https://example.com"
  },
  "status": {
    "code": 500,
    "responseTime": 0
  },
  "timestamp": "2026-01-31T12:00:00Z",
  "source": "lighthouse"
}
```

### Rate Limiting

Webhooks are rate-limited to prevent spam:
- Minimum interval: 60 seconds between notifications per webhook
- Applies per webhook configuration
- Prevents notification storms during outages

### Storage

Webhook configurations are stored in:
```
~/Library/Application Support/Lighthouse/webhooks.json
```

## Implementation Details

### Architecture

```
Models/
├── PortInfo.swift          # Extended with isStarred
├── WebsiteInfo.swift       # Extended with isStarred, webhooksEnabled
└── WebhookConfig.swift     # New: Webhook configuration

Services/
├── FavoritesStorage.swift  # New: Favorites persistence
├── WebhookService.swift    # New: Webhook delivery
├── WebhookStorage.swift    # New: Webhook persistence
└── ShortcutManager.swift   # New: Global shortcuts

Utilities/
└── FrameworkIconMapper.swift  # Extended with database detection

Views/
└── WebhookSettingsView.swift  # New: Webhook management UI
```

### Database Detection Logic

1. Check process name for database keywords
2. Fallback to port number matching
3. Generate connection string based on database type
4. Display database-specific icon

### Favorites Logic

1. Generate unique identifier: `port-workingDirectory` or `port-processName`
2. Store in UserDefaults as Set<String>
3. Apply starred status on port refresh
4. Sort: starred first, then by port/name

### Webhook Delivery Flow

1. Website status changes detected
2. Check if webhooks enabled for website
3. For each enabled webhook:
   - Check trigger conditions
   - Check rate limit
   - Format payload for webhook type
   - Send HTTP POST request
   - Record send time for rate limiting

### Global Shortcuts

1. Register hotkey with Carbon Events API
2. Install event handler for keyboard events
3. On hotkey press:
   - Activate app
   - Post notification to open menu
4. Persist shortcut configuration in UserDefaults

## Future Enhancements

- [ ] Customizable keyboard shortcuts UI
- [ ] Filter toggle for starred-only view
- [ ] Webhook retry logic
- [ ] Webhook delivery history
- [ ] More database types (CouchDB, Cassandra, etc.)
- [ ] Connection string templates
- [ ] Webhook payload customization
- [ ] Multiple shortcut actions
