# Testing the Addon Locally

You can validate addon changes **without** waiting for Home Assistant to rebuild.

## Option 1: Local Docker build (recommended)

From your machine (Mac/Linux with Docker installed):

```bash
cd israeli-bank-firefly-importer-security-enhanced-addon
chmod +x scripts/build-and-test.sh
./scripts/build-and-test.sh
```

This builds the same image HA would build. If the build succeeds and prints `IMPORTER_ENTRY=/usr/local/lib/node_modules/.../src/index.js`, the addon should work in HA.

**Time:** ~2–5 minutes (vs waiting for HA addon store + rebuild).

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
