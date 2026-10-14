#!/bin/sh
# Prepares Button Mapper for remapping remote keys (the mappings themselves are done in the app's UI).
#  - enables Button Mapper's accessibility service next to Projectivy's (so Home override keeps working)
#  - grants WRITE_SECURE_SETTINGS (unlocks Button Mapper's extra actions without a PC each time)
#  - prints the key table from remap/KEYS.md
. "$(dirname "$0")/../lib.sh"
BM=flar2.homebutton; BM_A11Y="$BM/a.i"     # service name as of Button Mapper 4.12 (check: dumpsys package flar2.homebutton)
PROJ_A11Y="com.spocky.projengmenu/com.spocky.projengmenu.services.ProjectivyAccessibilityService"
sh_tv pm list packages | grep -q "$BM" || { echo "Install Button Mapper from the Play Store first:"; sh_tv am start -a android.intent.action.VIEW -d "market://details?id=$BM" >/dev/null; exit 1; }
svc=$(sh_tv dumpsys package $BM | grep -B3 'android.accessibilityservice.AccessibilityService"' | grep -oE "$BM/[A-Za-z0-9_.]+" | head -1); [ -n "$svc" ] && BM_A11Y="$svc"
cur=$(sh_tv settings get secure enabled_accessibility_services | tr -d '\r'); case "$cur" in ""|null) cur="$PROJ_A11Y:$BM_A11Y";; *"$BM_A11Y"*) ;; *) cur="$cur:$BM_A11Y";; esac
sh_tv settings put secure enabled_accessibility_services "$cur"; sh_tv settings put secure accessibility_enabled 1
sh_tv pm grant $BM android.permission.WRITE_SECURE_SETTINGS
echo "bound accessibility services: $(sh_tv dumpsys accessibility | grep -oE 'label=[A-Za-z ]+' | sort -u | tr '\n' ' ')"
echo; echo "Now map keys inside Button Mapper (Add Buttons -> press the key -> Customize -> Single tap). Reference:"; echo
sed -n '1,/^## Button Mapper/p' "$HERE/remap/KEYS.md" | grep '^|' ; echo
echo "To capture an unknown key's code: $ADB logcat -c; press it; $ADB logcat -d | grep interceptKeyTq"
