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
# Clone security-enhanced importer and install deps (--ignore-scripts skips husky prepare)
RUN echo "Importer cache bust: ${IMPORTER_CACHEBUST}" && \
    git clone --depth 1 https://github.com/Amitg89/israeli-bank-firefly-importer-security-enhanced.git /app/importer \
    && cd /app/importer && npm install --ignore-scripts \
    && apk del git

# Add non-root user (no --no-sandbox needed for Chromium)
RUN addgroup -S pptruser && adduser -S -G pptruser pptruser \
    && mkdir -p /home/pptruser/Downloads \
    && chown -R pptruser:pptruser /home/pptruser \
    && chown -R pptruser:pptruser /app

USER pptruser

CMD ["/run.sh"]
