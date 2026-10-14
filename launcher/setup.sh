#!/bin/sh
# Make Projectivy the home screen and (optionally) disable the stock Google TV home.
# usage: launcher/setup.sh            -> enable Projectivy's accessibility + notification access (override works)
#        launcher/setup.sh --disable-google-home   -> also disable launcherx + its setup-wizard fallback (RAM win)
#        launcher/setup.sh --revert   -> re-enable the Google home + fallback
. "$(dirname "$0")/../lib.sh"
PROJ=com.spocky.projengmenu
A11Y="$PROJ/$PROJ.services.ProjectivyAccessibilityService"
NOTIF="$PROJ/$PROJ.services.notification.NotificationListener"
case "$1" in
  --revert)
    sh_tv pm enable --user 0 com.google.android.apps.tv.launcherx
    sh_tv pm enable --user 0 com.google.android.tungsten.setupwraith; exit 0;;
esac
sh_tv pm list packages | grep -q "$PROJ" || { echo "Install Projectivy Launcher from the Play Store first:"; sh_tv am start -a android.intent.action.VIEW -d "market://details?id=$PROJ" >/dev/null; exit 1; }
cur=$(sh_tv settings get secure enabled_accessibility_services | tr -d '\r'); case "$cur" in *"$A11Y"*) ;; ""|null) cur="$A11Y";; *) cur="$cur:$A11Y";; esac
sh_tv settings put secure enabled_accessibility_services "$cur"; sh_tv settings put secure accessibility_enabled 1
nl=$(sh_tv settings get secure enabled_notification_listeners | tr -d '\r'); case "$nl" in *"$NOTIF"*) ;; ""|null) nl="$NOTIF";; *) nl="$nl:$NOTIF";; esac
sh_tv settings put secure enabled_notification_listeners "$nl"
echo "Projectivy accessibility + notification access enabled. In Projectivy: Settings > General > Override current launcher."
if [ "$1" = "--disable-google-home" ]; then
  sh_tv cmd package query-activities --brief -a android.intent.action.MAIN -c android.intent.category.HOME | grep -q "$PROJ" || { echo "ABORT: Projectivy is not registered as a HOME app yet. Open it once first."; exit 1; }
  sh_tv pm disable-user --user 0 com.google.android.apps.tv.launcherx
  sh_tv pm disable-user --user 0 com.google.android.tungsten.setupwraith
  echo "Stock home disabled. Known side effects: gear key dead (see remap/), YouTube/Disney+/Prime remote keys dead (remap them), 'Google TV Home' tile in Inputs keeps its name."
fi
