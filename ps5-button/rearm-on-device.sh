#!/system/bin/sh
# DEVICE-SIDE re-arm, run as the shell user after a full reboot. Lives at /data/local/tmp/rearm.sh.
# Google TV / Hisense re-enable some of these at boot; Shizuku's server dies at boot.
pm disable-user --user 0 com.google.android.apps.tv.launcherx
pm disable-user --user 0 com.google.android.tungsten.setupwraith
# Hisense's Smartsense "StoreModeManager" force-enables the Google Assistant package at boot and later; keep it off
# and keep the system's assistant slot empty so a re-enabled package is never used.
pm disable-user --user 0 com.google.android.katniss
# Smartsense only force-enables the Assistant when this backup property is -1 (unset); any other value makes it skip.
setprop persist.vt.katniss_status_backup 3
settings put secure voice_interaction_service '""'
settings put secure assistant '""'
APK=$(pm path moe.shizuku.privileged.api | sed 's/package://')
pidof shizuku_server >/dev/null 2>&1 || /data/local/tmp/shizuku/starter --apk="$APK"
