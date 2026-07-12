#!/bin/bash
set -e

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [13] Configuring power"

chroot rootdir systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

mkdir -p rootdir/etc/NetworkManager/conf.d
cat > rootdir/etc/NetworkManager/conf.d/wifi-powersave.conf << 'EOF'
[connection] wifi.powersave = 2
EOF

mkdir -p rootdir/etc/modprobe.d
cat > rootdir/etc/modprobe.d/ath10k.conf << 'EOF'
options ath10k_core skip_otp=y
EOF

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [13] Done"
