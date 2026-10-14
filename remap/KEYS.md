# Remote keycodes on the Hisense U8N (Google TV) remote

Found with `adb shell getevent -l` and `logcat | grep interceptKeyTq` while pressing keys.

| Key on remote | Android keycode | Stock behaviour | What it does after disabling the Google TV home |
|---|---|---|---|
| Tubi | 606 (scan 419) | Smartsense GlobalKeyReceiver -> Google home -> launch `com.tubitv` (Play Store if missing) | nothing -> free to remap (used for the PS5 button) |
| YouTube / Disney+ / Prime Video | vendor keycodes (detect in Button Mapper) | same chain via the Google home | nothing -> remap to the apps in Button Mapper (Applications action) |
| Netflix | handled by `com.mstar.netflixobserver` | opens Netflix | still works |
| Gear (settings) | 83 KEYCODE_NOTIFICATION | system "notification handler" -> Google home dashboard | nothing -> remap (Actions -> System Settings, or Custom keycode 702) |
| Menu | 702 physical (82 when injected) | Hisense quick bar; on a game-mode HDMI input: Game Bar | unchanged |
| Inputs | 178 KEYCODE_TV_INPUT | Hisense Inputs screen (`com.vt.tv.input`) | unchanged |
| Mic | no key event (Bluetooth voice path straight into the Assistant) | Assistant | cannot be remapped |

Useful injectable keycodes: `input keyevent 702` opens the Hisense quick-settings bar (Settings, Quick Tools, Picture Mode, Sound Mode, Sleep Timer, Audio Output, Picture, Sound, Help) except on a game-mode input, where Live TV turns it into the Game Bar. `input keyevent 178` opens the Inputs screen. The quick bar's other trigger, broadcast `com.hisense.tv.SHOW_SQUARES_MENU`, is protected (system apps only).

## Button Mapper mappings used
| Key | Single tap |
|---|---|
| Tubi (606) | Advanced -> Shell command: `sh /data/local/tmp/psbutton.sh` (PS5 PS button over CEC, needs Shizuku) |
| Gear (83) | Actions -> System Settings |
| YouTube | Applications -> YouTube |
| Disney+ | Applications -> Plex (your call) |
| Prime Video | Applications -> Prime Video |
