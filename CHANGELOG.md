# Changelog

All notable changes to this project will be documented in this file.

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
