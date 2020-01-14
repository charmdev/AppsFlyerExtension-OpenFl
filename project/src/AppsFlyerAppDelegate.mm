#include "AppsFlyerAppInterface.h"
#import <UIKit/UIKit.h>
#import <AppsFlyerLib/AppsFlyerTracker.h>

extern "C" void returnConversionSuccess (const char* data);
extern "C" void returnConversionError ();

@interface ConversionListener : NSObject <AppsFlyerTrackerDelegate>
@end

// Copied from Apple's header in case it is missing in some cases (e.g. pre-Xcode 8 builds).
#ifndef NSFoundationVersionNumber_iOS_9_x_Max
#define NSFoundationVersionNumber_iOS_9_x_Max 1299
#endif

@implementation ConversionListener

static NSMutableString *resultString;
static NSString *errorString;


/*
-(BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *) launchOptions
{
    [AppsFlyerTracker sharedTracker].delegate = self;
    NSLog(@"willFinishLaunchingWithOptions AppsFlyer");
    return YES;
}
*/

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

    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableString* referrerUri = [[NSMutableString alloc] init];
        for (NSString* key in [installData allKeys]) {
            if ([referrerUri length]>0)
                [referrerUri appendString:@"&"];
            [referrerUri appendFormat:@"%@=%@", key, [installData objectForKey:key]];
        }
        returnConversionSuccess([referrerUri UTF8String]);
    });
}

-(void)onConversionDataRequestFailure:(NSError *) error {
    dispatch_async(dispatch_get_main_queue(), ^{
        returnConversionError();
    });
}

@end

namespace appsflyerextension {

    void Init()
    {
        [AppsFlyerTracker sharedTracker].appleAppID = [[NSBundle mainBundle].infoDictionary objectForKey:@"AppsFlyerAppId"];
        [AppsFlyerTracker sharedTracker].appsFlyerDevKey = [[NSBundle mainBundle].infoDictionary objectForKey:@"AppsFlyerDevKey"];
        NSLog(@"appsflyerextension Init appId:%@, appKey:%@", [AppsFlyerTracker sharedTracker].appleAppID, [AppsFlyerTracker sharedTracker].appsFlyerDevKey);

        ConversionListener *listener = [[ConversionListener alloc] init];
        [AppsFlyerTracker sharedTracker].delegate = listener;
        NSLog(@"appsflyerextension Init");
    }
    
    void TrackAppLaunch() {
        NSLog(@"appsflyerextension TrackAppLaunch");
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
