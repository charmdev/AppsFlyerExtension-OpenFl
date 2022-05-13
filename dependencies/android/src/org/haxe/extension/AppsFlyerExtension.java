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
import com.appsflyer.attribution.AppsFlyerRequestListener;

import android.app.Application;
import java.util.*;
import java.lang.Runnable;

import org.haxe.lime.HaxeObject;
import org.haxe.extension.Extension;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;


public class AppsFlyerExtension extends Extension {

	private static AppsFlyerExtension instance = null;

	private static String LOG_TAG = "AppsFlyer";

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

	static void startTracking (String devKey) {
		AppsFlyerExtension.devKey = devKey;

		Log.v(LOG_TAG, "startTracking with id: " + devKey);

		final AppsFlyerConversionListener convListener = new AppsFlyerConversionListener() {
			
			@Override
			public void onConversionDataSuccess(Map<String,Object> conversionData) {
				Log.d(LOG_TAG, "Success onConversionDataSuccess");
				for (String attrName : conversionData.keySet()) {
					Log.d(LOG_TAG, "attribute: " + attrName + " = " + conversionData.get(attrName));
				}
				setInstallData(conversionData);
			}

			@Override
			public void onConversionDataFail(String errorMessage) {
				Log.d(LOG_TAG, "Error onConversionDataFail: " + errorMessage);
				conversionError = "error getting conversion data: " + errorMessage;
				errorCallback(conversionError);
			}

			@Override
			public void onAppOpenAttribution(Map<String, String> conversionData) {
				for (String attrName : conversionData.keySet()) {
					Log.d(LOG_TAG, "attribute: " + attrName + " = " + conversionData.get(attrName));
				}
			}

			@Override
			public void onAttributionFailure(String errorMessage) {
				Log.d(LOG_TAG, "error onAttributionFailure : " + errorMessage);
			}
		};

		final AppsFlyerRequestListener requestListener = new AppsFlyerRequestListener() {
			@Override
			public void onSuccess() {
				Log.d(LOG_TAG,"Request to server successfully sent");
			}

			@Override
			public void onError(int code, String error) {
				Log.d(LOG_TAG,"Error sending request to server: "+error);
				conversionError = "Error sending request to server: "+error;
				errorCallback(conversionError);
			}
		};

		AppsFlyerLib.getInstance().init(
			devKey,
			convListener,
			Extension.mainContext
		);

		AppsFlyerLib.getInstance().start(Extension.mainActivity.getApplication(), devKey, requestListener);

		AppsFlyerLib.getInstance().logSession(Extension.mainContext);
	}

	public static void trackEvent (String eventName, String eventData) {

		Log.v(LOG_TAG, "Trying to send. trackEvent: " + eventName + ", data: " + eventData);
		Map<String, Object> eventValue = new HashMap<String, Object>();
		if (eventData != null) {
			try {
				JSONObject jObject = new JSONObject(eventData);

				Iterator<String> keys = jObject.keys();

				while (keys.hasNext()) {
					String key = (String) keys.next();
					eventValue.put(key,jObject.get(key));
				}
				AppsFlyerLib.getInstance().logEvent(Extension.mainContext, eventName, eventValue);
				Log.v(LOG_TAG, "Success!");
			} catch (final JSONException e) {
				Log.e(LOG_TAG, "Json parsing error: " + e.getMessage());
			}
		}
	}

	private static void successCallback(String response) {
		if (AppsFlyerExtension.callbackObj != null)
			AppsFlyerExtension.callbackObj.call1("onSuccess_jni", response);
	}

	private static void errorCallback(String errMsg) {
		if (AppsFlyerExtension.callbackObj != null)
			AppsFlyerExtension.callbackObj.call0("onError_jni");
	}

	private static void setInstallData(Map<String, Object> conversionData) {
		if (sessionCount == 0)
		{
			installConversionData = Joiner.on("&").withKeyValueSeparator("=").join(conversionData);

			Log.v(LOG_TAG, "ad campaign info: " + installConversionData);
			successCallback(installConversionData);
			sessionCount++;
		}
	}
	
	public boolean onActivityResult (int requestCode, int resultCode, Intent data) {
		return true;
	}

	public String getString(int resId) {
		Context ctx = mainActivity;
		return ctx.getString(resId);
	}
	
	
	public void onCreate (Bundle savedInstanceState) {
		startTracking(getString(org.haxe.extension.appsflyerextension.R.string.af_dev_key));
	}
	
	public void onDestroy () {
		
	}
	
	public void onPause () {
		
	}
	
	public void onRestart () {
		
	}
	
	public void onResume () {
		AppsFlyerLib.getInstance().logSession(Extension.mainContext);
	}
	
	public void onStart () {
		
	}
	
	public void onStop () {
		
	}
	
}
