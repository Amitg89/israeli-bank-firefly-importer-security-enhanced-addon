# Changelog

All notable changes to this project will be documented in this file.

## [1.0.28] - 2026-07-19

### Added
- Discount debug capture: when `scraper.options.storeFailureScreenShotPath` is set, the scraper now saves a "filmstrip" (a screenshot every ~1.5s through the post-login wait) plus `discount-debug.log` (console errors, page errors, failed requests, and telebank/gatewayAPI response statuses + final URL) in the same directory. Lets us see WHY the SPA hangs instead of only the final spinner frame. No effect on normal runs.

## [1.0.27] - 2026-07-19

### Changed
- **Switched the add-on base image from Alpine to Debian (glibc)** so Chromium is the full mainstream build instead of Alpine's stripped musl one. This targets the root cause of the Discount login hang: Alpine's Chromium is bot-flagged and freezes on Telebank's post-login SPA loader, while the same scrape succeeds in a real browser. Added `build.yaml` pinning the Debian bookworm base per arch; Chromium path is now `/usr/bin/chromium`; fonts and root execution retained from 1.0.26. Dropped the i386 arch (no Debian bookworm base).

## [1.0.26] - 2026-07-19

### Changed
- Added real fonts (Noto incl. Hebrew, DejaVu) to the image — a fontless browser can fail to render the bank's SPA and hang on its loader.
- Run the container as root so Chromium can save a failure screenshot to the mapped /config volume for debugging (add-ons are isolated containers; Chromium already runs with --no-sandbox). Set `scraper.options.storeFailureScreenShotPath` in your config to capture it.

## [1.0.25] - 2026-07-19

### Fixed
- Discount login blocked in HA's Alpine Chromium (verified: config/credentials are correct and the same scrape succeeds on desktop Chrome). Added in-page stealth to the Discount scraper — spoofs navigator.webdriver/platform/languages/plugins, window.chrome, notification permission, and WebGL vendor/renderer, injected before page scripts so it also covers the post-login SPA where Telebank runs its bot checks. This hides the headless/Linux tells specific to the container browser.

## [1.0.24] - 2026-07-19

### Fixed
- Discount still stalled on the post-login loader from the addon (verified working locally): the Linux/headless fingerprint was the tell. The scraper now presents a coherent Windows-Chrome identity (UA string, client hints, he-IL Accept-Language), and `--disable-blink-features=AutomationControlled` joined the default Chromium args.

## [1.0.23] - 2026-07-19

### Fixed
- Discount login stuck on the SPA loader (UNKNOWN_ERROR): the site's bot detection stalls for a HeadlessChrome user agent. The scraper now masks the UA before submitting (as Isracard does) and polls for the account homepage / password-renewal / error states instead of a single navigation wait.

## [1.0.22] - 2026-07-19

### Fixed
- Chromium now launches with `--disable-dev-shm-usage --no-sandbox --disable-gpu` by default: modern Chromium crashes with "Navigating frame was detached" inside HA's container due to the small /dev/shm. No manual `scraper.options.args` config needed anymore.

## [1.0.21] - 2026-07-19

### Fixed
- "Navigating frame was detached" crash on all scrapers: the addon image installs the latest Alpine Chromium, which the scraper's pinned Puppeteer 22.15 (2024) cannot drive. The scraper fork is now merged with upstream master (Puppeteer 24.40 + 2026 bank-site fixes, including Max credit-card balances), keeping the fork's Isracard login-flip and anti-bot patches.

## [1.0.20] - 2026-07-19

### Added
- Automatic bank balance reconciliation: when the scraped bank balance differs from the balance Firefly III computed from transactions, the importer now creates a Firefly `reconciliation` transaction (tagged `balance-adjustment`) to close the gap. Disable with `reconcileBalance: false` in the importer config yaml.

## [1.0.15] - 2025-02-05

### Fixed
- Addon no longer starts and stops immediately with no logs.
- Aligned with the working [original addon](https://github.com/itairaz1/israeli-bank-firefly-importer-hass-addon) pattern: clone importer repo, `npm install --ignore-scripts` (avoids husky prepare failures in Docker), run `node src/index.js` from a fixed path.
- Log a startup message at the very beginning of `run.sh` so logs always appear when the addon runs.
- Simplified `run.sh`: set env vars then `cd /app/importer && exec node src/index.js` (no IMPORTER_ENTRY or node_modules scan).

### Changed
- `log_level` schema in addon config set to `str` to avoid schema validation issues.

## [1.0.0] - 2024-02-05

### Added
- Initial release of security-enhanced Home Assistant addon
- AES-256-GCM encryption support for credentials
- Master password configuration option
- Log level configuration option
- Comprehensive documentation for secure setup

### Security
- Encrypted configuration file support
- Master password protection for credentials
- Log redaction to prevent credential leakage

### Credits
- Based on [israeli-bank-firefly-importer-hass-addon](https://github.com/itairaz1/israeli-bank-firefly-importer-hass-addon) by Itai Raz
- Uses [israeli-bank-firefly-importer-security-enhanced](https://github.com/Amitg89/israeli-bank-firefly-importer-security-enhanced)
