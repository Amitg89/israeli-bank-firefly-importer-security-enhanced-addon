# Changelog

All notable changes to this project will be documented in this file.

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
