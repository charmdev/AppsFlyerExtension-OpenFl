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
AutoGCRoot* _conversionSuccessResult = 0;
AutoGCRoot* _conversionErrorResult = 0;

static void appsflyerextension_trackAppLaunch () {
	
	TrackAppLaunch();
	
}
DEFINE_PRIM (appsflyerextension_trackAppLaunch, 0);

static void appsflyerextension_trackEvent (value eventName, value eventData) {

	TrackEvent(val_get_string(eventName), val_get_string(eventData));

}
DEFINE_PRIM (appsflyerextension_trackEvent, 2);

static void appsflyerextension_addConversionListenerCallback(value onSuccess, value onError) {
	_onSuccess = new AutoGCRoot(onSuccess);
	_onError = new AutoGCRoot(onError);

	if (_conversionSuccessResult != 0)
	{
		val_call1(_onSuccess->get(), _conversionSuccessResult->get());
	}
	else if (_conversionErrorResult != 0)
	{
		val_call1(_onError->get(), _conversionErrorResult->get());
	}
	
}
DEFINE_PRIM (appsflyerextension_addConversionListenerCallback, 2);

static void appsflyerextension_removeConversionListenerCallback() {
	_onSuccess = 0;
	_onError = 0;
}
DEFINE_PRIM (appsflyerextension_removeConversionListenerCallback, 0);

extern "C" void appsflyerextension_main () {
	
	val_int(0); // Fix Neko init
	
}
DEFINE_ENTRY_POINT (appsflyerextension_main);



extern "C" int appsflyerextension_register_prims () { 
	Init();
	return 0;
}

extern "C" void returnConversionSuccess (const char* data)
{
	if (_onSuccess != 0)
	{
		val_call1(_onSuccess->get(), alloc_string(data));
	}
	else
	{
		_conversionSuccessResult = new AutoGCRoot(alloc_string(data));
	}
}

extern "C" void returnConversionError (const char* data)
{
	if (_onError != 0)
	{
		val_call1(_onError->get(), alloc_string(data));
	}
	else
	{
		_conversionErrorResult = new AutoGCRoot(alloc_string(data));
	}
}
