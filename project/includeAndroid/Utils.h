#ifndef APPSFLYEREXTENSION_H
#define APPSFLYEREXTENSION_H

namespace appsflyerextension {

	void StartTracking(const char *devkey, const char *appId);
	void TrackEvent(const char *eventName, const char *eventData);
}


#endif