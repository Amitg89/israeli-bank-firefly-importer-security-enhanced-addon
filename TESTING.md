# Testing the Addon Locally

You can validate addon changes **without** waiting for Home Assistant to rebuild.

## Option 1: Local Docker build (recommended)

From your machine (Mac/Linux with Docker installed):

```bash
cd israeli-bank-firefly-importer-security-enhanced-addon
chmod +x scripts/build-and-test.sh
./scripts/build-and-test.sh
```

This builds the same image HA would build. If the build succeeds and prints `IMPORTER_ENTRY=/app/importer/src/index.js`, the addon should work in HA.

**Time:** ~2–5 minutes (vs waiting for HA addon store + rebuild).

## Option 1b: Run with your config on your PC (see why it exits)

After building (Option 1), you can run the **same image** with your encrypted config and see the real Node error in the terminal:

1. **Put your addon config in a folder**, e.g. `./test-config/`:
   - `config.encrypted.yaml` (your encrypted file)

2. **Run the importer inside the container** (bypasses HA/bashio so we pass env by hand):

```bash
# From addon repo root, after ./scripts/build-and-test.sh
# --entrypoint "" is required: the addon image uses an s6 init entrypoint that does not
# pass the container's env to the process, so -e vars would be empty without it.
docker run --rm -it --entrypoint "" \
  -v "$(pwd)/test-config:/config/israeli-bank-firefly-importer:ro" \
  -e CONFIG_FILE=/config/israeli-bank-firefly-importer/config.encrypted.yaml \
  -e FIREFLY_BASE_URL=http://host.docker.internal:3473 \
  -e FIREFLY_TOKEN_API=your-token-if-needed \
  -e MASTER_PASSWORD=your-master-password \
  -e CRON="0 6 * * *" \
  -e LOG_LEVEL=info \
  israeli-bank-firefly-importer-security-enhanced:test \
  /bin/sh -c 'cd /app/importer && node src/index.js'
```

- Replace `your-master-password` and paths/ports as needed.
- Use `host.docker.internal` so the container can reach Firefly on your host (e.g. `http://host.docker.internal:3473`).
- Any **Critical error** or stack trace will appear in your terminal so we can fix the real issue.

## Option 2: Build for your HA architecture

If your Home Assistant runs on ARM (e.g. Raspberry Pi), use that base image:

```bash
# For aarch64 (e.g. RPi 4)
BUILD_FROM=ghcr.io/home-assistant/aarch64-base:latest ./scripts/build-and-test.sh

# For armhf (e.g. RPi 3)
BUILD_FROM=ghcr.io/home-assistant/armhf-base:latest ./scripts/build-and-test.sh
```

## Option 3: Check where npm installed the package (on your machine)

After installing globally, see the path npm uses:

```bash
npm i -g https://github.com/Amitg89/israeli-bank-firefly-importer-security-enhanced.git --ignore-scripts
npm list -g israeli-bank-firefly-importer --parseable
# Or: node -e "console.log(require.resolve('israeli-bank-firefly-importer/package.json'))"
```

---

## Why can’t I just edit files in the File Editor?

The addon runs **inside a Docker container**. The container’s filesystem is the **image** built from the addon repo (Dockerfile + `run.sh`, etc.).  

The **File Editor** in Home Assistant edits files on the **host** (e.g. `/config`). Those are not inside the addon container. So changing a file via File Editor does **not** change the addon’s `run.sh` or the installed npm package.  

To change addon behavior you have to **rebuild the image** (by updating the addon in HA or building locally as above).

---

## Quick reference

| Goal                         | Action |
|-----------------------------|--------|
| Test Dockerfile + entry path | Run `./scripts/build-and-test.sh` |
| Test on correct architecture | Set `BUILD_FROM` and run the script |
| See what’s in the image      | `docker run --rm ... ls /usr/local/lib/node_modules` |
