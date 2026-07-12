#!/bin/bash
set -e

HOSTNAME="${HOSTNAME:-xiaomi-raphael}"

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [04] Configuring network"

echo "nameserver 1.1.1.1" > rootdir/etc/resolv.conf
echo "${HOSTNAME}" > rootdir/etc/hostname
echo "127.0.0.1 localhost
127.0.1.1 ${HOSTNAME}" > rootdir/etc/hosts

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [04] Done"
