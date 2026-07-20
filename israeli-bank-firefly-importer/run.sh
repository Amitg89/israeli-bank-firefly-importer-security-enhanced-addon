#!/usr/bin/with-contenv bashio
set -e

# Log immediately so we always have output if the addon runs (helps debug "start and stop with no logs")
bashio::log.info "Israeli Bank Firefly III Importer (Security Enhanced) addon starting"

# Firefly III configuration
export FIREFLY_BASE_URL=$(bashio::config 'firefly_base_url')
export FIREFLY_TOKEN_API=$(bashio::config 'firefly_token_api')

# Config file path
export CONFIG_FILE=$(bashio::config 'config_file')

# Security: master password for decrypting credentials (optional if using encrypted config)
export MASTER_PASSWORD=$(bashio::config 'master_password')

# Schedule, log level, and scraper navigation timeout (ms; higher helps in Docker/HA)
export CRON=$(bashio::config 'cron')
export LOG_LEVEL=$(bashio::config 'log_level')
export SCRAPER_TIMEOUT=$(bashio::config 'scraper_timeout')
export SCRAPER_BROWSER_WS_ENDPOINT=$(bashio::config 'browser_ws_endpoint')
# bashio returns the literal string "null" for a missing/unset optional key
# (e.g. right after upgrading, before the new option is saved) — treat as empty.
if [ "${SCRAPER_BROWSER_WS_ENDPOINT}" = "null" ]; then
    export SCRAPER_BROWSER_WS_ENDPOINT=""
fi

if [ -n "${SCRAPER_BROWSER_WS_ENDPOINT}" ]; then
    _redacted=$(echo "${SCRAPER_BROWSER_WS_ENDPOINT}" | sed 's/token=[^&?]*/token=***/g')
    bashio::log.info "Browser mode: remote (Browserless) at ${_redacted}"
else
    bashio::log.info "Browser mode: local Chromium"
fi

bashio::log.info "Config: ${CONFIG_FILE}, Firefly: ${FIREFLY_BASE_URL}, Cron: ${CRON}, ScraperTimeout: ${SCRAPER_TIMEOUT}ms"

# Run from importer directory so module resolution and cwd are correct (fixed path from Dockerfile)
cd /app/importer || { bashio::log.error "Importer directory missing"; exit 1; }
exec node src/index.js
