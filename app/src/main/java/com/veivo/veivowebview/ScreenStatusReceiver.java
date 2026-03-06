package com.veivo.veivowebview;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

public class ScreenStatusReceiver extends BroadcastReceiver {
    private final static String TAG = "PlayerMusicService";
    @Override
    public void onReceive(Context context, Intent intent) {
        String action = intent.getAction();
        if(action.equals(Intent.ACTION_SCREEN_OFF)){
            // 当屏幕关闭时，启动一个像素的Activity
            Intent activity = new Intent(context,OnePxActivity.class);
            activity.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            context.startActivity(activity);
        } else if (action.equals(Intent.ACTION_SCREEN_ON)){
            // 用户解锁，关闭Activity
            // 这里发个广播是什么鬼，其实看下面OnePxAcitivity里面的代码就知道了，发这个广播就是为了finish掉OnePxActivity
            Intent broadcast = new Intent("FinishActivity");
            // broadcast.setFlags(32);Intent.FLAG_INCLUDE_STOPPED_PACKAGES
            context.sendBroadcast(broadcast);//发送对应的广播
        }
    }
}
