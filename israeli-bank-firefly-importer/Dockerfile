ARG BUILD_FROM
FROM $BUILD_FROM

# Install Node.js, npm, Chromium for Puppeteer, and git for npm install from GitHub
RUN apk add --no-cache nodejs npm chromium git

# Configure Puppeteer to use system Chromium
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

WORKDIR /app

# Copy run script
COPY run.sh /
RUN chmod a+x /run.sh

# Install the security-enhanced importer from the GitHub repo
# Note: Update this when the package is published to npm
RUN npm i -g https://github.com/Amitg89/israeli-bank-firefly-importer-security-enhanced.git

# Add non-root user for security (no --no-sandbox needed)
RUN addgroup -S pptruser && adduser -S -G pptruser pptruser \
    && mkdir -p /home/pptruser/Downloads /app \
    && chown -R pptruser:pptruser /home/pptruser \
    && chown -R pptruser:pptruser /app

# Run as non-privileged user
USER pptruser

CMD ["/run.sh"]
