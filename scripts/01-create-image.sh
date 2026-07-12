#!/bin/bash
set -e

IMAGE_SIZE="${IMAGE_SIZE:-4G}"
IMAGE_NAME="${IMAGE_NAME:-rootfs.img}"

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [01] Creating image (${IMAGE_SIZE})"

truncate -s ${IMAGE_SIZE} ${IMAGE_NAME}
mkfs.ext4 ${IMAGE_NAME}
mkdir -p rootdir
mount -o loop ${IMAGE_NAME} rootdir

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [01] Done"
