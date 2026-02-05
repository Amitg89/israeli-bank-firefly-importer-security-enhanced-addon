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

# Run the importer via node - use path recorded at build time, or discover
ENTRY=""
if [[ -f /app/IMPORTER_ENTRY ]]; then
  read -r ENTRY < /app/IMPORTER_ENTRY
  [[ -f "$ENTRY" ]] || ENTRY=""
fi
if [[ -z "$ENTRY" ]]; then
  NODE_MODULES="/usr/local/lib/node_modules"
  for dir in "${NODE_MODULES}"/israeli-bank-firefly-importer*; do
    [[ -d "$dir" ]] || continue
    if [[ -f "${dir}/src/index.js" ]]; then
      ENTRY="${dir}/src/index.js"
      break
    fi
  done
fi
if [[ -z "$ENTRY" ]] || [[ ! -f "$ENTRY" ]]; then
  bashio::log.error "Importer entry not found"
  exit 1
fi
exec /usr/bin/node "$ENTRY"
