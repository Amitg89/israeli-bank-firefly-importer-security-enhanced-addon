ARG BUILD_FROM
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

# Install git and the security-enhanced importer in same layer
# --ignore-scripts skips "prepare" (husky install) which fails in Docker
RUN apk add --no-cache git \
    && npm i -g https://github.com/Amitg89/israeli-bank-firefly-importer-security-enhanced.git --ignore-scripts \
    && apk del git

# Record the actual path to the importer entry (npm from git can name folder differently)
RUN IMPORTER_ENTRY=$(find /usr/local/lib/node_modules -name 'index.js' -path '*/israeli-bank-firefly-importer*/src/index.js' 2>/dev/null | head -1) \
    && echo "${IMPORTER_ENTRY}" > /app/IMPORTER_ENTRY

# Allow non-root user to run the global npm binary and read node_modules
RUN chmod -R o+rx /usr/local/lib/node_modules \
    && chmod o+rx /usr/local/bin/israeli-bank-firefly-importer 2>/dev/null || true

# Add non-root user for security (no --no-sandbox needed)
RUN addgroup -S pptruser && adduser -S -G pptruser pptruser \
    && mkdir -p /home/pptruser/Downloads /app \
    && chown -R pptruser:pptruser /home/pptruser \
    && chown -R pptruser:pptruser /app

# Run as non-privileged user
USER pptruser

CMD ["/run.sh"]
