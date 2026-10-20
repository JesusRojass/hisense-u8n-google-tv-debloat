# boot-rearm: make Shizuku (and the other re-arm steps) survive reboots, no PC needed

Shizuku's server dies on every full reboot, and this Hisense firmware has no usable Wireless-debugging pairing UI for
Shizuku's own start-on-boot. But the firmware opens classic TCP ADB on port 5555 at every boot (`service.adb.tcp.port=5555`).
So this tiny app, ~20 s after boot, connects to the TV's **own** adbd at `127.0.0.1:5555` with its own RSA key
(using the [dadb](https://github.com/mobile-dev-inc/dadb) client library) and runs `/data/local/tmp/rearm.sh`
(see `../ps5-button/rearm-on-device.sh`), which restarts Shizuku and re-freezes what Hisense/Google re-enable.

- First launch: open "TV Re-arm" once from the launcher, accept the TV's "Allow USB debugging?" dialog with
  *Always allow*. After that it is silent. The activity shows the last result and a log.
- Retries up to 6 times with backoff if adbd or Shizuku isn't up yet.
- Build: put the jars listed in `build.sh` into `libs/` (dadb 2.0.0, okio 2.10.0, kotlin-stdlib 1.9.20 + jdk7/jdk8 from
  Maven Central), then `./build.sh`. Needs a JDK 17 and Android build-tools; no Gradle.
- Caveat: if the TV ever drops its saved ADB keys again (seen once, "Expected keyStore, but got tag=adbKey" at boot),
  the dialog shows again and the app keeps retrying until you accept it.
