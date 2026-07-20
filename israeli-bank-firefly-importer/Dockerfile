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
ARG IMPORTER_CACHEBUST=2026-07-20-browserless-ws-endpoint
RUN echo "Importer cache-bust: ${IMPORTER_CACHEBUST}"

# Clone importer and install deps (scraper from GitHub has no src/ in pack, so we build it separately)
RUN git clone --depth 1 https://github.com/Amitg89/israeli-bank-firefly-importer-security-enhanced.git /app/importer \
    && cd /app/importer && npm install --ignore-scripts \
    && git clone --depth 1 https://github.com/Amitg89/updated-Israeli-bank-scrapers.git /tmp/scraper \
    && (cd /tmp/scraper && npm install --ignore-scripts && npm run clean && npm run build:js) \
    && cp -r /tmp/scraper/lib /app/importer/node_modules/israeli-bank-scrapers/ \
    && rm -rf /tmp/scraper \
    && apt-get purge -y git && apt-get autoremove -y

# Run as root: HA add-ons are isolated containers, and root lets Chromium
# write failure screenshots to the mapped /config volume for debugging.
# Chromium runs with --no-sandbox (set in the importer's default scraper args),
# which is required when running as root.
CMD ["/run.sh"]
