#!/bin/sh
# Undo list for everything this repo's batches changed on the author's U8N. Run whole or pick lines.
. "$(dirname "$0")/../lib.sh"
sh_tv pm install-existing --user 0 com.calientetv   # or reinstall from Play Store
sh_tv pm install-existing --user 0 com.fic.foxsports   # or reinstall from Play Store
sh_tv pm install-existing --user 0 com.cbs.ca   # or reinstall from Play Store
sh_tv pm install-existing --user 0 com.google.android.videos   # or reinstall from Play Store
sh_tv pm install-existing --user 0 com.spotify.tv.android   # or reinstall from Play Store
sh_tv pm enable --user 0 net.vidaatv.hisense.android.tv
sh_tv pm enable --user 0 com.vidaa.oemtabcontentprovider
sh_tv pm enable --user 0 com.google.android.play.games
sh_tv pm enable --user 0 com.hisense.odinbrowser
sh_tv pm enable --user 0 android.autoinstalls.config.google.gtvpai
sh_tv pm enable --user 0 com.vt.tv.evservice
sh_tv pm enable --user 0 com.vt.hishow
sh_tv pm enable --user 0 com.vt.tv.protector
sh_tv pm enable --user 0 com.vt.tv.ai_sense
sh_tv pm enable --user 0 com.vt.alexa
sh_tv pm enable --user 0 com.vt.storemode
sh_tv pm enable --user 0 tv.mopa.ginga
sh_tv pm enable --user 0 com.google.android.feedback
sh_tv pm enable --user 0 com.google.android.syncadapters.calendar
sh_tv pm enable --user 0 com.android.printspooler
sh_tv pm enable --user 0 com.google.android.apps.tv.launcherx
sh_tv pm enable --user 0 com.google.android.tungsten.setupwraith
sh_tv pm install-existing --user 0 com.google.android.katniss   # Assistant was removed for user 0 (pm uninstall --user 0)
sh_tv pm enable --user 0 com.google.android.apps.tv.dreamx
