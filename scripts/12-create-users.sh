#!/bin/bash
set -e

ROOT_PASS="${ROOT_PASS:-1234}"
USER_NAME="${USER_NAME:-user}"
USER_PASS="${USER_PASS:-1234}"

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [12] Creating users"

echo "root:${ROOT_PASS}" | chroot rootdir chpasswd
chroot rootdir useradd -m -G wheel -s /bin/bash ${USER_NAME}
echo "${USER_NAME}:${USER_PASS}" | chroot rootdir chpasswd
echo '%wheel ALL=(ALL) ALL' > rootdir/etc/sudoers.d/99-wheel-user
chmod 0440 rootdir/etc/sudoers.d/99-wheel-user

sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' rootdir/etc/ssh/sshd_config
echo "PasswordAuthentication yes" >> rootdir/etc/ssh/sshd_config

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [12] Done"
