#!/bin/bash
set -e

KERNEL_DEBS_DIR="${KERNEL_DEBS_DIR:-.}"

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [09] Installing kernel"

chroot rootdir dnf install -y --allowerasing dpkg diffutils 2>/dev/null || true

cp ${KERNEL_DEBS_DIR}/*-xiaomi-raphael.deb rootdir/tmp/
chroot rootdir dpkg -i /tmp/linux-image-xiaomi-raphael.deb
chroot rootdir dpkg -i /tmp/linux-headers-xiaomi-raphael.deb
chroot rootdir dpkg -i /tmp/firmware-xiaomi-raphael.deb
rm rootdir/tmp/*-xiaomi-raphael.deb

KVER=$(ls rootdir/lib/modules/ | grep sm8150 | sort -V | tail -1)
chroot rootdir dracut --force --no-hostonly --kver "$KVER"
echo "[$(date +'%Y-%m-%d %H:%M:%S')] [09] Done"
