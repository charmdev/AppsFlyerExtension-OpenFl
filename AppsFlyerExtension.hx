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

	#if (cpp || neko)
		private static var appsflyerextension_startTracking = Lib.load ("appsflyerextension", "appsflyerextension_startTracking", 2);
		private static var appsflyerextension_trackEvent = Lib.load ("appsflyerextension", "appsflyerextension_trackEvent", 2);
		private static var appsflyerextension_addConversionListenerCallback = Lib.load ("appsflyerextension", "appsflyerextension_addConversionListenerCallback", 2);
	#end
	#if (android && openfl)
		public var onSuccess_jni:String -> Void;
		public var onError_jni:String -> Void;
		private static var appsflyerextension_addConversionListenerCallback_jni = JNI.createStaticMethod ("org.haxe.extension.AppsFlyerExtension", "addConversionListenerCallback", "(Lorg/haxe/lime/HaxeObject;)V");
		private static var appsflyerextension_startTracking_jni = JNI.createStaticMethod ("org.haxe.extension.AppsFlyerExtension", "startTracking", "(Ljava/lang/String;)V");
		private static var appsflyerextension_trackEvent_jni = JNI.createStaticMethod ("org.haxe.extension.AppsFlyerExtension", "trackEvent", "(Ljava/lang/String;Ljava/lang/String;)V");
	#end

	private static var instance:AppsFlyerExtension;

	private function new()
	{}

	public static function getInstance():AppsFlyerExtension
	{
		if (instance == null)
		{
			instance = new AppsFlyerExtension();
		}

		return instance;
	}
	
	public static function startTracking (devKey:String, appId:String = ""):Void {

		trace("AppsFlyerReferrerDetectStep startTracking");

		#if (android && openfl)

			appsflyerextension_startTracking_jni(devKey);

		#end
		#if (neko || cpp)

			appsflyerextension_startTracking(devKey, appId);

		#end
		
	}

	public static function trackEvent (eventName:String, eventData:String):Void {

		trace("AppsFlyerReferrerDetectStep trackEvent");

		#if (android && openfl)

			appsflyerextension_trackEvent_jni(eventName, eventData);
			appsflyerextension_trackEvent(eventName, eventData);

		#end
		#if (neko || cpp)

			appsflyerextension_trackEvent(eventName, eventData);

		#end

	}

	public static function addConversionListenerCallback(onSuccess:String -> Void, onError:String -> Void):Void {

		#if (android && openfl)

			getInstance().onSuccess_jni = onSuccess;
			getInstance().onError_jni = onError;
			appsflyerextension_addConversionListenerCallback_jni(getInstance());

		#end
		#if (neko || cpp)

			appsflyerextension_addConversionListenerCallback(onSuccess, onError);

		#end
	}
	
}