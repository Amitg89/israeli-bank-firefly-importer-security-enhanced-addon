#!/bin/bash
# HA add-on start wrapper for ghcr.io/browserless/chromium.
# Reads /data/options.json (written by HA Supervisor) with jq, maps options
# to the browserless v2 environment variables, then execs the image's original
# entrypoint: ./scripts/start.sh (which runs dumb-init -- node build/index.js).
#
# NO bashio — this is NOT an HA base image; the container is Ubuntu-based.

set -e

OPTIONS=/data/options.json

# -r (not just -f): we run as blessuser, so the Supervisor-written file must
# also be readable, otherwise fall back to image defaults instead of crashing.
if [ ! -r "$OPTIONS" ]; then
    echo "[browserless] WARNING: $OPTIONS missing or unreadable; running with image defaults (no TOKEN — endpoint unauthenticated)."
else
    # TOKEN — only export if non-empty (browserless auto-generates one if unset)
    _token=$(jq -r '.token // ""' "$OPTIONS")
    if [ -n "$_token" ]; then
        export TOKEN="$_token"
    fi

    # TIMEOUT — session timeout in milliseconds (maps to connection_timeout option)
    _timeout=$(jq -r '.connection_timeout // 600000' "$OPTIONS")
    export TIMEOUT="$_timeout"

    # CONCURRENT — max concurrent browser sessions
    _concurrent=$(jq -r '.max_concurrent_sessions // 2' "$OPTIONS")
    export CONCURRENT="$_concurrent"
fi

# Log startup config (redact token value)
echo "[browserless] Starting: CONCURRENT=${CONCURRENT:-10} TIMEOUT=${TIMEOUT:-30000} TOKEN=${TOKEN:+(set)}"

# Exec the image's original start script from its working directory (/usr/src/app).
# The base image sets WORKDIR /usr/src/app and APP_DIR=/usr/src/app; start.sh
# is at ./scripts/start.sh relative to that directory.
cd "${APP_DIR:-/usr/src/app}"
exec ./scripts/start.sh "$@"
