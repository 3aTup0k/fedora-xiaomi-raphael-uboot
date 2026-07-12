#!/bin/bash
set -e

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [15] Configuring ZRAM"

mkdir -p rootdir/etc/systemd/zram-generator.conf.d
cat > rootdir/etc/systemd/zram-generator.conf.d/50-zram.conf << 'EOF'
[zram0]
zram-size = 10240
compression-algorithm = zstd
EOF

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [15] Done"
