#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
UPSTREAM_REF="${UPSTREAM_REF:-4dbf3a2a37744cb1c4c8150a32ca6280fcc8bf2c}"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/showcase-6s.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT

command -v curl >/dev/null || { echo "curl is required"; exit 1; }
command -v tar >/dev/null || { echo "tar is required"; exit 1; }
command -v patch >/dev/null || { echo "patch is required"; exit 1; }

echo "[1/4] Downloading upstream Showcase $UPSTREAM_REF"
curl -L --fail --retry 3 \
  "https://github.com/amineross/showcase/archive/$UPSTREAM_REF.tar.gz" \
  -o "$WORK/showcase.tar.gz"

echo "[2/4] Extracting and applying iPhone 6s HCI patch"
tar -xzf "$WORK/showcase.tar.gz" -C "$WORK"
SRC="$(find "$WORK" -maxdepth 1 -type d -name 'showcase-*' | head -n 1)"
[ -n "$SRC" ] || { echo "source extraction failed"; exit 1; }
cp "$ROOT/patches/6s-hci-wake.patch" "$WORK/6s.patch"
cd "$SRC"
patch -p1 < "$WORK/6s.patch"

echo "[3/4] Building the rootless test package"
export IPAD_HOST="${IPAD_HOST:-localhost}"
export IPAD_PORT="${IPAD_PORT:-2222}"
export IPAD_USER="${IPAD_USER:-mobile}"
export IPAD_PASS="${IPAD_PASS:-alpine}"
cd "$SRC"
./packaging/scripts/fetch-installed-app.sh
./packaging/scripts/build-rootless-deb.sh

echo "[4/4] Done"
echo "Package: $SRC/packaging/build/"
ls -lh "$SRC/packaging/build/"*.deb
