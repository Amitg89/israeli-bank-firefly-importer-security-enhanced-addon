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

bashio::log.info "Config: ${CONFIG_FILE}, Firefly: ${FIREFLY_BASE_URL}, Cron: ${CRON}, ScraperTimeout: ${SCRAPER_TIMEOUT}ms"

# Run from importer directory so module resolution and cwd are correct (fixed path from Dockerfile)
cd /app/importer || { bashio::log.error "Importer directory missing"; exit 1; }
exec node src/index.js
