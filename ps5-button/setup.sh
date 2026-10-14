#!/bin/sh
# One-time setup for "remote button -> PS5 PS button over HDMI-CEC".
# Prereqs on the TV: Shizuku (sideload from github.com/RikkaApps/Shizuku/releases; it is not on the TV Play Store)
#                    Button Mapper (Play Store, Pro needed for the Shell command action).
# What this does: pushes the device scripts, extracts Shizuku's native starter from the installed APK and starts the
# Shizuku server, then prints exactly what to configure in Button Mapper.
. "$(dirname "$0")/../lib.sh"
D="$HERE/ps5-button"
sh_tv pm list packages | grep -q moe.shizuku.privileged.api || { echo "Install Shizuku first (sideload the APK from the official GitHub release)."; exit 1; }
"$ADB" push "$D/ps-button.sh" /data/local/tmp/psbutton.sh </dev/null >/dev/null && sh_tv chmod 755 /data/local/tmp/psbutton.sh
"$ADB" push "$D/rearm-on-device.sh" /data/local/tmp/rearm.sh </dev/null >/dev/null && sh_tv chmod 755 /data/local/tmp/rearm.sh
# Shizuku's own start.sh is never written on this TV, so run its native starter directly.
ABI=$(sh_tv getprop ro.product.cpu.abi | tr -d '\r'); APK=$(sh_tv pm path moe.shizuku.privileged.api | sed 's/package://' | tr -d '\r')
TMP=$(mktemp -d); "$ADB" pull "$APK" "$TMP/shizuku.apk" </dev/null >/dev/null && unzip -o -q "$TMP/shizuku.apk" "lib/$ABI/libshizuku.so" -d "$TMP"
sh_tv mkdir -p /data/local/tmp/shizuku; "$ADB" push "$TMP/lib/$ABI/libshizuku.so" /data/local/tmp/shizuku/starter </dev/null >/dev/null; sh_tv chmod 755 /data/local/tmp/shizuku/starter; rm -rf "$TMP"
sh_tv "/data/local/tmp/shizuku/starter --apk=$APK" | tail -2
# sanity: does the CEC call work from a bare shell? (sends a key release only)
sh_tv "env -i /system/bin/sh -c '/system/bin/service call hdmi_control 16 i32 0 i32 3 i32 0'" | grep -q Parcel && echo "HDMI control service reachable from shell: OK" || echo "WARNING: shell cannot call hdmi_control on this TV"
cat <<'TXT'

Now in Button Mapper on the TV (Shizuku dialog -> Allow, when it appears):
  Add Buttons -> press the remote key you want (the Tubi key is keycode 606 on the U8N remote)
  Customize ON -> Single tap -> dropdown "Advanced" -> Shell command:
      sh /data/local/tmp/psbutton.sh
  Tick "Show toast", press TEST while the TV shows the PS5. If the toast says "Shizuku service not connected",
  open Button Mapper's main screen once (Use Shizuku -> Connected) and TEST again. Then OK.
After a full reboot run ps5-button/rearm-after-reboot.sh.
TXT
