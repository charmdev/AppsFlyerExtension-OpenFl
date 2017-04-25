#include "UtilsIos.h"
#import <UIKit/UIKit.h>
#import <AppsFlyerLib/AppsFlyerTracker.h>

@interface AppsFlyerTrackerController : NSObject<UIApplicationDelegate>
@end

@implementation AppsFlyerTrackerController

	- (void)startTracking:(NSString*)key withId:(NSString*)aId
    {
    	NSLog(@"AppsFlyerTrackerController startTracking");
    	NSLog(@"%@",key);
    	[AppsFlyerTracker sharedTracker].appleAppID = aId;
		[AppsFlyerTracker sharedTracker].appsFlyerDevKey = key;

        [[AppsFlyerTracker sharedTracker] trackAppLaunch];
    }
    - (void) trackEvent:(NSString *)eventName withData:(NSData*)data
    {
    	NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
		[[AppsFlyerTracker sharedTracker] trackEvent:eventName withValues:responseDic];
    }

@end

namespace appsflyerextension {

	AppsFlyerTrackerController* getController()
	{
		static AppsFlyerTrackerController* controller = NULL;
		if(controller == NULL)
		{
			controller = [[AppsFlyerTrackerController alloc] init];
		}
		return controller;
	}
	void StartTracking(std::string devkey, std::string appId) {
		NSLog(@"appsflyerextension StartTracking");
		NSString* key = [[NSString alloc] initWithUTF8String:devkey.c_str()];
		NSString* aId = [[NSString alloc] initWithUTF8String:appId.c_str()];
		AppsFlyerTrackerController* controller = getController();
		[controller startTracking:key withId:aId];

	}
	void TrackEvent(std::string eventName, std::string eventData) {
		NSLog(@"appsflyerextension TrackEvent");
		NSString* eName = [[NSString alloc] initWithUTF8String:eventName.c_str()];
		NSString* jsonStr = [[NSString alloc] initWithUTF8String:eventData.c_str()];
		NSData* data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];

		AppsFlyerTrackerController* controller = getController();
		[controller trackEvent:eName withData:data];
    }
	
	
}