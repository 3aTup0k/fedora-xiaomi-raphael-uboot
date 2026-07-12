#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../build-config.sh"

FEDORA_VERSION="${FEDORA_VERSION:-42}"

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [06] Installing packages"

ALL_PACKAGES=$(get_packages "$SYSTEM_TYPE" "$DESKTOP_ENV")

chroot rootdir dnf install -y --releasever=$FEDORA_VERSION \
    --nogpgcheck --setopt=install_weak_deps=False --allowerasing \
    $ALL_PACKAGES

chroot rootdir dnf clean all

case "$DESKTOP_ENV" in
    "gnome")
        mkdir -p rootdir/etc/gdm
        cat > rootdir/etc/gdm/custom.conf << 'EOF'
[daemon]
AutomaticLoginEnable=true
AutomaticLogin=user
EOF
        chroot rootdir systemctl enable gdm
        ;;
    "phosh"|"phosh-core"|"phosh-full")
        chroot rootdir systemctl enable phosh
        ;;
    "kde")
        mkdir -p rootdir/etc/sddm.conf.d
        cat > rootdir/etc/sddm.conf.d/autologin.conf << 'EOF'
[Autologin]
User=user
Session=plasma
EOF
        chroot rootdir systemctl enable sddm
        ;;
esac

chroot rootdir systemctl set-default graphical.target
chroot rootdir systemctl enable NetworkManager sshd

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [06] Done"
