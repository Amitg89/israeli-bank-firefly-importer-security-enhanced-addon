# https://developers.home-assistant.io/docs/add-ons/configuration#add-on-dockerfile
# HA supervisor passes BUILD_FROM; default for local builds
ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:latest
FROM $BUILD_FROM

# Install Node.js, npm, Chromium, git, and fonts.
# Fonts (incl. Hebrew via Noto) matter: a browser with no fonts can fail to
# lay out the bank's SPA and hang on its loading screen.
RUN apk add --no-cache nodejs npm chromium git \
    fontconfig font-noto font-noto-hebrew ttf-dejavu

# Configure Puppeteer to use system Chromium
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

WORKDIR /app

# Copy run script
COPY run.sh /
RUN chmod a+x /run.sh

# Cache-bust: bump this when importer or scraper fixes are pushed so HA addon update re-clones
ARG IMPORTER_CACHEBUST=2026-07-19-fonts-root-screenshot
RUN echo "Importer cache-bust: ${IMPORTER_CACHEBUST}"

# Clone importer and install deps (scraper from GitHub has no src/ in pack, so we build it separately)
RUN git clone --depth 1 https://github.com/Amitg89/israeli-bank-firefly-importer-security-enhanced.git /app/importer \
    && cd /app/importer && npm install --ignore-scripts \
    && git clone --depth 1 https://github.com/Amitg89/updated-Israeli-bank-scrapers.git /tmp/scraper \
    && (cd /tmp/scraper && npm install --ignore-scripts && npm run clean && npm run build:js) \
    && cp -r /tmp/scraper/lib /app/importer/node_modules/israeli-bank-scrapers/ \
    && rm -rf /tmp/scraper \
    && apk del git

# Run as root: HA add-ons are isolated containers, and root lets Chromium
# write failure screenshots to the mapped /config volume for debugging.
# Chromium runs with --no-sandbox (set in the importer's default scraper args),
# which is required when running as root.
CMD ["/run.sh"]
