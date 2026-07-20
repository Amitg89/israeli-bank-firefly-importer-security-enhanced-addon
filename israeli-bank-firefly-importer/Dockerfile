# https://developers.home-assistant.io/docs/add-ons/configuration#add-on-dockerfile
# Debian base (glibc) so we get a full, mainstream Chromium instead of Alpine's
# stripped musl build — Alpine's Chromium is bot-flagged by Discount/Telebank
# and hangs on the post-login SPA loader. build.yaml pins the Debian base per arch.
ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base-debian:bookworm
FROM $BUILD_FROM

# Install Node.js, npm, Chromium, git, and fonts (Hebrew via Noto).
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        nodejs npm chromium git ca-certificates \
        fontconfig fonts-noto fonts-liberation fonts-dejavu-core \
    && rm -rf /var/lib/apt/lists/*

# Configure Puppeteer to use the system (Debian) Chromium
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

WORKDIR /app

# Copy run script
COPY run.sh /
RUN chmod a+x /run.sh

# Cache-bust: bump this when importer or scraper fixes are pushed so HA addon update re-clones
ARG IMPORTER_CACHEBUST=2026-07-21-reconciliation-fix
RUN echo "Importer cache-bust: ${IMPORTER_CACHEBUST}"

# Clone importer and install deps (scraper from GitHub has no src/ in pack, so we build it separately).
# IMPORTANT: branches are pinned explicitly. The scraper fork's default branch on
# GitHub is a stale `main`; all development happens on `master`. A bare
# `git clone --depth 1` fetches the default branch, which silently deployed
# months-old scraper code in every image up to and including 1.0.30.
RUN git clone --depth 1 --branch main https://github.com/Amitg89/israeli-bank-firefly-importer-security-enhanced.git /app/importer \
    && cd /app/importer && npm install --ignore-scripts \
    && git clone --depth 1 --branch master https://github.com/Amitg89/updated-Israeli-bank-scrapers.git /tmp/scraper \
    && (cd /tmp/scraper && npm install --ignore-scripts && npm run clean && npm run build:js) \
    && cp -r /tmp/scraper/lib /app/importer/node_modules/israeli-bank-scrapers/ \
    && rm -rf /tmp/scraper \
    # Build-time sanity check: the deployed scraper lib must contain the remote
    # browser support. Fails the build loudly instead of shipping stale code.
    && grep -q browserWSEndpoint /app/importer/node_modules/israeli-bank-scrapers/lib/scrapers/base-scraper-with-browser.js \
    && grep -q discount-debug /app/importer/node_modules/israeli-bank-scrapers/lib/scrapers/discount.js \
    && apt-get purge -y git && apt-get autoremove -y

# Run as root: HA add-ons are isolated containers, and root lets Chromium
# write failure screenshots to the mapped /config volume for debugging.
# Chromium runs with --no-sandbox (set in the importer's default scraper args),
# which is required when running as root.
CMD ["/run.sh"]
