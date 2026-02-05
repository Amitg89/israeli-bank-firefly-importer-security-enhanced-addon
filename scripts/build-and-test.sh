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
# Use NO_CACHE=1 to force a fresh clone (e.g. after pushing importer fixes)
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
echo "Build succeeded. Verifying importer entry..."
ENTRY=$(docker run --rm israeli-bank-firefly-importer-security-enhanced:test cat /app/IMPORTER_ENTRY 2>/dev/null || true)
if [[ -n "$ENTRY" ]]; then
  echo "IMPORTER_ENTRY=$ENTRY"
  echo ""
  echo "Entry point found. Run full test? (docker run --rm ... /run.sh)"
  echo "To run with your config locally (see real errors):"
  echo "  mkdir -p test-config && cp /path/to/config.encrypted.yaml test-config/"
  echo "  docker run --rm -it --entrypoint \"\" -v \$(pwd)/test-config:/config/israeli-bank-firefly-importer:ro \\"
  echo "    -e CONFIG_FILE=/config/israeli-bank-firefly-importer/config.encrypted.yaml \\"
  echo "    -e FIREFLY_BASE_URL=http://host.docker.internal:3473 -e FIREFLY_TOKEN_API=x -e MASTER_PASSWORD=xxx -e CRON='0 6 * * *' -e LOG_LEVEL=info \\"
  echo "    israeli-bank-firefly-importer-security-enhanced:test \\"
  echo "    /bin/sh -c 'cd /app/importer && node src/index.js'"
  echo "  (--entrypoint \"\" is required so -e env vars reach the process)"
  echo "  See TESTING.md for details."
else
  echo "WARNING: /app/IMPORTER_ENTRY is empty or missing."
  echo "Listing /usr/local/lib/node_modules:"
  docker run --rm israeli-bank-firefly-importer-security-enhanced:test ls -la /usr/local/lib/node_modules/ 2>/dev/null || true
  exit 1
fi
