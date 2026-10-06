#!/usr/bin/env bash
# Pterodactyl Easy Installer (Panel + Wings)
# Jalankan di VPS sebagai root:
#   bash ptero-install.sh
# Membungkus installer komunitas resmi:
# https://github.com/pterodactyl-installer/pterodactyl-installer

INSTALLER_URL="https://pterodactyl-installer.se"

R="\e[31m"; G="\e[32m"; Y="\e[33m"; C="\e[36m"; B="\e[1m"; X="\e[0m"
info() { echo -e "${C}[INFO]${X} $*"; }
ok()   { echo -e "${G}[OK]${X} $*"; }
warn() { echo -e "${Y}[WARN]${X} $*"; }
fail() { echo -e "${R}[ERROR]${X} $*"; exit 1; }

preflight() {
  [ "$(uname -s)" = "Linux" ] || fail "Hanya untuk Linux."
  [ "$(id -u)" -eq 0 ] || fail "Jalankan sebagai root: sudo bash ptero-install.sh"

  . /etc/os-release 2>/dev/null
  info "OS: ${PRETTY_NAME:-unknown}"
  case "${ID:-}" in
    ubuntu|debian|rocky|almalinux|centos) ;;
    *) warn "OS tidak ada di daftar yang didukung (Ubuntu/Debian/Rocky/Alma)." ;;
  esac

  ram_mb=$(awk '/MemTotal/ {print int($2/1024)}' /proc/meminfo)
  [ "$ram_mb" -ge 1800 ] || warn "RAM hanya ${ram_mb} MB. Panel butuh minimal ~2 GB."

  if command -v systemd-detect-virt >/dev/null 2>&1; then
    virt=$(systemd-detect-virt)
    case "$virt" in
      openvz|lxc) warn "Virtualisasi $virt terdeteksi. Wings/Docker biasanya tidak jalan di sini." ;;
    esac
  fi

  if ! command -v curl >/dev/null 2>&1; then
    info "Memasang curl..."
    if command -v apt-get >/dev/null 2>&1; then
      apt-get update -y && apt-get install -y curl || fail "Gagal install curl."
    else
      yum install -y curl || fail "Gagal install curl."
    fi
  fi
  ok "Pengecekan awal selesai."
}

confirm() {
  read -r -p "$1 [y/N]: " a
  [[ "$a" =~ ^[Yy]([Ee][Ss])?$ ]]
}

run_installer() {
  echo -e "\n${B}Saat menu installer resmi muncul, ketik:${X} ${G}$1${X}"
  echo -e "Lalu ikuti pertanyaan (domain, password DB, email admin, SSL, dll).\n"
  bash <(curl -sSL "$INSTALLER_URL") || fail "Installer berhenti dengan error."
  ok "Selesai."
}

post_info() {
  echo -e "
${B}Langkah setelah install:${X}
 1. Buka https://DOMAIN-KAMU, login dengan akun admin yang dibuat tadi.
 2. Buat Location + Node di Admin > Locations / Nodes.
 3. Di Node > tab Configuration, salin config ke /etc/pterodactyl/config.yml
    (atau pakai perintah auto-deploy dari panel).
 4. Jalankan wings:  ${G}systemctl enable --now wings${X}
 5. Buka port: 80, 443, 8080 (wings API), 2022 (SFTP), + port game server.
 6. Cek status: ${G}systemctl status wings${X}
"
}

preflight

echo -e "
${B}${C}=== Pterodactyl Easy Installer ===${X}

  ${G}1${X}) Panel saja
  ${G}2${X}) Wings saja
  ${G}3${X}) Panel + Wings (satu VPS)
  ${G}4${X}) Cek status layanan
  ${G}0${X}) Keluar
"
read -r -p "Pilihan: " choice

case "$choice" in
  1) confirm "Install Panel?" && run_installer 0 ;;
  2) confirm "Install Wings? (Docker dipasang otomatis)" && { run_installer 1; post_info; } ;;
  3) confirm "Install Panel + Wings di server ini?" && { run_installer 2; post_info; } ;;
  4) systemctl --no-pager status wings pteroq nginx mariadb 2>&1 | head -n 60 ;;
  *) info "Keluar." ;;
esac
