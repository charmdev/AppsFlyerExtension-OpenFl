#ifndef APPSFLYEREXTENSION_H
#define APPSFLYEREXTENSION_H
#include <string>

namespace appsflyerextension {

	void TrackAppLaunch();

	void TrackEvent(std::string eventName, std::string eventData);

	void Init();
	
}

#endif
