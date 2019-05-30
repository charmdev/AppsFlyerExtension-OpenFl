#include "AppsFlyerAppInterface.h"
#include "AppsFlyerObserver.h"
#import <UIKit/UIKit.h>
#import <AppsFlyerLib/AppsFlyerTracker.h>

namespace appsflyerextension {
    
	AppsFlyerObserver *obs;
	
	void Pre_init() {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
            obs = [[AppsFlyerObserver alloc] init];
            [[NSNotificationCenter defaultCenter]
             addObserver:obs
             selector:@selector(applicationDidFinishLaunching:)
             name:@"UIApplicationDidFinishLaunchingNotification"
             object:nil
             ];
            
            NSLog(@"appsflyerextension Pre_init");
            
        });
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
