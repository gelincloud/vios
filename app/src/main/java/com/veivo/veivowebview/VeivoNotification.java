package com.veivo.veivowebview;

import android.app.Activity;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.res.Resources;
import android.graphics.Color;
import android.os.PowerManager;
import android.os.PowerManager.WakeLock;
import android.os.Vibrator;
import android.text.Spannable;
import android.text.style.URLSpan;
import android.util.Log;
import android.webkit.WebView;

import java.util.HashSet;
import java.util.Set;

public class VeivoNotification {
	private NotificationManager nm ;
	private Notification nf ;
//	private BroadcastReceiver receiver;
	private Context context;
	private final static String KEY_MESSAGE="write_message";
	private static final String KEY_CONTACT="look_contact";
	private static final String KEY_TWEET="look_tweet";
	private final static String KEY_TO_MESSAGE="to_message";
	private final static String KEY_TO_MAIN="to_main";
	private final static String KEY_TO_LIST="to_list";
	//private int msgCount;
	private static Set<String> mids = new HashSet<String>();
	private static VeivoNotification notification;
	public WebView web;
	private Vibrator vibrator;
	
	public synchronized static VeivoNotification getInstance(Context context,WebView web){
		if(notification==null){
			notification = new VeivoNotification(context,web);
		}
		if(web!=null)
			notification.web=web;
		return notification;
	}
	public VeivoNotification(Context context,final WebView web){
		this.web=web;
		this.context=context;
		nm=(NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
		IntentFilter filter = new IntentFilter(); 
		filter.addAction(KEY_CONTACT);
		filter.addAction(KEY_MESSAGE);
		filter.addAction(KEY_TWEET);
//		receiver = new BroadcastReceiver() {
//		    public void onReceive(Context context, Intent intent) {
//		    	
//		    }
//		};
//		context.registerReceiver(receiver, filter);
	}
	public void onNewIntent(Intent intent){
		Log.d("notificationExtend", intent.getAction()	);
        if (intent.getAction().equals(KEY_CONTACT)) {
        }else if(intent.getAction().equals(KEY_TO_MESSAGE)){
        	//String mid=intent.getStringExtra("mid");
        	String mid=null;
        	for(String mid1 : mids){
        		if(mid!=null&&mid!=mid1){//different mids
        			mid="";
        			break;
        		}
        		mid=mid1;
        	}
        	//msgCount=0;
        	Log.d("notificationExtend", "go to App.im.quickPosition1('"+mid+"')");
        	if(web!=null){
        		web.loadUrl("javascript:App.im.quickPosition1("+mid+")",null);
        	}else{
        		Intent in = new Intent(context,MainActivity.class);
//    	        in.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
//    	        if (android.os.Build.VERSION.SDK_INT >= 12) {
//    	            intent.setFlags(32);
//    	        }
    	        String afterLoad = "javascript:App.im.quickPosition1("+mid+")";
    	        in.putExtra("afterLoad", afterLoad);
    	        context.startActivity(in);
        	}
        	mids.clear();
        }else if(intent.getAction().equals(KEY_TWEET)){
        	
        }else if(intent.getAction().equals(KEY_TO_LIST)){
        	//msgCount=0;
        }
	}
	private String stripCid(String mid){
		String r = mid.substring(0,mid.lastIndexOf("-"));
		return r;
	}
	public void touchNotification(){
        	//String mid=intent.getStringExtra("mid");
        	String mid=null;
        	for(String mid1 : mids){
        		if(mid!=null&&(!stripCid(mid).equals(stripCid(mid1)))){//different conversations
        			mid="";
        			break;
        		}
        		mid=mid1;
        	}
        	//msgCount=0;
        	mids.clear();
        	Log.d("notificationExtend", "go to App.im.quickPosition1('"+mid+"')");
        	if(mid!=null&&!mid.trim().equals(""))
        		web.loadUrl("javascript:App.im.quickPosition1('"+mid+"')",null);
        	//web.loadUrl("javascript:ialert('"+mid+"');");
	}
//	public void showDefautNotification(){
//		nf = new Notification();
//		nf.icon = R.drawable.notification;
//		RemoteViews remoteView = new RemoteViews(context.getPackageName(),R.layout.notificationext);
//		remoteView.setOnClickPendingIntent(R.id.message, registerReceiver(KEY_MESSAGE));
//		remoteView.setOnClickPendingIntent(R.id.contact, registerReceiver(KEY_CONTACT));
//		remoteView.setOnClickPendingIntent(R.id.tweet, registerReceiver(KEY_TWEET));
//		nf.contentView=remoteView;
//		nf.flags = Notification.FLAG_ONGOING_EVENT;
//		nf.flags |= Notification.FLAG_NO_CLEAR;
//		nm.notify(0,nf);
//	}
	public void notifyNewMessage(String mid,String gp,String sender,String text,int type){
		if(mids.contains(mid))
			return;
		//msgCount++;
		mids.add(mid);
    	turnScreenOn();
    	
		
		if(type==2||MainActivity.isForeground){
			if(!Util.isHome((Activity)this.context)){
				long [] pattern = { 100, 250, 250, 250 };   // ֹͣ ���� ֹͣ ����   
				SystemHelper.vibrate((Activity)this.context,pattern, false);
				
//				Notification notification = new Notification(R.drawable.notification,notiText,System.currentTimeMillis());
//				if(notification.DEFAULT_SOUND>0){
//					MediaPlayer mp = new MediaPlayer();
//					try {
//					mp.setDataSource(context, RingtoneManager
//					.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION));
//					mp.prepare();
//					mp.start();
//					} catch (Exception e) {
//					e.printStackTrace();
//					}
//				}
				return;
			}
		}
		
		//Log.v("notificationExtend", "msgcount"+msgCount);
		Resources resource=context.getResources();
		Intent in;
		String notiTitle = "";
		String notiText="";
		in = new Intent(context,MainActivity.class);
		if(mids.size()==1){
			in.setAction(KEY_TO_MESSAGE);
			Log.d("conversationMid", mid);
			
				//in=new Intent(context,VeivoMessageActivity.class);
				if(gp!=null){
					notiTitle = gp;
					notiText = sender+": "+'\n'+text;
				}else{
					notiTitle = sender;
					notiText =text;
				}
				//in.putExtra("peer", notiTitle);
				notiText = notiText.replace("<br>", "\n");
				if(notiText.contains("https:")){
					notiText = notiText.substring(0, notiText.indexOf("https:"));
				}
			Log.d("MID",mid);
			in.putExtra("mid", mid);
		}else{
			in.setAction(KEY_TO_LIST);
			notiTitle= resource.getString(R.string.veivomessage);
			notiText = resource.getString(R.string.you_have_message)+mids.size()+resource.getString(R.string._message);
		}
		CharSequence stext = notiText; 
		if(stext instanceof Spannable){  
			String msg = "";
			int end = stext.length(); 
			Spannable sp = (Spannable)stext;
			URLSpan[] urls=sp.getSpans(0, end, URLSpan.class);   		           
			for(URLSpan url : urls){   
					msg+= replaceMessageUrl(url.getURL(),notiText,null);
					
			}   
			if(!msg.equals("")){
				notiText = msg;
			}
		}
		//����ϵͳ��ʽ��Ϣ

		/*
		NotificationManager nm = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
		Notification notification = new Notification(R.drawable.notification,notiText,System.currentTimeMillis());
		PendingIntent contentIntent = PendingIntent.getActivity(context, 0, in, PendingIntent.FLAG_UPDATE_CURRENT);
		//TODO disable for api26
		//notification.setLatestEventInfo(context, notiTitle,notiText, contentIntent);
		setSystemSoundAndLed(notification);
		notification.flags |= Notification.FLAG_ONGOING_EVENT|Notification.FLAG_AUTO_CANCEL;
		
		nm.notify(0, notification);
		*/

		final NotificationManager mNotificationManager = (NotificationManager)context.getSystemService(Context.NOTIFICATION_SERVICE);
		String id = "channel_1";
		String description = "123";
		int importance = NotificationManager.IMPORTANCE_HIGH;
		NotificationChannel mChannel = new NotificationChannel(id, "123", importance);
		mChannel.setDescription(description);
		mChannel.enableLights(true);
		mChannel.setLightColor(Color.GREEN);
		//mChannel.enableVibration(true);
		//mChannel.setVibrationPattern(new long[]{ 100, 250, 250, 250 });
		mNotificationManager.createNotificationChannel(mChannel);

		PendingIntent contentIntent = PendingIntent.getActivity(context, 0, in, PendingIntent.FLAG_UPDATE_CURRENT);

		final Notification notification = new Notification.Builder(context, id)
				.setContentTitle(notiTitle)
				.setSmallIcon(R.drawable.notification)
				//.setLargeIcon(R.drawable.notification)
				.setContentText(notiText)
				.setAutoCancel(true)
				.setContentIntent(contentIntent)
				.build();



//		RemoteViews remoteViews = new RemoteViews(context.getPackageName(), R.layout.notification_layout);
//		notification.flags=Notification.FLAG_ONGOING_EVENT;
//		notification.flags |= Notification.FLAG_NO_CLEAR;
//
//		Intent intentOne = new Intent(context, MainActivity.class);
//		PendingIntent pendingIntentOne = PendingIntent.getActivity(context, 0, intentOne, PendingIntent.FLAG_UPDATE_CURRENT);
//
//		Intent intent = new Intent("notification_clicked");
//		PendingIntent pendingIntent = PendingIntent.getBroadcast(context, PENDINGINTENT_REQUEST_CODE, intent,PendingIntent.FLAG_UPDATE_CURRENT);
//
////		remoteViews.setTextViewText(R.id.nl_tv_filename,filePath);
////		remoteViews.setTextViewText(R.id.nl_tv_type,recordType);
//		remoteViews.setOnClickPendingIntent(R.id.nl_rl_parent, pendingIntent);



		mNotificationManager.notify(1, notification);
	}
	private void turnScreenOn() {
		//should wake up the phone
    	PowerManager pm = (PowerManager)context.getSystemService(Context.POWER_SERVICE); 
    	WakeLock wl = pm.newWakeLock(PowerManager.FULL_WAKE_LOCK | PowerManager.ACQUIRE_CAUSES_WAKEUP, this.getClass().getCanonicalName()); 
    	//WakeLock wl = pm.newWakeLock(android.view.WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON, this.getClass().getCanonicalName());

    	wl.acquire();
    	
		final WakeLock finalWl=wl;
        
        new Thread(new Runnable(){
        	public void run(){
        		try {
     				Thread.sleep(1000*10);
     			} catch (InterruptedException e) {
     				e.printStackTrace();
     			}
            	 if(finalWl.isHeld()){
                 	finalWl.release();
             		System.out.println("release gcm wake lock");
             	}
        	}
        }).start();
	}
//	public void unregister(){
//		context.unregisterReceiver(receiver);
//	}
	public static void setSystemSoundAndLed(Notification n){
  			n.defaults |= Notification.DEFAULT_SOUND; 
	        n.defaults |= Notification.DEFAULT_LIGHTS; 
	        n.ledARGB = Color.BLUE; 
	        n.ledOnMS = 1000; 
	        n.ledOffMS = 0; 
	        n.flags |= Notification.FLAG_SHOW_LIGHTS;
	        n.vibrate =   new long[] { 100, 250, 250, 250 };
	}
	public static String replaceMessageUrl(String url,String content,String isMymessage){
		if(url.matches("(http://www.veivo.com/){1}[\\w]{32}")){ //rss
			content = content.replace(url, "�鿴");
		}else if(url.indexOf("veivo.com/agreejoin")>=0){
			if(isMymessage != null){
				content = content.replace(url, "ͬ��");
			}else{
				return null;
			}
		}else if(url.indexOf("veivo.com/sharecontact")>=0){
			if(isMymessage != null){
				content = content.replace(url, "���");
			}else{
				return null;
			}
		}else if(url.indexOf("veivo.com/info?atx=getappdetail")>=0){
			content = content.replace(url, "����");
		}else{
			content = null;
		}
		return content;
	}
	
	public PendingIntent registerReceiver(String key){
		Intent nextIntent = new Intent(key);
		return registerReceiver(nextIntent);
	}
	public PendingIntent registerReceiver(Intent nextIntent){
		PendingIntent  messageIntent = PendingIntent.getBroadcast(context, 0, nextIntent, PendingIntent.FLAG_UPDATE_CURRENT);
        return messageIntent;
	}
}