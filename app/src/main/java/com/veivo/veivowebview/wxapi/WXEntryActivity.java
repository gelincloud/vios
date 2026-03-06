package com.veivo.veivowebview.wxapi;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Intent;
import android.content.res.Configuration;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.webkit.ValueCallback;
import android.webkit.WebView;
import android.widget.EditText;
import android.widget.TextView;

import com.tencent.mm.opensdk.modelbase.BaseReq;
import com.tencent.mm.opensdk.modelbase.BaseResp;
import com.tencent.mm.opensdk.modelmsg.SendAuth;
import com.tencent.mm.opensdk.modelmsg.SendMessageToWX;
import com.tencent.mm.opensdk.openapi.IWXAPI;
import com.tencent.mm.opensdk.openapi.IWXAPIEventHandler;
//import com.tencent.mm.sdk.modelbase.BaseReq;
//import com.tencent.mm.sdk.modelbase.BaseResp;
//import com.tencent.mm.sdk.modelmsg.SendAuth;
//import com.tencent.mm.sdk.modelmsg.SendMessageToWX;
//import com.tencent.mm.sdk.openapi.IWXAPI;
//import com.tencent.mm.sdk.openapi.IWXAPIEventHandler;
//import com.tencent.mm.sdk.openapi.WXAPIFactory;
import com.tencent.mm.opensdk.openapi.WXAPIFactory;
import com.veivo.veivowebview.MainActivity;
import com.veivo.veivowebview.R;
import com.veivo.veivowebview.WebViewManager;

//import org.xwalk.core.XWalkView;

import java.util.Locale;

@SuppressLint("JavascriptInterface")
public class WXEntryActivity extends Activity implements IWXAPIEventHandler {
	private WebView webView;

	//jpush
	public static final String MESSAGE_RECEIVED_ACTION = "com.example.jpushdemo.MESSAGE_RECEIVED_ACTION";
	//private MessageReceiver mMessageReceiver;
	public static final String KEY_MESSAGE = "message";
	public static final String KEY_EXTRAS = "extras";
	public static boolean isForeground = false;
	public IWXAPI api;

	private EditText msgText;

	//public XWalkView mXwalkView;
	protected String regId;
    /**
     * Intent used to display a message in the screen.
     */
    final String DISPLAY_MESSAGE_ACTION =
            "com.veivo.veivowebview.DISPLAY_MESSAGE";
    TextView mDisplay;
    protected AsyncTask<Void, Void, Void> mRegisterTask;
    
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		Bundle extras = getIntent().getExtras();
		
		System.out.println("WXEntryActivity create.");
		
    	api = WXAPIFactory.createWXAPI(this, WebViewManager.APPID, false);
		api.registerApp(WebViewManager.APPID);    

		api.handleIntent(this.getIntent(), this);
		
		String _url=null;
		String afterLoad = null;
		if(extras!=null){
			_url = (String)extras.get("url");
			afterLoad = (String)extras.get("afterLoad");
			Log.i("afterLoad", afterLoad==null?"":afterLoad);
		}
		if(_url==null)
			_url="https://www.veivo.com";
//		XWalkPreferences.setValue(XWalkPreferences.ANIMATABLE_XWALK_VIEW, true);		
//		XWalkPreferences.setValue(XWalkPreferences.REMOTE_DEBUGGING, true);
	    setContentView(R.layout.activity_wxentry);
	    //mXwalkView = (XWalkView) findViewById(R.id.wxactivity_main);
	    
//		setContentView(R.layout.shared_activity_main);
//	    sharedXwalkView = (SharedXWalkView) findViewById(R.id.shared_activity_main);
	    
		Locale current = getResources().getConfiguration().locale;
		
		
		//WebViewManager.INSTANCE.initWXMainWebView(this,mXwalkView,current,_url,afterLoad); // simply call init and let the manager handle the re-binding of the WebView to the current activity layout

		//		WebViewManager.INSTANCE.initMainWebView(this,sharedXwalkView,current,_url,afterLoad); // simply call init and let the manager handle the re-binding of the WebView to the current activity layout
		//registerMessageReceiver();
	}	
	public static ValueCallback<Uri> mUploadMessage;    
	public final static int FILECHOOSER_RESULTCODE=1;    
	  
	 @Override    
	 protected void onActivityResult(int requestCode, int resultCode,    
	                                    Intent intent) {    
//	  if(requestCode==FILECHOOSER_RESULTCODE)    
//	  {    
//	   if (null == mUploadMessage) return;    
//	            Uri result = intent == null || resultCode != RESULT_OK ? null    
//	                    : intent.getData();    
//	            mUploadMessage.onReceiveValue(result);    
//	            mUploadMessage = null;    
//	  }  
		 if(requestCode==FILECHOOSER_RESULTCODE)  
		  {  
		   if (null == mUploadMessage) return;  
		            Uri result = intent == null || resultCode != RESULT_OK ? null  
		                    : intent.getData();  
		            mUploadMessage.onReceiveValue(result);  
		            mUploadMessage = null;  
		  }
	  if (webView != null) {
		  //webView.onActivityResult(requestCode, resultCode, intent);
      }
	  }    
	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.main, menu);
		return true;
	}

	
	//flipscreen not loading again  
	@Override  
	public void onConfigurationChanged(Configuration newConfig){          
	    super.onConfigurationChanged(newConfig);  
	    System.out.println("Configuration changed.");
	}  
	@Override
	protected void onDestroy() {
		System.out.println("WXEntryActivity Destroy");
		super.onDestroy();
//	    XWalkPreferences.setValue(XWalkPreferences.ANIMATABLE_XWALK_VIEW, false);
//		if (mXwalkView != null) {
//            mXwalkView.onDestroy();
//        }
		//notification.unregister();
		
//		//gcm
//		if (mRegisterTask != null) {
//            mRegisterTask.cancel(true);
//        }
//        unregisterReceiver(mHandleMessageReceiver);
//        GCMRegistrar.onDestroy(this);
//        //���ᢷ�����ע����registration id
//        WebViewManager.INSTANCE.logout();
//        if(regId!=null)
//        	NetUtils.getUrl("https://www.veivo.com/info?atx=removegcmuser&regid="+regId, "UTF-8");
		
       
	}
	@Override
	protected void onNewIntent(Intent intent) {
		Log.d("intent", "intent:"+this.getIntent().getAction());
		Bundle extras = intent.getExtras();
	    String action = intent.getAction();
	    String type = intent.getType();
		super.onNewIntent(intent);
		
//		if(Intent.ACTION_SEND.equals(action)&& type != null){
//		        if ("text/plain".equals(type)) {
//		        	 String sharedText = intent.getStringExtra(Intent.EXTRA_TEXT);
//		     	    String sharedTitle = intent.getStringExtra(Intent.EXTRA_TITLE);
//		     	    if(sharedTitle!=null)
//		     	    	sharedText=sharedText+sharedTitle;
//		     	    if (sharedText != null) {
//						String script = "javascript:Veivo.pushContent0(\""+sharedText+"\",function(){},function(){});";
//						mXwalkView.load(script, null);
//		     	    }
//		        }
//		}else{
//			WebViewManager.INSTANCE.getNotification().touchNotification();
//		}
		
		
			
			setIntent(intent);
	        api.handleIntent(intent, this);
		
	}
	@Override
	protected void onResume(){
		System.out.println("WXEntryActivity Resume.");
		isForeground = true;
		//JPushInterface.onResume(this);
		super.onResume();
		if (webView != null) {
			webView.resumeTimers();
			//webView.onShow();
        }
	}
	@Override
	protected void onPause(){
		System.out.println("WXEntryActivity Pause.");
		isForeground = false;
		//JPushInterface.onPause(this);
		super.onPause();
		if (webView != null) {
			webView.pauseTimers();
			//webView.onHide();
        }
	}
//	@Override
//    public void onBackPressed()
//    {
//		mXwalkView.load("javascript:Veivo.backPrePage();", null);
//    }
//    protected final BroadcastReceiver mHandleMessageReceiver =
//            new BroadcastReceiver() {
//        @Override
//        public void onReceive(Context context, Intent intent) {
//        	System.out.println("111");
//        }
//    };	
    //jpush
//	public void registerMessageReceiver() {
//		mMessageReceiver = new MessageReceiver();
//		IntentFilter filter = new IntentFilter();
//		filter.setPriority(IntentFilter.SYSTEM_HIGH_PRIORITY);
//		filter.addAction(MESSAGE_RECEIVED_ACTION);
//		registerReceiver(mMessageReceiver, filter);
//	}
//	public class MessageReceiver extends BroadcastReceiver {
//
//		@Override
//		public void onReceive(Context context, Intent intent) {
//			System.out.println("jpush received message.");
//			if (MESSAGE_RECEIVED_ACTION.equals(intent.getAction())) {
//              String messge = intent.getStringExtra(KEY_MESSAGE);
//              String extras = intent.getStringExtra(KEY_EXTRAS);
//              StringBuilder showMsg = new StringBuilder();
//              showMsg.append(KEY_MESSAGE + " : " + messge + "\n");
//              if (!com.veivo.veivowebview.Util.isEmpty(extras)) {
//            	  showMsg.append(KEY_EXTRAS + " : " + extras + "\n");
//              }
//              setCostomMsg(showMsg.toString());
//			}
//		}
//	}
//	private void setCostomMsg(String msg){
//		 if (null != msgText) {
//			 msgText.setText(msg);
//			 msgText.setVisibility(android.view.View.VISIBLE);
//        }
//	}
	@Override
	public void onReq(BaseReq arg0) {
		// TODO Auto-generated method stub
		System.out.println("onReq invoked.");
	}
	@Override
	public void onResp(BaseResp resp) {
        String code = null;
        System.out.println("********start**********");
        System.out.println(resp);
        
        if(resp==null){
        	Intent intent = new Intent(WXEntryActivity.this,MainActivity.class);  
    		
    		startActivity(intent);  
        	
        	return;
        }
        
		Intent intent = new Intent(WXEntryActivity.this,MainActivity.class);  
		if(resp instanceof SendMessageToWX.Resp){
			intent.putExtra("issharetowechat", "1");
		}
        
        try{
        
        switch (resp.errCode) {
        case BaseResp.ErrCode.ERR_OK://用户同意,只有这种情况的时候code是有效的
        	
        	if(resp instanceof SendMessageToWX.Resp){
        		System.out.println("%%%%%%%%%SendMessageToWX%%%%%%%%");
        		SendMessageToWX.Resp r = (SendMessageToWX.Resp) resp;
        		intent.putExtra("sharestatus", "success");
        	}
        	else{
        		code = ((SendAuth.Resp) resp).code;
        	}
            
            //Toast.makeText(this, "同意 code="+code, Toast.LENGTH_SHORT).show();
            
            
            
            //System.out.println(code);
//            final String uri = "https://api.weixin.qq.com/sns/oauth2/access_token?appid=wx969cbab03c4c292f&secret=56e19710200dfe6136b0b7ca0567d02f&code="+code+"&grant_type=authorization_code";
//            System.out.println(uri);
//            new Thread(new Runnable(){
//
//				@Override
//				public void run() {
//					// TODO Auto-generated method stub
//					 String v = Util.doGet(uri,"UTF-8");
//			            System.out.println(v);
//			            OauthBean ob = OauthUtil.parseResposne(v);
//			            
//				}
//            	
//            }).start();  
           
            break;
        case BaseResp.ErrCode.ERR_AUTH_DENIED://用户拒绝授权
        	//Toast.makeText(this, "拒绝", Toast.LENGTH_SHORT).show();
            break;
        case BaseResp.ErrCode.ERR_USER_CANCEL://用户取消
        	//Toast.makeText(this, "取消", Toast.LENGTH_SHORT).show();
            break;

        default://发送返回
            break;
        }
        
        //Toast.makeText(this, "回调1", Toast.LENGTH_SHORT).show();
        
        //finish();
        
        }catch(Exception e){
        	e.printStackTrace();
        }
        System.out.println("********mid1**********");

		if(code!=null)
			intent.putExtra("code", code);
        System.out.println("********mid2**********");

		startActivity(intent);  
        System.out.println("********end**********");

//      
        //this.finish();
        //finish();
//		 Bundle bundle = new Bundle();  
//	        switch (resp.errCode) {  
//	        case BaseResp.ErrCode.ERR_OK:  
////	      可用以下两种方法获得code  
////	      resp.toBundle(bundle);  
////	      Resp sp = new Resp(bundle);  
////	      String code = sp.code;<span style="white-space:pre">  
////	      或者  
//	        String code = ((SendAuth.Resp) resp).code;  
//	            //上面的code就是接入指南里要拿到的code  
//	              
//	            break;  
//	  
//	        default:  
//	            break;  
//	        }  
//	        Toast.makeText(this, "MainActivity onResp ", Toast.LENGTH_SHORT).show();
//	      System.out.println("onResp invoked.");
	}
}