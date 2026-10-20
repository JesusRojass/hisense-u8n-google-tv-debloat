package dev.rojas.tvrearm;

import android.app.job.JobInfo;
import android.app.job.JobScheduler;
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;

public class BootReceiver extends BroadcastReceiver {
    static final int JOB_ID = 4242;
    @Override public void onReceive(Context ctx, Intent intent) {
        ctx.getSharedPreferences(RearmJobService.PREFS, Context.MODE_PRIVATE).edit().putInt(RearmJobService.KEY_TRIES, 0).apply();
        schedule(ctx, 20_000);
    }
    static void schedule(Context ctx, long delayMs) {
        JobScheduler js = ctx.getSystemService(JobScheduler.class);
        JobInfo job = new JobInfo.Builder(JOB_ID, new ComponentName(ctx, RearmJobService.class))
                .setMinimumLatency(delayMs)
                .setOverrideDeadline(delayMs + 60_000)
                .setBackoffCriteria(30_000, JobInfo.BACKOFF_POLICY_LINEAR)
                .build();
        js.schedule(job);
        Rearm.log(ctx, "boot: re-arm scheduled in " + (delayMs / 1000) + "s");
    }
}
