/*
 * Copyright 2012 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.veivo.veivowebview;

import static com.veivo.veivowebview.CommonUtilities.SENDER_ID;
import static com.veivo.veivowebview.CommonUtilities.displayMessage;

import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

import com.google.android.gcm.GCMBaseIntentService;
import com.google.android.gcm.GCMRegistrar;
import com.veivo.veivowebview.R;

/**
 * IntentService responsible for handling GCM messages.
 */
public class GCMIntentService extends GCMBaseIntentService {

    @SuppressWarnings("hiding")
    private static final String TAG = "GCMIntentService";

    public GCMIntentService() {
        super(SENDER_ID);
    }
    @Override
    protected void onRegistered(Context context, String registrationId) {
        Log.i(TAG, "Device registered: regId = " + registrationId);
        //displayMessage(context, getString(R.string.gcm_registered));
        ServerUtilities.veivoRegister(context,registrationId);
    }

    @Override
    protected void onUnregistered(Context context, String registrationId) {
        Log.i(TAG, "Device unregistered");
        displayMessage(context, getString(R.string.gcm_unregistered));
        if (GCMRegistrar.isRegisteredOnServer(context)) {
            ServerUtilities.unregister(context, registrationId);
        } else {
            // This callback results from the call to unregister made on
            // ServerUtilities when the registration to the server failed.
            Log.i(TAG, "Ignoring unregister callback");
        }
    }
//    @Override
//	public void onHandleIntent(Intent intent) {
//        Bundle extras = intent.getExtras();
//        GoogleCloudMessaging gcm = GoogleCloudMessaging.getInstance(this);
//        // The getMessageType() intent parameter must be the intent you received
//        // in your BroadcastReceiver.
//        String messageType = gcm.getMessageType(intent);
// 
//        if (!extras.isEmpty()) {  // has effect of unparcelling Bundle
    @Override
    protected void onMessage(Context context, Intent intent) {
    	String action = intent.getAction();
    	
        Bundle bundle = intent.getExtras();
        String payload = (String)bundle.get("payload");
        String mid = null;
        String senderName = null;
        String text = null;
        String groupName=null;
        System.out.println(payload);
        //
        try {
			JSONObject obj = (JSONObject)new JSONParser().parse(payload);
			if(obj!=null){
				mid = (String)obj.get("mid");
				senderName = (String)obj.get("senderName");
				text = (String)obj.get("text");
				groupName = (String)obj.get("gp");
			}
		} catch (ParseException e) {
			e.printStackTrace();
		} catch(Exception e){
			e.printStackTrace();
		}
       
        //generateNotification(context,bundle);
        VeivoNotification notification = VeivoNotification.getInstance(context, null);
        notification.notifyNewMessage(mid, undefine(groupName), senderName, text,1);
        
//        boolean running = false;
//        ActivityManager activityManager = (ActivityManager) this.getSystemService( ACTIVITY_SERVICE ); 
//        List<RunningAppProcessInfo> procInfos = activityManager.getRunningAppProcesses(); 
//        for(int i = 0; i < procInfos.size(); i++){ 
//            if(procInfos.get(i).processName.equals("com.veivo.veivowebview")) {
//               running = true;
//            } 
//        } 
//        if(!running){
//	        Intent in = new Intent(this,MainActivity.class);
//	        in.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
//	        if (android.os.Build.VERSION.SDK_INT >= 12) {
//	            intent.setFlags(32);
//	        }
//	        startActivity(in);
//        }
//        WebViewManager.INSTANCE.notify(mid, groupName, senderName, text, 1);
//        
//        context.sendBroadcast(intent);
    }

    @Override
    protected void onDeletedMessages(Context context, int total) {
        Log.i(TAG, "Received deleted messages notification");
        String message = getString(R.string.gcm_deleted, total);
        displayMessage(context, message);
        // notifies user
        generateNotification(context, message);
    }

    @Override
    public void onError(Context context, String errorId) {
        Log.i(TAG, "Received error: " + errorId);
        displayMessage(context, getString(R.string.gcm_error, errorId));
    }

    @Override
    protected boolean onRecoverableError(Context context, String errorId) {
        // log message
        Log.i(TAG, "Received recoverable error: " + errorId);
        displayMessage(context, getString(R.string.gcm_recoverable_error,
                errorId));
        return super.onRecoverableError(context, errorId);
    }

    /**
     * Issues a notification to inform the user that server has sent a message.
     */
    private static void generateNotification(Context context, String message) {
    }
    @Override  
    public void onDestroy() {  
        super.onDestroy();
    	System.out.println("on destroy");
//        Intent intent = new Intent("com.veivo.veivowebview.destroy");
//        sendBroadcast(intent);  
//    	Intent s=new Intent(this,ProxyService.class);   
//		System.out.println("starting ProxyService...");
//		startService(s);
    }  
	public String undefine(String s){
		if(s==null)
			return null;
		if(s.equals("undefined")){
			return null;
		}else
			return s;
	};

}
