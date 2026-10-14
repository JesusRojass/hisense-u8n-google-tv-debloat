#!/bin/sh
# Press the PS5's PS button from your computer (TV must be showing the PS5 so it is the CEC active source).
. "$(dirname "$0")/../lib.sh"
sh_tv sh /data/local/tmp/psbutton.sh
