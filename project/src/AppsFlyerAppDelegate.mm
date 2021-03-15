#include "AppsFlyerAppInterface.h"
#import <UIKit/UIKit.h>
#import <AppsFlyerLib/AppsFlyerLib.h>

extern "C" void returnConversionSuccess (const char* data);
extern "C" void returnConversionError ();

@interface ConversionListener : NSObject <AppsFlyerLibDelegate>
@end

// Copied from Apple's header in case it is missing in some cases (e.g. pre-Xcode 8 builds).
#ifndef NSFoundationVersionNumber_iOS_9_x_Max
#define NSFoundationVersionNumber_iOS_9_x_Max 1299
#endif

@implementation ConversionListener

static NSMutableString *resultString;
static NSString *errorString;


-(void)onConversionDataSuccess:(NSDictionary*) installData
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

-(void)onConversionDataFail:(NSError *) error {
	dispatch_async(dispatch_get_main_queue(), ^{
		returnConversionError();
	});
}

@end

namespace appsflyerextension {

	void Init()
	{
		[AppsFlyerLib shared].appleAppID = [[NSBundle mainBundle].infoDictionary objectForKey:@"AppsFlyerAppId"];
		[AppsFlyerLib shared].appsFlyerDevKey = [[NSBundle mainBundle].infoDictionary objectForKey:@"AppsFlyerDevKey"];
		NSLog(@"appsflyerextension Init appId:%@, appKey:%@", [AppsFlyerLib shared].appleAppID, [AppsFlyerLib shared].appsFlyerDevKey);

		ConversionListener *listener = [[ConversionListener alloc] init];
		[AppsFlyerLib shared].delegate = listener;
		NSLog(@"appsflyerextension Init");
	}
	
	void TrackAppLaunch() {
		NSLog(@"appsflyerextension start");
		[[AppsFlyerLib shared] start];
	}

	void TrackEvent(std::string eventName, std::string eventData) {
		NSLog(@"appsflyerextension TrackEvent");
		NSString* eName = [[NSString alloc] initWithUTF8String:eventName.c_str()];
		NSString* jsonStr = [[NSString alloc] initWithUTF8String:eventData.c_str()];
		NSData* data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
		
		NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
		[[AppsFlyerLib shared] logEvent:eName withValues:responseDic];
		
		NSLog(@"%@", responseDic);
	}
	
}
