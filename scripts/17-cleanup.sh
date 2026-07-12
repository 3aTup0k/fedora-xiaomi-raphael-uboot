#!/bin/bash
set -e

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [17] Cleaning up"

chroot rootdir dnf clean all
mv rootdir/boot/initramfs-* rootdir/boot/initramfs 2>/dev/null || true
mv rootdir/boot/vmlinuz-* rootdir/boot/linux.efi 2>/dev/null || true
rm -f rootdir/lib/firmware/reg* 2>/dev/null || true

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [17] Done"
