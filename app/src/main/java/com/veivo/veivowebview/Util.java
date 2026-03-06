package com.veivo.veivowebview;

import java.util.ArrayList;
import java.util.List;

import android.app.Activity;
import android.app.ActivityManager;
import android.app.ActivityManager.RunningTaskInfo;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;

public class Util {
	/**
	 */  
	private static List<String> getHomes(Activity context) {  
        List<String> names = new ArrayList<String>();  
        PackageManager packageManager = context.getPackageManager();  

        Intent intent = new Intent(Intent.ACTION_MAIN);
     intent.addCategory(Intent.CATEGORY_HOME);  
        List<ResolveInfo> resolveInfo = packageManager.queryIntentActivities(intent,  
              PackageManager.MATCH_DEFAULT_ONLY);  
        for(ResolveInfo ri : resolveInfo){  
           names.add(ri.activityInfo.packageName);  
        }  
        return names;
    }
	/**
	 */
	public static boolean isHome(Activity context){ 
        ActivityManager mActivityManager = (ActivityManager)context.getSystemService(Context.ACTIVITY_SERVICE);  
        List<RunningTaskInfo> rti = mActivityManager.getRunningTasks(1);
        List<String> strs = getHomes(context);
        if(strs != null && strs.size() > 0){
            return strs.contains(rti.get(0).topActivity.getPackageName());
        }else{
            return false;
        }
    }
    public static boolean isEmpty(String s) {
        if (null == s)
            return true;
        if (s.length() == 0)
            return true;
        if (s.trim().length() == 0)
            return true;
        return false;
    }
}
