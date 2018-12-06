#ifndef EXTENSION_FIREBASE_APP_DELEGATE_H
#define EXTENSION_FIREBASE_APP_DELEGATE_H

#import <UIKit/UIKit.h>

@interface AppsFlyerTrackerController : NSObject<UIApplicationDelegate, AppsFlyerTrackerDelegate>
	- (void)startTracking:(NSString *)key withId:(NSString *)aId;
	- (void)trackEvent:(NSString *)eventName withData:(NSData*)data

@end

#endif
