#!/usr/bin/env bash
# Build the addon image locally (same way Home Assistant does) to test without HA.
# Run from addon repo root: ./scripts/build-and-test.sh
# Requires: Docker

set -e
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"
ADDON_DIR="israeli-bank-firefly-importer"

# Same base image Home Assistant uses for amd64
export BUILD_FROM="${BUILD_FROM:-ghcr.io/home-assistant/amd64-base:latest}"

echo "Building with BUILD_FROM=$BUILD_FROM"
if [[ -n "$NO_CACHE" ]]; then
  echo "NO_CACHE is set: doing a full rebuild (no cache)"
else
  echo "Tip: If you pushed importer fixes, run: NO_CACHE=1 $0"
fi
echo "This may take 2-5 minutes..."
docker build \
  $([[ -n "$NO_CACHE" ]] && echo --no-cache) \
  --build-arg BUILD_FROM="$BUILD_FROM" \
  --tag israeli-bank-firefly-importer-security-enhanced:test \
  --file "$ADDON_DIR/Dockerfile" \
  "$ADDON_DIR"

echo ""
echo "Build succeeded. Verifying importer..."
if docker run --rm israeli-bank-firefly-importer-security-enhanced:test test -f /app/importer/src/index.js; then
  echo "Importer entry /app/importer/src/index.js found."
  echo ""
  echo "To run with your config locally (see real errors):"
  echo "  mkdir -p test-config && cp /path/to/config.encrypted.yaml test-config/"
  echo "  docker run --rm -it -v \$(pwd)/test-config:/config/israeli-bank-firefly-importer:ro \\"
  echo "    -e CONFIG_FILE=/config/israeli-bank-firefly-importer/config.encrypted.yaml \\"
  echo "    -e FIREFLY_BASE_URL=http://host.docker.internal:3473 -e FIREFLY_TOKEN_API=x \\"
  echo "    -e MASTER_PASSWORD=xxx -e CRON='0 6 * * *' -e LOG_LEVEL=info \\"
  echo "    -e SCRAPER_TIMEOUT=60000 \\"
  echo "    israeli-bank-firefly-importer-security-enhanced:test /run.sh"
  echo "  See TESTING.md for details."
else
  echo "WARNING: /app/importer/src/index.js not found."
  exit 1
fi
