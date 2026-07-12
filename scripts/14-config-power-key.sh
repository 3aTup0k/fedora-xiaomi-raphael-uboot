#!/bin/bash
set -e

if [ "$DESKTOP_ENV" != "gnome" ]; then
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [14] Not GNOME, skip"
    exit 0
fi

POWER_KEY_USER="${USER_NAME:-user}"
echo "[$(date +'%Y-%m-%d %H:%M:%S')] [14] Configuring power key"

install -d rootdir/etc/systemd/logind.conf.d
cat > rootdir/etc/systemd/logind.conf.d/power-key.conf << 'EOF'
[Login] HandlePowerKey=ignore HandlePowerKeyLongPress=ignore PowerKeyIgnoreInhibited=yes
EOF

cat > rootdir/usr/local/sbin/power-key-handler.py << 'PYEOF'
#!/usr/bin/env python3
import logging,os,select,struct,subprocess,sys,threading,time
EVENT_FMT="llHHi";EVENT_SIZE=struct.calcsize(EVENT_FMT);LONG=1.0
logging.basicConfig(level=logging.INFO,format="power-key: %(message)s",stream=sys.stdout)
log=logging.getLogger()
def get_user():
    u=os.environ.get("USER_NAME")
    if u: return u
    import pwd;return pwd.getpwuid(os.getuid()).pw_name
def find_dev():
    from pathlib import Path
    for p in sorted(Path("/sys/class/input").glob("input*/name")):
        if p.read_text().strip()=="pm8941_pwrkey":
            d=Path(f"/dev/input/event{p.parent.name.replace('input','')}")
            if d.exists():return str(d)
    return "/dev/input/event0"
def env():
    import pwd;u=get_user();uid=pwd.getpwnam(u).pw_uid;rt=f"/run/user/{uid}"
    e=os.environ.copy();e.update({"HOME":f"/home/{u}","USER":u,"LOGNAME":u,"XDG_RUNTIME_DIR":rt,"DBUS_SESSION_BUS_ADDRESS":f"unix:path={rt}/bus"})
    for d in("wayland-0","wayland-1"):
        if os.path.exists(f"{rt}/{d}"):e["WAYLAND_DISPLAY"]=d;break
    return e
def toggle():
    e=env()
    try:r=subprocess.run(["gdbus","call","--session","--dest","org.gnome.ScreenSaver","--object-path","/org/gnome/ScreenSaver","--method","org.gnome.ScreenSaver.GetActive"],env=e,capture_output=True,text=True,timeout=2);a="(true"in r.stdout
    except:a=False
    subprocess.run(["gdbus","call","--session","--dest","org.gnome.ScreenSaver","--object-path","/org/gnome/ScreenSaver","--method","org.gnome.ScreenSaver.SetActive","false"if a else"true"],env=e,timeout=3)
def menu():
    e=env()
    r=subprocess.run(["busctl","--user","call","org.gnome.SessionManager","/org/gnome/SessionManager","org.gnome.SessionManager","RequestShutdown"],env=e,capture_output=True,timeout=3)
    if r.returncode:subprocess.Popen(["gnome-session-quit","--power-off"],env=e)
def wait_sess(t=120):
    import pwd;u=get_user();uid=pwd.getpwnam(u).pw_uid;bus=f"/run/user/{uid}/bus";dead=time.monotonic()+t
    while time.monotonic()<dead:
        if os.path.exists(bus):
            try:subprocess.run(["pgrep","-u",u,"-x","gnome-shell"],check=True,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL);time.sleep(3);return True
            except:pass
        time.sleep(1)
    return False
def main():
    if not wait_sess():sys.exit(1)
    fd=os.open(find_dev(),os.O_RDONLY|os.O_NONBLOCK);pt=None;lf=False;lt=None;ip=False
    def cl():nonlocal lt;lt and lt.cancel();lt=None
    def ol():nonlocal lf;ip and(lf:=True)or menu()
    while True:
        r,_,_=select.select([fd],[],[],1)
        if not r:continue
        d=os.read(fd,EVENT_SIZE)
        if len(d)<EVENT_SIZE:continue
        *_,c,v=struct.unpack(EVENT_FMT,d)
        if c!=116:continue
        if v==1 and not ip:
            ip=True;pt=time.monotonic();lf=False;cl();lt=threading.Timer(LONG,ol);lt.daemon=True;lt.start()
        elif v==0 and pt:
            ip=False;cl()
            if not lf and time.monotonic()-pt<LONG:toggle()
            pt=None
if __name__=="__main__":main()
PYEOF
chmod 755 rootdir/usr/local/sbin/power-key-handler.py

install -d rootdir/etc/systemd/user
cat > rootdir/etc/systemd/user/power-key-handler.service << EOF
[Unit] Description=Power key handler After=graphical-session.target Wants=graphical-session.target
[Service] Type=simple Environment=USER_NAME=${POWER_KEY_USER} ExecStart=/usr/bin/python3 /usr/local/sbin/power-key-handler.py Restart=always RestartSec=5
[Install] WantedBy=graphical-session.target
EOF
mkdir -p rootdir/etc/systemd/user/graphical-session.target.wants
ln -sf /etc/systemd/user/power-key-handler.service rootdir/etc/systemd/user/graphical-session.target.wants/

install -d rootdir/var/lib/systemd/linger
touch rootdir/var/lib/systemd/linger/"${POWER_KEY_USER}"

install -d rootdir/etc/dconf/db/local.d rootdir/etc/dconf/profile
cat > rootdir/etc/dconf/db/local.d/01-power-key << 'EOF'
[org/gnome/settings-daemon/plugins/power] power-button-action='nothing'
EOF
[ ! -f rootdir/etc/dconf/profile/user ] && cat > rootdir/etc/dconf/profile/user << 'EOF'
user-db:user system-db:local
EOF
chroot rootdir dconf update 2>/dev/null || true

cat > rootdir/etc/udev/rules.d/99-power-key.rules << 'EOF'
ACTION=="add",SUBSYSTEM=="input",KERNEL=="event*",ATTRS{name}=="pm8941_pwrkey",MODE="0666"
EOF
echo "[$(date +'%Y-%m-%d %H:%M:%S')] [14] Done"
