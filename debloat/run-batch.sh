#!/bin/sh
# usage: debloat/run-batch.sh debloat/batch-a.txt
# Applies one batch file (lines: "disable <pkg>" or "uninstall <pkg>"), logs every result,
# and appends the exact undo command for each success to debloat/restore.sh.
. "$(dirname "$0")/../lib.sh"
LOG="$HERE/debloat/log.txt"; RESTORE="$HERE/debloat/restore.sh"
[ -f "$RESTORE" ] || { printf '#!/bin/sh\n# Undo list, appended automatically by run-batch.sh. Run whole or pick lines.\n. "$(dirname "$0")/../lib.sh"\n' > "$RESTORE"; chmod +x "$RESTORE"; }
grep -vE '^\s*(#|$)' "$1" | while read -r action pkg; do
  case "$action" in
    uninstall) out=$(sh_tv pm uninstall --user 0 "$pkg" 2>&1); undo="sh_tv pm install-existing --user 0 $pkg   # or reinstall from Play Store";;
    disable)   out=$(sh_tv pm disable-user --user 0 "$pkg" 2>&1); undo="sh_tv pm enable --user 0 $pkg";;
    *) echo "unknown action '$action'"; continue;;
  esac
  out=$(printf '%s' "$out" | tr -d '\r')
  echo "$(date '+%F %T') $action $pkg -> $out" | tee -a "$LOG"
  case "$out" in *Success*|*"new state: disabled"*) echo "$undo" >> "$RESTORE";; esac
done
