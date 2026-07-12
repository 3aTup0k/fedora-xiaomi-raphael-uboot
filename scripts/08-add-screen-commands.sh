#!/bin/bash
set -e

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [08] Adding screen commands"

cat >> rootdir/etc/bash.bashrc << 'EOF'
leijun() {
    if [ -n "$SSH_CONNECTION" ] || [ -n "$SSH_TTY" ]; then
        sudo sh -c 'TERM=linux setterm --blank force </dev/tty1'
    else
        setterm --blank force --term linux </dev/tty1
    fi
    echo "Screen off"
}
jinfan() {
    if [ -n "$SSH_CONNECTION" ] || [ -n "$SSH_TTY" ]; then
        sudo sh -c 'TERM=linux setterm --blank poke </dev/tty1'
    else
        setterm --blank poke --term linux </dev/tty1
    fi
    echo "Screen on"
}
EOF

cat > rootdir/etc/systemd/system/blank_screen.service << 'EOF'
[Unit]
Description=Blank screen after 15s
After=multi-user.target
[Service]
Type=simple
ExecStartPre=/bin/bash -c "sleep 15"
ExecStart=sh -c 'TERM=linux setterm --blank force </dev/tty1'
User=root
Restart=on-failure
RestartSec=5s
[Install]
WantedBy=multi-user.target
EOF

chroot rootdir systemctl enable blank_screen.service
echo "[$(date +'%Y-%m-%d %H:%M:%S')] [08] Done"
