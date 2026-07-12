#!/bin/bash
set -e

FEDORA_VERSION="${FEDORA_VERSION:-42}"
ARCH="aarch64"

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [05] Configuring DNF repos"

cat > rootdir/etc/yum.repos.d/fedora.repo << EOF
[fedora]
name=Fedora \$releasever - $ARCH
metalink=https://mirrors.fedoraproject.org/metalink?repo=fedora-\$releasever&arch=$ARCH
enabled=1
gpgcheck=0
skip_if_unavailable=False

[updates]
name=Fedora \$releasever - $ARCH - Updates
metalink=https://mirrors.fedoraproject.org/metalink?repo=updates-released-f\$releasever&arch=$ARCH
enabled=1
gpgcheck=0
skip_if_unavailable=False
EOF

cat > rootdir/etc/yum.repos.d/pocketblue.repo << EOF
[pocketblue]
name=pocketblue common
baseurl=https://download.copr.fedorainfracloud.org/results/pocketblue/common/fedora-\$releasever-$ARCH/
enabled=1
gpgcheck=0
skip_if_unavailable=False
EOF

cat > rootdir/etc/yum.repos.d/pocketblue-sm8150.repo << EOF
[pocketblue-sm8150]
name=pocketblue sm8150
baseurl=https://download.copr.fedorainfracloud.org/results/pocketblue/sm8150/fedora-\$releasever-$ARCH/
enabled=1
gpgcheck=0
skip_if_unavailable=False
EOF

cat > rootdir/etc/yum.repos.d/onesaladleaf-sdm845.repo << EOF
[onesaladleaf-sdm845]
name=onesaladleaf sdm845
baseurl=https://download.copr.fedorainfracloud.org/results/onesaladleaf/sdm845/fedora-\$releasever-$ARCH/
enabled=1
gpgcheck=0
skip_if_unavailable=False
EOF

rm -f rootdir/etc/yum.repos.d/*.rpmsave 2>/dev/null || true

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [05] Done"
