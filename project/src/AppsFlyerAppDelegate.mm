#include "Utils.h"
#import <UIKit/UIKit.h>
#import <AppsFlyerLib/AppsFlyerTracker.h>

extern "C" void returnConversionSuccess (const char* data);
extern "C" void returnConversionError (const char* data);

@interface NMEAppDelegate : NSObject <UIApplicationDelegate, AppsFlyerTrackerDelegate>
@end

// Copied from Apple's header in case it is missing in some cases (e.g. pre-Xcode 8 builds).
#ifndef NSFoundationVersionNumber_iOS_9_x_Max
#define NSFoundationVersionNumber_iOS_9_x_Max 1299
#endif

@implementation NMEAppDelegate(UIApplicationDelegate)

-(BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *) launchOptions
{
    [AppsFlyerTracker sharedTracker].delegate = self;
    return YES;
}

-(void)onConversionDataReceived:(NSDictionary*) installData
{
    NSLog(@"%@", installData);
    id status = [installData objectForKey:@"af_status"];
    if([status isEqualToString:@"Non-organic"]) {
        id sourceID = [installData objectForKey:@"media_source"];
        id campaign = [installData objectForKey:@"campaign"];
        NSLog(@"This is a none organic install. Media source: %@  Campaign: %@",sourceID,campaign);
    } else if([status isEqualToString:@"Organic"]) {
        NSLog(@"This is an organic install.");
    }
    
    NSMutableString *resultString = [NSMutableString string];
    for (NSString* key in [installData allKeys]){
        if ([resultString length]>0)
            [resultString appendString:@"&"];
        [resultString appendFormat:@"%@=%@", key, [installData objectForKey:key]];
    }
    
    appsflyerextension::rConversionSuccess([resultString UTF8String]);
}

-(void)onConversionDataRequestFailure:(NSError *) error {
    NSLog(@"%@", error);
    NSString *resultString = [NSString stringWithFormat:@"%@", error];
    
    appsflyerextension::rConversionError([resultString UTF8String]);
}


@end

namespace appsflyerextension {

    void rConversionError (const char* data)
    {
        returnConversionError(data);
    }
    
    void rConversionSuccess (const char* data)
    {
        returnConversionSuccess(data);
    }
    
	void StartTracking(std::string devkey, std::string appId) {
		NSLog(@"appsflyerextension StartTracking");
		NSString* key = [[NSString alloc] initWithUTF8String:devkey.c_str()];
		NSString* aId = [[NSString alloc] initWithUTF8String:appId.c_str()];

        [AppsFlyerTracker sharedTracker].appleAppID = aId;
        [AppsFlyerTracker sharedTracker].appsFlyerDevKey = key;
        
        [[AppsFlyerTracker sharedTracker] trackAppLaunch];

	}
	void TrackEvent(std::string eventName, std::string eventData) {
		NSLog(@"appsflyerextension TrackEvent");
		NSString* eName = [[NSString alloc] initWithUTF8String:eventName.c_str()];
		NSString* jsonStr = [[NSString alloc] initWithUTF8String:eventData.c_str()];
		NSData* data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        [[AppsFlyerTracker sharedTracker] trackEvent:eName withValues:responseDic];

        NSLog(@"%@", responseDic);
    }
	
	
}
