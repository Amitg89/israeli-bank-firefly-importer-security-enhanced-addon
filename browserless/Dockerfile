# https://developers.home-assistant.io/docs/add-ons/configuration#add-on-dockerfile
# The base image comes from build.yaml (ghcr.io/browserless/chromium:latest),
# which is Ubuntu 24.04-based and already contains Node.js, Chromium, and the
# browserless server. We only add jq for reading /data/options.json and wire in
# our own start.sh that reads HA add-on options and then hands off to the
# image's original entrypoint (./scripts/start.sh -> dumb-init node build/index.js).
ARG BUILD_FROM
FROM $BUILD_FROM

# The base image ends as USER blessuser (uid 999); root is required for apt
# and for installing the wrapper. Switch back to blessuser afterwards so the
# browserless server and Chrome run unprivileged, as upstream intends.
USER root

# Install jq to parse /data/options.json in start.sh
RUN apt-get update \
    && apt-get install -y --no-install-recommends jq \
    && rm -rf /var/lib/apt/lists/*

COPY start.sh /ha_start.sh
RUN chmod +x /ha_start.sh

USER blessuser

CMD ["/ha_start.sh"]
