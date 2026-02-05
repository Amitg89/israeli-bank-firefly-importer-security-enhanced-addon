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
echo "This may take 2-5 minutes..."
docker build \
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
  echo "  docker run --rm -e CONFIG_FILE=/dev/null -e FIREFLY_BASE_URL=http://x -e FIREFLY_TOKEN_API=x -e CRON='' -e MASTER_PASSWORD=x israeli-bank-firefly-importer-security-enhanced:test /run.sh"
else
  echo "WARNING: /app/IMPORTER_ENTRY is empty or missing."
  echo "Listing /usr/local/lib/node_modules:"
  docker run --rm israeli-bank-firefly-importer-security-enhanced:test ls -la /usr/local/lib/node_modules/ 2>/dev/null || true
  exit 1
fi
