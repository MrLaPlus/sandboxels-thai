#!/bin/sh
# คัดลอกเฉพาะ thai.js เข้าโฟลเดอร์มอดของ Sandboxels
# ไม่ลบมอดอื่น และไม่แตะเซฟ
set -eu
HERE=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
SRC="$HERE/thai.js"
if [ ! -f "$SRC" ]; then
  echo "ไม่พบ thai.js คู่กับสคริปต์นี้" >&2
  exit 1
fi

copied="|"
roots="|"

copy_to() {
  dir=$1
  mkdir -p "$dir"
  dir=$(CDPATH= cd -- "$dir" && pwd -P)
  case $copied in
    *"|$dir|"*) return 0 ;;
  esac
  cp -f "$SRC" "$dir/thai.js"
  copied="${copied}$dir|"
  echo "คัดลอกไปที่ $dir/thai.js"
}

add_root() {
  root=$1
  [ -n "$root" ] || return 0
  [ -d "$root" ] || return 0
  case $roots in
    *"|$root|"*) return 0 ;;
  esac
  roots="${roots}$root|"
}

# เกมผ่าน Proton อ่าน AppData\Roaming\sandboxels ไม่ใช่ ~/.local/share
copy_prefix_users() {
  pfx=$1
  force=$2
  usersdir="$pfx/drive_c/users"
  [ -d "$usersdir" ] || return 0
  for userdir in "$usersdir"/*; do
    [ -d "$userdir" ] || continue
    name=$(basename "$userdir")
    case $name in
      Public|public|"Default User"|"All Users") continue ;;
    esac
    data="$userdir/AppData/Roaming/sandboxels"
    if [ "$force" = 1 ] || [ -d "$data" ]; then
      copy_to "$data/mods"
    fi
  done
}

install_proton_at() {
  root=$1
  compat="$root/steamapps/compatdata"
  [ -d "$compat" ] || return 0
  # 3664820 คือ Sandboxels บน Steam สร้างโฟลเดอร์ให้แม้ยังไม่เคยเปิดเกม
  if [ -d "$compat/3664820/pfx" ]; then
    copy_prefix_users "$compat/3664820/pfx" 1
  fi
  for app in "$compat"/*; do
    [ -d "$app/pfx" ] || continue
    copy_prefix_users "$app/pfx" 0
  done
}

read_library_vdf() {
  vdf=$1
  [ -f "$vdf" ] || return 0
  while IFS= read -r line; do
    case $line in
      *'"path"'*)
        path=$(printf '%s\n' "$line" | sed 's/.*"path"[[:space:]]*"//; s/"[[:space:]]*$//')
        add_root "$path"
        ;;
    esac
  done < "$vdf"
}

if [ -d "$HOME/.var/app/com.valvesoftware.Steam" ]; then
  copy_to "$HOME/.var/app/com.valvesoftware.Steam/.local/share/sandboxels/mods"
fi
copy_to "$HOME/.local/share/sandboxels/mods"

add_root "$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam"
add_root "$HOME/.local/share/Steam"
add_root "$HOME/.steam/steam"
add_root "$HOME/.steam/root"
add_root "$HOME/.var/app/com.valvesoftware.Steam/.steam/steam"
add_root "$HOME/.var/app/com.valvesoftware.Steam/.steam/root"

for vdf in \
  "$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/libraryfolders.vdf" \
  "$HOME/.var/app/com.valvesoftware.Steam/.steam/steam/steamapps/libraryfolders.vdf" \
  "$HOME/.local/share/Steam/steamapps/libraryfolders.vdf" \
  "$HOME/.steam/steam/steamapps/libraryfolders.vdf" \
  "$HOME/.steam/root/steamapps/libraryfolders.vdf"
do
  read_library_vdf "$vdf"
done

oldifs=$IFS
IFS='|'
for root in $roots; do
  [ -n "$root" ] || continue
  install_proton_at "$root"
done
IFS=$oldifs

echo "ปิดเกมให้หมด แล้วเปิดใหม่ เกมอ่านมอดตอนเปิดเท่านั้น"
echo "ดูบรรทัด [มอดไทย] ใช้งานแล้ว ในคอนโซล"
echo "อย่าวางไฟล์อื่นจากโฟลเดอร์นี้เข้า mods"
