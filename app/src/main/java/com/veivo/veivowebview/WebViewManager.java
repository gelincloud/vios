package com.veivo.veivowebview;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.media.MediaRecorder;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.provider.MediaStore;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import android.text.TextUtils;
import android.util.Log;
import android.view.ViewGroup;
import android.webkit.JavascriptInterface;
import android.webkit.ValueCallback;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Toast;

import com.alipay.sdk.app.PayTask;
import com.facebook.AccessToken;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.GraphRequest;
import com.facebook.GraphResponse;
import com.facebook.login.LoginManager;
import com.facebook.login.LoginResult;
import com.facebook.login.widget.LoginButton;
//import com.firebase.ui.auth.AuthUI;
import com.google.android.gms.auth.api.signin.GoogleSignIn;
import com.google.android.gms.auth.api.signin.GoogleSignInAccount;
import com.google.android.gms.auth.api.signin.GoogleSignInClient;
import com.google.android.gms.auth.api.signin.GoogleSignInOptions;
//import com.sina.weibo.sdk.api.ImageObject;
//import com.sina.weibo.sdk.api.TextObject;
//import com.sina.weibo.sdk.api.WebpageObject;
//import com.sina.weibo.sdk.api.WeiboMessage;
//import com.sina.weibo.sdk.api.WeiboMultiMessage;
//import com.sina.weibo.sdk.api.share.SendMessageToWeiboRequest;
//import com.sina.weibo.sdk.api.share.SendMultiMessageToWeiboRequest;
//import com.sina.weibo.sdk.auth.Oauth2AccessToken;
//import com.sina.weibo.sdk.auth.WbAuthListener;
//import com.sina.weibo.sdk.auth.WeiboAuthListener;
//import com.sina.weibo.sdk.auth.sso.SsoHandler;
//import com.sina.weibo.sdk.common.UiError;
//import com.sina.weibo.sdk.exception.WeiboException;
//import com.sina.weibo.sdk.utils.Utility;
//import com.tencent.mm.opensdk.modelpay.PayReq;
//import com.tencent.mm.sdk.modelmsg.SendAuth;
//import com.tencent.mm.sdk.modelmsg.SendMessageToWX;
//import com.tencent.mm.sdk.modelmsg.WXMediaMessage;
//import com.tencent.mm.sdk.modelmsg.WXWebpageObject;
//import com.tencent.mm.sdk.modelpay.PayReq;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.auth.AuthCredential;
import com.google.firebase.auth.AuthResult;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.auth.GoogleAuthCredential;
import com.google.firebase.auth.GoogleAuthProvider;
import com.google.firebase.auth.OAuthProvider;
import com.google.firebase.auth.TwitterAuthProvider;
import com.sina.weibo.sdk.api.TextObject;
import com.sina.weibo.sdk.api.WebpageObject;
import com.sina.weibo.sdk.api.WeiboMultiMessage;
import com.sina.weibo.sdk.auth.AuthInfo;
import com.sina.weibo.sdk.auth.Oauth2AccessToken;
import com.sina.weibo.sdk.auth.WbAuthListener;
import com.sina.weibo.sdk.common.UiError;
import com.sina.weibo.sdk.openapi.IWBAPI;
import com.sina.weibo.sdk.share.WbShareCallback;
import com.tencent.mm.opensdk.modelmsg.SendAuth;
import com.tencent.mm.opensdk.modelmsg.SendMessageToWX;
import com.tencent.mm.opensdk.modelmsg.WXMediaMessage;
import com.tencent.mm.opensdk.modelmsg.WXWebpageObject;
import com.tencent.mm.opensdk.modelpay.PayReq;
//import com.tencent.mm.sdk.openapi.WXAPIFactory;

import com.veivo.veivowebview.alipay.PayResult;
import com.veivo.veivowebview.wxapi.WXEntryActivity;

import org.json.JSONObject;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URL;
import java.util.Arrays;
import java.util.List;
import java.util.Locale;
import java.util.UUID;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import cn.jpush.android.api.JPushInterface;

public enum WebViewManager {
    INSTANCE;
    private WebView webView;
	private LoginButton bt_facebook;

	private VeivoNotification notification;
	private MainActivity contextActivity;
	private WXEntryActivity wxcontextActivity;

	private MediaRecorder recorder;


	public static String APPID="wx7a4c4ac378586fe9";
	
	private static final int SDK_PAY_FLAG = 1;
	private static final int CHANGE_STATUS_BAR = 999;

	private Handler mHandler = new Handler() {
		@SuppressWarnings("unused")
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case SDK_PAY_FLAG: {
				PayResult payResult = new PayResult((String) msg.obj);
				/**
				 * 同步返回的结果必须放置到服务端进行验证（验证的规则请看https://doc.open.alipay.com/doc2/
				 * detail.htm?spm=0.0.0.0.xdvAU6&treeId=59&articleId=103665&
				 * docType=1) 建议商户依赖异步通知
				 */
				String resultInfo = payResult.getResult();// 同步返回需要验证的信息

				String resultStatus = payResult.getResultStatus();
				// 判断resultStatus 为“9000”则代表支付成功，具体状态码代表含义可参考接口文档
				if (TextUtils.equals(resultStatus, "9000")) {
					//Toast.makeText(contextActivity, "支付成功", Toast.LENGTH_SHORT).show();
					if(contextActivity.webview!=null){
						String s="javascript:window.paymenttodesktop();";
						//String s="javascript:alert(window.paymenttodesktop);";
						contextActivity.webview.loadUrl(s, null);
					}
				} else {
					// 判断resultStatus 为非"9000"则代表可能支付失败
					// "8000"代表支付结果因为支付渠道原因或者系统原因还在等待支付结果确认，最终交易是否成功以服务端异步通知为准（小概率状态）
					if (TextUtils.equals(resultStatus, "8000")) {
						//Toast.makeText(contextActivity, "支付结果确认中", Toast.LENGTH_SHORT).show();
						if(contextActivity.webview!=null){
							String s="javascript:alert('支付结果确认中');";
							contextActivity.webview.loadUrl(s, null);
						}

					} else {
						// 其他值就可以判断为支付失败，包括用户主动取消支付，或者系统返回的错误
						//Toast.makeText(contextActivity, "支付失败", Toast.LENGTH_SHORT).show();
						
						if(contextActivity.webview!=null){
							String s="javascript:alert('支付失败!');";
							contextActivity.webview.loadUrl(s, null);
						}

					}
				}
				break;
			}
			case CHANGE_STATUS_BAR:{
				String color = (String)msg.obj;
				int colorResInt = Color.parseColor(color);
				 StatusBarUtils.setWindowStatusBarColor(contextActivity, colorResInt);
				break;
			}
			default:
				break;
			}
		};
	};
	
    private WebViewManager() {
    }

    @JavascriptInterface
    public void initMainWebView(final MainActivity context,WebView v,final Locale locale,final String _url,final String afterLoad) {
 
    	
    	contextActivity = context;
    	if(this.webView == null) // when init is called for the first time we setup our webview once-off (which remains for the lifetime of the application)
    	{
    		 //��ȡwebview
            webView = v;
    		notification=VeivoNotification.getInstance(context, this.webView);
            //XWalkSettings setting =webView.getSettings();
            //����ʹ�û��棺   
            //webView.getSettings().setCacheMode(WebSettings.LOAD_CACHE_ELSE_NETWORK);    
            //��ʹ�û��棺   
            //webView.getSettings().setUserAgentString(webView.getSettings().getUserAgentString()+"(android app) "+"veivo "+locale.getLanguage());
            //����webview֧��javascript
    		//webView.getSettings().setJavaScriptEnabled(true);
    		
    		String ua = getWebViewUserAgent(webView)+"(android app) api26 "+MainActivity.veivoClientUA+" "+locale.getLanguage();
    		setWebViewUserAgent(webView,ua);


			webView.getSettings().setJavaScriptEnabled(true);
			webView.getSettings().setJavaScriptCanOpenWindowsAutomatically(true);
			webView.getSettings().setSupportMultipleWindows(true);
			webView.setWebViewClient(new WebViewClient());
			//webView.setWebChromeClient(new WebChromeClient());




			webView.setWebChromeClient(new WebChromeClient() {

				// For Android >= 5.0
				@Override
				public boolean onShowFileChooser(WebView webView, ValueCallback<Uri[]> filePathCallback, WebChromeClient.FileChooserParams fileChooserParams) {
					MainActivity.uploadMessageAboveL = filePathCallback;


					String[] acc = fileChooserParams.getAcceptTypes();
					if(acc!=null&&acc.length==1&&acc[0].indexOf("audio")>=0){
						openAudioChooserActivity();
						return true;
					}else if(acc!=null&&acc.length==1&&acc[0].indexOf("video")>=0){

						if (ContextCompat.checkSelfPermission(context, android.Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
							// 进入这儿表示没有权限
							if (ActivityCompat.shouldShowRequestPermissionRationale(contextActivity, android.Manifest.permission.CAMERA)) {
								// 提示已经禁止
								//ToastUtil.longToast(mContext, getString(R.string.you_have_cut_down_the_permission));
							} else {
								ActivityCompat.requestPermissions(contextActivity, new String[]{android.Manifest.permission.CAMERA}, 100);
							}
						} else {
							openVideoChooserActivity();
						}

						return true;
					}else if(acc!=null&&acc.length==1&&acc[0].indexOf("image")>=0){
						if (ContextCompat.checkSelfPermission(context, android.Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
							// 进入这儿表示没有权限
							if (ActivityCompat.shouldShowRequestPermissionRationale(contextActivity, android.Manifest.permission.CAMERA)) {
								// 提示已经禁止
								//ToastUtil.longToast(mContext, getString(R.string.you_have_cut_down_the_permission));
							} else {
								ActivityCompat.requestPermissions(contextActivity, new String[]{android.Manifest.permission.CAMERA}, 100);
							}
						} else {
							openCameraChooserActivity();
						}

						return true;
					}
					//System.out.println(acc);


					openImageChooserActivity();
					return true;
				}

				private void openImageChooserActivity() {
					Intent i = new Intent(Intent.ACTION_GET_CONTENT);
					i.addCategory(Intent.CATEGORY_OPENABLE);
					i.setType("image/*");
					context.startActivityForResult(Intent.createChooser(i, "Image Chooser"), 1);
				}
				private void openAudioChooserActivity() {
//					Intent i = new Intent(Intent.ACTION_GET_CONTENT);
//					i.addCategory(Intent.CATEGORY_OPENABLE);
//					i.setType("recorder");

					Intent i = new Intent(MediaStore.Audio.Media.RECORD_SOUND_ACTION);

//					context.startActivityForResult(Intent.createChooser(i, "Image Chooser"), 1);


					context.startActivityForResult(Intent.createChooser(i,"Recorder"),1);
				}

				private void openVideoChooserActivity() {
//					Intent i = new Intent(Intent.ACTION_GET_CONTENT);
//					i.addCategory(Intent.CATEGORY_OPENABLE);
//					i.setType("recorder");

					Intent i = new Intent(MediaStore.ACTION_VIDEO_CAPTURE);

					context.startActivityForResult(Intent.createChooser(i, "Video Recorder"), 1);


					//context.startActivityForResult(i,1);
				}

				private void openCameraChooserActivity() {
//					Intent i = new Intent(Intent.ACTION_GET_CONTENT);
//					i.addCategory(Intent.CATEGORY_OPENABLE);
//					i.setType("recorder");

					Intent i = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);

					context.startActivityForResult(Intent.createChooser(i, "Image Capture"), 1);


					//context.startActivityForResult(i,1);
				}

//				private boolean startRecord() {
//					recorder = new MediaRecorder();
//					try {
//						recorder.setAudioSource(MediaRecorder.AudioSource.MIC);
//					}catch (IllegalStateException e){
//						e.printStackTrace();
//					}
//
//					recorder.setOutputFormat(MediaRecorder.OutputFormat.AMR_NB);
//					recorder.setOutputFile("");
//					recorder.setAudioEncoder(MediaRecorder.AudioEncoder.AMR_NB);
//					try {
//						recorder.prepare();
//					}catch (IOException e){
//						e.printStackTrace();
//					}
//					recorder.start();
//					return true;
//				}
//
//				private void stopRecord() {
//					recorder.stop();
//					recorder.reset();
//					recorder.release();
//					recorder = null;
//				}


/*
				@Override
				public void onProgressChanged(WebView view, int newProgress) {
//					if (newProgress == 100) {
//						mBar.setVisibility(View.GONE);
//					} else {
//						mBar.setVisibility(View.VISIBLE);
//						mBar.setProgress(newProgress);
//					}
					super.onProgressChanged(view, newProgress);
				}

				//For Android API < 11 (3.0 OS)
				public void openFileChooser(ValueCallback<Uri> valueCallback) {
//					uploadMessage = valueCallback;
//					openImageChooserActivity();
					startCamera(valueCallback);
				}

				//For Android API >= 11 (3.0 OS)
				public void openFileChooser(ValueCallback<Uri> valueCallback, String acceptType, String capture) {
//					uploadMessage = valueCallback;
					openImageChooserActivity();
					startCamera(valueCallback);
				}

				//For Android API >= 21 (5.0 OS)
				@Override
				public boolean onShowFileChooser(WebView webView, ValueCallback<Uri[]> filePathCallback, WebChromeClient.FileChooserParams fileChooserParams) {
//					uploadMessageAboveL = filePathCallback;
//					openImageChooserActivity();
					return true;
				}
				private void startCamera(ValueCallback<Uri> uploadMsg){
					MainActivity.mUploadMessage = uploadMsg;
					Intent cameraIntent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
					context.startActivityForResult( cameraIntent, MainActivity.FILECHOOSER_RESULTCODE );

				}
				private void startVideo(ValueCallback<Uri> uploadMsg){
					MainActivity.mUploadMessage = uploadMsg;
					Intent cameraIntent = new Intent(MediaStore.ACTION_VIDEO_CAPTURE);
					context.startActivityForResult( cameraIntent, MainActivity.FILECHOOSER_RESULTCODE );

				}
				private void startChooser(ValueCallback<Uri> uploadMsg){
					MainActivity.mUploadMessage = uploadMsg;
					Intent i = new Intent(Intent.ACTION_GET_CONTENT);
					i.addCategory(Intent.CATEGORY_OPENABLE);
					i.setType("image/*");
					context.startActivityForResult( Intent.createChooser( i, "File Chooser" ), MainActivity.FILECHOOSER_RESULTCODE );

				}
				private void startRecord(ValueCallback<Uri> uploadMsg){
					MainActivity.mUploadMessage = uploadMsg;
					Intent cameraIntent = new Intent(MediaStore.Audio.Media.RECORD_SOUND_ACTION);
					context.startActivityForResult( cameraIntent, MainActivity.FILECHOOSER_RESULTCODE );
				}
				private void openImageChooserActivity() {
					Intent i = new Intent(Intent.ACTION_GET_CONTENT);
					i.addCategory(Intent.CATEGORY_OPENABLE);
					i.setType("image/*");
					startActivityForResult(Intent.createChooser(i, "Image Chooser"), FILE_CHOOSER_RESULT_CODE);
				}
*/
			});

    		//webView.setXWalkClient(new myWebClient(v));
    		//webView.setXWalkWebChromeClient(client);
//    		webView.setWebViewClient(new myWebClient(this));  

			/*上传文件
    		webView.setUIClient(new XWalkUIClient(v)
    		    {    
    		           //The undocumented magic method override    
    		           //Eclipse will swear at you if you try to put @Override here    
    		        // For Android 3.0+  
    		        public void openFileChooser(XWalkView view,ValueCallback<Uri> uploadMsg) {    
    		        	startCamera(uploadMsg);
    		           }  
    		  
    		        // For Android 3.0+  
    		           public void openFileChooser(XWalkView view, ValueCallback uploadMsg, String acceptType ) {  
    		        	   startCamera(uploadMsg);
    		           }  
    		  
    		        //For Android 4.1  
    		           public void openFileChooser(XWalkView view, ValueCallback<Uri> uploadMsg, String acceptType, String capture){  
    		        	  if("true".equals(capture)){
    		        		  if("audio/*".equals(acceptType)){
    		        			  startRecord(uploadMsg);
    		        		  }else if("video/*".equals(acceptType)){
    		        			  startVideo(uploadMsg);
    		        		  }else{
    		        			  startCamera(uploadMsg);
    		        		  }
    		        	  }else{
    		        		  startChooser(uploadMsg);
    		        	  }
    		  
    		           }  
    		           private void startCamera(ValueCallback<Uri> uploadMsg){
    		        	   MainActivity.mUploadMessage = uploadMsg;  
    		        	   Intent cameraIntent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
    		        	   context.startActivityForResult( cameraIntent, MainActivity.FILECHOOSER_RESULTCODE );

    		           }
    		           private void startVideo(ValueCallback<Uri> uploadMsg){
    		        	   MainActivity.mUploadMessage = uploadMsg;  
    		        	   Intent cameraIntent = new Intent(MediaStore.ACTION_VIDEO_CAPTURE);
    		        	   context.startActivityForResult( cameraIntent, MainActivity.FILECHOOSER_RESULTCODE );

    		           }
    		           private void startChooser(ValueCallback<Uri> uploadMsg){
    		        	   MainActivity.mUploadMessage = uploadMsg;  
    		               Intent i = new Intent(Intent.ACTION_GET_CONTENT);  
    		               i.addCategory(Intent.CATEGORY_OPENABLE);  
    		               i.setType("image/*");  
    		               context.startActivityForResult( Intent.createChooser( i, "File Chooser" ), MainActivity.FILECHOOSER_RESULTCODE );

    		           }
    		           private void startRecord(ValueCallback<Uri> uploadMsg){
    		        	   MainActivity.mUploadMessage = uploadMsg;  
    		        	   Intent cameraIntent = new Intent(Media.RECORD_SOUND_ACTION);
    		        	   context.startActivityForResult( cameraIntent, MainActivity.FILECHOOSER_RESULTCODE );
    		           }
    		  
    		    });
    		*/
    		    
    		webView.addJavascriptInterface(this, "notifyandroid");
    		webView.loadUrl(_url,null);
    		//webView.loadAppFromManifest("file:///android_asset/manifest.json", null);
    		
    		
    		Log.i("afterLoad", afterLoad==null?"":afterLoad);

    		//显示Loading progress
			/*
    		webView.setWebChromeClient(new WebChromeClient() {
   	    	 @Override
   			 public void onProgressChanged(WebView view, int progress)
   			 {  
   			  //Make the bar disappear after URL is loaded, and changes string to Loading...  
   			  context.setProgress(progress * 100); //Make the bar disappear after URL is loaded  
   			  System.out.println("progress:"+progress);
   			  // Return the app name after finish loading  
   			     if(progress == 100)  {
   			    	 if(afterLoad!=null)
   			    		 webView.loadUrl(afterLoad, null);
   			     }
   			   }  
//   	    	@Override
//   	    	public boolean shouldOverrideUrlLoading(XWalkView view, String url)
//   	    	{ 
////   	    		MyXWalkView xView = (MyXWalkView) view; 
////   	    		xView.loadUrl(url); 
//   	    		view.load(url,url); 
//   	    		return true; 
//   	    	}
   			 });
    		 */

    		//webView.loadAppFromManifest("file:///android_asset/manifest.json", null);
//    	    this.webView = new WebView(context);
//    	    this.webView.loadUrl("https://l.veivo.com");
    	}
    	else 
    	{
    	    //every other time we call init we simply check if the webview has a parent viewgroup/layout and remove it from that layout
    	    //detach the webview from its current parent, this sets up the WebView to be rebound to the new Activity (new orientation)
    	    ViewGroup parentViewGroup = (ViewGroup)webView.getParent();
    	    if(parentViewGroup != null)
    	    {
    	        parentViewGroup.removeView(webView);
    	    }
        	context.setContentView(webView); // re-associate the webview with the current activity layout (new orientation)

    	}
    }
    /*
   public void initWXMainWebView(final WXEntryActivity context,WebView v,final Locale locale,final String _url,final String afterLoad) {
 
    	
	   wxcontextActivity = context;
    	if(this.webView == null) // when init is called for the first time we setup our webview once-off (which remains for the lifetime of the application)
    	{
    		 //��ȡwebview
            webView = v;
    		notification=VeivoNotification.getInstance(context, this.webView);
            //XWalkSettings setting =webView.getSettings();
            //����ʹ�û��棺   
            //webView.getSettings().setCacheMode(WebSettings.LOAD_CACHE_ELSE_NETWORK);    
            //��ʹ�û��棺   
            //webView.getSettings().setUserAgentString(webView.getSettings().getUserAgentString()+"(android app) "+"veivo "+locale.getLanguage());
            //����webview֧��javascript
    		//webView.getSettings().setJavaScriptEnabled(true);
    		
    		String ua = getWebViewUserAgent(webView)+"(android app) "+"veivo2 "+locale.getLanguage();
    		setWebViewUserAgent(webView,ua);
    		
    		//webView.setXWalkClient(new myWebClient(v));
    		//webView.setXWalkWebChromeClient(client);
//    		webView.setWebViewClient(new myWebClient(this));  
    		
    		webView.setUIClient(new XWalkUIClient(v)    
    		    {    
    		           //The undocumented magic method override    
    		           //Eclipse will swear at you if you try to put @Override here    
    		        // For Android 3.0+  
    		        public void openFileChooser(XWalkView view,ValueCallback<Uri> uploadMsg) {    
    		        	startCamera(uploadMsg);
    		           }  
    		  
    		        // For Android 3.0+  
    		           public void openFileChooser(XWalkView view, ValueCallback uploadMsg, String acceptType ) {  
    		        	   startCamera(uploadMsg);
    		           }  
    		  
    		        //For Android 4.1  
    		           public void openFileChooser(XWalkView view, ValueCallback<Uri> uploadMsg, String acceptType, String capture){  
    		        	  if("true".equals(capture)){
    		        		  if("audio/*".equals(acceptType)){
    		        			  startRecord(uploadMsg);
    		        		  }else if("video/*".equals(acceptType)){
    		        			  startVideo(uploadMsg);
    		        		  }else{
    		        			  startCamera(uploadMsg);
    		        		  }
    		        	  }else{
    		        		  startChooser(uploadMsg);
    		        	  }
    		  
    		           }  
    		           private void startCamera(ValueCallback<Uri> uploadMsg){
    		        	   MainActivity.mUploadMessage = uploadMsg;  
    		        	   Intent cameraIntent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
    		        	   context.startActivityForResult( cameraIntent, MainActivity.FILECHOOSER_RESULTCODE );

    		           }
    		           private void startVideo(ValueCallback<Uri> uploadMsg){
    		        	   MainActivity.mUploadMessage = uploadMsg;  
    		        	   Intent cameraIntent = new Intent(MediaStore.ACTION_VIDEO_CAPTURE);
    		        	   context.startActivityForResult( cameraIntent, MainActivity.FILECHOOSER_RESULTCODE );

    		           }
    		           private void startChooser(ValueCallback<Uri> uploadMsg){
    		        	   MainActivity.mUploadMessage = uploadMsg;  
    		               Intent i = new Intent(Intent.ACTION_GET_CONTENT);  
    		               i.addCategory(Intent.CATEGORY_OPENABLE);  
    		               i.setType("image/*");  
    		               context.startActivityForResult( Intent.createChooser( i, "File Chooser" ), MainActivity.FILECHOOSER_RESULTCODE );

    		           }
    		           private void startRecord(ValueCallback<Uri> uploadMsg){
    		        	   MainActivity.mUploadMessage = uploadMsg;  
    		        	   Intent cameraIntent = new Intent(Media.RECORD_SOUND_ACTION);
    		        	   context.startActivityForResult( cameraIntent, MainActivity.FILECHOOSER_RESULTCODE );
    		           }
    		  
    		    });
    		    
    		webView.addJavascriptInterface(this, "notifyandroid");
    		webView.loadUrl(_url,null);
    		//crosswalk专有
    		//webView.loadAppFromManifest("file:///android_asset/manifest.json", null);
    		
    		
    		Log.i("afterLoad", afterLoad==null?"":afterLoad);
    		webView.setResourceClient(new XWalkResourceClient(webView) {
   	    	 @Override
   			 public void onProgressChanged(XWalkView view, int progress)     
   			 {  
   			  //Make the bar disappear after URL is loaded, and changes string to Loading...  
   			  context.setProgress(progress * 100); //Make the bar disappear after URL is loaded  
   			  System.out.println("progress:"+progress);
   			  // Return the app name after finish loading  
   			     if(progress == 100)  {
   			    	 if(afterLoad!=null)
   			    		 webView.loadUrl(afterLoad, null);
   			     }
   			   }  
//   	    	@Override
//   	    	public boolean shouldOverrideUrlLoading(XWalkView view, String url)
//   	    	{ 
////   	    		MyXWalkView xView = (MyXWalkView) view; 
////   	    		xView.loadUrl(url); 
//   	    		view.load(url,url); 
//   	    		return true; 
//   	    	}
   			 });
    		//webView.loadAppFromManifest("file:///android_asset/manifest.json", null);
//    	    this.webView = new WebView(context);
//    	    this.webView.loadUrl("https://l.veivo.com");
    	}
    	else 
    	{
    	    //every other time we call init we simply check if the webview has a parent viewgroup/layout and remove it from that layout
    	    //detach the webview from its current parent, this sets up the WebView to be rebound to the new Activity (new orientation)
    	    ViewGroup parentViewGroup = (ViewGroup)webView.getParent();
    	    if(parentViewGroup != null)
    	    {
    	        parentViewGroup.removeView(webView);
    	    }
        	context.setContentView(webView); // re-associate the webview with the current activity layout (new orientation)

    	}
    }
    */

	public void changeUrl(String _url){
		webView.loadUrl(_url,null);
	}

    @JavascriptInterface
    public void addShortcut(String appname,String iconUrl,String url) {
        //Adding shortcut for MainActivity 
        //on Home screen
//        Intent shortcutIntent = new Intent(contextActivity.getApplicationContext(),
//                UrlActivity.class);


//    	Intent intent = new Intent(contextActivity,NotitleUrlActivity.class);
//    	intent.putExtra("url", url);
//    	System.out.println(url);
//    	contextActivity.startActivity(intent);
//    	contextActivity.overridePendingTransition(R.anim.in_from_right, R.anim.out_to_left);
    	
        Intent intent = new Intent(contextActivity,NotitleUrlActivity.class);
    	intent.putExtra("url", url);
    		intent.setAction(Intent.ACTION_MAIN);
    		intent.setData(Uri.parse(url));
    	System.out.println(url);
    	
        Intent addIntent = new Intent();
        addIntent
                .putExtra(Intent.EXTRA_SHORTCUT_INTENT, intent);
        addIntent.putExtra(Intent.EXTRA_SHORTCUT_NAME, appname);
        addIntent.putExtra(Intent.EXTRA_SHORTCUT_ICON,
        		getLocalOrNetBitmap(iconUrl));

        addIntent
                .setAction("com.android.launcher.action.INSTALL_SHORTCUT");
        contextActivity.getApplicationContext().sendBroadcast(addIntent);
    }
    private Bitmap getLocalOrNetBitmap(String url)  
    {  
        Bitmap bitmap = null;  
        InputStream in = null;  
        BufferedOutputStream out = null;  
        try  
        {  
            in = new BufferedInputStream(new URL(url).openStream(),1024);  
            final ByteArrayOutputStream dataStream = new ByteArrayOutputStream();  
            out = new BufferedOutputStream(dataStream, 1024);  
            copy(in, out);  
            out.flush();  
            byte[] data = dataStream.toByteArray();  
            bitmap = BitmapFactory.decodeByteArray(data, 0, data.length);  
            data = null;  
            return bitmap;  
        }  
        catch (IOException e)  
        {  
            e.printStackTrace();  
            return null;  
        }  
    }  
    private void copy(InputStream in, OutputStream out)
            throws IOException {
        byte[] b = new byte[1024];
        int read;
        while ((read = in.read(b)) != -1) {
            out.write(b, 0, read);
        }
    }
    @JavascriptInterface
	public void notify(String mid,String gp,String sender,String text,int type) {
        notification.notifyNewMessage(mid, undefine(gp), sender, text,type);
    }
	public static boolean isGooglePlayInstalled(Context context) {
		PackageManager pm = context.getPackageManager();
		boolean app_installed = false;
		try
		{
			PackageInfo info = pm.getPackageInfo("com.android.vending", PackageManager.GET_ACTIVITIES);
			String label = (String) info.applicationInfo.loadLabel(pm);
			app_installed = (label != null && !label.equals("Market"));
		}
		catch (PackageManager.NameNotFoundException e)
		{
			app_installed = false;
		}
		return app_installed;
	}
	@JavascriptInterface
	public void logout(){
		SharedPreferences.Editor sharedata = contextActivity.getSharedPreferences("data", 0).edit();  
		sharedata.remove("appid");  
		sharedata.commit();

		String regId = contextActivity.getSharedPreferences("data", 0).getString("jpush_reg_id", "");
		
//		try{
//			GCMRegistrar.checkDevice(contextActivity);
//		}catch(Exception e){
//			e.printStackTrace();
//			this.webView.load("https://www.veivo.com/UserAdmin?atx=logoff", null);
//			return;
//		}
//		
//        GCMRegistrar.unregister(contextActivity);
        //���ᢷ�����ע��registration id
        removeRegistrationId(regId);
        //NetUtils.getUrl("https://www.veivo.com/info?atx=removegcmuser&regtoken="+regId, "UTF-8");
		//this.webView.loadUrl("https://www.veivo.com/UserAdmin?atx=logoff", null);

		if(isGooglePlayInstalled(contextActivity)) {
			try {
				GoogleSignInOptions gso = new GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
						.requestEmail()
						.build();
				GoogleSignInClient mGoogleSignInClient = GoogleSignIn.getClient(contextActivity, gso);
				mGoogleSignInClient.signOut().addOnCompleteListener(contextActivity,
						new OnCompleteListener<Void>() {
							@Override
							public void onComplete(@NonNull Task<Void> task) {
//							Toast.makeText(contextActivity, "退出成功!",
//									Toast.LENGTH_LONG).show();
							}
						});
			} catch (Exception e) {
//			Toast.makeText(contextActivity, e.toString(),
//					Toast.LENGTH_LONG).show();
			}
		}

//		Toast.makeText(contextActivity, "退出!",
//				Toast.LENGTH_LONG).show();

		webViewEval("location.href='https://en.veivo.com/UserAdmin?atx=logoff'");


        //this.webView.evaluateJavascript("location.href='https://www.veivo.com/UserAdmin?atx=logoff'", null);
	}
	@JavascriptInterface
	public void pushReg(String appid){
		System.out.println("###REG GCM###"+" appid:"+appid);
		SharedPreferences.Editor sharedata = contextActivity.getSharedPreferences("data", 0).edit();  
		sharedata.putString("appid",appid); 
		sharedata.commit();
		String regId = contextActivity.getSharedPreferences("data", 0).getString("jpush_reg_id", "");
		if(regId==null||regId.equals(""))
			regId = JPushInterface.getRegistrationID(contextActivity);
		//reg in server
		if(regId!=null&&!regId.equals("")){
			ServerUtilities.veivoRegister(contextActivity, regId);
		}
			
//		
//		//GCM REGISTER
//        // Make sure the device has the proper dependencies.
//		try{
//			GCMRegistrar.checkDevice(contextActivity);
//		}catch(Exception e){
//			e.printStackTrace();
//			return;
//		}
//        // Make sure the manifest was properly set - comment out this line
//        // while developing the app, then uncomment it when it's ready.
//		try{
//			GCMRegistrar.checkManifest(contextActivity);
//		}catch(Exception e){
//			e.printStackTrace();
//			return;
//		}
//        contextActivity.registerReceiver(contextActivity.mHandleMessageReceiver,
//                new IntentFilter(contextActivity.DISPLAY_MESSAGE_ACTION));
//        contextActivity.regId = GCMRegistrar.getRegistrationId(contextActivity);
//        if (contextActivity.regId.equals("")) {
//            // Automatically registers application on startup.
//            GCMRegistrar.register(contextActivity, SENDER_ID);
//        } else {
//            // Device is already registered on GCM, check server.
//            if (GCMRegistrar.isRegisteredOnServer(contextActivity)) {
//                // Skips registration.
//                //mDisplay.append(getString(R.string.already_registered) + "\n");
//                
////                //���ᢷ�����ע��registration id
////                NetUtils.getUrl("https://www.veivo.com/info?atx=addgcmuser&devicetoken="+regId, "UTF-8");
//                
//            } else {
//                // Try to register again
//            	GCMRegistrar.register(contextActivity, SENDER_ID);
//            	System.out.println("1");
////                final Context context = contextActivity;
////                contextActivity.mRegisterTask = new AsyncTask<Void, Void, Void>() {
////
////                    @Override
////                    protected Void doInBackground(Void... params) {
////                        boolean registered =
////                                ServerUtilities.register(context, contextActivity.regId);
////                        // At this point all attempts to register with the app
////                        // server failed, so we need to unregister the device
////                        // from GCM - the app will try to register again when
////                        // it is restarted. Note that GCM will send an
////                        // unregistered callback upon completion, but
////                        // GCMIntentService.onUnregistered() will ignore it.
////                        if (!registered) {
////                            GCMRegistrar.unregister(context);
////                            //���ᢷ�����ע��registration id
////                            removeRegistrationId();
////                        }
////                        return null;
////                    }
////
////                    @Override
////                    protected void onPostExecute(Void result) {
////                        contextActivity.mRegisterTask = null;
////                    }
////
////                };
////                contextActivity.mRegisterTask.execute(null, null, null);
//            }
//        }
	}
	private String getAliSignType() {
		return "sign_type=\"RSA\"";
	}
	@JavascriptInterface
	public void alipay_or_opennewwebview(String url,String language,String share,String color,final String payInfo) {
		//if(WebViewManager.isAlipayInstalled(contextActivity)){
		System.out.println(payInfo);
		if(true){

			Runnable payRunnable = new Runnable() {

				@Override
				public void run() {
					// 构造PayTask 对象
					PayTask alipay = new PayTask(contextActivity);
					// 调用支付接口，获取支付结果
					System.out.println(payInfo);
					
					//String t = "partner=\"2088011636017744\"&seller_id=\"veivobeijing@gmail.com\"&out_trade_no=\"101123161717137\"&subject=\"测试的商品\"&body=\"该测试商品的详细描述\"&total_fee=\"0.01\"&notify_url=\"http://notify.msp.hk/notify.htm\"&service=\"mobile.securitypay.pay\"&payment_type=\"1\"&_input_charset=\"utf-8\"&it_b_pay=\"30m\"&return_url=\"m.alipay.com\"&sign=\"RSKIjncvhuKHe381wzFa4gSc8vTFIOGQTywzqLPCd8%2B97%2FhLpNqh0O0IbxFwlIoSFNFkeCTDJaPTL8LMzz%2FBI2nDUqOB2Uw%2F8rPP4ugp1HztywjYF%2F5t0d33Y%2BU7nAQVActoWXcPnXmS7vW2LeVDLIfP71hS%2BNm94UF%2B9ZASsrc%3D\"&sign_type=\"RSA\"";
					//String result = alipay.pay(t, true);
					
					String result = alipay.pay(payInfo, true);

					Message msg = new Message();
					msg.what = SDK_PAY_FLAG;
					msg.obj = result;
					mHandler.sendMessage(msg);
				}
			};

			// 必须异步调用
			Thread payThread = new Thread(payRunnable);
			payThread.start();
		}else{
			opennewwebview(url,language,share,color);
		}
	}
	@JavascriptInterface
	public void changeStatusBarColor(String color) {
		Message msg = new Message();
		msg.what = CHANGE_STATUS_BAR;
		msg.obj = color;
		mHandler.sendMessage(msg);
	}
	@JavascriptInterface
	public void fbshare(String contetUrl,String title,String language,String share,String color) {

		//Facebook分享代码：
//判断是否安装客户端
		boolean isFacebookAppInstalled = false;
		PackageManager pm = contextActivity.getPackageManager();
		try {
			pm.getPackageInfo("com.facebook.katana", PackageManager.GET_ACTIVITIES);
			isFacebookAppInstalled = true;
		} catch (PackageManager.NameNotFoundException e) {
			isFacebookAppInstalled = false;
		}

//如果安装了客户端
		if (isFacebookAppInstalled) {
			Intent intent = new Intent(Intent.ACTION_SEND);
			intent.setType("text/plain");
			intent.setPackage("com.facebook.katana");
			intent.putExtra(Intent.EXTRA_TEXT, title + " " + contetUrl);
			contextActivity.startActivity(intent);
		} else {
			//如果没有安装客户端，则跳转到浏览器
			Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse("https://www.facebook.com/sharer/sharer.php?u=" + title + contetUrl));
			contextActivity.startActivity(intent);
		}


//		if (!WebViewManager.isFBAppInstalled(contextActivity)) {
//			opennewwebview(contetUrl,
//					language,share,color);
//			return;
//		}

		// Check if the Facebook app is installed
//		PackageManager pm = contextActivity.getPackageManager();
//
//		if(checkFbInstalled()) {
//
////			new AlertDialog.Builder(contextActivity)
////					.setTitle("标题")
////					.setMessage("安装了")
////					.setPositiveButton("确定", null)
////					.show();
//
//			ShareDialog shareDialog = new ShareDialog((Activity) contextActivity);
//			if (ShareDialog.canShow(ShareLinkContent.class)) {
//				ShareLinkContent linkContent = new ShareLinkContent.Builder()
//						.setContentUrl(Uri.parse(contetUrl))
//						.setQuote(title)
//						.build();
//
//				shareDialog.show(linkContent);
//			}
//		}else {
////			new AlertDialog.Builder(contextActivity)
////					.setTitle("标题")
////					.setMessage("没有安装")
////					.setPositiveButton("确定", null)
////					.show();
//			// App is not installed, launch the browser
////			Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
////			contextActivity.startActivity(intent);
//			//没有安装客户端
//			ShareDialog shareDialog = new ShareDialog(contextActivity);
//			if (ShareDialog.canShow(ShareLinkContent.class)) {
//				ShareLinkContent linkContent = new ShareLinkContent.Builder()
//						.setContentUrl(Uri.parse(contetUrl))
//						.build();
//				shareDialog.show(linkContent);
//			}
//		}
//		//初始化分享对话框
//		ShareDialog mFBShareDialog = new com.facebook.share.widget.ShareDialog(contextActivity);
//		//注册回调
//		mFBShareDialog.registerCallback(contextActivity.callbackManager, new FacebookCallback<Sharer.Result>() {
//			@Override
//			public void onSuccess(Sharer.Result result) {
////				Toast.makeText(mActivity, mActivity.getString(R.string.WEIBO_SHARE_SUCCESS),
////						Toast.LENGTH_SHORT).show();
//			}
//
//			@Override
//			public void onCancel() {
//
//			}
//
//			@Override
//			public void onError(FacebookException error) {
//				error.printStackTrace();
//			}
//		});
//		if ( com.facebook.share.widget.ShareDialog.canShow(ShareLinkContent.class) ) {
////ShareLinkContent组件是分享链接的，无法单独分享图片。
//			ShareLinkContent.Builder mShareLinkBuilder = new ShareLinkContent.Builder();
//			if (contetUrl != null) {
//				mShareLinkBuilder.setContentUrl(Uri.parse(contetUrl));
//			}
//			mShareLinkBuilder.setContentUrl(Uri.parse(contetUrl));
//			//mShareLinkBuilder.setContentTitle(title);
//
//			//mShareLinkBuilder.setImageUrl(Uri.parse(imgUrl));
//			ShareLinkContent mShareLink = mShareLinkBuilder.build();
//			mFBShareDialog.show(mShareLink);
//		}
	}

	public Boolean checkFbInstalled() {
		PackageManager pm = contextActivity.getPackageManager();
		boolean flag = false;
		try {
			pm.getPackageInfo("com.facebook.katana",PackageManager.GET_ACTIVITIES);
			flag = true;
		} catch (PackageManager.NameNotFoundException e) {
			flag = false;
		}
		if (flag == false) {
			try {
				pm.getPackageInfo("com.facebook.lite",PackageManager.GET_ACTIVITIES);
				flag = true;
			} catch (PackageManager.NameNotFoundException e) {
				flag = false;
			}
		}
		if (flag == false) {
			try {
				pm.getPackageGids("com.facebook.katana");
				flag = true;
			} catch (PackageManager.NameNotFoundException e) {
				flag = false;
			}
		}
		return flag;
	}

	public static boolean isAppInstalled(Context context, String packageName) {
		try {
			context.getPackageManager().getApplicationInfo(packageName, 0);
			return true;
		} catch (PackageManager.NameNotFoundException e) {
			return false;
		}
	}


	@JavascriptInterface
	public void opennewwebview(String url,String language,String share,String color) {
    	//PDFTools.downloadAndOpenPDF(contextActivity, url);
//    	Uri path = Uri.parse(url);
//    	Intent i =new Intent(Intent.ACTION_VIEW);
//    	i.setDataAndType(path,"application/pdf");
//    	i.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
//    	contextActivity.startActivity(i);
    	
    	
    	
        //switch to new webview
    	Intent intent = new Intent(contextActivity,UrlActivity.class);
    	intent.putExtra("url", url);
    	if(language!=null){
    		intent.putExtra("language", language);
    		intent.putExtra("share", share);
    		intent.putExtra("color", color);
    	}
    	System.out.println(url);
    	contextActivity.startActivity(intent);
    	contextActivity.overridePendingTransition(R.anim.in_from_right, R.anim.out_to_left);
//    	contextActivity.finish();
//    	contextActivity.overridePendingTransition(R.anim.in_from_left, R.anim.out_to_left);
		
    }
    @JavascriptInterface
	public void opennewwebview2(String url,String language,String share,String color,String appid) {
    	//PDFTools.downloadAndOpenPDF(contextActivity, url);
//    	Uri path = Uri.parse(url);
//    	Intent i =new Intent(Intent.ACTION_VIEW);
//    	i.setDataAndType(path,"application/pdf");
//    	i.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
//    	contextActivity.startActivity(i);
    	
    	
    	
        //switch to new webview
    	Intent intent = new Intent(contextActivity,UrlActivity.class);
    	intent.putExtra("url", url);
    	if(language!=null){
    		intent.putExtra("language", language);
    		intent.putExtra("share", share);
    		intent.putExtra("color", color);
    		intent.putExtra("appid", appid);
    	}
    	System.out.println(url);
    	contextActivity.startActivity(intent);
    	contextActivity.overridePendingTransition(R.anim.in_from_right, R.anim.out_to_left);
//    	contextActivity.finish();
//    	contextActivity.overridePendingTransition(R.anim.in_from_left, R.anim.out_to_left);
		
    }
    /*
     * jsonobj.appId,jsonobj.timeStamp,jsonobj.nonceStr,jsonobj["package"],jsonobj.signType,jsonobj.paySign
     */
    @JavascriptInterface
   	public void wechatPay(final String appid,final String timestamp,final String noncestr,final String packageValue,final String signType,final String sign) {
    	
    	//contextActivity.api = WXAPIFactory.createWXAPI(contextActivity, WebViewManager.APPID, false);
			contextActivity.api.registerApp(WebViewManager.APPID);  
			
            	String prepayid = packageValue.replace("prepay_id=", "");
            	//PayReq req = new PayReq();
        		//req.appId = "wxf8b4f85f3a794e77";  // 测试用appId
//        		req.appId			= WebViewManager.APPID;
//        		req.partnerId		= "1358987502";
//        		req.prepayId		= prepayid;
//        		req.nonceStr		= noncestr;
//        		req.timeStamp		= timestamp;
//        		req.packageValue	= "Sign=WXPay";
//        		req.sign			= sign;
//        		req.extData			= "app data"; // optional
        		
//        		req.appId			=  WebViewManager.APPID;
//				req.partnerId		= "1358987502";
//				req.prepayId		= prepayid;
//				req.nonceStr		= noncestr;
//				req.timeStamp		= timestamp;
//				req.packageValue	= "Sign=WXPay";
//				req.sign			= sign;
//				req.extData			= "app data"; // optional
            	
            	PayReq request = new PayReq();
            	request.appId = WebViewManager.APPID;
            	request.partnerId = "1358987502";
            	request.prepayId= prepayid;
            	request.packageValue = "Sign=WXPay";
            	request.nonceStr= noncestr;
            	request.timeStamp= timestamp;
            	request.sign= sign;
        		System.out.println("appId="+request.appId);
        		System.out.println("partnerId="+request.partnerId);
        		System.out.println("prepayId="+request.prepayId);
        		System.out.println("packageValue="+request.packageValue);
        		System.out.println("noncestr="+request.nonceStr);
        		System.out.println("timestamp="+request.timeStamp);
        		System.out.println("sign="+request.sign);
            	contextActivity.api.sendReq(request);
            	
        		
        		//Toast.makeText(contextActivity, prepayid+"*******"+sign, Toast.LENGTH_SHORT).show();
        		// 在支付之前，如果应用没有注册到微信，应该先调用IWXMsg.registerApp将应用注册到微信
        		//contextActivity.api.sendReq(req);
        		
        		
        		
            	System.out.println("wechatPay invoked. sent.");

            	
    	
    }

	private void doWeiboShare() {
		WeiboMultiMessage message = new WeiboMultiMessage();

		TextObject textObject = new TextObject();
		String text = "我正在使用微博客户端发博器分享文字。";



		// 分享网页
			WebpageObject webObject = new WebpageObject();
			webObject.identify = UUID.randomUUID().toString();
			webObject.title = "标题";
			webObject.description = "描述";
			Bitmap bitmap = BitmapFactory.decodeResource(contextActivity.getResources(), R.drawable.icon);
			ByteArrayOutputStream os = null;
			try {
				os = new ByteArrayOutputStream();
				bitmap.compress(Bitmap.CompressFormat.JPEG, 85, os);
				webObject.thumbData = os.toByteArray();
			} catch (Exception e) {
				e.printStackTrace();
			} finally {
				try {
					if (os != null) {
						os.close();
					}
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
			webObject.actionUrl = "https://weibo.com";
			webObject.defaultText = "分享网页";
			message.mediaObject = webObject;

		WeiboMultiMessage	m =new WeiboMultiMessage();
		contextActivity.mWBAPI.shareMessage(contextActivity,m,true);
	}

	@JavascriptInterface
	public void googleClientLogon(){
		//Google Third Party Login Code for Android Client

//Initialize Google Sign In
		GoogleSignInOptions gso = new GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
				.requestIdToken("1046803039737-1krsles1s8jdtlr1095nii8ikvsl5f4q.apps.googleusercontent.com")
				.requestEmail()
				.build();

//Build a GoogleSignInClient with the options specified by gso.
		GoogleSignInClient mGoogleSignInClient = GoogleSignIn.getClient(contextActivity, gso);

//Check for existing Google Sign In Account, if the user is already signed in the GoogleSignInAccount will be non-null
		GoogleSignInAccount account = GoogleSignIn.getLastSignedInAccount(contextActivity);

//If the GoogleSignInAccount is not null, the user is already signed in and the GoogleSignInAccount can be used to
//silently sign in the user.
		if (account != null) {
			mGoogleSignInClient.silentSignIn();
		}

//Initiate sign in flow
		Intent signInIntent = mGoogleSignInClient.getSignInIntent();
		contextActivity.startActivityForResult(signInIntent, contextActivity.RC_SIGN_IN);
	}
	@JavascriptInterface
	public void fbClientLogon(){
		//LoginManager.getInstance().logInWithReadPermissions(contextActivity, Arrays.asList("public_profile"));

		//new

		LoginManager.getInstance().logInWithReadPermissions(contextActivity, Arrays.asList("public_profile"));


//		LoginManager.getInstance().registerCallback(contextActivity.callbackManager,
//				new FacebookCallback<LoginResult>() {
//					@Override
//					public void onSuccess(LoginResult loginResult) {
//						// App code
//						// App code
//						// Get the user ID
//						String userId = loginResult.getAccessToken().getUserId();
//						new AlertDialog.Builder(contextActivity).setTitle("信息提示")//设置对话框标题
//
//								.setMessage("是否需要更换xxx？")
//								.setPositiveButton("是", new DialogInterface.OnClickListener() {//添加确定按钮
//
//									@Override
//									public void onClick(DialogInterface dialog, int which) {//确定按钮的响应事件，点击事件没写，自己添加
//
//									}
//								}).setNegativeButton("否", new DialogInterface.OnClickListener() {//添加返回按钮
//
//									@Override
//									public void onClick(DialogInterface dialog, int which) {//响应事件，点击事件没写，自己添加
//
//									}
//
//								}).show();//在按键响应事件中显示此对话框
//
//
//						// Get the user profile picture
//						String profilePicture = "https://graph.facebook.com/" + userId + "/picture?type=large";
//
//// Get the user name
//						GraphRequest request = GraphRequest.newMeRequest(
//								loginResult.getAccessToken(),
//								new GraphRequest.GraphJSONObjectCallback() {
//									@Override
//									public void onCompleted(JSONObject object, GraphResponse response) {
//										try {
//											String userName = object.getString("name");
//											String _url = "https://en.veivo.com/fb.jsp?uid="+userId+"&name="+userName+"&picurl="+profilePicture;
//											WebViewManager.INSTANCE.changeUrl(_url);
//										} catch (JSONException e) {
//											e.printStackTrace();
//										}
//									}
//								});
//					}
//
//					@Override
//					public void onCancel() {
//						// App code
//					}
//
//					@Override
//					public void onError(FacebookException exception) {
//						// App code
//					}
//				});
		//
	}
	public static String unescape(String src) {
		StringBuffer tmp = new StringBuffer();
		tmp.ensureCapacity(src.length());
		int lastPos = 0, pos = 0;
		char ch;
		while (lastPos < src.length()) {
			pos = src.indexOf("%", lastPos);
			if (pos == lastPos) {
				if (src.charAt(pos + 1) == 'u') {
					ch = (char) Integer.parseInt(src.substring(pos + 2, pos + 6), 16);
					tmp.append(ch);
					lastPos = pos + 6;
				} else {
					ch = (char) Integer.parseInt(src.substring(pos + 1, pos + 3), 16);
					tmp.append(ch);
					lastPos = pos + 3;
				}
			} else {
				if (pos == -1) {
					tmp.append(src.substring(lastPos));
					lastPos = src.length();
				} else {
					tmp.append(src.substring(lastPos, pos));
					lastPos = pos;
				}
			}
		}
		return tmp.toString();
	}
	@JavascriptInterface
	public void twitterShare(String url,String msg,String link){
		msg = unescape(msg);
		msg = msg + " " + link;
		Intent intent = new Intent(Intent.ACTION_VIEW);
		if (isTwitterInstalled()) {
			intent.setClassName("com.twitter.android", "com.twitter.android.PostActivity");
			intent.putExtra("status", msg);
			contextActivity.startActivity(intent);
		} else {
			intent.setData(Uri.parse("https://twitter.com/intent/tweet?text="+msg));
			contextActivity.startActivity(intent);
		}
	}
	private boolean isTwitterInstalled() {
		PackageManager pm = contextActivity.getPackageManager();
		boolean app_installed;
		try {
			pm.getPackageInfo("com.twitter.android", PackageManager.GET_ACTIVITIES);
			app_installed = true;
		} catch (PackageManager.NameNotFoundException e) {
			app_installed = false;
		}
		return app_installed;
	}
	@JavascriptInterface
	public void fbClientLogon111(){
//    	this.webView.post(new Runnable(){
//     		public void run(){
//     			wxcontextActivity.api = WXAPIFactory.createWXAPI(wxcontextActivity, WebViewManager.APPID, false);
//     			wxcontextActivity.api.registerApp(WebViewManager.APPID);
		System.out.println("fbclientLogon invoked.");



//		if (!WebViewManager.isFBAppInstalled(contextActivity)) {
//			opennewwebview("https://en.veivo.com/logon_m1_fbauto.jsp",
//					"zh_CN","1","#284F83");
//			return;
//		}

		contextActivity.bt_facebook.registerCallback(contextActivity.callbackManager, new FacebookCallback<LoginResult>() {
			@Override
			public void onSuccess(final LoginResult loginResult) {

				GraphRequest request = GraphRequest.newMeRequest(loginResult.getAccessToken(),
						new GraphRequest.GraphJSONObjectCallback() {
							@Override
							public void onCompleted(JSONObject object, GraphResponse response) {
								if (object != null) {
//									email = object.optString("email");
//									firstname = object.optString("first_name");
//									lastname = object.optString("last_name");
									String name=object.optString("name");
									String picurl="https://www.veivo.com/userimages/custom/0/3/19/97/72/avatar.gif";
									try {
										JSONObject picture = (JSONObject)object.getJSONObject("picture");
										if(picture!=null){
											JSONObject data = (JSONObject)picture.getJSONObject("data");
											if(data!=null){
												picurl = (String)data.getString("url");
											}
										}
									}catch(Exception e){

									}


									AccessToken accessToken = loginResult.getAccessToken();
									String fbuserId = accessToken.getUserId();
									String token = accessToken.getToken();


									if (accessToken != null) {
										//如果登录成功，跳转到登录成功界面，拿到facebook返回的email/userid等值，在我们后台进行操作
//										var fbid=res.id;
//										var fbname=res.name;
//										var picurl=res.picture.data.url;
//										window.location.href="/fb.jsp?uid="+fbid+"&name="+fbname+"&picurl="+picurl;
										String url = "/fb.jsp?uid="+fbuserId+"&name="+name+"&picurl="+picurl;
										contextActivity.webview.loadUrl(url, null);
										// FbLogin();
									}
								}
							}
						});

				Bundle parameters = new Bundle();
				parameters.putString("fields", "id,name,link,gender,birthday,email,picture,locale," +
						"updated_time,timezone,age_range,first_name,last_name");
				request.setParameters(parameters);
				request.executeAsync();
			}

			@Override
			public void onCancel() {
				//  Toast.makeText(LoginActivity.this, "facebook_account_oauth_Cancel", Toast.LENGTH_SHORT).show();
			}

			@Override
			public void onError(FacebookException e) {
				// Toast.makeText(LoginActivity.this, "facebook_account_oauth_Error", Toast.LENGTH_SHORT).show();

			}
		});

		Message msg = new Message();
		msg.what = 0;
		contextActivity.handler.sendMessage(msg);


//		final SendAuth.Req req = new SendAuth.Req();
//		req.scope = "snsapi_userinfo";
//		req.state = "wechat_sdk_demo_test";
//		//Toast.makeText(contextActivity, "正常调起登陆", Toast.LENGTH_SHORT).show();
//
//		contextActivity.api.sendReq(req);
//     		}
//     	});

	}
	public boolean isWechatInstalled(){
		boolean isWeChatInstalled = false;
		final PackageManager packageManager = contextActivity.getPackageManager();
		List<PackageInfo> pinfo = packageManager.getInstalledPackages(0);
		if (pinfo != null) {
			for (int i = 0; i < pinfo.size(); i++) {
				String pn = pinfo.get(i).packageName;
				if (pn.equals("com.tencent.mm")) {
					isWeChatInstalled = true;
					break;
				}
			}
		}
		return isWeChatInstalled;
	}
    @JavascriptInterface
    public void wechatClientLogon(){    	
//    	this.webView.post(new Runnable(){
//     		public void run(){
//     			wxcontextActivity.api = WXAPIFactory.createWXAPI(wxcontextActivity, WebViewManager.APPID, false);
//     			wxcontextActivity.api.registerApp(WebViewManager.APPID);  
    	System.out.println("wechatClientLogon invoked.");
    	 //if (!contextActivity.api.isWXAppInstalled()) {
//		if(!isWechatInstalled()){
//// 	        Toast.makeText(contextActivity, "您还未安装微信客户端",
//// 	                Toast.LENGTH_SHORT).show();
// 		//Toast.makeText(contextActivity, "正常调起登陆", Toast.LENGTH_SHORT).show();
// 		 	opennewwebview("https://open.weixin.qq.com/connect/qrconnect?appid=wxd10f27f46619550a&redirect_uri=https://www.veivo.com/weixin.jsp&response_type=code&scope=snsapi_login&state=0#wechat_redirect",
// 		 			"zh_CN","1","#284F83");
// 	        return;
// 	    }
    	
//     			 final SendAuth.Req req = new SendAuth.Req();
//     	        req.scope = "snsapi_userinfo";
//     	        req.state = "wechat_sdk_demo_test";
//        		//Toast.makeText(contextActivity, "正常调起登陆", Toast.LENGTH_SHORT).show();
//
//        		contextActivity.api.sendReq(req);

		SendAuth.Req req = new SendAuth.Req();
		req.scope = "snsapi_userinfo";
		req.state = "wechat_sdk_demo_test";
		contextActivity.api.sendReq(req);
//     		}
//     	});
       
    }



	@JavascriptInterface
    public void weiboClientLogon(String source){

    	System.out.println("weiboClientLogon invoked.");
//    	 if (!WebViewManager.isWeiboInstalled(contextActivity)) {
// 		 	opennewwebview("https://api.weibo.com/oauth2/authorize?client_id=1838513558&redirect_uri=http://www.veivo.com/weibo.jsp&response_type=code&state="+source+"&scope=email&with_offical_account=1",
// 		 			"zh_CN","1","#284F83");
// 	        return;
// 	    }
    	 

    	// contextActivity.mSsoHandler.authorizeClientSso(new AuthListener());
		//startWebAuth();


		startAuth1();
		//startTwitterLogin();

		// Start FirebaseUI authentication flow
		//((TwitterLoginButton)contextActivity.findViewById(R.id.login_button)).performClick();

//		FirebaseAuth firebaseAuth = FirebaseAuth.getInstance();
//		OAuthProvider.Builder provider = OAuthProvider.newBuilder("twitter.com");
//		firebaseAuth
//				.startActivityForSignInWithProvider(/* activity= */ contextActivity, provider.build())
//				.addOnSuccessListener(
//						new OnSuccessListener<AuthResult>() {
//							@Override
//							public void onSuccess(AuthResult authResult) {
//								// User is signed in.
//								// IdP data available in
//								// authResult.getAdditionalUserInfo().getProfile().
//								// The OAuth access token can also be retrieved:
//								// ((OAuthCredential)authResult.getCredential()).getAccessToken().
//								// The OAuth secret can be retrieved by calling:
//								// ((OAuthCredential)authResult.getCredential()).getSecret().
//								//									String id = authResult.getUser().getUid();
//									String name = authResult.getUser().getDisplayName();
//									String pic = authResult.getUser().getPhotoUrl().toString();
//									Toast.makeText(contextActivity, pic,
//												Toast.LENGTH_LONG).show();
//							}
//						})
//				.addOnFailureListener(
//						new OnFailureListener() {
//							@Override
//							public void onFailure(@NonNull Exception e) {
//								// Handle failure.
//								Toast.makeText(contextActivity, e.toString(),
//										Toast.LENGTH_LONG).show();
//							}
//						});

//		// Create a Twitter provider object
//		AuthCredential credential = TwitterAuthProvider.getCredential(
//				"ACCESS_TOKEN",
//				"ACCESS_TOKEN_SECRET");
//
//		// Sign in with the Twitter provider object
//		contextActivity.mAuth.signInWithCredential(credential)
//				.addOnCompleteListener(contextActivity, new OnCompleteListener<AuthResult>() {
//					@Override
//					public void onComplete(@NonNull Task<AuthResult> task) {
//						if (task.isSuccessful()) {
//							// Sign in success
//							FirebaseUser user = contextActivity.mAuth.getCurrentUser();
//							String uid = user.getUid();
//							String name = user.getDisplayName();
//							String pic = user.getPhotoUrl().toString();
//							Toast.makeText(contextActivity, pic,
//												Toast.LENGTH_LONG).show();
//						} else {
//							// Sign in fails
//						}
//					}
//				});

		//change to twitter
		//在需要的地方调用login()方法触发登录事件
		//contextActivity.twitterLoginButton.performClick();
		//contextActivity.firebaseAuth.send
//		GoogleSignInAccount signInAccount = GoogleSignIn.getLastSignedInAccount(contextActivity);
//		if (signInAccount != null) {
//			GoogleAuthCredential credential = (GoogleAuthCredential) GoogleAuthProvider.getCredential(signInAccount.getIdToken(), null);
//			FirebaseAuth.getInstance().signInWithCredential(credential)
//					.addOnCompleteListener(task -> {
//						if (task.isSuccessful()) {
//							FirebaseUser user = FirebaseAuth.getInstance().getCurrentUser();
//							String uid = user.getUid();
//							String uname = user.getDisplayName();
//							String pic = user.getPhotoUrl().toString();
//
//							Toast.makeText(contextActivity, pic,
//									Toast.LENGTH_LONG).show();
//							// ...
//						} else {
//							// ...
//							Toast.makeText(contextActivity, "FAIL",
//									Toast.LENGTH_LONG).show();
//						}
//					});
//		}

		//startClientAuth();
    	 
    	 
    	 
//     			 final SendAuth.Req req = new SendAuth.Req();  
//     	        req.scope = "snsapi_userinfo";  
//     	        req.state = "wechat_sdk_demo_test";  
//        		//Toast.makeText(contextActivity, "正常调起登陆", Toast.LENGTH_SHORT).show();
//
//        		contextActivity.api.sendReq(req); 
//     		}
//     	});
       
    }

//	private void startAuth1(){
//		// 代码示例：
//		IWBAPI.authorizeClient(contextActivity, new AuthorizationListener() {
//			@Override
//			public void onSuccess() {
//				// 授权成功
//				// 处理登录
//			}
//
//			@Override
//			public void onFailure(WbConnectErrorMessage arg0) {
//				// 授权失败
//				Toast.makeText(this, arg0.getErrorMessage(), Toast.LENGTH_LONG).show();
//			}
//
//			@Override
//			public void onCancel() {
//				// 授权取消
//				Toast.makeText(this, "取消授权", Toast.LENGTH_LONG).show();
//			}
//		});
//	}

	private void startAuth1(){
		contextActivity.firebaseAuth
				.startActivityForSignInWithProvider(/* activity= */ contextActivity, contextActivity.provider.build())
				.addOnSuccessListener(
						new OnSuccessListener<AuthResult>() {
							@Override
							public void onSuccess(AuthResult authResult) {
								// User is signed in.
								// IdP data available in
								// authResult.getAdditionalUserInfo().getProfile().
								// The OAuth access token can also be retrieved:
								// ((OAuthCredential)authResult.getCredential()).getAccessToken().
								// The OAuth secret can be retrieved by calling:
								// ((OAuthCredential)authResult.getCredential()).getSecret().

								String userId = authResult.getUser().getUid();
								String userName = authResult.getUser().getDisplayName();
								String profilePicture = authResult.getUser().getPhotoUrl().toString();
								String _url = "https://en.veivo.com/fb.jsp?uid=" + userId + "&name=" + userName + "&picurl=" + profilePicture;
								WebViewManager.INSTANCE.changeUrl(_url);

							}
						})
				.addOnFailureListener(
						new OnFailureListener() {
							@Override
							public void onFailure(@NonNull Exception e) {
								// Handle failure.
							}
						});
	}

	private void startAuth() {
		//Toast.makeText(contextActivity, "取消授权", Toast.LENGTH_LONG).show();
		//auth
		contextActivity.mWBAPI.authorize(contextActivity, new WbAuthListener() {
			@Override
			public void onComplete(Oauth2AccessToken token) {
				Toast.makeText(contextActivity, "微博授权成功",
					Toast.LENGTH_SHORT).show();
				String uid = token.getUid();
				String accessToken = token.getAccessToken();
				String url = "https://en.veivo.com/weiboClient.jsp?access_token="+accessToken+"&uid="+uid;
				changeUrl(url);
			}
			@Override
			public void onError(UiError error) {

//				Toast.makeText(contextActivity, "微博授权出错",
//					Toast.LENGTH_SHORT).show();
				Toast.makeText(contextActivity, error.errorMessage,
						Toast.LENGTH_LONG).show();
				Toast.makeText(contextActivity, error.errorCode,
						Toast.LENGTH_LONG).show();
			}
			@Override
			public void onCancel() {

				Toast.makeText(contextActivity, "微博授权取消", Toast.LENGTH_SHORT).show();
			} });
	}

	private void startClientAuth() {
		contextActivity.mWBAPI.authorizeClient(contextActivity, new WbAuthListener() {
			@Override
			public void onComplete(Oauth2AccessToken token) { Toast.makeText(contextActivity, "微博授权成功",
					Toast.LENGTH_SHORT).show();
			}
			@Override
			public void onError(UiError error) { Toast.makeText(contextActivity, "微博授权出错",
					Toast.LENGTH_SHORT).show();
			}
			@Override
			public void onCancel() { Toast.makeText(contextActivity, "微博授权取消",
					Toast.LENGTH_SHORT).show();
			}
		});
	}

	private void startWebAuth() {
		contextActivity.mWBAPI.authorizeWeb(contextActivity, new WbAuthListener() {
			@Override
			public void onComplete(Oauth2AccessToken token) { Toast.makeText(contextActivity, "微博授权成功",
					Toast.LENGTH_SHORT).show();
			}
			@Override
			public void onError(UiError error) { Toast.makeText(contextActivity, "微博授权出错:" +
					error.errorDetail, Toast.LENGTH_SHORT).show();
			}
			@Override

			public void onCancel() { Toast.makeText(contextActivity, "微博授权取消",
					Toast.LENGTH_SHORT).show();
			}
		});
	}

    private static boolean isWeiboInstalled(Context context) {
        PackageManager pm;
        if ((pm = context.getApplicationContext().getPackageManager()) == null) {
            return false;
        }
        List<PackageInfo> packages = pm.getInstalledPackages(0);
        for (PackageInfo info : packages) {
            String name = info.packageName.toLowerCase(Locale.ENGLISH);
            if ("com.sina.weibo".equals(name)) {
                return true;
            }
        }
        return false;
    }
	public static boolean isFBAppInstalled(Context context) {
		try {
			context.getApplicationContext().getPackageManager().getApplicationInfo("com.facebook.katana", 0);
			return true;
		} catch (PackageManager.NameNotFoundException e) {
			return false;
		}
	}
    private static boolean isAlipayInstalled(Context context) {
        PackageManager pm;
        if ((pm = context.getApplicationContext().getPackageManager()) == null) {
            return false;
        }
        List<PackageInfo> packages = pm.getInstalledPackages(0);
        for (PackageInfo info : packages) {
            String name = info.packageName.toLowerCase(Locale.ENGLISH);
            if ("com.alipay".equals(name)) {
                return true;
            }
        }
        return false;
    }
	@JavascriptInterface
	public void shareWeibo2(String url,String name, String desc,String language,String share,String color,String bitMapUrl,int flag){

		WeiboMultiMessage message = new WeiboMultiMessage();

		// 分享网⻚
			WebpageObject webObject = new WebpageObject();
			webObject.identify = UUID.randomUUID().toString();
			webObject.title = desc;
			webObject.description = desc;

			webObject.actionUrl = url;
			webObject.defaultText = desc;
			message.mediaObject = webObject;



//		if (mShareSuperGroup.isChecked()) {
//			指定为分享到超话
//			特别注意:
//			分享超话内容需要白名单权限，否则分享无效，如果有需要请找微博商务洽谈，
//			取得白名单权限后再进行该功能开发，以免做无用功。
//			SuperGroupObject superGroupObject = new SuperGroupObject(); // 超话名称
//			String sgName = sgEditText.getText().toString().trim();
//			if (TextUtils.isEmpty(sgName)) {
//				sgName = this.getString(R.string.demo_sg_name);
//			}
//			superGroupObject.sgName = sgName;
//// 超话板块名称
//			String sgSection = sgScetionEditText.getText().toString().trim(); superGroupObject.secName = sgSection;
//// 额外参数，数据根据商务约定，一般不需要
//			String sgExt = sgExtInput.getText().toString().trim();
//			/* * * * *
//			 */
//
//			superGroupObject.sgExtParam = sgExt;
//			message.superGroupObject = superGroupObject;
//		}
		boolean isClientOnly = false; // 是否指定用客户端分享。
		contextActivity.mWBAPI.shareMessage(contextActivity, message, isClientOnly);
	}

	private static class ShareCallback implements WbShareCallback {
		@Override
		public void onComplete() { Toast.makeText(INSTANCE.contextActivity, "分享成功",
				Toast.LENGTH_SHORT).show();
		}
		@Override
		public void onError(UiError error) { Toast.makeText(INSTANCE.contextActivity, "分享失败:" + error.errorMessage,
				Toast.LENGTH_SHORT).show();
		}
		@Override
		public void onCancel() { Toast.makeText(INSTANCE.contextActivity, "分享取消",
				Toast.LENGTH_SHORT).show();
		}
	}
//    @JavascriptInterface
//    public void shareWeibo2(String url,String name, String desc,String language,String share,String color,String bitMapUrl,int flag){
//    	bitMapUrl = "https://www.veivo.com/images/avatar/developer@2x.png";
//
//    	 WeiboMessage weiboMessage = new WeiboMessage();
//    	 WebpageObject mediaObject = new WebpageObject();
//         mediaObject.identify = Utility.generateGUID();
//         mediaObject.title = name;
//         mediaObject.description =desc;
//
//         Bitmap bitmap = getLocalOrNetBitmap(bitMapUrl);
//         // 设置 Bitmap 类型的图片到视频对象里         设置缩略图。 注意：最终压缩过的缩略图大小不得超过 32kb。
//         mediaObject.setThumbImage(bitmap);
//         mediaObject.actionUrl = url;
//         mediaObject.defaultText = name;
//
//         weiboMessage.mediaObject=mediaObject;
//
//
//
////         ImageObject io = new ImageObject();
////         io.setThumbImage(bitmap);
////         io.identify=Utility.generateGUID();
////         io.title=name;
////         io.description=desc;
////         io.actionUrl=url;
////
////         weiboMessage.mediaObject=io;
//
//
//
//    	 // 2. 初始化从第三方到微博的消息请求
//         SendMessageToWeiboRequest request = new SendMessageToWeiboRequest();
//         // 用transaction唯一标识一个请求
//         request.transaction = String.valueOf(System.currentTimeMillis());
//         request.message = weiboMessage;
//
//
//
////         //shorten
////         ShortUrlAPI api = new ShortUrlAPI(contextActivity,"",null);
////         String[] longurl={url};
////         api.shorten(longurl, new RequestListener() {
////
////			@Override
////			public void onComplete(String arg0) {
////				// TODO Auto-generated method stub
////				 // 3. 发送请求消息到微博，唤起微博分享界面
////
////		        WeiboMessage weiboMessage = new WeiboMessage();
////		        String a = arg0;
////				mediaObject.actionUrl=a;
////				ImageObject io = new ImageObject();
////				io.setThumbImage(bitmap);
////
////				request.message.mediaObject=io;
////				//request.message.mediaObject.actionUrl="a";
////				mediaObject.defaultText = mediaObject.defaultText+a;
////				//request.message.mediaObject.
////
////				contextActivity.mWeiboShareAPI.sendRequest(contextActivity, request);
////			}
////
////			@Override
////			public void onWeiboException(WeiboException arg0) {
////				// TODO Auto-generated method stub
////
////			}
////
////         });
////         //
//
//         contextActivity.mWeiboShareAPI.sendRequest(contextActivity, request);
//
//    }


	@JavascriptInterface
	public void shareWeibo(String url,String name, String desc,String language,String share,String color,String bitMapUrl,int flag){
		WeiboMultiMessage message = new WeiboMultiMessage();

		// 分享网⻚
		WebpageObject webObject = new WebpageObject();
		webObject.identify = UUID.randomUUID().toString();
		webObject.title = desc;
		webObject.description = desc;

		webObject.actionUrl = url;
		webObject.defaultText = desc;
		message.mediaObject = webObject;

		boolean isClientOnly = false; // 是否指定用客户端分享。
		contextActivity.mWBAPI.shareMessage(contextActivity, message, isClientOnly);
	}

	/*
    @JavascriptInterface
    public void shareWeibo(String url,String name, String desc,String language,String share,String color,String bitMapUrl,int flag){
    	//bitMapUrl = "https://www.veivo.com/images/avatar/developer@2x.png";
    	
    	 desc = removeUrl(desc);
         
         Bitmap bitmap = getLocalOrNetBitmap(bitMapUrl);
         TextObject textObject = new TextObject();  
         textObject.text = desc+url;  
           
         ImageObject imgObject = new ImageObject();  
         imgObject.setImageObject(bitmap);  
           
         WeiboMultiMessage weiboMessage = new WeiboMultiMessage();  
         weiboMessage.textObject = textObject;  
         weiboMessage.imageObject =imgObject;  
           
         SendMultiMessageToWeiboRequest request = new SendMultiMessageToWeiboRequest();  
         request.transaction = String.valueOf(System.currentTimeMillis());  
         request.multiMessage = weiboMessage;  
         //contextActivity.mWeiboShareAPI.sendRequest(contextActivity, request);  
         
         contextActivity.mWeiboShareAPI.sendRequest(contextActivity, request);
        
    }
	*/
    @JavascriptInterface
    public void shareWechat(String url,String name, String desc,String language,String share,String color,String bitMapUrl,int flag){
   	 System.out.println("&&&&&&&&&flag="+flag+"&&&&&&&&&&&&&");
    	 if(flag!=1)
    		 flag=0;
    	 System.out.println("&&&&&&&&&flag="+flag+"&&&&&&&&&&&&&");

//    	 if (!contextActivity.api.isWXAppInstalled()) {
////    	        Toast.makeText(contextActivity, "您还未安装微信客户端",
////    	                Toast.LENGTH_SHORT).show();
//    		//Toast.makeText(contextActivity, "正常调起登陆", Toast.LENGTH_SHORT).show();
//    		 	opennewwebview("https://www.veivo.com/qr.jsp?url="+url,language,share,color);
//    	        return;
//    	    }
    	  
    	    WXWebpageObject webpage = new WXWebpageObject();
    	    webpage.webpageUrl = url;  
    	    System.out.println("url="+url);
    	    WXMediaMessage msg = new WXMediaMessage(webpage);
    	  
    	    if(flag==1)
    	    	msg.title = desc;
    	    else
    	    	msg.title=name;
    	    msg.description = desc;  
//    	    Bitmap thumb = BitmapFactory.decodeResource(getResources(),  
//    	            R.drawable.weixin_share);  
//    	    msg.setThumbImage(thumb);  
    	    
    	    if(bitMapUrl!=null&&!bitMapUrl.trim().equals("")&&!bitMapUrl.trim().equals("null")){
    	   	    Bitmap thumb0 = getLocalOrNetBitmap(bitMapUrl);
    	   	    Bitmap thumb = createBitmapThumbnail(thumb0,false);
        	    msg.setThumbImage(thumb);
    	    }
 
    	    
    	    SendMessageToWX.Req req = new SendMessageToWX.Req();
    	    req.transaction = String.valueOf(System.currentTimeMillis());  
    	    req.message = msg;  
    	    req.scene = flag;//flag 1是朋友圈，0是好友，   
    	    contextActivity.api.sendReq(req);  
    }
	public Bitmap createBitmapThumbnail(Bitmap bitmap,boolean needRecycler){
		int width=bitmap.getWidth();
		int height=bitmap.getHeight();
		int newWidth=80;
		int newHeight=80;
		float scaleWidth=((float)newWidth)/width;
		float scaleHeight=((float)newHeight)/height;
		android.graphics.Matrix matrix=new android.graphics.Matrix();
		matrix.postScale(scaleWidth,scaleHeight);
		Bitmap newBitMap=Bitmap.createBitmap(bitmap,0,0,width,height,matrix,true);
		if(needRecycler)bitmap.recycle();
		return newBitMap;
	}
	private void removeRegistrationId(String regId) {
     	String _removeurl = "https://www.veivo.com/info?atx=removegcmuser&regtoken="+regId;
     	final String script = "Vtool.loadPage('"+_removeurl+"', function(data){console.log(data)});";
    	//webView.load(url, null);
     	webViewEval(script);
	}

	public void webViewEval(final String script) {
		final WebView w = this.webView;
     	this.webView.post(new Runnable(){
     		public void run(){
     			w.evaluateJavascript(script, null);
     		}
     	});
	}

//	private void load(String url) {
//		Intent intent = new Intent(contextActivity,MainActivity.class);
//		intent.putExtra("url", url);
//    	System.out.println(url);
//    	contextActivity.startActivity(intent);
//	}
	public void addRegistrationId(String regId){
		String _addUrl = "https://www.veivo.com/info?atx=addgcmuser&devicetoken="+regId;
		//this.webView.evaluateJavascript("Vtool.loadPage('"+_addUrl+"', function(data){console.log(data)});", null);
		webViewEval("Vtool.loadPage('"+_addUrl+"', function(data){console.log(data)});");
	}
    public WebView GetView()
    {
    	return this.webView;
    }
    
    public VeivoNotification getNotification(){
    	return this.notification;
    }
    
	public String undefine(String s){
		if(s.equals("undefined")){
			return null;
		}else
			return s;
	};
	public static void setWebViewUserAgent(WebView webView, String userAgent)
	{

		android.webkit.WebSettings settings = webView.getSettings();
		settings.setUserAgentString(userAgent);
		settings.setJavaScriptEnabled(true);

		//设置参数
		settings.setBuiltInZoomControls(true);
		settings.setCacheMode(android.webkit.WebSettings.LOAD_DEFAULT);
		//settings.setAppCacheEnabled(true);// 设置缓存

		/*
	    try
	    {
	        Method ___getBridge = XWalkView.class.getDeclaredMethod("getBridge");
	        ___getBridge.setAccessible(true);
	        XWalkViewBridge xWalkViewBridge = null;
	        xWalkViewBridge = (XWalkViewBridge)___getBridge.invoke(webView);
	        XWalkSettings xWalkSettings = xWalkViewBridge.getSettings();
	        xWalkSettings.setUserAgentString(userAgent);
	        xWalkSettings.setDomStorageEnabled(true);
	        xWalkSettings.setJavaScriptEnabled(true);
	    }
	    catch (NoSuchMethodException e)
	    {
	        // Could not set user agent
	        e.printStackTrace();
	    }
	    catch(IllegalAccessException e){
	    	e.printStackTrace();
	    }
	    catch(InvocationTargetException e){
	    	e.printStackTrace();
	    }
	    */
	}
	public static String getWebViewUserAgent(WebView webView)
	{
		//String userAgent = "";
//	    try
//	    {
//	        Method ___getBridge = XWalkView.class.getDeclaredMethod("getBridge");
//	        ___getBridge.setAccessible(true);
//	        XWalkViewBridge xWalkViewBridge = null;
//	        xWalkViewBridge = (XWalkViewBridge)___getBridge.invoke(webView);
//	        XWalkSettings xWalkSettings = xWalkViewBridge.getSettings();
//	        userAgent = xWalkSettings.getUserAgentString();
//	    }
//	    catch (NoSuchMethodException e)
//	    {
//	        // Could not set user agent
//	        e.printStackTrace();
//	    }
//	    catch(IllegalAccessException e){
//	    	e.printStackTrace();
//	    }
//	    catch(InvocationTargetException e){
//	    	e.printStackTrace();
//	    }
	  //  return userAgent;
		//return "Mozilla/5.0 (Linux; Android 8.0.0; LND-AL30) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.157 Mobile Safari/537.36";
		return "Mozilla/9.0 (Linux; Android 9.0.0; LND-AL30) AppleWebKit/637.66 (KHTML, like Gecko) Chrome/90.0.3112.90 Safari/637.66";
	}
	
	   /**
     * 微博认证授权回调类。
     * 1. SSO 授权时，需要在 {@link #onActivityResult} 中调用 {@link SsoHandler#authorizeCallBack} 后，
     *    该回调才会被执行。
     * 2. 非 SSO 授权时，当授权结束后，该回调就会被执行。
     * 当授权成功后，请保存该 access_token、expires_in、uid 等信息到 SharedPreferences 中。
     */

	   /*
    class AuthListener implements WeiboAuthListener {
    	 private Oauth2AccessToken mAccessToken;
        @Override
        public void onComplete(Bundle values) {
        	
            // 从 Bundle 中解析 Token
            mAccessToken = Oauth2AccessToken.parseAccessToken(values);
            //从这里获取用户输入的 电话号码信息 
            String  phoneNum =  mAccessToken.getPhoneNum();
            
            Toast.makeText(WebViewManager.INSTANCE.contextActivity, mAccessToken.isSessionValid()+"",Toast.LENGTH_SHORT);
            
            if (mAccessToken.isSessionValid()) {
//                // 显示 Token
//                updateTokenView(false);
                
            	System.out.println("session valid!!!");
            	String uid = mAccessToken.getUid();
            	String token = mAccessToken.getToken();
            	
            	
            	String url = "https://www.veivo.com/weiboClient.jsp?access_token="+token+"&uid="+uid;
            	
            	System.out.println(url);
            	
            	WebView v = WebViewManager.INSTANCE.GetView();
            	if(v!=null){
            		System.out.println("webview is not null");
        			v.loadUrl(url,null);
            	}
            	
                // 保存 Token 到 SharedPreferences
               // AccessTokenKeeper.writeAccessToken(contextActivity, mAccessToken);
//                Toast.makeText(contextActivity, 
//                        R.string.weibosdk_demo_toast_auth_success, Toast.LENGTH_SHORT).show();
            } else {
                // 以下几种情况，您会收到 Code：
                // 1. 当您未在平台上注册的应用程序的包名与签名时；
                // 2. 当您注册的应用程序包名与签名不正确时；
                // 3. 当您在平台上注册的包名和签名与您当前测试的应用的包名和签名不匹配时。
                String code = values.getString("code");
                
            	System.out.println("session invalid");
            	System.out.println("code="+code);

                
//                String message = getString(R.string.weibosdk_demo_toast_auth_failed);
//                if (!TextUtils.isEmpty(code)) {
//                    message = message + "\nObtained the code: " + code;
//                }
//                Toast.makeText(contextActivity, message, Toast.LENGTH_LONG).show();
            }
        }

        @Override
        public void onCancel() {
//            Toast.makeText(WBAuthActivity.this, 
//                   R.string.weibosdk_demo_toast_auth_canceled, Toast.LENGTH_LONG).show();
        	System.out.println("Weibo Canceled!");

        }

        @Override
        public void onWeiboException(WeiboException e) {
//            Toast.makeText(WBAuthActivity.this, 
//                    "Auth exception : " + e.getMessage(), Toast.LENGTH_LONG).show();
        	System.out.println("Weibo Exception!");

        }
    }
	*/

	private static String removeUrl(String commentstr)
    {
        String urlPattern = "((https?|ftp|gopher|telnet|file|Unsure|http):((//)|(\\\\))+[\\w\\d:#@%/;$()~_?\\+-=\\\\\\.&]*)";
        Pattern p = Pattern.compile(urlPattern,Pattern.CASE_INSENSITIVE);
        Matcher m = p.matcher(commentstr);
        int i = 0;
        while (m.find()) {
            commentstr = commentstr.replaceAll(m.group(i),"").trim();
            i++;
        }
        return commentstr;
    }
	/*
	public class myWebClient extends XWalkClient  
	{

		public myWebClient(XWalkView view) {
			super(view);
			// TODO Auto-generated constructor stub
		}  
//	    @Override  
//	    public void onPageStarted(WebView view, String url, Bitmap favicon) {  
//	        // TODO Auto-generated method stub  
//	        super.onPageStarted(view, url, favicon);  
//	    }  
//	  
//	    @Override  
//	    public boolean shouldOverrideUrlLoading(WebView view, String url) {  
//	        // TODO Auto-generated method stub  
//	  
//	        view.loadUrl(url);  
//	        return true;  
//	  
//	    }  
//	  
//	    @Override  
//	    public void onPageFinished(WebView view, String url) {  
//	        // TODO Auto-generated method stub  
//	        super.onPageFinished(view, url);  
//	  
//	      //  progressBar.setVisibility(View.GONE);  
//	    }  
	}*/  
}