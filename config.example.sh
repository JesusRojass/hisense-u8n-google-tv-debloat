# Copy to config.sh and edit. All scripts source config.sh if present.
ADB="${ADB:-adb}"                       # path to adb (e.g. ~/Library/Android/sdk/platform-tools/adb)
TV_IP="${TV_IP:-192.168.1.50}"          # your TV's LAN IP (Settings > Network)
TV="$TV_IP:5555"
