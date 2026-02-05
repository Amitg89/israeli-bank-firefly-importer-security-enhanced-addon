#!/usr/bin/with-contenv bashio
set -e

# Firefly III configuration
export FIREFLY_BASE_URL=$(bashio::config 'firefly_base_url')
export FIREFLY_TOKEN_API=$(bashio::config 'firefly_token_api')

# Config file path
export CONFIG_FILE=$(bashio::config 'config_file')

# Master password for decrypting credentials (Security Enhancement)
export MASTER_PASSWORD=$(bashio::config 'master_password')

# Schedule configuration
export CRON=$(bashio::config 'cron')

# Log level
export LOG_LEVEL=$(bashio::config 'log_level')

# Validate master password if using encrypted config
if [[ "$CONFIG_FILE" == *"encrypted"* ]] && [[ -z "$MASTER_PASSWORD" ]]; then
    bashio::log.warning "Config file appears to be encrypted but MASTER_PASSWORD is not set!"
    bashio::log.warning "Please set master_password in addon configuration."
fi

bashio::log.info "Starting Israeli Bank Firefly III Importer (Security Enhanced)"
bashio::log.info "Config file: ${CONFIG_FILE}"
bashio::log.info "Firefly URL: ${FIREFLY_BASE_URL}"
bashio::log.info "Cron schedule: ${CRON}"

# Run the importer (full path - HA container often has minimal PATH)
exec /usr/local/bin/israeli-bank-firefly-importer
