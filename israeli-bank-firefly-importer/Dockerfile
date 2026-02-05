# Default for local builds; HA supervisor overrides with correct arch
ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:latest
FROM $BUILD_FROM

# Install Node.js, npm, and Chromium for Puppeteer
RUN apk add --no-cache nodejs npm chromium

# Configure Puppeteer to use system Chromium
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

WORKDIR /app

# Copy run script
COPY run.sh /
RUN chmod a+x /run.sh

# Clone and install importer locally so layout is predictable (avoids npm global git-install quirks)
RUN apk add --no-cache git \
    && git clone --depth 1 https://github.com/Amitg89/israeli-bank-firefly-importer-security-enhanced.git /app/importer \
    && cd /app/importer && npm install --ignore-scripts \
    && apk del git

# Resolve entry from package.json "main" and record it
RUN node -e " \
  const fs = require('fs'); \
  const path = require('path'); \
  const root = '/app/importer'; \
  const pkgPath = path.join(root, 'package.json'); \
  const pkg = JSON.parse(fs.readFileSync(pkgPath, 'utf8')); \
  const main = pkg.main || 'src/index.js'; \
  const entry = path.join(root, main); \
  if (!fs.existsSync(entry)) throw new Error('entry not found: ' + entry); \
  fs.writeFileSync('/app/IMPORTER_ENTRY', entry); \
"

# Allow non-root user to read and run the importer
RUN chmod -R o+rx /app/importer

# Add non-root user for security (no --no-sandbox needed)
RUN addgroup -S pptruser && adduser -S -G pptruser pptruser \
    && mkdir -p /home/pptruser/Downloads /app \
    && chown -R pptruser:pptruser /home/pptruser \
    && chown -R pptruser:pptruser /app

# Run as non-privileged user
USER pptruser

CMD ["/run.sh"]
