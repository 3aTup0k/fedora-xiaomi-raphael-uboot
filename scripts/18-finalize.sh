#!/bin/bash
set -e

IMAGE_NAME="${IMAGE_NAME:-rootfs.img}"
IMAGE_UUID="${IMAGE_UUID:-ee8d3593-59b1-480e-a3b6-4fefb17ee7d8}"

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [18] Finalizing"

umount rootdir/sys rootdir/proc rootdir/dev/pts rootdir/dev rootdir/boot rootdir 2>/dev/null || true
rm -d rootdir 2>/dev/null || true

e2fsck -f -y ${IMAGE_NAME}
tune2fs -U ${IMAGE_UUID} ${IMAGE_NAME}

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [18] Done"
echo "[$(date +'%Y-%m-%d %H:%M:%S')] Boot: root=PARTLABEL=userdata"
