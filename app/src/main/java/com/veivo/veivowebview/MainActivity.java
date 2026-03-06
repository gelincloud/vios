package com.veivo.veivowebview;


import static android.content.ContentValues.TAG;

import android.annotation.SuppressLint;
import android.annotation.TargetApi;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.BroadcastReceiver;
import android.content.ClipData;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.res.Configuration;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Base64;
import android.util.Log;
import android.view.Menu;
import android.webkit.ValueCallback;
import android.widget.EditText;
import android.widget.TextView;
import android.webkit.WebView;

import com.facebook.Profile;
import com.facebook.login.LoginManager;
//import com.firebase.ui.auth.IdpResponse;
import com.google.android.gms.auth.api.signin.GoogleSignIn;
import com.google.android.gms.auth.api.signin.GoogleSignInAccount;
import com.google.android.gms.common.api.ApiException;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.Task;
//import com.sina.weibo.sdk.api.share.BaseResponse;
//import com.sina.weibo.sdk.api.share.IWeiboHandler;
//import com.sina.weibo.sdk.api.share.IWeiboShareAPI;
//import com.sina.weibo.sdk.api.share.WeiboShareSDK;
//import com.sina.weibo.sdk.auth.AuthInfo;
//import com.sina.weibo.sdk.auth.sso.SsoHandler;
//import com.sina.weibo.sdk.constant.WBConstants;

import com.google.firebase.auth.AuthCredential;
import com.google.firebase.auth.AuthResult;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.auth.OAuthProvider;
import com.google.firebase.auth.TwitterAuthProvider;
import com.sina.weibo.sdk.auth.AuthInfo;
import com.sina.weibo.sdk.openapi.IWBAPI;
import com.sina.weibo.sdk.openapi.SdkListener;
import com.sina.weibo.sdk.openapi.WBAPIFactory;
import com.tencent.mm.opensdk.modelbase.BaseReq;
import com.tencent.mm.opensdk.modelbase.BaseResp;
import com.tencent.mm.opensdk.modelmsg.SendAuth;
import com.tencent.mm.opensdk.openapi.IWXAPI;
import com.tencent.mm.opensdk.openapi.IWXAPIEventHandler;
import com.tencent.mm.opensdk.openapi.WXAPIFactory;
//import com.tencent.mm.sdk.modelbase.BaseReq;
//import com.tencent.mm.sdk.modelbase.BaseResp;
//import com.tencent.mm.sdk.modelmsg.SendAuth;
//import com.tencent.mm.sdk.openapi.IWXAPI;
//import com.tencent.mm.sdk.openapi.IWXAPIEventHandler;
//import com.tencent.mm.sdk.openapi.WXAPIFactory;

import android.view.View;
import android.widget.Toast;

import androidx.annotation.NonNull;

import com.facebook.AccessToken;
import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.FacebookSdk;
import com.facebook.appevents.AppEventsLogger;
import com.facebook.login.LoginResult;
import com.facebook.login.widget.LoginButton;

//import com.twitter.sdk.android.core.Callback;
//import com.twitter.sdk.android.core.Result;
//import com.twitter.sdk.android.core.Twitter;
//import com.twitter.sdk.android.core.TwitterException;
//import com.twitter.sdk.android.core.TwitterSession;
//import com.twitter.sdk.android.core.identity.TwitterLoginButton;

//import org.xwalk.core.XWalkPreferences;
//import org.xwalk.core.XWalkView;

import java.io.IOException;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.util.Locale;
import java.util.UUID;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

import cn.jpush.android.api.JPushInterface;
//import okhttp3.Call;
//import okhttp3.Callback;
//import okhttp3.FormBody;
//import okhttp3.HttpUrl;
//import okhttp3.OkHttpClient;
//import okhttp3.Request;
//import okhttp3.Response;

@SuppressLint("JavascriptInterface")
public class MainActivity extends Activity implements IWXAPIEventHandler
	//	,IWeiboHandler.Response
	{
	//    @ViewInject(id = R.id.facebook)
	public LoginButton bt_facebook;
//	public CallbackManager mCallbackManager;
	private AccessToken mAccessToken;
	//private WebView webView;

	//jpush
	public static final String MESSAGE_RECEIVED_ACTION = "com.example.jpushdemo.MESSAGE_RECEIVED_ACTION";
	private MessageReceiver mMessageReceiver;
	public static final String KEY_MESSAGE = "message";
	public static final String KEY_EXTRAS = "extras";
	public static boolean isForeground = false;
	public IWXAPI api;

	private EditText msgText;

//	public XWalkView mXwalkView;
	public WebView webview;
	protected String regId;
    /**
     * Intent used to display a message in the screen.
     */
    final String DISPLAY_MESSAGE_ACTION =
            "com.veivo.veivowebview.DISPLAY_MESSAGE";
    TextView mDisplay;
    protected AsyncTask<Void, Void, Void> mRegisterTask;
    
    private String loginScript=null;


	public static final String APP_KY = "1784628633";
	//public static final String APP_KY = "1659628660";
	//private static final String REDIRECT_URL = "https://api.weibo.com/oauth2/default.html";
	//private static final String REDIRECT_URL = "https://api.weibo.com/oauth2/authorize?client_id=1784628633&redirect_uri=https://en.veivo.com";

		public static final  String REDIRECT_URL="http://www.sina.com";
		//public static final  String REDIRECT_URL="https://en.veivo.com";
	public IWBAPI mWBAPI;

	public static final String SCOPE =
            "email,direct_messages_read,direct_messages_write,"
            + "friendships_groups_read,friendships_groups_write,statuses_to_me_read,"
            + "follow_app_official_microblog," + "invitation_write";
		//public static final String SCOPE = "all";
    private AuthInfo mAuthInfo;
//    public SsoHandler mSsoHandler;
//
//    public IWeiboShareAPI  mWeiboShareAPI = null;

	public static String veivoClientUA = "veivo2";

	public static  int RC_SIGN_IN = 999;


	public static ValueCallback<Uri> uploadMessage;
	public static ValueCallback<Uri[]> uploadMessageAboveL;

	public CallbackManager callbackManager;

	public Handler handler = new Handler() {
		@Override
		public void handleMessage(Message msg) {
			if (msg.what == 0) {
				bt_facebook.performClick();
			}
		}
	};

	protected FirebaseAuth firebaseAuth = FirebaseAuth.getInstance();
	protected  OAuthProvider.Builder provider;

		protected FirebaseAuth mAuth;

		protected static final int RC_SIGN_IN_TWITTER = 123;
		protected static final String TWITTER_PROVIDER = "twitter";

	//	protected TwitterLoginButton twitterLoginButton;

		@Override
	protected void onCreate(Bundle savedInstanceState) {
//		super.onCreate(savedInstanceState);
		Bundle extras = getIntent().getExtras();

		//判断有没有安装fb
		//if (WebViewManager.isFBAppInstalled(this)) {
		if(true){
			veivoClientUA="andveivo222";
		}


		//
			mAuth = FirebaseAuth.getInstance();



		//第一行，初始化FacebookSdk,
		FacebookSdk.sdkInitialize(getApplicationContext());

		AppEventsLogger.activateApp(getApplication());
		callbackManager = CallbackManager.Factory.create();
		LoginManager.getInstance().registerCallback(callbackManager,
				new FacebookCallback<LoginResult>() {
					@Override
					public void onSuccess(LoginResult loginResult) {
						try {
							// App code
							// Get the user ID
							//	String userId = loginResult.getAccessToken().getUserId();

// Get user id
							String userId = loginResult.getAccessToken().getUserId();

// Get user name
							//String userName = loginResult.getAccessToken().getUserName();

// Get user profile picture
							Profile profile = Profile.getCurrentProfile();
							String userName = profile.getName();
							String profilePicture = profile.getProfilePictureUri(200, 200).toString();
							//											String userName = object.getString("name");
							String _url = "https://en.veivo.com/fb.jsp?uid=" + userId + "&name=" + userName + "&picurl=" + profilePicture;
							WebViewManager.INSTANCE.changeUrl(_url);

							// Get the user profile picture
							//String profilePicture = "https://graph.facebook.com/" + userId + "/picture?type=large";

// Get the user name
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

						}catch (Exception e){
							Toast.makeText(MainActivity.this, e.toString(),
									Toast.LENGTH_LONG).show();
						}


					}

					@Override
					public void onCancel() {
						// App code
					}

					@Override
					public void onError(FacebookException exception) {
						// App code
					}
				});

		//end facebook
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);


			//初始化Twitter API
			// Initialize OkHttpClient


			// 初始化 Firebase 实例
			FirebaseAuth mAuth = FirebaseAuth.getInstance();

// 创建 Twitter 登录按钮（或其他触发登录的 UI 元素）
			// Initialize Twitter authentication
//			String TWITTER_CONSUMER_KEY = "zm2r1SPJjciC5EQjZqPFX2pMs";
//			String TWITTER_CONSUMER_SECRET="ZThMTkIailybggEzSQZbTKZLsRIpidRw2Pe5ej7AoaMxy6wdeN";
//			TwitterAuthConfig authConfig = new TwitterAuthConfig(
//					TWITTER_CONSUMER_KEY,
//					TWITTER_CONSUMER_SECRET);
//
//			TwitterConfig twitterConfig = new TwitterConfig.Builder(this)
//					.twitterAuthConfig(authConfig)
//					.build();
//			Twitter.initialize(twitterConfig);
//
//			// Set up Twitter login button
//			 twitterLoginButton = findViewById(R.id.twitter_login_button);
//
//			Callback callback = new Callback<TwitterSession>() {
//				@Override
//				public void success(Result<TwitterSession> result) {
//					handleTwitterSession(result.data);
//				}
//
//				@Override
//				public void failure(TwitterException exception) {
//					//Log.e(TAG, "Twitter login failed", exception);
//					Toast.makeText(MainActivity.this, "Twitter login failed", Toast.LENGTH_LONG).show();
//				}
//			};
//			twitterLoginButton.setCallback(callback);

			// find the Twitter login button

			provider = OAuthProvider.newBuilder("twitter.com");

			Task<AuthResult> pendingResultTask = firebaseAuth.getPendingAuthResult();
			if (pendingResultTask != null) {
				// There's something already here! Finish the sign-in for your user.
				pendingResultTask
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
			} else {
				// There's no pending result so you need to start the sign-in flow.
				// See below.
			}




//			String TWITTER_CONSUMER_KEY = "94w0HqspOouSMg4nOgUrelQIC";
//			String TWITTER_CONSUMER_SECRET="RMM2q6AEHClsSp5zxLlUDyGIJJWYvQYmqRV05LxJoytPdI6YH5";
//			TwitterAuthConfig authConfig = new TwitterAuthConfig(
//					TWITTER_CONSUMER_KEY,
//					TWITTER_CONSUMER_SECRET);
//
//			TwitterConfig twitterConfig = new TwitterConfig.Builder(this)
//					.twitterAuthConfig(authConfig)
//					.build();
//			Twitter.initialize(twitterConfig);
//			twitterLoginButton = findViewById(R.id.twitter_login_button);
//
//			// set up a callback to handle successful login attempts
//			twitterLoginButton.setCallback(new Callback<TwitterSession>() {
//				@Override
//				public void success(Result<TwitterSession> result) {
//					// get the Twitter session and auth token
//					TwitterSession session = result.data;
//					TwitterAuthToken authToken = session.getAuthToken();
//
//					// print some debug info
//					Log.i(TAG, "User ID: " + session.getUserId());
//					Log.i(TAG, "Screen name: " + session.getUserName());
//					Log.i(TAG, "Token: " + authToken.token);
//					Log.i(TAG, "Secret: " + authToken.secret);
//
//					// show a toast message to indicate successful login
//					Toast.makeText(MainActivity.this, "Logged in as " + session.getUserName(), Toast.LENGTH_SHORT).show();
//				}
//
//				@Override
//				public void failure(TwitterException e) {
//					// display an error message if login fails
//					Log.e(TAG, "Twitter Login Failure", e);
//					Toast.makeText(MainActivity.this, "Twitter Login Failure", Toast.LENGTH_SHORT).show();
//				}
//			});
			//end twitter

//		mCallbackManager = CallbackManager.Factory.create();
//		//找到login, button
//		bt_facebook = (LoginButton) findViewById(R.id.facebook);


//		bt_facebook.registerCallback(mCallbackManager, new FacebookCallback<LoginResult>() {
//			@Override
//			public void onSuccess(LoginResult loginResult) {
//				Log.e("abc", "onSuccess");
//			}
//
//			@Override
//			public void onCancel() {
//				Log.e("abc", "onCancel");
//			}
//
//			@Override
//			public void onError(FacebookException error) {
//				Log.e("abc", "onError");
//			}
//		});

//		Intent intent = new Intent();  
//        //制定intent要启动的类  
//        intent.setClass(MainActivity.this, com.veivo.veivowebview.wxapi.WXEntryActivity.class);
//        //启动一个新的Activity  
//        startActivity(intent);  
//        //关闭当前的  
////        MainActivity.this.finish();  

//		android.view.Window window = getWindow();
//		int flag=android.view.WindowManager.LayoutParams.;
//		window.setFlags(flag, flag);
        
		System.out.println("MainActivity create.");
		
		
		
//    	api = WXAPIFactory.createWXAPI(this, null);
//		api.registerApp(WebViewManager.APPID);


		api = WXAPIFactory.createWXAPI(this, WebViewManager.APPID, false);
		api.registerApp(WebViewManager.APPID);

		//api.handleIntent(this.getIntent(), this);
		

		/*
		mAuthInfo = new AuthInfo(this, "1784628633", "http://www.sina.com", SCOPE);
        mSsoHandler = new SsoHandler(MainActivity.this, mAuthInfo);

        // 创建微博分享接口实例
        mWeiboShareAPI = WeiboShareSDK.createWeiboAPI(this, "1784628633");
        
        // 注册第三方应用到微博客户端中，注册成功后该应用将显示在微博的应用列表中。
        // 但该附件栏集成分享权限需要合作申请，详情请查看 Demo 提示
        // NOTE：请务必提前注册，即界面初始化的时候或是应用程序初始化时，进行注册
        mWeiboShareAPI.registerApp();
        
		// 当 Activity 被重新初始化时（该 Activity 处于后台时，可能会由于内存不足被杀掉了），
        // 需要调用 {@link IWeiboShareAPI#handleWeiboResponse} 来接收微博客户端返回的数据。
        // 执行成功，返回 true，并调用 {@link IWeiboHandler.Response#onResponse}；
        // 失败返回 false，不调用上述回调
        if (savedInstanceState != null) {
            mWeiboShareAPI.handleWeiboResponse(getIntent(), this);
        }

		 */
		initSdk();
		
		JPushInterface.setDebugMode(true);
        JPushInterface.init(this);
		
		String _url=null;
		String afterLoad = null;
		if(extras!=null){
			_url = (String)extras.get("url");
			afterLoad = (String)extras.get("afterLoad");
			Log.i("afterLoad", afterLoad==null?"":afterLoad);
		}
		if(_url==null)
			_url="https://en.veivo.com";
		
		
		
//		XWalkPreferences.setValue(XWalkPreferences.ANIMATABLE_XWALK_VIEW, true);		
//		XWalkPreferences.setValue(XWalkPreferences.REMOTE_DEBUGGING, true);
	    setContentView(R.layout.activity_main);
	    //mXwalkView = (XWalkView) findViewById(R.id.activity_main);
		webview = findViewById(R.id.activity_main);

	    
//		setContentView(R.layout.shared_activity_main);
//	    sharedXwalkView = (SharedXWalkView) findViewById(R.id.shared_activity_main);
	    
		Locale current = getResources().getConfiguration().locale;
		
		//WebViewManager.INSTANCE.initMainWebView(this,mXwalkView,current,_url,afterLoad); // simply call init and let the manager handle the re-binding of the WebView to the current activity layout
		WebViewManager.INSTANCE.initMainWebView(this,webview,current,_url,afterLoad);

		//		WebViewManager.INSTANCE.initMainWebView(this,sharedXwalkView,current,_url,afterLoad); // simply call init and let the manager handle the re-binding of the WebView to the current activity layout
		registerMessageReceiver();
		
		
	}



		//init sdk
		private void initSdk1() {
			AuthInfo authInfo = new AuthInfo(this, APP_KY, REDIRECT_URL, SCOPE);
			mWBAPI = WBAPIFactory.createWBAPI(this);
			mWBAPI.registerApp(this, authInfo);
		}

	private void initSdk() {
		AuthInfo authInfo = new AuthInfo(this, APP_KY, REDIRECT_URL, SCOPE);
		mWBAPI = WBAPIFactory.createWBAPI(this); // 传Context即可，不再依赖于Activity
		mWBAPI.registerApp(this, authInfo, new SdkListener() {
			@Override
			public void onInitSuccess() {
				// SDK初始化成功回调，成功一次后再次初始化将不再有任何回调
				System.out.println("##########微博初始化成功###########");
			}
			@Override
			public void onInitFailure(Exception e) { // SDK初始化失败回调
				//
				System.out.println("##########微博初始化失败###########");
			}
		});
	}

	public static ValueCallback<Uri> mUploadMessage;    
	public final static int FILECHOOSER_RESULTCODE=1;

	public void getFaceBookToken(View view) {
		AccessToken mAccessToken = AccessToken.getCurrentAccessToken();
		Log.e("token", "token :" + mAccessToken.getToken() + "," + "user_id" + mAccessToken.getUserId());
	}

	@Override
	 protected void onActivityResult(int requestCode, int resultCode,    
	                                    Intent intent) {



		super.onActivityResult(requestCode, resultCode, intent);
		try {
			callbackManager.onActivityResult(requestCode, resultCode, intent);
		}catch(Exception e){
			Toast.makeText(this, e.toString(),
					Toast.LENGTH_LONG).show();
		}
		if(requestCode==64206){
			return;
		}
//		callbackManager.onActivityResult(requestCode,
//				resultCode, intent);

//		new AlertDialog.Builder(this).setTitle("onActivityResult信息提示")//设置对话框标题
//
//				.setMessage("是否需要更换xxx？")
//				.setPositiveButton("是", new DialogInterface.OnClickListener() {//添加确定按钮
//
//					@Override
//					public void onClick(DialogInterface dialog, int which) {//确定按钮的响应事件，点击事件没写，自己添加
//
//					}
//				}).setNegativeButton("否", new DialogInterface.OnClickListener() {//添加返回按钮
//
//					@Override
//					public void onClick(DialogInterface dialog, int which) {//响应事件，点击事件没写，自己添加
//
//					}
//
//				}).show();//在按键响应事件中显示此对话框

		 //Toast.makeText(this, "activity result", Toast.LENGTH_SHORT);
		 
//	  if(requestCode==FILECHOOSER_RESULTCODE)    
//	  {    
//	   if (null == mUploadMessage) return;    
//	            Uri result = intent == null || resultCode != RESULT_OK ? null    
//	                    : intent.getData();    
//	            mUploadMessage.onReceiveValue(result);    
//	            mUploadMessage = null;    
//	  }



		 /*
		 if(requestCode==FILECHOOSER_RESULTCODE)  
		  {  
		   if (null == mUploadMessage) return;  
		            Uri result = intent == null || resultCode != RESULT_OK ? null  
		                    : intent.getData();  
		            mUploadMessage.onReceiveValue(result);  
		            mUploadMessage = null;  
		  }
	  if (mXwalkView != null) {
          mXwalkView.onActivityResult(requestCode, resultCode, intent);
      }
      */

		 if (requestCode == FILECHOOSER_RESULTCODE) {
			 if (null == uploadMessage && null == uploadMessageAboveL) return;
			 Uri result = intent == null || resultCode != RESULT_OK ? null : intent.getData();
			 if (uploadMessageAboveL != null) {
				 onActivityResultAboveL(requestCode, resultCode, intent);
			 } else if (uploadMessage != null) {
				 uploadMessage.onReceiveValue(result);
				 uploadMessage = null;
			 }
		 }

		if (requestCode == RC_SIGN_IN) {
			//The Task returned from this call is always completed, no need to attach a listener.
			Task<GoogleSignInAccount> task = GoogleSignIn.getSignedInAccountFromIntent(intent);
			handleSignInResult(task);
		}

	  
	// SSO 授权回调
      // 重要：发起 SSO 登陆的 Activity 必须重写 onActivityResults
//      if (mSsoHandler != null) {
//          mSsoHandler.authorizeCallBack(requestCode, resultCode, intent);
//      }
		if (mWBAPI != null) {
			mWBAPI.authorizeCallback(this,requestCode, resultCode, intent);
		}

		// Handle FirebaseUI authentication result
//		if (requestCode == RC_SIGN_IN_TWITTER && resultCode == RESULT_OK) {
//			FirebaseUser firebaseUser = FirebaseAuth.getInstance().getCurrentUser();
//			if (firebaseUser != null) {
//				// Use OkHttpClient to get Twitter access token and secret
//				Request request = new Request.Builder()
//						.url("https://api.twitter.com/oauth/access_token")
//						.header("Authorization", createAuthorizationHeader())
//						.post(new FormBody.Builder()
//								.add("oauth_verifier", intent.getStringExtra("oauth_verifier"))
//								.build())
//						.build();
//				mOkHttpClient.newCall(request).enqueue(new Callback() {
//					@Override
//					public void onFailure(@NonNull Call call, @NonNull IOException e) {
//						// Failed to get Twitter access token and secret
//					}
//
//					@Override
//					public void onResponse(@NonNull Call call, @NonNull Response response) throws IOException {
//						String responseBodyString = response.body().string();
//						String accessToken = "";
//						String secret = "";
//
//						// Parse Twitter access token and secret from response body
//						for (String param : responseBodyString.split("&")) {
//							String[] keyValue = param.split("=");
//							if (keyValue[0].equals("oauth_token")) {
//								accessToken = keyValue[1];
//							} else if (keyValue[0].equals("oauth_token_secret")) {
//								secret = keyValue[1];
//							}
//						}
//
//						// Create a Firebase custom token using Twitter access token and secret
//						OAuthProvider.Builder providerBuilder = OAuthProvider.newBuilder(TWITTER_PROVIDER);
//						providerBuilder.addCustomParameter("access_token_key", accessToken);
//						providerBuilder.addCustomParameter("access_token_secret", secret);
//						OAuthProvider oAuthProvider = providerBuilder.build();
//						FirebaseAuth.getInstance()
//								.signInWithCredential(
//										oAuthProvider.getCredential(null,null,null))
//								.addOnCompleteListener(task -> {
//									if (task.isSuccessful()) {
//										// Firebase authentication successful
//										Toast.makeText(MainActivity.this, "SUCCESS",Toast.LENGTH_LONG).show();
//									} else {
//										// Firebase authentication failed
//										Toast.makeText(MainActivity.this, "SUCCESS",
//												Toast.LENGTH_LONG).show();
//									}
//								});
//					}
//				});
//			}
//		}

		//((TwitterLoginButton)findViewById(R.id.login_button)).onActivityResult(requestCode, resultCode, intent);

		//twitterLoginButton.onActivityResult(requestCode, resultCode, intent);


		

	}



	private void handleSignInResult(Task<GoogleSignInAccount> completedTask) {
		try {
			GoogleSignInAccount account = completedTask.getResult(ApiException.class);
			String photoUrl = account.getPhotoUrl().toString();
			String uid = account.getId();
			String name = account.getDisplayName();
			System.out.println("#######sign in result##########");
			System.out.println(photoUrl);
			System.out.println(name);
			System.out.println(uid);
			System.out.println("#######sign in result##########");

			String _url="https://en.veivo.com/g.jsp?uid="+uid+"&name="+name+"&picurl="+photoUrl;
			WebViewManager.INSTANCE.changeUrl(_url);
			// Signed in successfully, show authenticated UI.
			//updateUI(account);
		} catch (ApiException e) {
			// The ApiException status code indicates the detailed failure reason.
			// Please refer to the GoogleSignInStatusCodes class reference for more information.
			//Log.w(TAG, "signInResult:failed code=" + e.getStatusCode());
			//updateUI(null);
			e.printStackTrace();
		}
	}

	@TargetApi(Build.VERSION_CODES.O)
	private void onActivityResultAboveL(int requestCode, int resultCode, Intent intent) {
		if (requestCode != FILECHOOSER_RESULTCODE || uploadMessageAboveL == null)
			return;
		Uri[] results = null;
		if (resultCode == Activity.RESULT_OK) {
			if (intent != null) {
				String dataString = intent.getDataString();
				ClipData clipData = intent.getClipData();
				if (clipData != null) {
					results = new Uri[clipData.getItemCount()];
					for (int i = 0; i < clipData.getItemCount(); i++) {
						ClipData.Item item = clipData.getItemAt(i);
						results[i] = item.getUri();
					}
				}
				if (dataString != null)
					results = new Uri[]{Uri.parse(dataString)};
			}
		}
		uploadMessageAboveL.onReceiveValue(results);
		uploadMessageAboveL = null;
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

//		if(mMessageReceiver!=null)
//        	unregisterReceiver(mMessageReceiver);
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
		     	    if(sharedTitle==null) 
		     	    	   sharedTitle = intent.getStringExtra(Intent.EXTRA_SUBJECT);
		     	    if(sharedTitle!=null)
		     	    	sharedText=sharedTitle+sharedText;
		     	    if (sharedText != null) {
						String script = "javascript:Veivo.pushContent0(\""+sharedText+"\",function(){},function(){});";
						webview.loadUrl(script, null);
		     	    }
		        }
		}else{
			WebViewManager.INSTANCE.getNotification().touchNotification();
		}
		

		String _url=null;
		if(extras!=null){
			String code = (String)extras.get("code");
	        //Toast.makeText(this, "New Intent. code="+code, Toast.LENGTH_SHORT).show();
			if(code!=null){
				_url="https://www.veivo.com/weixin4.jsp?code="+code;
				//Toast.makeText(this, "_url="+_url, Toast.LENGTH_SHORT).show();
				if(webview!=null){
					String s="javascript:window.location.href=\""+_url+"\"";
					//loginScript = s;
					//Toast.makeText(this, "s="+s, Toast.LENGTH_SHORT).show();
					webview.loadUrl(s, null);
					/*
					new AlertDialog.Builder(this)
							.setTitle("提示")
							.setMessage(s)
							.setPositiveButton("确定", new DialogInterface.OnClickListener() {
								@Override
								public void onClick(DialogInterface dialog, int which) {
									// 点击确定按钮时执行的操作
									dialog.dismiss(); // 关闭对话框
								}
							})
							.setNegativeButton("取消", null)
							.show();*/

				}
			}
			
			String status = (String)extras.get("status");
			//Toast.makeText(this, "444444", Toast.LENGTH_SHORT).show();
			if(status!=null){
				//Toast.makeText(this, status, Toast.LENGTH_SHORT).show();
				if(status.equals("success")){
					if(webview!=null){
						String s="javascript:window.paymenttodesktop();";
						webview.loadUrl(s, null);
					}
				}else{
					if(webview!=null){
						String s="javascript:alert('支付失败!');";
						webview.loadUrl(s, null);
					}
				}
			}
			
			String issharetowechat = (String)extras.get("issharetowechat");
			if(issharetowechat!=null){
				String sharestatus = (String)extras.get("sharestatus");
				if(sharestatus!=null&&sharestatus.equals("success")){
					if(webview!=null){
						String s="javascript:alert('分享成功！');";
						webview.loadUrl(s, null);
					}
				}else{
					if(webview!=null){
						String s="javascript:alert('分享失败!');";
						webview.loadUrl(s, null);
					}
				}
			}
			
		}
			
			setIntent(intent);
	        api.handleIntent(intent, this);
	        
	      //  mWeiboShareAPI.handleWeiboResponse(intent, this);
		
	}
	@Override
	protected void onResume(){
		System.out.println("MainActivity Resume.");
		isForeground = true;
		JPushInterface.onResume(this);
		super.onResume();
		//AppEventsLogger.activateApp(this);//facebook added
		//AppEventsLogger.activateApp(this.getApplication());
		if (webview != null) {
            webview.resumeTimers();
           // webview.onShow();
            
//            if(loginScript!=null){
//            	mXwalkView.load(loginScript, null);
//            	loginScript=null;
//            }
            
        }
	}
	@Override
	protected void onPause(){
		System.out.println("MainActivity Pause.");
		isForeground = false;
		JPushInterface.onPause(this);
		super.onPause();
		//AppEventsLogger.deactivateApp(this);//facebook added
		if (webview != null) {
            webview.pauseTimers();
            //webview.onHide();
        }
	}
	@Override
    public void onBackPressed()
    {
		webview.loadUrl("javascript:Veivo.backPrePage();", null);
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
              if (!Util.isEmpty(extras)) {
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

		switch (resp.errCode) {
			case BaseResp.ErrCode.ERR_OK:
				//Get the code
				String code = ((SendAuth.Resp) resp).code;
				if(code!=null){
					String _url="https://www.veivo.com/weixin3.jsp?code="+code;
					//Toast.makeText(this, "_url="+_url, Toast.LENGTH_SHORT).show();
					if(webview!=null){
						String s="javascript:window.location.href=\""+_url+"\"";
						//loginScript = s;
						//Toast.makeText(this, "s="+s, Toast.LENGTH_SHORT).show();
						webview.loadUrl(s, null);
					}
				}
				break;
			case BaseResp.ErrCode.ERR_AUTH_DENIED:
				//User denied authorization
				break;
			case BaseResp.ErrCode.ERR_USER_CANCEL:
				//User canceled authorization
				break;
			default:
				break;
		}
	}
//	@Override
//	public void onResponse(BaseResponse baseResp) {
//
//		System.out.println("***onResponse invoked***");
//		System.out.println(baseResp);
//		System.out.println("***onResponse invoked***");
//
//		String script=null;
//		if(baseResp!= null){
//            switch (baseResp.errCode) {
//            case WBConstants.ErrorCode.ERR_OK:
//               // Toast.makeText(this, R.string.weibosdk_demo_toast_share_success, Toast.LENGTH_LONG).show();
//            	script = "alert(\"分享成功！\");";
//            	//webView.load(url, null);
//             	WebViewManager.INSTANCE.webViewEval(script);
//                break;
//            case WBConstants.ErrorCode.ERR_CANCEL:
//                //Toast.makeText(this, R.string.weibosdk_demo_toast_share_canceled, Toast.LENGTH_LONG).show();
//            	script = "alert(\"分享失败！\");";
//            	//webView.load(url, null);
//             	WebViewManager.INSTANCE.webViewEval(script);
//                break;
//            case WBConstants.ErrorCode.ERR_FAIL:
////                Toast.makeText(this,
////                        getString(R.string.weibosdk_demo_toast_share_failed) + "Error Message: " + baseResp.errMsg,
////                        Toast.LENGTH_LONG).show();
//            	script = "alert(\"分享失败！\");";
//            	//webView.load(url, null);
//             	WebViewManager.INSTANCE.webViewEval(script);
//                break;
//            }
//        }
//	}
}
