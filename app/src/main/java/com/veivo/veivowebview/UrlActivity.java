package com.veivo.veivowebview;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.net.Uri;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.GestureDetector;
import android.view.GestureDetector.SimpleOnGestureListener;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ArrayAdapter;
import android.widget.EditText;
import android.widget.ListPopupWindow;
import android.widget.TextView;

import java.util.HashMap;
import java.util.Locale;

public class UrlActivity extends Activity{
	//private XWalkView mXwalkView;
	private WebView webView;
	private ListPopupWindow mListPopupWindow;
	private Context mContext;
	private TextView mButton;
	private String language;
	private String isShare;
	private String color;
	private String notitle;
	private String appid;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		String _url = null;
		Bundle extras = getIntent().getExtras();
		if(extras!=null){
			_url = (String) extras.get("url");
			language = (String) extras.get("language");
			isShare = (String) extras.get("share");
			color = (String) extras.get("color");
			notitle = (String) extras.getString("notitle");
			appid = (String) extras.getString("appid");
		}
		if(color==null)
			color="#284F83";
		
		//
		int colorResInt = Color.parseColor(color);
		 StatusBarUtils.setWindowStatusBarColor(this, colorResInt);
		//
		
		Intent intent = this.getIntent();
		Uri uri = intent.getData();
		if(uri!=null){
			_url = uri.toString();
			isShare = "1";
		}
		super.onCreate(savedInstanceState);
		// XWalkPreferences.setValue(XWalkPreferences.ANIMATABLE_XWALK_VIEW,
		// true);
		// requestWindowFeature(Window.FEATURE_CUSTOM_TITLE);
		// requestWindowFeature(Window.PROGRESS_VISIBILITY_ON);
		// mXwalkView = new XWalkView(this, (AttributeSet)null);
		// setContentView(mXwalkView);
		setContentView(R.layout.activity_url);
		
		findViewById(R.id.urlPageTitle).setBackgroundColor(Color.parseColor(color));
		if(notitle!=null&&notitle.equals("1")){
			findViewById(R.id.urlPageTitle).setVisibility(View.INVISIBLE);
		}
		
		if(isShare==null||isShare.equals("0")){
			findViewById(R.id.moreButton).setVisibility(View.INVISIBLE);
		}
		findViewById(R.id.urlReply).setVisibility(View.INVISIBLE);
		findViewById(R.id.urlChangeFont).setVisibility(View.INVISIBLE);
		findViewById(R.id.replyButton).setOnClickListener(new OnClickListener(){

			@Override
			public void onClick(View v) {
				String text = webView.getTitle()+" "+webView.getUrl();
				String c = ((TextView)findViewById(R.id.replyText)).getText().toString();
				if(c!=null&&!c.trim().equals("")){
					String script = "Veivo.commentAndShare(\""+text+"\",\""+c+"\",function(){alert(App.locale.appbase_message_send_ok);});";
					WebViewManager.INSTANCE.webViewEval(script);
					transitionFinish();
				}
			}
			
		});
		
		Window mWindow = getWindow();
		mWindow.setFeatureInt(Window.FEATURE_PROGRESS,
				Window.PROGRESS_VISIBILITY_ON);

		webView = findViewById(R.id.urlWebView);
		//显示Loading...
		webView.setWebChromeClient(new WebChromeClient() {
			@Override
			public void onProgressChanged(WebView view, int progress) {
				// Make the bar disappear after URL is loaded, and changes
				// string to Loading...
				TextView tv = (TextView) findViewById(R.id.urlTitle);
				tv.setText(R.string.url_loading);
				UrlActivity.this.setProgress(progress * 100); // Make the bar
																// disappear
																// after URL is
																// loaded

				// Return the app name after finish loading
				//if (progress == 100)
				if(progress > 60)
					tv.setText(view.getTitle());
			}
		});


		String ua = WebViewManager.getWebViewUserAgent(webView)+"(android app) "+MainActivity.veivoClientUA+" "+language;
		WebViewManager.setWebViewUserAgent(webView,ua);

		HashMap h = new HashMap();
		//"User-Agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.90 Safari/537.36"
		h.put("User-Agent", "Mozilla/9.0 (Linux; Android 9.0.0; LND-AL30) AppleWebKit/637.66 (KHTML, like Gecko) Chrome/90.0.3112.90 Safari/637.66");

		webView.getSettings().setJavaScriptEnabled(true);
		webView.getSettings().setJavaScriptCanOpenWindowsAutomatically(true);
		webView.getSettings().setSupportMultipleWindows(true);
		webView.getSettings().setDomStorageEnabled(true);
		webView.setWebViewClient(new WebViewClient());
		//webView.setWebChromeClient(new WebChromeClient());

		webView.loadUrl(_url, h);
		//mXwalkView.evaluateJavascript("document.body.style.transform=\"scale(2.5)\";", null);
		bindingEvent();
		
		detector = new GestureDetector(this, new GestureListener());  
	}

	@Override
	protected void onDestroy() {
		super.onDestroy();
		// XWalkPreferences.setValue(XWalkPreferences.ANIMATABLE_XWALK_VIEW,
		// false);
		if (webView != null) {
			webView.destroy();
		}
	}

	@Override
	public void onBackPressed() {
		if(webView.canGoBack()){
			webView.goBack();
		}else{
			transitionFinish();			
		}
	}

	private void bindingEvent() {
		TextView back = (TextView) findViewById(R.id.backToMain);
		back.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				if(webView.canGoBack()){
					webView.goBack();
				}else{
					transitionFinish();			
				}
			}
		});
		if(isShare!=null&&isShare.equals("1")){
			createShareButton();
		}
	}

	private void createShareButton() {
			mContext = this;
			Resources resource=mContext.getResources();
			
			Configuration config = resource.getConfiguration();
			DisplayMetrics dm = resource.getDisplayMetrics();
			if(language!=null&&language.toLowerCase().indexOf("en")>=0)
				config.locale = Locale.ENGLISH;
			else if(language!=null&&language.toLowerCase().indexOf("zh")>=0)
				config.locale = Locale.SIMPLIFIED_CHINESE;
			else
				config.locale = getResources().getConfiguration().locale;//use os locale
			resource.updateConfiguration(config, dm);
			
			final String itmes[] = { 
					resource.getString(R.string.url_sharetostatus),
					resource.getString(R.string.url_pushtogroup),
					resource.getString(R.string.url_messageto),
					resource.getString(R.string.url_comment),
					resource.getString(R.string.url_cloudnote),
	//				resource.getString(R.string.url_savetophoto),
	//				resource.getString(R.string.url_sharephoto)
	//				resource.getString(R.string.url_changefont)
					//resource.getString(R.string.url_appchat),
					//resource.getString(R.string.url_appprofile),
					resource.getString(R.string.url_close)
					};
			mListPopupWindow = new ListPopupWindow(mContext);
			mListPopupWindow.setAdapter(new ArrayAdapter<String>(mContext,
					R.layout.url_item, itmes));
			//findViewById(R.layout.url_item).setBackgroundColor(Color.parseColor(color));

			int outerwidth=getResources().getDisplayMetrics().widthPixels;
			if(outerwidth>1000)
				outerwidth=1000;
			if(outerwidth<600)
				outerwidth=600;
			mListPopupWindow.setWidth(outerwidth/2);
			//mListPopupWindow.setHeight(400);
			mListPopupWindow.setModal(true);
			//mListPopupWindow.setVerticalOffset(10);
			mListPopupWindow.setBackgroundDrawable(new ColorDrawable(Color.parseColor(color)));
			mListPopupWindow.setOnItemClickListener(new OnItemClickListener() {
				@Override
				public void onItemClick(AdapterView<?> arg0, View arg1,
						int position, long arg3) {
					String text = webView.getTitle()+" "+webView.getUrl();
					String script = null;
//					Toast.makeText(mContext, "�����" + itmes[position]+" isShowing:"+mListPopupWindow.isShowing(),
//							Toast.LENGTH_SHORT).show();
					switch (position){
						case 0 :
							script = "Veivo.sendAsMyTweet(\""+text+"\",function(){alert(App.locale.appbase_message_send_ok);});";
							WebViewManager.INSTANCE.webViewEval(script);
							transitionFinish();
							break;
						case 1 :
							script = "Veivo.pushContent(\""+text+"\",function(){},function(){alert(App.locale.appbase_message_send_ok);});";
							WebViewManager.INSTANCE.webViewEval(script);
							transitionFinish();
							break;
						case 2 :
							script = "Veivo.shareByMessage(\""+text+"\",function(){},function(){alert(App.locale.appbase_message_send_ok);});";
							WebViewManager.INSTANCE.webViewEval(script);
							transitionFinish();
							break;
						case 3 :
							findViewById(R.id.urlChangeFont).setVisibility(View.INVISIBLE);
							findViewById(R.id.urlReply).setVisibility(View.VISIBLE);
							//bind close event
							findViewById(R.id.closeButton).setOnClickListener(new OnClickListener() {
								@Override
								public void onClick(View v) {
									findViewById(R.id.urlReply).setVisibility(View.INVISIBLE);
								}
							});
							((EditText)findViewById(R.id.replyText)).addTextChangedListener(new TextWatcher() {

								@Override
								public void beforeTextChanged(CharSequence s,
										int start, int count, int after) {
									
								}

								@Override
								public void onTextChanged(CharSequence s,
										int start, int before, int count) {
									String a = s.toString();
									if(a!=null&&!a.equals("")){
										findViewById(R.id.replyButton).setAlpha(1);
										//enable send
									}else{
										//disable send
										findViewById(R.id.replyButton).setAlpha(0.5f);
									}
								}

								@Override
								public void afterTextChanged(Editable s) {

								}
							});
							break;
						case 4 :
							script = "Veivo.sendAsNote(\""+text+"\",function(){alert(App.locale.appbase_message_send_ok);});";
							WebViewManager.INSTANCE.webViewEval(script);
							transitionFinish();
							break;
//						case 5 :
//							findViewById(R.id.urlReply).setVisibility(View.INVISIBLE);
//							findViewById(R.id.urlChangeFont).setVisibility(View.VISIBLE);
//							findViewById(R.id.close_changeFont).setOnClickListener(new OnClickListener() {
//								@Override
//								public void onClick(View v) {
//									findViewById(R.id.urlChangeFont).setVisibility(View.INVISIBLE);
//								}
//							});
//							break;
//						case 5:
//							script = "Veivo.appchat(\""+appid+"\",function(){alert(App.locale.appbase_message_send_ok);});";
//							WebViewManager.INSTANCE.webViewEval(script);
//							transitionFinish();
//							break;
//						case 6:
//							script = "handle.toAppProfile(undefined,\""+appid+"\");";
//							WebViewManager.INSTANCE.webViewEval(script);
//							transitionFinish();
//							break;
						case 5 :
							mListPopupWindow.dismiss();
							transitionFinish();
							break;
					}
					mListPopupWindow.dismiss();
				}
			});
			
			mButton = (TextView) findViewById(R.id.moreButton);
			// ָ��anchor
			mListPopupWindow.setAnchorView(mButton);
			mButton.setOnClickListener(new OnClickListener() {
				@Override
				public void onClick(View v) {
						mListPopupWindow.show();
				}
			});
	}

	private void transitionFinish() {
		webView.stopLoading();
		finish();
		overridePendingTransition(R.anim.in_from_left, R.anim.out_to_right);
	}
	
	    private GestureDetector detector;
	    
	    @Override
	    public boolean dispatchTouchEvent(MotionEvent event){
	        this.detector.onTouchEvent(event);
	        return super.dispatchTouchEvent(event);
	    }
	    class GestureListener extends SimpleOnGestureListener  
	    {  
	  
	        @Override  
	        public boolean onDoubleTap(MotionEvent e)  
	        {  
	            // TODO Auto-generated method stub  
	            Log.i("TEST", "onDoubleTap");  
	            return super.onDoubleTap(e);  
	        }  
	  
	        @Override  
	        public boolean onDown(MotionEvent e)  
	        {  
	            // TODO Auto-generated method stub  
	            Log.i("TEST", "onDown");  
	            return super.onDown(e);  
	        }  
	  
	        @Override  
	        public boolean onFling(MotionEvent e1, MotionEvent e2, float velocityX,  
	                float velocityY)  
	        {  
	            // TODO Auto-generated method stub  
	            Log.i("TEST", "onFling:velocityX = " + velocityX + " velocityY" + velocityY); 
	            if(Math.abs(velocityX)>Math.abs(velocityY)+30&&velocityX>0){
	            	//transitionFinish();
	            }
	            return super.onFling(e1, e2, velocityX, velocityY);  
	        }  
	  
	        @Override  
	        public void onLongPress(MotionEvent e)  
	        {  
	            // TODO Auto-generated method stub  
	            Log.i("TEST", "onLongPress");  
	            super.onLongPress(e);  
	        }  
	  
	        @Override  
	        public boolean onScroll(MotionEvent e1, MotionEvent e2,  
	                float distanceX, float distanceY)  
	        {  
	            // TODO Auto-generated method stub  
	            Log.i("TEST", "onScroll:distanceX = " + distanceX + " distanceY = " + distanceY);  
	            return super.onScroll(e1, e2, distanceX, distanceY);  
	        }  
	  
	        @Override  
	        public boolean onSingleTapUp(MotionEvent e)  
	        {  
	            // TODO Auto-generated method stub  
	            Log.i("TEST", "onSingleTapUp");  
	            return super.onSingleTapUp(e);  
	        }  
	          
	    }

}