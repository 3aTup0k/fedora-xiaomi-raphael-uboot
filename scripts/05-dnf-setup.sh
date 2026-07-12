#!/bin/bash
set -e

FEDORA_VERSION="${FEDORA_VERSION:-42}"

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [05] Configuring DNF repos"

cat > rootdir/etc/yum.repos.d/fedora.repo << EOF
[fedora]
name=Fedora \$releasever - aarch64
metalink=https://mirrors.fedoraproject.org/metalink?repo=fedora-\$releasever&arch=aarch64
enabled=1
gpgcheck=0
skip_if_unavailable=False

[updates]
name=Fedora \$releasever - aarch64 - Updates
metalink=https://mirrors.fedoraproject.org/metalink?repo=updates-released-f\$releasever&arch=aarch64
enabled=1
gpgcheck=0
skip_if_unavailable=False
EOF

rm -f rootdir/etc/yum.repos.d/*.rpmsave 2>/dev/null || true

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [05] Done"
