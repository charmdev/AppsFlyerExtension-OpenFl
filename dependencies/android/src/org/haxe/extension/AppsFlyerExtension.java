package org.haxe.extension;


import android.app.Activity;
import android.content.res.AssetManager;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.view.View;
import android.util.Log;
import com.google.common.base.Joiner;
import com.appsflyer.AppsFlyerLib;
import com.appsflyer.AppsFlyerConversionListener;
import android.app.Application;
import java.util.*;
import java.lang.Runnable;

import org.haxe.lime.HaxeObject;
import org.haxe.extension.Extension;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;



/* 
	You can use the Android Extension class in order to hook
	into the Android activity lifecycle. This is not required
	for standard Java code, this is designed for when you need
	deeper integration.
	
	You can access additional references from the Extension class,
	depending on your needs:
	
	- Extension.assetManager (android.content.res.AssetManager)
	- Extension.callbackHandler (android.os.Handler)
	- Extension.mainActivity (android.app.Activity)
	- Extension.mainContext (android.content.Context)
	- Extension.mainView (android.view.View)
	
	You can also make references to static or instance methods
	and properties on Java classes. These classes can be included 
	as single files using <java path="to/File.java" /> within your
	project, or use the full Android Library Project format (such
	as this example) in order to include your own AndroidManifest
	data, additional dependencies, etc.
	
	These are also optional, though this example shows a static
	function for performing a single task, like returning a value
	back to Haxe from Java.
*/
public class AppsFlyerExtension extends Extension {

    private static AppsFlyerExtension instance = null;

    public static String devKey = null;
    public static String installConversionData = null;
    public static String conversionError = null;
    public static int sessionCount = 0;
    public static HaxeObject callbackObj = null;

    public AppsFlyerExtension()
    {
        if (instance != null)
            instance = this;
    }

    public static AppsFlyerExtension getInstance() {
        if (instance == null) {
            instance = new AppsFlyerExtension();
        }

        return instance;
    }

    public static void addConversionListenerCallback(HaxeObject callbackObj) {

        AppsFlyerExtension.callbackObj = callbackObj;

        if (AppsFlyerExtension.installConversionData != null)
            successCallback(AppsFlyerExtension.installConversionData);

        if (AppsFlyerExtension.conversionError != null)
            errorCallback(AppsFlyerExtension.conversionError);
    }

    private void startTracking (String devKey) {
        AppsFlyerExtension.devKey = devKey;

        Log.v(AppsFlyerLib.LOG_TAG, "startTracking with id: " + devKey);

        final AppsFlyerConversionListener convListener = new AppsFlyerConversionListener() {
            /* Returns the attribution data. Note - the same conversion data is returned every time per install */
            @Override
            public void onInstallConversionDataLoaded(Map<String, String> conversionData) {
                for (String attrName : conversionData.keySet()) {
                    Log.d(AppsFlyerLib.LOG_TAG, "attribute: " + attrName + " = " + conversionData.get(attrName));
                }
                setInstallData(conversionData);
            }

            @Override
            public void onInstallConversionFailure(String errorMessage) {
                Log.d(AppsFlyerLib.LOG_TAG, "error getting conversion data: " + errorMessage);
                conversionError = "error getting conversion data: " + errorMessage;
                errorCallback(conversionError);
            }

            /* Called only when a Deep Link is opened */
            @Override
            public void onAppOpenAttribution(Map<String, String> conversionData) {
                for (String attrName : conversionData.keySet()) {
                    Log.d(AppsFlyerLib.LOG_TAG, "attribute: " + attrName + " = " + conversionData.get(attrName));
                }
            }

            @Override
            public void onAttributionFailure(String errorMessage) {
                Log.d(AppsFlyerLib.LOG_TAG, "error onAttributionFailure : " + errorMessage);
            }
        };

        AppsFlyerLib.getInstance().init(
                devKey,
                convListener,
                Extension.mainContext
        );

        AppsFlyerLib.getInstance().startTracking(Extension.mainActivity.getApplication(), devKey);

    }

    public static void trackEvent (String eventName, String eventData) {

        Log.v(AppsFlyerLib.LOG_TAG, "Trying to send. trackEvent: " + eventName + ", data: " + eventData);
        Map<String, Object> eventValue = new HashMap<String, Object>();
        if (eventData != null) {
            try {
                JSONObject jObject = new JSONObject(eventData);

                Iterator<String> keys = jObject.keys();

                while (keys.hasNext()) {
                    String key = (String) keys.next();
                    eventValue.put(key,jObject.get(key));
                }
                AppsFlyerLib.getInstance().trackEvent(Extension.mainContext, eventName, eventValue);
                Log.v(AppsFlyerLib.LOG_TAG, "Success!");
            } catch (final JSONException e) {
                Log.e(AppsFlyerLib.LOG_TAG, "Json parsing error: " + e.getMessage());
            }
        }
    }

    private static void successCallback(String response)
    {
        if (AppsFlyerExtension.callbackObj != null)
            AppsFlyerExtension.callbackObj.call1("onSuccess_jni", response);
    }

    private static void errorCallback(String errMsg)
    {
        if (AppsFlyerExtension.callbackObj != null)
            AppsFlyerExtension.callbackObj.call1("onError_jni", errMsg);
    }

    private static void setInstallData(Map<String, String> conversionData){
        if(sessionCount == 0)
        {
            installConversionData = Joiner.on("&").withKeyValueSeparator("=").join(conversionData);

            Log.v(AppsFlyerLib.LOG_TAG, "ad campaign info: " + installConversionData);
            successCallback(installConversionData);
            sessionCount++;
        }

    }
	
	/**
	 * Called when an activity you launched exits, giving you the requestCode 
	 * you started it with, the resultCode it returned, and any additional data 
	 * from it.
	 */
	public boolean onActivityResult (int requestCode, int resultCode, Intent data) {
		
		return true;
		
	}

    public String getString(int resId)
    {
        Context ctx = mainActivity;
        return ctx.getString(resId);
    }
	
	
	/**
	 * Called when the activity is starting.
	 */
	public void onCreate (Bundle savedInstanceState) {
		Log.v(AppsFlyerLib.LOG_TAG, "activity onCreate");
        startTracking(getString(org.haxe.extension.appsflyerextension.R.string.af_dev_key));
	}
	
	
	/**
	 * Perform any final cleanup before an activity is destroyed.
	 */
	public void onDestroy () {
		
		
		
	}
	
	
	/**
	 * Called as part of the activity lifecycle when an activity is going into
	 * the background, but has not (yet) been killed.
	 */
	public void onPause () {
		
		
		
	}
	
	
	/**
	 * Called after {@link #onStop} when the current activity is being 
	 * re-displayed to the user (the user has navigated back to it).
	 */
	public void onRestart () {
		
		
		
	}
	
	
	/**
	 * Called after {@link #onRestart}, or {@link #onPause}, for your activity 
	 * to start interacting with the user.
	 */
	public void onResume () {
		
		
		
	}
	
	
	/**
	 * Called after {@link #onCreate} &mdash; or after {@link #onRestart} when  
	 * the activity had been stopped, but is now again being displayed to the 
	 * user.
	 */
	public void onStart () {
		
		
		
	}
	
	
	/**
	 * Called when the activity is no longer visible to the user, because 
	 * another activity has been resumed and is covering this one. 
	 */
	public void onStop () {
		
		
		
	}
	
	
}
