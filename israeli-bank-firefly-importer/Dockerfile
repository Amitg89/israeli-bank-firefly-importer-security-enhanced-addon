# https://developers.home-assistant.io/docs/add-ons/configuration#add-on-dockerfile
# HA supervisor passes BUILD_FROM; default for local builds
ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:latest
FROM $BUILD_FROM

# Install Node.js, npm, Chromium, and git (for clone)
RUN apk add --no-cache nodejs npm chromium git

# Configure Puppeteer to use system Chromium
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

WORKDIR /app

# Copy run script
COPY run.sh /
RUN chmod a+x /run.sh

# Cache-bust: bump this when importer or scraper fixes are pushed so HA addon update re-clones
ARG IMPORTER_CACHEBUST=2026-02-08-isracard-skip-extra
RUN echo "Importer cache-bust: ${IMPORTER_CACHEBUST}"

# Clone importer and install deps (scraper from GitHub has no src/ in pack, so we build it separately)
RUN git clone --depth 1 https://github.com/Amitg89/israeli-bank-firefly-importer-security-enhanced.git /app/importer \
    && cd /app/importer && npm install --ignore-scripts \
    && git clone --depth 1 https://github.com/Amitg89/updated-Israeli-bank-scrapers.git /tmp/scraper \
    && (cd /tmp/scraper && npm install --ignore-scripts && npm run clean && npm run build:js) \
    && cp -r /tmp/scraper/lib /app/importer/node_modules/israeli-bank-scrapers/ \
    && rm -rf /tmp/scraper \
    && apk del git

# Add non-root user (no --no-sandbox needed for Chromium)
RUN addgroup -S pptruser && adduser -S -G pptruser pptruser \
    && mkdir -p /home/pptruser/Downloads \
    && chown -R pptruser:pptruser /home/pptruser \
    && chown -R pptruser:pptruser /app

USER pptruser

CMD ["/run.sh"]
