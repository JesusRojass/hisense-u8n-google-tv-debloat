package dev.rojas.tvrearm;

import android.app.job.JobParameters;
import android.app.job.JobService;
import android.content.SharedPreferences;

public class RearmJobService extends JobService {
    static final String PREFS = "rearm", KEY_TRIES = "tries";
    @Override public boolean onStartJob(JobParameters params) {
        new Thread(() -> {
            SharedPreferences p = getSharedPreferences(PREFS, MODE_PRIVATE);
            int tries = p.getInt(KEY_TRIES, 0) + 1;
            String result = Rearm.run(this, 60_000);
            boolean ok = Rearm.looksOk(result);
            boolean retry = !ok && tries < 6;          // adbd or Shizuku not ready yet -> back off and retry (max 6)
            p.edit().putInt(KEY_TRIES, ok ? 0 : tries).apply();
            Rearm.log(this, "job try " + tries + (ok ? " OK" : (retry ? " failed, will retry" : " failed, giving up")));
            jobFinished(params, retry);
        }, "tv-rearm").start();
        return true;
    }
    @Override public boolean onStopJob(JobParameters params) { return true; }
}
