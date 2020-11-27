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

	#if (ios)
		private static var appsflyerextension_trackAppLaunch = Lib.load ("appsflyerextension", "appsflyerextension_trackAppLaunch", 0);
		private static var appsflyerextension_trackEvent = Lib.load ("appsflyerextension", "appsflyerextension_trackEvent", 2);
		private static var appsflyerextension_addConversionListenerCallback = Lib.load ("appsflyerextension", "appsflyerextension_addConversionListenerCallback", 2);
		private static var appsflyerextension_removeConversionListenerCallback = Lib.load ("appsflyerextension", "appsflyerextension_removeConversionListenerCallback", 0);
	#end
	#if (android && openfl)
		public var onSuccess_jni:String -> Void;
		public var onError_jni:Void -> Void;
		private static var appsflyerextension_addConversionListenerCallback_jni = JNI.createStaticMethod ("org.haxe.extension.AppsFlyerExtension", "addConversionListenerCallback", "(Lorg/haxe/lime/HaxeObject;)V");
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
	
	public static function trackAppLaunch():Void {
		#if (ios)
			appsflyerextension_trackAppLaunch();
		#end
	}

	public static function trackEvent (eventName:String, eventData:String):Void {

		trace("AppsFlyerReferrerDetectStep trackEvent");

		#if (android)

			appsflyerextension_trackEvent_jni(eventName, eventData);

		#end
		#if (ios)

			appsflyerextension_trackEvent(eventName, eventData);

		#end

	}

	public static function addConversionListenerCallback(onSuccess:String -> Void, onError:Void -> Void):Void {
		#if (android)

			getInstance().onSuccess_jni = onSuccess;
			getInstance().onError_jni = onError;
			appsflyerextension_addConversionListenerCallback_jni(getInstance());

		#end
		#if (ios)

			appsflyerextension_addConversionListenerCallback(onSuccess, onError);

		#end
	}

	public static function removeConversionListenerCallback():Void {
		#if (android)
			getInstance().onSuccess_jni = function(_):Void {trace("ignore");}
			getInstance().onError_jni = function():Void {trace("ignore");}
		#end
		#if (ios)
			appsflyerextension_removeConversionListenerCallback();
		#end
	}
}