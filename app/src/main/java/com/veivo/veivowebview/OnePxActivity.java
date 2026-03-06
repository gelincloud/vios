package com.veivo.veivowebview;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.util.Log;
import android.view.Gravity;
import android.view.Window;
import android.view.WindowManager;

public class OnePxActivity extends Activity {
    private static final String TAG="PlayerMusicService";
    protected BroadcastReceiver receiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            // 收到广播
            Log.d(TAG, "onReceive: 收到广播，关闭Activity");
            OnePxActivity.this.finish();
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.d(TAG, "onCreate: 开启一像素页面");
        Window window = getWindow();
        // 设置窗口位置在左上角
        window.setGravity(Gravity.LEFT | Gravity.TOP);
        WindowManager.LayoutParams params = window.getAttributes();
        params.x = 0;
        params.y = 0;
        params.width = 1;
        params.height = 1;
        window.setAttributes(params);

        // 动态注册广播，这个广播是在屏幕亮的时候，发送广播，来关闭当前的Activity
        registerReceiver(receiver, new IntentFilter("FinishActivity"));

    }

    @Override
    protected void onDestroy() {
        unregisterReceiver(receiver);
        Log.e(TAG,  "onDestory");
        super.onDestroy();
    }
}
