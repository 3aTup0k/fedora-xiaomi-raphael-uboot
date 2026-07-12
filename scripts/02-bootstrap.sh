#!/bin/bash
set -e

FEDORA_VERSION="${FEDORA_VERSION:-42}"
BOOT_IMG="${BOOT_IMG:-xiaomi-k20pro-boot.img}"
ARCH="aarch64"

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [02] Bootstrapping Fedora $FEDORA_VERSION"

mkdir -p rootdir/proc rootdir/sys rootdir/dev rootdir/dev/pts

TEMP_REPO_DIR=$(mktemp -d)
cat > "${TEMP_REPO_DIR}/fedora.repo" << EOF
[fedora]
name=Fedora \$releasever - $ARCH
metalink=https://mirrors.fedoraproject.org/metalink?repo=fedora-\$releasever&arch=$ARCH
enabled=1
gpgcheck=0
skip_if_unavailable=False
EOF

dnf install -y --installroot="$PWD/rootdir" --forcearch="$ARCH" \
    --releasever="$FEDORA_VERSION" \
    --setopt=install_weak_deps=False \
    --setopt="reposdir=${TEMP_REPO_DIR}" \
    --nogpgcheck \
    fedora-repos bash dnf systemd

rm -rf -- "$TEMP_REPO_DIR"

if [ -f "${BOOT_IMG}" ]; then
    mount -o loop ${BOOT_IMG} rootdir/boot
else
    echo "Error: ${BOOT_IMG} not found"; exit 1
fi

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [02] Done"
