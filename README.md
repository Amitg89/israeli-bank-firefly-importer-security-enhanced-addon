# Israeli Bank Firefly III Importer - Security Enhanced (Home Assistant Addon)

Home Assistant addon for the security-enhanced Israeli Bank Firefly Importer.

## Credits

This addon is based on the excellent work of:
- **[Itai Raz](https://github.com/itairaz1)** - Original [israeli-bank-firefly-importer](https://github.com/itairaz1/israeli-bank-firefly-importer) and [HA addon](https://github.com/itairaz1/israeli-bank-firefly-importer-hass-addon)
- **[Eran Shaham](https://github.com/eshaham)** - [Israeli Bank Scrapers](https://github.com/eshaham/israeli-bank-scrapers)

## What's Different?

This addon uses the [security-enhanced importer](https://github.com/Amitg89/israeli-bank-firefly-importer-security-enhanced) which adds:

| Feature | Description |
|---------|-------------|
| **AES-256-GCM Encryption** | Bank credentials encrypted at rest |
| **Master Password Protection** | Credentials decrypted only with your password |
| **PBKDF2 Key Derivation** | 100,000 iterations for secure key generation |
| **Log Redaction** | Credentials never appear in logs |

## How it works (wrapper vs scraper)

**This repository is only the wrapper.** It does **not** contain the scraper or importer code.

| What | Where it lives | When it gets used |
|------|----------------|-------------------|
| **Addon (wrapper)** | This repo: `israeli-bank-firefly-importer-security-enhanced-addon` | Defines the HA addon: `config.yaml`, `Dockerfile`, `run.sh`. You add this repo to Home Assistant. |
| **Importer (scraper + Firefly logic)** | Another repo: [israeli-bank-firefly-importer-security-enhanced](https://github.com/Amitg89/israeli-bank-firefly-importer-security-enhanced) | **Downloaded during the Docker image build.** When you install or update the addon, the Dockerfile runs `git clone ... security-enhanced.git /app/importer` and `npm install` there. So the running container has the importer code inside the image. |

Flow:

1. **Install/update addon** → Home Assistant builds a Docker image from this repo’s `Dockerfile`.
2. **During build** → The Dockerfile clones the security-enhanced importer from GitHub into `/app/importer` and runs `npm install --ignore-scripts`. The importer itself depends on [israeli-bank-scrapers](https://github.com/eshaham/israeli-bank-scrapers) (via npm); that’s installed as a dependency, not cloned.
3. **At runtime** → The addon runs `run.sh`, which sets env vars (Firefly URL, config path, master password, cron) and then runs `node /app/importer/src/index.js`. So the “actual” scraper/importer code runs from the copy that was baked into the image at build time.

So: **this project = wrapper only. The scraper/importer code is pulled from GitHub during the installation/build process** (when the addon image is built), not shipped inside this repo.

## Installation

### Step 1: Add Repository to Home Assistant

[![Add repository to Home Assistant](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2FAmitg89%2Fisraeli-bank-firefly-importer-security-enhanced-addon)

Or manually:
1. Go to **Settings** → **Add-ons** → **Add-on Store**
2. Click the menu (⋮) in the top right → **Repositories**
3. Add: `https://github.com/Amitg89/israeli-bank-firefly-importer-security-enhanced-addon`

### Step 2: Install the Addon

1. Find **"Israeli Bank FireFly III Importer (Security Enhanced)"** in the Add-on Store
2. Click **Install**

**Note:** The first install (and each addon version update) builds the image from source (git clone + npm install), which can take **15–30 minutes** depending on your host. Later starts are quick.

### Step 3: Create Configuration Directory

```bash
mkdir -p /config/israeli-bank-firefly-importer
```

### Step 4: Create Your Configuration File

Download the template:

```bash
cd /config/israeli-bank-firefly-importer
wget https://raw.githubusercontent.com/Amitg89/israeli-bank-firefly-importer-security-enhanced-addon/main/israeli-bank-firefly-importer/basic.template.config.yaml -O config.yaml
```

Edit with your credentials:

```yaml
firefly:
  baseUrl: 'http://your-firefly:8080'
  tokenApi: 'your-api-token'

banks:
  - type: leumi
    credentials:
      username: 'your-username'
      password: 'your-password'
    creditCards:
      - type: isracard
        credentials:
          id: '123456789'
          card6Digits: '123456'
          password: 'your-password'
```

### Step 5: Encrypt Your Configuration (Recommended)

The encryption tool runs **on your computer** (or any machine with Node.js), not inside the addon. You then copy the encrypted file into Home Assistant.

**On your computer (PC/Mac/Linux with Node.js installed):**

1. **Create a folder** and put your `config.yaml` there (the one with plaintext bank credentials).

2. **Install the importer package** (includes the encrypt CLI):
   ```bash
   npm install -g https://github.com/Amitg89/israeli-bank-firefly-importer-security-enhanced.git
   ```

3. **Encrypt the config:**
   ```bash
   cd /path/to/your/folder
   israeli-bank-firefly-encrypt -i config.yaml -o config.encrypted.yaml
   ```
   You'll be prompted to create a master password. **Remember this password!**

4. **Copy `config.encrypted.yaml` into Home Assistant:**
   - **Samba share:** Copy to the share folder that maps to `/config` (e.g. `config/israeli-bank-firefly-importer/config.encrypted.yaml`).
   - **File editor addon:** In HA, open **File editor**, go to `/config/israeli-bank-firefly-importer/`, upload or paste the file as `config.encrypted.yaml`.
   - **SSH/SCP:** `scp config.encrypted.yaml user@homeassistant:/config/israeli-bank-firefly-importer/`

5. **Delete the plaintext file** on your computer (and never commit it to git).

**Alternative (if you have Node.js on the HA host):** SSH into Home Assistant, install the package with `npm install -g ...`, then run the encrypt command inside `/config/israeli-bank-firefly-importer` and `rm config.yaml` there. Most HA setups don't have Node.js on the host, so the "on your computer" method above is usually easier.

### Step 6: Configure the Addon

Go to the addon **Configuration** tab and set:

| Option | Value |
|--------|-------|
| `firefly_base_url` | Your Firefly III URL (e.g., `http://192.168.1.100:8080`) |
| `firefly_token_api` | Your Firefly API token (optional if in config file) |
| `config_file` | `/config/israeli-bank-firefly-importer/config.encrypted.yaml` |
| `master_password` | The password you used to encrypt the config |
| `cron` | Schedule (e.g., `0 6 * * *` for daily at 6 AM) |
| `log_level` | `info` (or `debug` for troubleshooting) |

### Step 7: Start the Addon

1. Click **Start**
2. Check the **Log** tab for output
3. Verify transactions appear in Firefly III

---

## Configuration Options

| Option | Required | Description |
|--------|----------|-------------|
| `firefly_base_url` | Yes | URL of your Firefly III instance |
| `firefly_token_api` | No* | Firefly API token (*required if not in config file) |
| `config_file` | Yes | Path to your config file |
| `master_password` | No* | Master password (*required for encrypted configs) |
| `cron` | Yes | Cron schedule for imports |
| `log_level` | No | Log verbosity (info/debug/warn/error) |

---

## Security Best Practices

### 1. Always Use Encrypted Configuration

Never store plaintext credentials. Always encrypt your config file.

### 2. Use Home Assistant Secrets (Alternative)

Instead of setting `master_password` directly, you can use HA secrets:

In `secrets.yaml`:
```yaml
bank_importer_master_password: 'your-strong-password'
```

### 3. Restrict File Permissions

```bash
chmod 600 /config/israeli-bank-firefly-importer/config.encrypted.yaml
chmod 600 /config/secrets.yaml
```

### 4. Enable 2FA on Home Assistant

Always use two-factor authentication on your HA instance.

### 5. Use Cloudflare Access

If exposing HA to the internet, add Cloudflare Access for additional authentication.

---

## Troubleshooting

### "MASTER_PASSWORD is not set"

Set `master_password` in the addon configuration.

### "Failed to decrypt credentials"

- Verify your master password is correct
- Ensure the config file was encrypted with the same password

### "Scraping failed"

- Check your bank credentials are correct
- Try with `log_level: debug` for more details
- Verify your bank's website is accessible

### Addon won't start

Check the Log tab for error messages. Common issues:
- Invalid YAML in config file
- Missing required configuration options

---

## Supported Banks & Credit Cards

### Banks
- Leumi
- Hapoalim
- Discount
- Mizrahi
- Beinleumi
- Otsar Hahayal
- Massad
- Yahav

### Credit Cards
- Isracard
- Visa Cal
- Max
- Amex

---

## Links

- **Security-Enhanced Importer:** https://github.com/Amitg89/israeli-bank-firefly-importer-security-enhanced
- **Original Importer:** https://github.com/itairaz1/israeli-bank-firefly-importer
- **Israeli Bank Scrapers:** https://github.com/eshaham/israeli-bank-scrapers
- **Firefly III:** https://www.firefly-iii.org/

---

## Testing changes without waiting for HA

To validate Dockerfile or `run.sh` changes locally (same image HA builds), run:

```bash
./scripts/build-and-test.sh
```

See [TESTING.md](TESTING.md) for details and other options.

## License

[MIT License](LICENSE)

This project is based on [israeli-bank-firefly-importer-hass-addon](https://github.com/itairaz1/israeli-bank-firefly-importer-hass-addon) which is also MIT licensed.
