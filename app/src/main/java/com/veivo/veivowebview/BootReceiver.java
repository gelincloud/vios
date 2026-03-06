package com.veivo.veivowebview;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.PowerManager;

import com.google.android.gcm.GCMBaseIntentService;

public class BootReceiver extends BroadcastReceiver {
	private static final Object LOCK = GCMBaseIntentService.class;
	private static PowerManager.WakeLock sWakeLock;
	// wakelock
    private static final String WAKELOCK_KEY = "GCM_LIB";
	@Override
	public void onReceive(Context context, Intent intent) {
//		Intent s=new Intent(context,GCMIntentService.class);   
//		System.out.println("starting GCMIntentService...");
//		context.startService(s);
		
//        synchronized (LOCK) {
//            if (sWakeLock == null) {
//                // This is called from BroadcastReceiver, there is no init.
//                PowerManager pm = (PowerManager)
//                        context.getSystemService(Context.POWER_SERVICE);
//                sWakeLock = pm.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK,
//                        WAKELOCK_KEY);
//            }
//        }
//        sWakeLock.acquire();
        intent.setClassName(context, context.getPackageName()+".GCMIntentService");
        //context.startService(intent);
		context.startForegroundService(new Intent(context, BootReceiver.class));
	}

}
