#!/bin/bash
set -e

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [07] Configuring locale"

echo "Europe/Moscow" > rootdir/etc/timezone
chroot rootdir ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
echo "LANG=en_US.UTF-8" > rootdir/etc/locale.conf

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [07] Done"
