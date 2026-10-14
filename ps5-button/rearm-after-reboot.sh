#!/bin/sh
# Run from your computer after the TV FULLY reboots (power cut / firmware update). Standby does not need it.
. "$(dirname "$0")/../lib.sh"
sh_tv sh /data/local/tmp/rearm.sh
sleep 3
sh_tv pidof shizuku_server >/dev/null && echo "Shizuku: running" || echo "Shizuku: NOT running - re-run ps5-button/setup.sh"
