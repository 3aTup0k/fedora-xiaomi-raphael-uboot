SYSTEM_TYPES="
  fedora-gnome
  fedora-kde
  fedora-niri
"

system_config() {
  case "$1" in
    "fedora-gnome")
      echo "IMAGE_SIZE=8G"
      echo "IS_DESKTOP=true"
      echo "DESKTOP_ENV=gnome"
      ;;
    "fedora-kde")
      echo "IMAGE_SIZE=8G"
      echo "IS_DESKTOP=true"
      echo "DESKTOP_ENV=kde"
      ;;
    "fedora-niri")
      echo "IMAGE_SIZE=5G"
      echo "IS_DESKTOP=true"
      echo "DESKTOP_ENV=niri"
      ;;
  esac
}

sources_config() {
  echo "FEDORA_VERSION=${FEDORA_VERSION:-42}"
  echo "FEDORA_MIRROR=https://mirrors.fedoraproject.org/metalink?arch=aarch64"
}

get_packages() {
  local system_type="$1"
  local desktop_env="$2"

  base_packages="bash-completion sudo openssh-server nano NetworkManager chrony curl wget glibc-langpack-en tzdata dnsmasq nftables iptables iproute alsa-utils alsa-ucm-conf-sm8150 pipewire-pulseaudio pipewire-alsa wireplumber systemd-ukify binutils qrtr pd-mapper rmtfs tqftpserv qbootctl q6voiced"

  case "$desktop_env" in
    "gnome")
      echo "$base_packages @gnome-desktop gdm"
      ;;
    "kde")
      echo "$base_packages @kde-desktop sddm"
      ;;
    "niri")
      echo "$base_packages @standard @base-graphical niri waybar fuzzel mako kitty swayidle swww waypaper"
      ;;
    *)
      echo "$base_packages"
      ;;
  esac
}
