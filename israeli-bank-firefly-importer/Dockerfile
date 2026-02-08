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

# Bump the string below when you want to force a fresh clone (avoids Docker cache serving old importer code)
ARG IMPORTER_CACHEBUST="addon-1.0.19"
# Importer repo URL (logged so you can verify source during install)
ARG IMPORTER_REPO_URL="https://github.com/Amitg89/israeli-bank-firefly-importer-security-enhanced.git"
# Scrapers package: GitHub URL to use (overrides npm dependency). Your fork with Isracard/Amex fixes.
ARG SCRAPERS_REPO_URL="https://github.com/Amitg89/updated-Israeli-bank-scrapers.git"
# Clone security-enhanced importer and install deps (--ignore-scripts skips husky prepare)
# Scrapers: we skip build:types because npm install from git can omit tsconfig.json (package "files"); runtime only needs build:js output.
RUN echo "=== Addon install: importer package ===" && \
    echo "Importer cache bust: ${IMPORTER_CACHEBUST}" && \
    echo "Cloning importer from URL: ${IMPORTER_REPO_URL}" && \
    git clone --depth 1 "${IMPORTER_REPO_URL}" /app/importer && \
    cd /app/importer && \
    echo "Importer cloned at commit: $(git rev-parse HEAD)" && \
    echo "Importer package version: $(node -p "require('./package.json').version")" && \
    echo "Installing npm dependencies..." && \
    npm install --ignore-scripts && \
    echo "Overriding israeli-bank-scrapers with fork from URL: ${SCRAPERS_REPO_URL}" && \
    npm install "${SCRAPERS_REPO_URL}" --ignore-scripts && \
    echo "Building israeli-bank-scrapers (TypeScript -> lib/)..." && \
    (cd node_modules/israeli-bank-scrapers && npm install --ignore-scripts && npm run clean && npm run build:js && npm run postbuild) && \
    echo "=== Installed versions ===" && \
    echo "Importer (from clone above): $(node -p "require('./package.json').version")" && \
    echo "israeli-bank-scrapers: $(node -p "require('israeli-bank-scrapers/package.json').version") (from ${SCRAPERS_REPO_URL})" && \
    echo "=== End install log ===" && \
    apk del git

# Add non-root user (no --no-sandbox needed for Chromium)
RUN addgroup -S pptruser && adduser -S -G pptruser pptruser \
    && mkdir -p /home/pptruser/Downloads \
    && chown -R pptruser:pptruser /home/pptruser \
    && chown -R pptruser:pptruser /app

USER pptruser

CMD ["/run.sh"]
