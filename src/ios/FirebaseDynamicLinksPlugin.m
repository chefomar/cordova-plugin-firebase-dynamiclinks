#import "FirebaseDynamicLinksPlugin.h"

@implementation FirebaseDynamicLinksPlugin

- (void)pluginInitialize {
    NSLog(@"Starting Firebase DynamicLinks plugin");

    if (![FIRApp defaultApp]) {
        [FIRApp configure];
    }
}

- (void)onDynamicLink:(CDVInvokedUrlCommand *)command {
    self.dynamicLinkCallbackId = command.callbackId;

    if (self.lastDynamicLinkData) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:self.lastDynamicLinkData];
        [pluginResult setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.dynamicLinkCallbackId];

        self.lastDynamicLinkData = nil;
    }
}

- (void)postDynamicLink:(FIRDynamicLink*) dynamicLink {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    NSString* absoluteUrl = dynamicLink.url.absoluteString;
    NSString* minimumAppVersion = dynamicLink.minimumAppVersion;
    BOOL weakConfidence = (dynamicLink.matchType == FIRDLMatchTypeWeak);

    [data setObject:(absoluteUrl ? absoluteUrl : @"") forKey:@"deepLink"];
    [data setObject:(minimumAppVersion ? minimumAppVersion : @"") forKey:@"minimumAppVersion"];
    [data setObject:(weakConfidence ? @"Weak" : @"Strong") forKey:@"matchType"];

    if (self.dynamicLinkCallbackId) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:data];
        [pluginResult setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.dynamicLinkCallbackId];
    } else {
        self.lastDynamicLinkData = data;
    }
}

@end
