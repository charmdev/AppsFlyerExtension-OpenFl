package;

#if cpp
import cpp.Lib;
#elseif neko
import neko.Lib;
#end

#if (android && openfl)
import openfl.utils.JNI;
#end


class AppsFlyerExtension {
	
	
	public static function startTracking (devKey:String, appId:String = ""):Void {
		
		#if (android && openfl)
		appsflyerextension_startTracking_jni(devKey, appId);
		appsflyerextension_startTracking(devKey, appId);
		#end
		#if (neko || cpp)
		appsflyerextension_startTracking(devKey, appId);
		#end
		
	}

	public static function trackEvent (eventName:String, eventData:String):Void {

		#if (android && openfl)
		appsflyerextension_trackEvent_jni(eventName, eventData);
		appsflyerextension_trackEvent(eventName, eventData);
		#end
		#if (neko || cpp)
		appsflyerextension_trackEvent(eventName, eventData);
		#end

	}

	#if (cpp || neko)
	private static var appsflyerextension_startTracking = Lib.load ("appsflyerextension", "appsflyerextension_startTracking", 2);
	private static var appsflyerextension_trackEvent = Lib.load ("appsflyerextension", "appsflyerextension_trackEvent", 2);
	#end
	#if (android && openfl)
	private static var appsflyerextension_startTracking_jni = JNI.createStaticMethod ("org.haxe.extension.AppsFlyerExtension", "startTracking", "(Ljava/lang/String;Ljava/lang/String;)V");
	private static var appsflyerextension_trackEvent_jni = JNI.createStaticMethod ("org.haxe.extension.AppsFlyerExtension", "trackEvent", "(Ljava/lang/String;Ljava/lang/String;)V");
	#end
	
	
}