#import <AppsFlyerAppInterface.h>
#import <AppsFlyerObserver.h>
#import <AppsFlyerLib/AppsFlyerTracker.h>

extern "C" void returnConversionSuccess (const char* data);
extern "C" void returnConversionError (const char* data);

@implementation AppsFlyerObserver

static NSMutableString *resultString;
static NSString *errorString;

-(void) applicationDidFinishLaunching:(NSNotification *)note {
    NSLog(@"appsflyerextension delegate = self");
	[AppsFlyerTracker sharedTracker].delegate = self;
    
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
    
    resultString = [NSMutableString string];
    for (NSString* key in [installData allKeys]){
        if ([resultString length]>0)
            [resultString appendString:@"&"];
        [resultString appendFormat:@"%@=%@", key, [installData objectForKey:key]];
    }
    
    if ([NSThread isMainThread]){
        returnConversionSuccess([resultString UTF8String]);
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            returnConversionSuccess([resultString UTF8String]);
        });
    }
    
}

-(void)onConversionDataRequestFailure:(NSError *) error {
    NSLog(@"%@", error);
    errorString = [NSString stringWithFormat:@"%@", error];
    
    if ([NSThread isMainThread]){
        returnConversionError([errorString UTF8String]);
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            returnConversionError([errorString UTF8String]);
        });
    }
}

@end
