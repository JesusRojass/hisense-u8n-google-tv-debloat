# Hisense U8N (Google TV) debloat, ad-free launcher, and a PS5 button on the remote

Everything I did to a Hisense 55U8N running Google TV (Android TV 12, MediaTek "hengshan" board, LatAm firmware)
to make it fast and ad-free, while keeping the picture/gaming pipeline, AirPlay, and Cast untouched.
No root. Everything is reversible with `pm enable` / `pm install-existing`, and `debloat/restore.sh` has the full undo list.

**Result:** sponsored apps gone, 23 packages frozen, Projectivy as home screen, idle free RAM roughly 135 MB -> 215 MB
on a TV with 2.4 GB total, Game Mode / VRR / ALLM / Dolby / CEC / AirPlay all still working, and the remote's Tubi key
presses the PS5's PS button over HDMI-CEC.

> Use at your own risk. Package names come from this exact model/firmware (`baseline/labels.txt` maps every package to
> its real app name). Other Hisense or Google TV models differ. Read a batch before running it.

## Requirements
- `adb` on your computer (Android platform-tools). Developer options -> USB debugging on the TV. This firmware opens
  TCP ADB on port 5555 whenever USB debugging is on, so `adb connect <tv-ip>:5555` works out of the box.
- `cp config.example.sh config.sh` and set `TV_IP` (and `ADB` if it isn't on your PATH).

## 1. Debloat
```bash
debloat/inventory.sh            # snapshot first (baseline/)
debloat/run-batch.sh debloat/batch-a.txt   # sponsored / regional preinstalls
debloat/run-batch.sh debloat/batch-b.txt   # Hisense visible clutter + ACR (content recognition)
debloat/run-batch.sh debloat/batch-c.txt   # minor Google leftovers
debloat/run-batch.sh debloat/batch-d.txt   # Google Assistant + Ambient Mode (optional, see notes)
```
Each line logs to `debloat/log.txt` and appends its undo command to `debloat/restore.sh`.
Everything uses `pm disable-user`; only four third-party sponsored apps are uninstalled (reinstallable from Play).

Deliberately **not** touched: `com.vt.tvservice`, `tvplayer`, `avmiddleware`, `aipq`, `videocolor`, Dolby, DRM,
HDMI/tuner inputs, Smartsense (handles remote keys and backlight), AirPlay/Cast stack, Play services, and every
Hisense/MediaTek package I couldn't positively identify. See `NOTES.md` for the per-package reasoning.

## 2. Launcher
Install **Projectivy Launcher** from the Play Store, then:
```bash
launcher/setup.sh                       # enables its accessibility override + notification access
launcher/setup.sh --disable-google-home # optional: freeze the stock Google TV home + its setup-wizard fallback
launcher/setup.sh --revert              # undo the freeze
```
The HOME intent chain on this TV is `launcherx (prio 2) -> setupwraith RecoveryActivity (prio 1) -> Projectivy (0)`,
which is why both must be disabled together. Side effects of the freeze: the gear key and the YouTube/Disney+/Prime
remote keys stop working (they were routed through the Google home; remap them, see `remap/`), the Inputs screen keeps a
"Google TV Home" tile, and the quick-settings dashboard is gone. The Netflix key keeps working.

## 3. PS5 PS button on a remote key (HDMI-CEC)
The PS5 opens its menu on the CEC "Root Menu" command. Android only maps that command to the Home/Menu keycodes, which
the TV eats, but on this firmware the adb shell user holds `android.permission.HDMI_CEC`, so a shell command can ask the
system HDMI service to send it directly:
```
/system/bin/service call hdmi_control 16 i32 0 i32 3 i32 1   # transaction 16 = sendKeyEvent(TV, KEYCODE_HOME, pressed)
/system/bin/service call hdmi_control 16 i32 0 i32 3 i32 0
```
Wiring: **Shizuku** (sideload; not on the TV Play Store) + **Button Mapper Pro** (shell command action).
```bash
ps5-button/setup.sh              # pushes scripts, starts Shizuku from its native starter, prints the Button Mapper steps
ps5-button/send-from-pc.sh       # press the PS button from your computer
ps5-button/rearm-after-reboot.sh # after a FULL reboot (not standby): restarts Shizuku, re-freezes what Hisense re-enables
```
Gotchas learned the hard way: Button Mapper's shell action silently does nothing while its Shizuku link is down (open
Button Mapper once; use TEST with "Show toast"); keep the command a single short token (`sh /data/local/tmp/psbutton.sh`);
the mic key cannot be remapped (it never produces a key event).

## 3b. Surviving reboots without a PC: `boot-rearm/`
Shizuku's server dies at every full reboot and this firmware has no usable Wireless-debugging pairing for Shizuku's
self-start. `boot-rearm/` is a 700 KB app that, ~20 s after boot, connects to the TV's **own** adbd on `127.0.0.1:5555`
(always open on this firmware) with its own key and runs the re-arm script. Install `boot-rearm.apk`, open it once,
accept the TV's "Allow USB debugging?" dialog with *Always allow*, done. Source + `build.sh` (plain SDK tools, no Gradle)
are in the folder; see its README.

## 4. Remote key remaps
```bash
remap/setup.sh   # enables Button Mapper's accessibility service next to Projectivy's, grants WRITE_SECURE_SETTINGS
```
Then map keys in Button Mapper. `remap/KEYS.md` has every keycode I found (Tubi = 606, gear = 83, Menu = 702, Inputs = 178)
and the mappings I use. Keycode 702 injected opens the Hisense quick-settings bar; 178 opens the Inputs screen.

## Things Hisense/Google undo on their own
- The stock home + setup wizard may come back enabled after a reboot (seen once); the re-arm script re-freezes them.
- Smartsense's `StoreModeManager` force-enables the Google Assistant package whenever `persist.vt.katniss_status_backup`
  is unset (-1) and the package is disabled. `setprop persist.vt.katniss_status_backup 3` (works from adb) makes it skip
  forever; the re-arm script also sets it and empties `voice_interaction_service` / `assistant`.
- Android's microphone privacy switch (`cmd sensor_privacy enable 0 microphone`) blocks mic access for every app;
  the far-field mic LED is a separate Settings toggle ("Voice LED").

## Repo layout
`debloat/` batches, runner, inventory, restore · `launcher/` Projectivy setup · `ps5-button/` CEC scripts ·
`remap/` Button Mapper prep + keycodes · `baseline/` package inventory with real app names · `NOTES.md` the full log.

Sources that helped: FLauncher README (launcher chain), seun-novodev's android-tv-debloat-toolkit, ohernandezdev's
android-tv-tune, tv.cobanov.dev, freya.cat's Google TV guide, FlatpanelsHD's Projectivy guide, and the libcec PS5 gist.
