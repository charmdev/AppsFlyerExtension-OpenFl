#ifndef STATIC_LINK
#define IMPLEMENT_API
#endif

#if defined(HX_WINDOWS) || defined(HX_MACOS) || defined(HX_LINUX)
#define NEKO_COMPATIBLE
#endif


#include <hx/CFFI.h>
#include "UtilsIos.h"

#define safe_val_string(str) str==NULL ? "" : std::string(val_string(str))

using namespace appsflyerextension;



static void appsflyerextension_startTracking (value devkey, value appId) {

	StartTracking(
		safe_val_string(devkey), safe_val_string(appId)
	);

}
DEFINE_PRIM (appsflyerextension_startTracking, 2);

static void appsflyerextension_trackEvent (value eventName, value eventData) {

	TrackEvent(safe_val_string(eventName), safe_val_string(eventData));

}
DEFINE_PRIM (appsflyerextension_trackEvent, 2);



extern "C" void appsflyerextension_main () {
	
	val_int(0); // Fix Neko init
	
}
DEFINE_ENTRY_POINT (appsflyerextension_main);



extern "C" int appsflyerextension_register_prims () { return 0; }