package dev.rojas.tvrearm;

import android.app.Activity;
import android.os.Bundle;
import android.widget.ScrollView;
import android.widget.TextView;

public class MainActivity extends Activity {
    @Override protected void onCreate(Bundle b) {
        super.onCreate(b);
        TextView tv = new TextView(this);
        tv.setPadding(48, 48, 48, 48); tv.setTextSize(16f);
        ScrollView sv = new ScrollView(this); sv.addView(tv); setContentView(sv);
        tv.setText("TV Re-arm\n\nRunning the re-arm script now (first run: approve the 'Allow USB debugging?' dialog, tick Always allow)...\n");
        new Thread(() -> {
            String r = Rearm.run(this, 180_000);
            runOnUiThread(() -> tv.setText("TV Re-arm\n\nResult:\n" + r + "\n\nIt also runs automatically ~20 s after every boot.\n\nLog:\n" + Rearm.readLog(this)));
        }, "tv-rearm-ui").start();
    }
}
