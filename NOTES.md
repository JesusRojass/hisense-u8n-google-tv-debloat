# Engineering notes (chronological, as the work happened)

## STATUS (2026-10-14 00:10)
- **Done:** Batches A/B/C applied (5 apps removed, 19 packages frozen), Projectivy launcher + override, stock Google home + setup wizard disabled (Phase 1b), reboot verified, Shizuku + Button Mapper Pro installed, **Tubi button → PS5 PS-button works** (single tap).
- **Memory:** idle MemFree ~135 MB → ~215 MB after debloat (`baseline/meminfo-before.txt` vs `meminfo-after.txt`).
- **2026-10-14 00:14:** Batch D applied (Google Assistant + Ambient Mode disabled) → debloat list complete, 23 packages disabled total. VRR confirmed OK on the PS5 .
- **2026-10-14 00:20:** Prime Video re-enabled (user uses it). AirPlay confirmed working. Netflix key still works natively; YouTube / Disney+ / Prime keys are dead with the Google home disabled → being remapped in Button Mapper (Applications action): YouTube→YouTube, Disney+ key→Plex, Prime→Prime Video.
- **Open:** Tubi long press (optional), Cast spot check, optional extras (Private DNS, Hisense privacy toggles), ADB left enabled for the re-arm script.
- **Lesson learned (Button Mapper):** its "Shell command" action runs through a Shizuku user service that is often *not connected* when the key fires, and it fails silently — only the TEST button reports "Shizuku service not connected". Opening Button Mapper once reconnects it. Also: keep the command a single short token (`sh /data/local/tmp/psbutton.sh`), the long one-liner with `;` was fragile to type and may not be parsed as a shell line.
- **Lesson learned (launcher):** the stock home came back enabled after the *first* reboot but stayed disabled after the second; the re-arm script re-disables it either way.


**Device:** Hisense SmartTV 4K FFM ("hengshan" MediaTek board), Android TV 12, build STT2.230310.002, LatAm firmware
**TV IP:** <TV_IP> · **Mac:** <PC_IP> · adb already authorized
**Baseline saved:** `baseline/` (166 packages, paths, real app labels in `labels.txt`)
**Priorities:** PS5 Pro / console picture & performance untouched · AirPlay + Cast kept · Plex kept · de-clutter: ad-free launcher, remove sponsored apps and visible junk · **uncertain Hisense pieces are not touched**

## Why this matters on this TV
- RAM is tight: 2.4 GB total, ~120 MB free, ~600 MB available at idle. Every background service we cut is real headroom.
- Top background offenders right now: Play services (20 services), Smartsense (9), Google app/Assistant (9), Netflix + observer (4), Google TV launcher (2).
- Storage is fine (13 GB free), so we disable rather than delete.

## Method
- `pm disable-user --user 0 <pkg>` for every system package. Reversible with `pm enable --user 0 <pkg>`. Nothing is deleted.
- `pm uninstall --user 0` only for the 4 sponsored third-party apps that live in `/data/app` and are reinstallable from Play Store.
- Max ~10 packages per batch, reboot, run the test checklist, then next batch.
- A `restore.sh` is generated before the first change. ADB stays connected until the final reboot checks pass.
- Turn **off** network ADB when finished (port 5555 accepts anyone on the LAN).

---

## Phase 1 — Launcher (do this first, before any launcher-related disabling)

**Launcher: Projectivy Launcher** (`com.spocky.projengmenu`, free, Play Store). Most polished and most-recommended in 2025/26 coverage (XDA, Android Police, FlatpanelsHD). Fallback: **FLauncher** (`me.efesser.flauncher`, open source, lighter).

1. Install Projectivy from the Play Store on the TV (I can open the store page over adb; you press Install).
2. Open it once, let it build the app grid. Hide/arrange apps as you like.
3. Projectivy → Settings → General → **Override current launcher** → grant the Accessibility permission when prompted.
4. Test: press Home from PS5 input, from Netflix, from standby wake. Home should land on Projectivy every time.

**Step 1b — the clean route (recommended once 1–4 work):** disable the stock launcher so Google's home never loads at all (no ads pre-rendering in RAM, Back button can't fall into it).
```
adb shell pm disable-user --user 0 com.google.android.apps.tv.launcherx
adb shell pm disable-user --user 0 com.google.android.tungsten.setupwraith   # fallback that re-enables launcherx
adb reboot
```
Verified on this TV: the HOME-intent chain is launcherx (priority 2) → setupwraith RecoveryActivity (priority 1) → Settings FallbackHome (−1000). With both disabled, Projectivy (priority 0) wins outright. This is why setupwraith must go too.

Trade-offs of 1b:
- Lose Google TV "Continue watching" rows, watchlist, and the Google TV home tabs. Projectivy has its own channel rows if you want them.
- YouTube remote button may stop working on some devices (Netflix button is handled by a separate observer and keeps working). Fix: Button Mapper app, or skip 1b.
- Google Assistant still works from the mic button (katniss stays).
- Reason to prefer 1b over override-only: a 2026 Google TV update reportedly broke Projectivy's override for some users; 1b doesn't depend on the override.

Revert: `adb shell pm enable --user 0 com.google.android.apps.tv.launcherx && adb shell pm enable --user 0 com.google.android.tungsten.setupwraith`

**Observed 2026-10-13:** both packages come back *enabled* after every full reboot (something in the Google TV stack resets them at boot; all 19 other disables persisted, and once re-disabled they stay down while running — verified over 3 minutes). Projectivy's accessibility override keeps Home working either way, so this only costs RAM until `ps-button/rearm-after-reboot.sh` is run. Shell cannot disable individual components on Android 12, so there is no finer-grained fix without root.

Zero-risk fallback if anything feels off: Settings → Accounts & Sign-in → **Apps only mode** (built-in, kills recommendations and sponsored rows, no ADB).

---

## Phase 2 — Debloat batches

### Batch A — Sponsored / regional preinstalls (pure ad placements)
| Package | App | Action |
|---|---|---|
| com.calientetv | FOX One MX | uninstall --user 0 |
| com.fic.foxsports | Fox Sports Mexico | uninstall --user 0 |
| com.cbs.ca | Paramount+ | uninstall --user 0 |
| com.google.android.videos | Google Play Movies | uninstall --user 0 |
| net.vidaatv.hisense.android.tv | Hisense Channels (FAST/ad channels) | disable |
| com.vidaa.oemtabcontentprovider | "Hisense" tab feed into Google TV home | disable |
| com.google.android.play.games | Google Play Games | disable |
| com.google.android.youtube.tvmusic | YouTube Music | disable |
| com.hisense.odinbrowser | Hi Browser | disable |
| com.amazon.amazonvideo.livingroom | Prime Video (user decision) | disable |
| com.spotify.tv.android | Spotify (user decision) | uninstall --user 0 |
| android.autoinstalls.config.google.gtvpai | Play auto-install stub (re-pushes sponsored apps) | disable |

### Batch B — Hisense apps that are visible clutter (positively identified only)
| Package | App (label from APK) | Why |
|---|---|---|
| com.vt.tv.evservice | "EVService" = **ACR** (class names: ACRService/ACRReceiver) | Content recognition for ad targeting; fingerprints whatever is on screen incl. PS5. Toggle off "Enhanced Viewing" in Settings → Privacy first. |
| com.vt.hishow | Family Moment | Photo-sharing app in the app grid |
| com.vt.tv.protector | Device Assistant | Hisense cleaner/booster app in the app grid |
| com.vt.tv.ai_sense | Camera Smart Functions | Needs a USB camera; app in the grid |
| com.vt.alexa | HiAlexa | Alexa integration |
| com.vt.storemode | StoreMode | Retail demo mode |
| tv.mopa.ginga | MoPA Ginga Service | Brazilian broadcast-interactivity middleware (not Hisense code, antenna-only) |

**Hisense packages deliberately left alone (not certain enough):** com.vt.tv.interactive, com.vt.tv.b2b, com.vt.udpserver (SyncPlayServer), com.vt.tv.smartservice, com.vt.tv.aiot / aiotprotocolapp / aiotsystemservice, com.vt.tv.dlna, com.vt.tv.singlelisten (BT Music), com.vt.tv.mediacenter, com.vt.tv.mobiledeviceconnectiontips (Miracast), com.vt.tv.customerlauncher, com.vt.tv.commonui. They are mostly invisible background pieces; Projectivy hides any leftover icons from the grid anyway.

### Batch C — Google extras (low value, safe per every toolkit reviewed)
| Package | App |
|---|---|
| com.google.android.feedback | Market Feedback Agent |
| com.google.android.syncadapters.calendar | Google Calendar Sync |
| com.android.printspooler | Print Spooler |
| com.android.dreams.basic | Basic Daydreams (only if Ambient Mode kept) |

---

## Decisions so far (2026-10-13)
- **Keep:** Plex, YouTube, YouTube Music, HBO Max, Netflix (+ tokenmanager/observer), Disney+, AirPlay, Google Cast, Miracast.
- **Remove:** Prime Video (com.amazon.amazonvideo.livingroom), Spotify (com.spotify.tv.android) → added to Batch A.
- **YouTube Music:** no better dedicated TV client exists (OuterTune/Metrolist/InnerTune are phone-only). Keep the official app. Optional later: SmartTube (sideload, ad-free YouTube + SponsorBlock) as a YouTube replacement; it plays music playlists but is not a music-first UI.
- **Google Assistant (katniss):** to be disabled, *after* the mic button is repurposed (see Phase 4). Disabling first would make the button dead while we test.
- **Firmware updates:** keep enabled (default).

## Phase 4 — Tubi button → PS5 "PS button" over CEC (PROVEN 2026-10-13)
**What works:** the adb shell user on this TV holds `android.permission.HDMI_CEC`, so a shell command can call the system HDMI service directly, bypassing Hisense's Live TV app:
```
/system/bin/service call hdmi_control 16 i32 0 i32 3 i32 1   # press  (txn 16 = sendKeyEvent, deviceType 0 = TV, keyCode 3 = HOME → CEC Root Menu 0x09)
/system/bin/service call hdmi_control 16 i32 0 i32 3 i32 0   # release
```
Verified: CEC log shows `<User Control Pressed> 04:44:09`, PS5 replied `<Menu Status> activated`, and the PS5 home/control menu opened on screen. Transaction number 16 confirmed from the TV's own framework.jar. Scripts: `ps-button/`.

**Why nothing simpler works:** Home and Menu are the only Android keycodes that map to CEC Root Menu. The system eats Home; Hisense's Live TV app eats Menu to open the Game Bar (hard-coded in LiveTVMainActivity.onKeyDown, no setting). Contents/Top/Context menu commands reach the PS5 but it ignores them; Exit (Back) works.

**The trigger:** the Tubi button is custom keycode 606 (scan 419). Chain: Smartsense GlobalKeyReceiver → broadcast to Google TV home (launcherx) → "launch com.tubitv" → Play Store. The mic button is NOT a key event (Bluetooth voice path straight into the Assistant), so it cannot be remapped; Tubi can.
Consequence: once launcherx is disabled (Phase 1b), the Tubi/Netflix/YouTube/Disney+/Prime app buttons will stop launching apps unless remapped. Test after 1b; Button Mapper can remap each.

**Wiring (needs a shell-uid helper on the TV; third-party apps cannot hold HDMI_CEC):**
- Option A (DONE): **Shizuku** (sideloaded) + **Button Mapper Pro**. Button Mapper: Add Buttons → Tubi registers as 606 → Customize on → Single tap → dropdown **Advanced** → **Shell command** = `sh /data/local/tmp/psbutton.sh` (the script lives at `ps-button/ps-button.sh`, pushed to `/data/local/tmp/psbutton.sh`, survives reboots). Button Mapper intercepts via accessibility before Hisense's global-key handler, so Play Store no longer opens.
- Option B (free, more work): **Key Mapper** (open source) mapping keycode 606 → launch a tiny custom "PS Button" app that I build, which runs the same command through Shizuku.
- Either way the helper dies on a *full reboot* (not standby). Re-arm from the Mac with `ps-button/rearm-after-reboot.sh` (one command). Power cuts and firmware updates are the only triggers.
- **Shizuku is not on the Play Store for TV.** Sideloaded v13.6.0 from the official RikkaApps GitHub release (sha256 6e273ab0…b790f). Its own start.sh was never written on this TV, so the native starter (`libshizuku.so` for armeabi-v7a) is pushed to `/data/local/tmp/shizuku/starter` and run with `--apk=<path of moe.shizuku.privileged.api>`. That is what the re-arm script does.
- Button Mapper 4.12 installed from Play; accessibility service `flar2.homebutton/a.i` enabled via secure settings; WRITE_SECURE_SETTINGS granted.
- Nice extra once this works: Button Mapper long-press on the same key → CEC Exit (`i32 4` = KEYCODE_BACK) or launch the Game Bar.

## Remote key findings (2026-10-14)
- **Gear key = keycode 83 (KEYCODE_NOTIFICATION).** System routes it to the "notification handler" = Google TV home dashboard → dead while launcherx is disabled. the owner does NOT want launcherx enabled, ever.
- **Hisense bottom quick bar** ("Settings | Quick Tools | Picture Mode | Sound Mode | Sleep Timer | Audio Output | Picture | Sound | Help") is a TV Settings overlay opened by **keycode 702** (physical Menu key on the remote sends 702; injected `input keyevent 702` opens it too). The alternative trigger, broadcast `com.hisense.tv.SHOW_SQUARES_MENU`, is a protected broadcast (shell/Shizuku cannot send it).
- Fix for the gear: Button Mapper → key 83 ("NOTIFICATION") → Single tap → Advanced → **Custom keycode 702**. On the PS5 input the same keycode lands in Live TV, which opens the Game Bar instead (game-mode logic inside LiveTVMainActivity, not changeable).
- **Menu key (82 injected / 702 physical)** on PS5 input → Game Bar (wanted, untouched).
- **Inputs screen** (com.vt.tv.input, keycode 178 / `am start -n com.vt.tv.input/.view.activity.MainActivity`) lists a "Google TV Home" tile (opens Projectivy). Label logic (HomeSourceRepository): "Home" only if the TV-mode value from launcherx's DeviceModeContentProvider == 2 (apps-only mode); with launcherx disabled the query fails → default → "Google TV Home". Custom input names (`tv_input_custom_labels`, id `android.intent.category.HOME`) are NOT applied to that tile (tested 2026-10-14, reverted). Not changeable without the Google home package or root.
- App keys: YouTube / Disney+ / Prime are routed through launcherx → remapped in Button Mapper (Applications action). Netflix key works natively.

## Phase 3 — Your call (not in default run)
| Package | App | Trade-off |
|---|---|---|
| com.netflix.ninja (+ tokenmanager, mstar.netflixobserver) | Netflix | Remove only if you never use it. Kills the Netflix remote button. |
| com.disney.disneyplus | Disney+ | Keep if used |
| com.wbd.stream | HBO Max | Keep if used |
| com.google.android.youtube.tv | YouTube | Keep (default) |
| com.google.android.katniss | Google app / Assistant | 9 services. Disabling frees RAM but kills mic button + voice search. |
| com.google.android.apps.tv.dreamx | Ambient Mode screensaver | Shows Google promos in some regions. Replace with basic daydream or Projectivy's screensaver. |
| com.vt.tv.ota, com.vt.remoteupgrade, com.vt.tv.usbota | Firmware updates | Freezing stops Hisense/Google from pushing new ads or breaking the launcher, but also stops security + HDMI/gaming fixes. Default: keep enabled. |

---

## Never touch (picture quality, gaming, inputs, core)
- **Picture/audio pipeline:** com.vt.tvservice, com.vt.tvplayer, com.vt.avmiddleware, com.vt.tv.aipq (AI PQ), com.vt.tv.videocolor, com.vt.tv.calmanconnector, com.vt.roomcalibration, com.dolby.android.audio.service, com.vt.edv.drmp (DRM), com.mediatek.system.pqrepository.overlay.config
- **Inputs / HDMI / CEC / tuner:** com.vt.tv.input (Inputs menu), com.vt.source.external (HDMI), com.vt.source.tuner, com.vt.tv.tvcenter (Live TV), com.mediatek.dtv.tvinput.framework.server, com.android.providers.tv, com.mediatek.tv.agent, com.mediatek.extservice
- **Remote & keys:** com.vt.tv.smartsense + smartsense.ui (handles global remote keys, remote backlight wake, input broadcasts), com.google.android.tv.remote.service, com.mediatek.autopair, com.android.bluetooth, com.mediatek.android.tv.globalkeyoverlay
- **AirPlay / Cast:** com.mediatek.AirplayAPK, com.mediatek.airplaydaemon, com.mediatek.partner.airplay_sys, com.vt.tv.airplaykeycheck, com.google.android.apps.mediashell (Google Cast)
- **Core Android/Google:** com.google.android.gms, gsf, com.android.vending, permissioncontroller, packageinstaller, webview, inputmethod.latin (keyboard), tts, com.android.tv.settings, systemui, location.fused (boot loop if disabled), all `*.overlay.*`, `*rro*`, `*resoverlay*`, networkstack, providers.*
- **Hisense system + anything uncertain:** com.vt.eula, com.vt.fte, com.vt.factory, com.vt.tv.commonui, com.vt.tv.customerlauncher, com.vt.tv.usbota, com.vt.tv.interactive, com.vt.tv.b2b, com.vt.udpserver, com.vt.tv.smartservice, com.vt.tv.aiot*, com.vt.tv.dlna, com.vt.tv.singlelisten, com.vt.tv.mediacenter, com.vt.tv.mobiledeviceconnectiontips, com.mediatek.network, com.mediatek.aowtis, com.mediatek.extservice, com.mediatek.tv.agent, com.mediatek.tis (already disabled), com.netflix.tokenmanager if Netflix kept. Rule: if it is Hisense/MediaTek and not positively identified, it stays.
- **Setup/launcher:** com.google.android.tungsten.setupwraith is only disabled as part of Phase 1b, never alone.

---

## Test checklist (after every batch and after final reboot)
1. Home button → Projectivy. Back from an app → Projectivy, not Google home.
2. Switch to PS5 HDMI: Game Mode / ALLM auto-engages, VRR + 120/144 Hz still show in PS5 video output info, HDR/Dolby Vision gaming still listed.
3. HDMI-CEC: PS5 power-on still wakes TV and switches input.
4. Inputs button on remote opens Inputs menu. Volume, mute, mic button, Netflix/YouTube buttons.
5. AirPlay from iPhone/Mac, Google Cast from phone. Plex plays.
6. Settings app opens; picture mode menu fully populated; sound modes fine.
7. Bluetooth remote still paired after reboot; Wi-Fi reconnects.
8. `adb shell cat /proc/meminfo | head -3` to compare free RAM vs baseline.

## Rollback
- `restore.sh` (generated before Batch A) re-enables everything in reverse order.
- Single package: `adb shell pm enable --user 0 <pkg>` or `adb shell pm install-existing --user 0 <pkg>`.
- Nuclear: Settings → System → About → Factory reset restores every package.

## Extras (optional, no package changes)
- Private DNS → `dns.adguard-dns.com` (Settings → Network → Advanced) blocks most in-app and launcher ad calls network-wide for this TV only.
- Settings → Privacy → Ads → reset advertising ID + opt out of personalization.
- Settings → Privacy → Usage & diagnostics → off.
- Disable Hisense "Enhanced Viewing Experience" / ACR consent in Settings before disabling evservice.

## Sources
- FLauncher README (launcherx + setupwraith fallback behaviour): https://github.com/svrooij/flauncher
- seun-novodev android-tv-debloat-toolkit (the Reddit toolkit; TCL-focused safe list, disable-user only, FLauncher): https://github.com/seun-novodev/android-tv-debloat-toolkit
- ohernandezdev android-tv-tune (2025/26, never-disable list, restore script pattern, ADB-off advice): https://github.com/ohernandezdev/android-tv-tune
- tv.cobanov.dev debloat rules (protected packages, 10-per-batch, location.fused boot loop): https://tv.cobanov.dev/en/prompt.txt
- freya.cat Google TV guide (order of operations, soft-brick warning): https://freya.cat/blog/post/2025-03-11
- FlatpanelsHD Projectivy guide: https://www.flatpanelshd.com/guide.php?subaction=showfull&id=1754640308
- Android Police / XDA / MakeUseOf Projectivy coverage: https://www.androidpolice.com/remove-google-tv-ads/ · https://www.xda-developers.com/google-tv-bloated-replaced-custom-launcher-actually-works/ · https://www.makeuseof.com/projectivy-google-tv-launcher-replacment/
- Android Authority on 2026 update breaking Projectivy override: https://www.androidauthority.com/google-tv-update-blocks-projectivy-override-3649445/
- Hisense ad behaviour background: https://www.tomshardware.com/tech-industry/big-tech/hisense-tvs-force-owners-to-watch-intrusive-ads-when-switching-inputs-visiting-the-home-screen-or-even-changing-channels-practice-infuriates-consumers-brand-denies-wrongdoing
