# Browserless Chromium Add-on

This add-on runs [Browserless v2](https://www.browserless.io/) (open-source edition) — a dedicated full Chrome/Chromium service that other add-ons or automations can connect to over WebSocket using the standard Puppeteer/Playwright CDP protocol.

Its primary purpose in this repository is to give the **Israeli Bank FireFly Importer** a real, non-sandboxed Chrome instance to scrape Discount Telebank's SPA, which hangs under the importer's bundled headless Chromium.

---

## Setup

### 1. Install and start this add-on

1. Go to **Settings → Add-ons → Add-on Store**.
2. Install **Browserless Chromium** from this repository.
3. Go to the **Configuration** tab and set your options (see below).
4. Click **Start**. The add-on exposes port **3000** on your HA host.

### 2. Configure the importer add-on

In the **Israeli Bank FireFly Importer (Security Enhanced)** add-on configuration, set:

```
browser_ws_endpoint: ws://homeassistant.local:3000?token=<your-token>&timeout=300000
```

Replace `homeassistant.local` with your HA host's IP if needed (e.g., `192.168.1.100`).

- The `token=` query parameter must match the `token` option you set in this add-on.
- The `timeout=` query parameter (in milliseconds) overrides the per-session timeout for that connection. Israeli bank scrapes can take several minutes, so `300000` (5 minutes) is a safe starting point. The add-on's `connection_timeout` option sets the server-side default.

---

## Configuration Options

| Option | Default | Description |
|--------|---------|-------------|
| `token` | _(empty)_ | API token clients must supply in `?token=` query params. If blank, Browserless generates a random token on startup and prints it to the logs — set an explicit value so the importer can connect reliably. |
| `connection_timeout` | `600000` | Server-side session timeout in milliseconds (10 minutes). Bank scrapes run for several minutes; set this high enough that a session is never killed mid-scrape. The default `30000` ms shipped by the upstream image is far too short for this use case — that is why we default to 600 000 ms here. |
| `max_concurrent_sessions` | `2` | Maximum number of simultaneous browser sessions. Each session uses ~200–400 MB RAM. Keep this low (1–2) on typical HA hardware. |

---

## Why a high connection_timeout?

The Discount Telebank SPA login takes 30–120 seconds under normal conditions. Browserless's default server-side timeout is 30 seconds, which kills the session before the scrape finishes. The add-on defaults to 600 000 ms (10 minutes) to ensure even slow or retrying scrapes complete. You can reduce this once you know how long your scrapes typically take.

---

## Notes

- The add-on binds Browserless to `0.0.0.0:3000` inside the container (set by the upstream image's `HOST` default). Port 3000 is mapped to the same port on the HA host.
- The upstream image runs as user `blessuser` (UID 999); this add-on preserves that — the wrapper script and the browserless server both run unprivileged.
- For `/dev/shm` constraints on HA hardware, the add-on image inherits the upstream's `--shm-size` defaults. If you see Chrome OOM crashes, check HA Supervisor logs for memory pressure.
