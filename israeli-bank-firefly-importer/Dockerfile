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

# Record the actual path to the importer entry (use package.json "main" field)
RUN node -e " \
  const fs = require('fs'); \
  const path = require('path'); \
  const mod = '/usr/local/lib/node_modules'; \
  const dirName = 'israeli-bank-firefly-importer'; \
  const pkgPath = path.join(mod, dirName, 'package.json'); \
  if (!fs.existsSync(pkgPath)) throw new Error('package.json not found at ' + pkgPath); \
  const pkg = JSON.parse(fs.readFileSync(pkgPath, 'utf8')); \
  if (pkg.name !== 'israeli-bank-firefly-importer') throw new Error('wrong package name: ' + pkg.name); \
  const main = pkg.main || 'src/index.js'; \
  const entry = path.join(mod, dirName, main); \
  if (!fs.existsSync(entry)) throw new Error('entry not found: ' + entry + ' (dir contents: ' + fs.readdirSync(path.join(mod, dirName)).join(', ') + ')'); \
  fs.writeFileSync('/app/IMPORTER_ENTRY', entry); \
"

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
