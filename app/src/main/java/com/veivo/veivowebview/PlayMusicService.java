package com.veivo.veivowebview;

import android.app.Service;
import android.content.Intent;
import android.content.IntentFilter;
import android.media.MediaPlayer;
import android.os.Build;
import android.os.IBinder;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;

public class PlayMusicService extends Service {

    private final static String TAG = "PlayMusicService";
    private MediaPlayer mMediaPlayer;
    private ScreenStatusReceiver mScreenStatusReceiver;
    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public void onCreate() {
        super.onCreate();
        initReceiver();
        mMediaPlayer = MediaPlayer.create(getApplicationContext(), R.raw.no_notice);
        mMediaPlayer.setLooping(true);
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {

        new Thread(new Runnable() {
            @Override
            public void run() {
                //播放无声音乐
                startPlayMusic();
            }
        }).start();

        return START_STICKY;
    }

    private void initReceiver() {
        //注册息屏，开屏广播
        mScreenStatusReceiver = new ScreenStatusReceiver();
        IntentFilter screenStatus = new IntentFilter(Intent.ACTION_SCREEN_ON);
        screenStatus.addAction(Intent.ACTION_SCREEN_OFF);
        registerReceiver(mScreenStatusReceiver, screenStatus);
    }

    private void startPlayMusic() {
        if (mMediaPlayer != null) {
            mMediaPlayer.start();
        }
    }
    private void stopPlayMusic() {
        if (mMediaPlayer != null) {
            mMediaPlayer.stop();
        }
    }
    @RequiresApi(api = Build.VERSION_CODES.O)
    @Override
    public void onDestroy() {
        super.onDestroy();
        stopPlayMusic();
        if (mScreenStatusReceiver!=null){
            unregisterReceiver(mScreenStatusReceiver);
        }
        // 重启
        // 启动服务的地方
        Intent intent = new Intent(getApplicationContext(), PlayMusicService.class);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent);
        } else {
            startService(intent);
        }

    }
}
