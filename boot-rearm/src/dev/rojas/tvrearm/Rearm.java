package dev.rojas.tvrearm;

import android.content.Context;
import android.util.Log;
import dadb.AdbKeyPair;
import dadb.AdbShellResponse;
import dadb.Dadb;
import java.io.File;
import java.io.FileWriter;
import java.text.SimpleDateFormat;
import java.util.Date;

/** Connects to this TV's own adbd (127.0.0.1:5555) with the app's own RSA key and runs the re-arm script. */
public final class Rearm {
    static final String TAG = "TvRearm";
    static final String SCRIPT = "sh /data/local/tmp/rearm.sh";

    public static String run(Context ctx, int socketTimeoutMs) {
        File dir = ctx.getFilesDir();
        File priv = new File(dir, "adbkey"), pub = new File(dir, "adbkey.pub");
        StringBuilder out = new StringBuilder();
        try {
            if (!priv.exists() || !pub.exists()) {
                AdbKeyPair.generate(priv, pub);
                out.append("generated new adb key (approve 'Allow USB debugging' on the TV once)\n");
            }
            AdbKeyPair key = AdbKeyPair.read(priv, pub);
            // first connect waits for the on-screen authorization, so allow a long socket timeout
            try (Dadb dadb = Dadb.create("127.0.0.1", 5555, key, 10_000, socketTimeoutMs)) {
                AdbShellResponse r = dadb.shell(SCRIPT);
                out.append(r.getAllOutput()).append("\nexit=").append(r.getExitCode()).append('\n');
                AdbShellResponse chk = dadb.shell("pidof shizuku_server && echo SHIZUKU_OK || echo SHIZUKU_DOWN");
                out.append(chk.getAllOutput());
            }
        } catch (Throwable t) {
            out.append("ERROR: ").append(t).append('\n');
            Log.w(TAG, "rearm failed", t);
        }
        log(ctx, out.toString());
        return out.toString();
    }

    public static boolean looksOk(String result) { return result.contains("SHIZUKU_OK"); }

    static void log(Context ctx, String s) {
        try (FileWriter w = new FileWriter(new File(ctx.getFilesDir(), "log.txt"), true)) {
            w.write(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date()) + "\n" + s + "\n");
        } catch (Exception ignored) {}
        Log.i(TAG, s);
    }

    public static String readLog(Context ctx) {
        try { return new String(java.nio.file.Files.readAllBytes(new File(ctx.getFilesDir(), "log.txt").toPath())); }
        catch (Exception e) { return "(no log yet)"; }
    }
}
