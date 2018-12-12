#ifndef STATIC_LINK
#define IMPLEMENT_API
#endif

#if defined(HX_WINDOWS) || defined(HX_MACOS) || defined(HX_LINUX)
#define NEKO_COMPATIBLE
#endif


#include <hx/CFFI.h>
#include "AppsFlyerAppInterface.h"

#include <string>
#include <vector>

#define safe_val_string(str) str==NULL ? "" : std::string(val_string(str))
#define safe_alloc_string(a) (a!=NULL?alloc_string(a):NULL)


using namespace appsflyerextension;

AutoGCRoot* _onSuccess = 0;
AutoGCRoot* _onError = 0;

static void appsflyerextension_startTracking (value devkey, value appId) {
	
	StartTracking(val_get_string(devkey), val_get_string(appId));
	
}
DEFINE_PRIM (appsflyerextension_startTracking, 2);

static void appsflyerextension_trackEvent (value eventName, value eventData) {

	TrackEvent(val_get_string(eventName), val_get_string(eventData));

}
DEFINE_PRIM (appsflyerextension_trackEvent, 2);

static void appsflyerextension_addConversionListenerCallback(value onSuccess, value onError) {
    _onSuccess = new AutoGCRoot(onSuccess);
    _onError = new AutoGCRoot(onError);
    
}
DEFINE_PRIM (appsflyerextension_addConversionListenerCallback, 2);
             
extern "C" void appsflyerextension_main () {
	
	val_int(0); // Fix Neko init
	
}
DEFINE_ENTRY_POINT (appsflyerextension_main);



extern "C" int appsflyerextension_register_prims () { return 0; }

extern "C" void returnConversionSuccess (const char* data)
{
    val_call1(_onSuccess->get(), alloc_string(data));
}

extern "C" void returnConversionError (const char* data)
{
    val_call1(_onError->get(), alloc_string(data));
}
