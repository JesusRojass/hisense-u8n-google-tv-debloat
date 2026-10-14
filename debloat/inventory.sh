#!/bin/sh
# Snapshot the TV before touching anything: package lists, enabled/disabled state, memory, running services.
# Output goes to baseline/ (safe to re-run; files are overwritten).
. "$(dirname "$0")/../lib.sh"
OUT="$HERE/baseline"; mkdir -p "$OUT"
sh_tv getprop ro.product.model; sh_tv getprop ro.build.display.id
sh_tv pm list packages -f > "$OUT/packages-all-with-paths.txt"
sh_tv pm list packages    > "$OUT/packages-all.txt"
sh_tv pm list packages -d > "$OUT/packages-disabled-before.txt"
sh_tv pm list packages -3 > "$OUT/packages-third-party.txt"
sh_tv pm list packages -s > "$OUT/packages-system.txt"
{ date; sh_tv cat /proc/meminfo | head -5; echo; echo "# running services by package";
  sh_tv dumpsys activity services | grep -oE 'ServiceRecord\{[0-9a-f]+ u0 [^/]+' | awk '{print $3}' | sort | uniq -c | sort -rn; } > "$OUT/meminfo-before.txt"
wc -l "$OUT"/*.txt
echo "Tip: baseline/labels.txt in this repo maps every package on the U8N to its real app name."
