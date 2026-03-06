package com.veivo.veivowebview.wxapi;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
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

//import com.tencent.mm.sdk.constants.ConstantsAPI;
//import com.tencent.mm.sdk.modelbase.BaseReq;
//import com.tencent.mm.sdk.modelbase.BaseResp;
//import com.tencent.mm.sdk.openapi.IWXAPI;
//import com.tencent.mm.sdk.openapi.IWXAPIEventHandler;
//import com.tencent.mm.sdk.openapi.WXAPIFactory;
import com.tencent.mm.opensdk.constants.ConstantsAPI;
import com.tencent.mm.opensdk.modelbase.BaseReq;
import com.tencent.mm.opensdk.modelbase.BaseResp;
import com.tencent.mm.opensdk.openapi.IWXAPI;
import com.tencent.mm.opensdk.openapi.IWXAPIEventHandler;
import com.tencent.mm.opensdk.openapi.WXAPIFactory;
import com.veivo.veivowebview.MainActivity;
import com.veivo.veivowebview.R;
import com.veivo.veivowebview.WebViewManager;

//import org.xwalk.core.XWalkView;

import java.util.Locale;

import cn.jpush.android.api.JPushInterface;

@SuppressLint("JavascriptInterface")
public class WXPayEntryActivity extends Activity implements IWXAPIEventHandler {
	//private WebView webView;

	//jpush
	public static final String MESSAGE_RECEIVED_ACTION = "com.example.jpushdemo.MESSAGE_RECEIVED_ACTION";
	private MessageReceiver mMessageReceiver;
	public static final String KEY_MESSAGE = "message";
	public static final String KEY_EXTRAS = "extras";
	public static boolean isForeground = false;
	public IWXAPI api;

	private EditText msgText;

	//public XWalkView mXwalkView;
	public WebView webView;
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
		
		System.out.println("MainActivity create.");
		
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
		registerMessageReceiver();
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
		 // webView.onActivityResult(requestCode, resultCode, intent);
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
		System.out.println("MainActivity Destroy");
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
		
		if(Intent.ACTION_SEND.equals(action)&& type != null){
		        if ("text/plain".equals(type)) {
		        	 String sharedText = intent.getStringExtra(Intent.EXTRA_TEXT);
		     	    String sharedTitle = intent.getStringExtra(Intent.EXTRA_TITLE);
		     	    if(sharedTitle!=null)
		     	    	sharedText=sharedText+sharedTitle;
		     	    if (sharedText != null) {
						String script = "javascript:Veivo.pushContent0(\""+sharedText+"\",function(){},function(){});";
						webView.loadUrl(script, null);
		     	    }
		        }
		}else{
			WebViewManager.INSTANCE.getNotification().touchNotification();
		}
		
		
			
			setIntent(intent);
	        api.handleIntent(intent, this);
		
	}
	@Override
	protected void onResume(){
		System.out.println("MainActivity Resume.");
		isForeground = true;
		JPushInterface.onResume(this);
		super.onResume();
		if (webView != null) {
			webView.resumeTimers();
			//webView.onShow();
        }
	}
	@Override
	protected void onPause(){
		System.out.println("MainActivity Pause.");
		isForeground = false;
		JPushInterface.onPause(this);
		super.onPause();
		if (webView != null) {
			webView.pauseTimers();
			//webView.onHide();
        }
	}
	@Override
    public void onBackPressed()
    {
		webView.loadUrl("javascript:Veivo.backPrePage();", null);
    }
    protected final BroadcastReceiver mHandleMessageReceiver =
            new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
        	System.out.println("111");
        }
    };	
    //jpush
	public void registerMessageReceiver() {
		mMessageReceiver = new MessageReceiver();
		IntentFilter filter = new IntentFilter();
		filter.setPriority(IntentFilter.SYSTEM_HIGH_PRIORITY);
		filter.addAction(MESSAGE_RECEIVED_ACTION);
		registerReceiver(mMessageReceiver, filter);
	}
	public class MessageReceiver extends BroadcastReceiver {

		@Override
		public void onReceive(Context context, Intent intent) {
			System.out.println("jpush received message.");
			if (MESSAGE_RECEIVED_ACTION.equals(intent.getAction())) {
              String messge = intent.getStringExtra(KEY_MESSAGE);
              String extras = intent.getStringExtra(KEY_EXTRAS);
              StringBuilder showMsg = new StringBuilder();
              showMsg.append(KEY_MESSAGE + " : " + messge + "\n");
              if (!com.veivo.veivowebview.Util.isEmpty(extras)) {
            	  showMsg.append(KEY_EXTRAS + " : " + extras + "\n");
              }
              setCostomMsg(showMsg.toString());
			}
		}
	}
	private void setCostomMsg(String msg){
		 if (null != msgText) {
			 msgText.setText(msg);
			 msgText.setVisibility(android.view.View.VISIBLE);
        }
	}
	@Override
	public void onReq(BaseReq arg0) {
		// TODO Auto-generated method stub
		System.out.println("onReq invoked.");
	}
	@Override
	public void onResp(BaseResp resp) {
		
		if (resp.getType() == ConstantsAPI.COMMAND_PAY_BY_WX) {
			
            Intent intent = new Intent(WXPayEntryActivity.this,MainActivity.class);  

            int code = resp.errCode;
            String msg = "";
            switch (code) {
            case 0:
                msg = "支付成功！";
    			intent.putExtra("status", "success");
    			startActivity(intent);  
                break;
           case -1:
                msg = "支付失败！";
    			intent.putExtra("status", "fail");
    			startActivity(intent);  
                break;
            case -2:
                msg = "您取消了支付！";
    			intent.putExtra("status", "fail");
    			startActivity(intent);  
               break;
 
            default:
                msg = "支付失败！";
    			intent.putExtra("status", "fail");
    			startActivity(intent);  
                break;
           }
//            AlertDialog.Builder builder = new AlertDialog.Builder(this);
//			builder.setTitle(R.string.app_tip);
//			builder.setMessage(getString(R.string.pay_result_callback_msg, String.valueOf(resp.errCode)));
//			builder.show();
        }
		
		//Toast.makeText(this, "111111", Toast.LENGTH_SHORT).show();
//		if (resp.getType() == ConstantsAPI.COMMAND_PAY_BY_WX) {
//			//Toast.makeText(this, "222222", Toast.LENGTH_SHORT).show();
//			AlertDialog.Builder builder = new AlertDialog.Builder(this);
//			builder.setTitle(R.string.app_tip);
//			builder.setMessage(getString(R.string.pay_result_callback_msg, String.valueOf(resp.errCode)));
//			builder.show();
//			Intent intent = new Intent(WXPayEntryActivity.this,MainActivity.class);  
//			intent.putExtra("status", "success");
//			startActivity(intent);  
//		}else{
//			//Toast.makeText(this, "333333", Toast.LENGTH_SHORT).show();
//			Intent intent = new Intent(WXPayEntryActivity.this,MainActivity.class);  
//			intent.putExtra("status", "fail");
//			startActivity(intent);  
//		}
        
        //Toast.makeText(this, "回调1", Toast.LENGTH_SHORT).show();
        
        //finish();
        
		
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