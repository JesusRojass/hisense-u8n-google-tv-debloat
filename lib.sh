# shared helpers, sourced by every script
HERE="$(cd "$(dirname "$0")/.." && pwd)"
[ -f "$HERE/config.sh" ] && . "$HERE/config.sh"
ADB="${ADB:-adb}"; TV_IP="${TV_IP:-}"; TV="${TV:-$TV_IP:5555}"
[ -n "$TV_IP" ] || { echo "Set TV_IP (copy config.example.sh to config.sh)"; exit 1; }
"$ADB" connect "$TV" >/dev/null 2>&1
"$ADB" shell echo ok </dev/null >/dev/null 2>&1 || { echo "TV not reachable over adb at $TV. Accept the 'Allow USB debugging?' prompt on the TV."; exit 1; }
sh_tv(){ "$ADB" shell "$@" </dev/null; }     # adb shell without eating stdin (safe inside loops)
