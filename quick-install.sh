#!/bin/sh
set -e

# apt-fast quick installer with Termux (Android) support.
#
# Environment overrides:
#   APT_FAST_URL   base URL to download the apt-fast files from.
#                  Default: https://raw.githubusercontent.com/TheTechTiger/apt-fast/termux-support
#   PREFIX         install prefix. Termux sets this automatically
#                  (usually /data/data/com.termux/files/usr).

if [ -n "$EUID" ]; then userid="$EUID"; else userid="$(id -u)"; fi

run_cmd() {
  [ "$userid" -ne 0 ] && set -- sudo "$@"
  "$@"
}

apt_fast_url="${APT_FAST_URL:-https://raw.githubusercontent.com/TheTechTiger/apt-fast/termux-support}"

is_termux() {
  # Explicit Termux marker.
  [ -n "${TERMUX_VERSION:-}" ] && return 0
  # Termux sets PREFIX to its app-private directory.
  case "${PREFIX:-}" in
    *com.termux*) return 0 ;;
  esac
  # uname -o prints "Android" on Termux.
  if command -v uname >/dev/null 2>&1; then
    [ "$(uname -o 2>/dev/null)" = "Android" ] && [ -n "${PREFIX:-}" ] && return 0
  fi
  return 1
}

download_file() {
  # $1 = URL, $2 = destination file
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$1" -o "$2"
  else
    wget "$1" -O "$2"
  fi
}

if is_termux; then
  # Termux is single-user: packages install without root, so sudo is
  # never needed (and must not be used). Everything lives under $PREFIX
  # because /usr/local and /etc are not writable on Android.
  : "${PREFIX:?PREFIX must be set in the Termux environment}"
  bindir="$PREFIX/bin"
  confdir="$PREFIX/etc"
  conffile="$confdir/apt-fast.conf"

  if ! type aria2c >/dev/null 2>&1; then
    apt-get update
    apt-get install -y aria2
  fi

  mkdir -p "$bindir" "$confdir"

  # remove apt-fast from old locations
  rm -f "$bindir/apt-fast" /usr/local/sbin/apt-fast 2>/dev/null || true

  download_file "$apt_fast_url/apt-fast" "$bindir/apt-fast"
  chmod +x "$bindir/apt-fast"
  if [ ! -f "$conffile" ]; then
    download_file "$apt_fast_url/apt-fast.conf" "$conffile"
  fi

  echo "apt-fast installed to $bindir/apt-fast"
  echo "Configuration file: $conffile"
  exit 0
fi

if [ "$userid" -ne 0 ]; then
  type sudo >/dev/null 2>&1 || { echo "sudo not installed, change into root context" >&2; exit 1; }
fi

if ! type aria2c >/dev/null 2>&1; then
  run_cmd apt-get update
  run_cmd apt-get install -y aria2
fi

# remove apt-fast from old location
run_cmd rm -f /usr/local/sbin/apt-fast

run_cmd wget "$apt_fast_url"/apt-fast -O /usr/local/bin/apt-fast
run_cmd chmod +x /usr/local/bin/apt-fast
if [ ! -f /etc/apt-fast.conf ]; then
  run_cmd wget "$apt_fast_url"/apt-fast.conf -O /etc/apt-fast.conf
fi
