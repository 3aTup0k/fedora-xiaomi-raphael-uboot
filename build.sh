#!/bin/bash
set -e

SYSTEM_TYPE="${1:?Usage: $0 <system_type> [kernel_version] [desktop_env]}"
KERNEL_VERSION="${2:-6.18}"
DESKTOP_ENV="${3:-phosh}"

if [[ "$SYSTEM_TYPE" == *"fedora-"* ]]; then
    FEDORA_VERSION="${FEDORA_VERSION:-42}"
    export FEDORA_VERSION
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/build-config.sh"

TMP_SYSTEM_CONFIG=$(mktemp)
system_config "$SYSTEM_TYPE" "$DESKTOP_ENV" > "$TMP_SYSTEM_CONFIG"
while IFS= read -r line; do export "$line"; done < "$TMP_SYSTEM_CONFIG"
rm "$TMP_SYSTEM_CONFIG"

TMP_SOURCES_CONFIG=$(mktemp)
sources_config "$SYSTEM_TYPE" > "$TMP_SOURCES_CONFIG"
while IFS= read -r line; do export "$line"; done < "$TMP_SOURCES_CONFIG"
rm "$TMP_SOURCES_CONFIG"

export SCRIPT_DIR KERNEL_VERSION DESKTOP_ENV
export IMAGE_NAME="rootfs.img"
export IMAGE_UUID="ee8d3593-59b1-480e-a3b6-4fefb17ee7d8"
export HOSTNAME="xiaomi-raphael"
export BOOT_IMG="xiaomi-k20pro-boot.img"
export KERNEL_DEBS_DIR="xiaomi-raphael-debs_$KERNEL_VERSION"
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"
export SYSTEM_TYPE

echo "[$(date +'%Y-%m-%d %H:%M:%S')] =========================================="
echo "[$(date +'%Y-%m-%d %H:%M:%S')] Fedora for Xiaomi Raphael Image Build"
echo "[$(date +'%Y-%m-%d %H:%M:%S')] =========================================="
echo "[$(date +'%Y-%m-%d %H:%M:%S')] System:   $SYSTEM_TYPE"
echo "[$(date +'%Y-%m-%d %H:%M:%S')] Fedora:   $FEDORA_VERSION"
echo "[$(date +'%Y-%m-%d %H:%M:%S')] Kernel:   $KERNEL_VERSION"
echo "[$(date +'%Y-%m-%d %H:%M:%S')] Size:     $IMAGE_SIZE"
[ "$IS_DESKTOP" = "true" ] && echo "[$(date +'%Y-%m-%d %H:%M:%S')] DE:       $DESKTOP_ENV"
echo "[$(date +'%Y-%m-%d %H:%M:%S')] =========================================="

[ -f "$BOOT_IMG" ] || { echo "Error: $BOOT_IMG not found"; exit 1; }
[ -d "$KERNEL_DEBS_DIR" ] || { echo "Error: $KERNEL_DEBS_DIR not found"; exit 1; }

chmod +x "$SCRIPT_DIR/scripts"/*.sh

"$SCRIPT_DIR/scripts/01-create-image.sh"
"$SCRIPT_DIR/scripts/02-bootstrap.sh"
"$SCRIPT_DIR/scripts/03-mount-dev.sh"
"$SCRIPT_DIR/scripts/04-config-network.sh"
"$SCRIPT_DIR/scripts/05-dnf-setup.sh"
"$SCRIPT_DIR/scripts/06-install-all-packages.sh"
"$SCRIPT_DIR/scripts/07-config-locale.sh"
"$SCRIPT_DIR/scripts/08-add-screen-commands.sh"
"$SCRIPT_DIR/scripts/09-install-kernel.sh"
"$SCRIPT_DIR/scripts/10-config-ncm.sh"
"$SCRIPT_DIR/scripts/11-config-fstab.sh"
"$SCRIPT_DIR/scripts/12-create-users.sh"
"$SCRIPT_DIR/scripts/13-config-power.sh"
"$SCRIPT_DIR/scripts/14-config-power-key.sh"
"$SCRIPT_DIR/scripts/15-config-zram.sh"
"$SCRIPT_DIR/scripts/16-config-audio.sh"
"$SCRIPT_DIR/scripts/17-cleanup.sh"
"$SCRIPT_DIR/scripts/18-finalize.sh"

echo "[$(date +'%Y-%m-%d %H:%M:%S')] Build complete"
ls -lh rootfs.img 2>/dev/null || true
