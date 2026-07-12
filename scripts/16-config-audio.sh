#!/bin/bash
set -e

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [16] Configuring audio"

mkdir -p rootdir/etc/wireplumber/wireplumber.conf.d
cat > rootdir/etc/wireplumber/wireplumber.conf.d/51-disable-suspension.conf << 'EOF'
monitor.alsa.rules = [ { matches = [ { node.name = "~alsa_input.*" }, { node.name = "~alsa_output.*" } ] actions = { update-props = { audio.format = "S16LE" audio.rate = 48000 api.alsa.period-size = 4096 api.alsa.period-num = 6 api.alsa.headroom = 512 } } } ]
EOF

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [16] Done"
