# Israeli Bank Firefly III Importer (Security Enhanced)

Security-enhanced Home Assistant addon for importing Israeli bank transactions into Firefly III.

## Security Features

- **AES-256-GCM Encryption** - Bank credentials encrypted at rest
- **Master Password Protection** - Decryption requires your password
- **PBKDF2 Key Derivation** - 100,000 iterations for secure keys
- **Log Redaction** - Credentials never appear in logs

## Quick Start

1. Create config directory: `/config/israeli-bank-firefly-importer/`
2. Add your `config.yaml` with bank credentials
3. Encrypt it: `israeli-bank-firefly-encrypt -i config.yaml -o config.encrypted.yaml`
4. Delete plaintext: `rm config.yaml`
5. Set `master_password` in addon configuration
6. Start the addon

## Configuration

| Option | Description |
|--------|-------------|
| `firefly_base_url` | Firefly III URL |
| `firefly_token_api` | Firefly API token |
| `config_file` | Path to config file |
| `master_password` | Decryption password |
| `cron` | Schedule (e.g., `0 6 * * *`) |
| `log_level` | info/debug/warn/error |

## Credits

- [Itai Raz](https://github.com/itairaz1) - Original importer
- [Eran Shaham](https://github.com/eshaham) - Israeli Bank Scrapers

## Links

- [Full Documentation](https://github.com/Amitg89/israeli-bank-firefly-importer-security-enhanced-addon)
- [Security-Enhanced Importer](https://github.com/Amitg89/israeli-bank-firefly-importer-security-enhanced)
