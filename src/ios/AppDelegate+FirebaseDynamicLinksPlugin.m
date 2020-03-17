#import "AppDelegate+FirebaseDynamicLinksPlugin.h"
#import "FirebaseDynamicLinksPlugin.h"
#import <objc/runtime.h>


@implementation AppDelegate (FirebaseDynamicLinksPlugin)

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *, id> *)options {
    return [self application:app
                   openURL:url
         sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    NSLog(@"(openURL) Recieved a dynamic link: %@", url.absoluteString);
    FirebaseDynamicLinksPlugin* dl = [self.viewController getCommandInstance:@"FirebaseDynamicLinks"];

    FIRDynamicLink *dynamicLink = [[FIRDynamicLinks dynamicLinks] dynamicLinkFromCustomSchemeURL:url];

    if (dynamicLink) {
        if (dynamicLink.url) {
            [dl postDynamicLink:dynamicLink];
        } else {
            NSLog(@"(openURL) Dynamiclink recieved but it does not contain any url.");
        }
        return TRUE;
    }
    return FALSE;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(nonnull NSUserActivity *)userActivity restorationHandler:
    #if defined(__IPHONE_12_0) && (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_12_0)
        (nonnull void (^)(NSArray<id<UIUserActivityRestoring>> *_Nullable))restorationHandler {
    #else
        (nonnull void (^)(NSArray *_Nullable))restorationHandler {
    #endif  // __IPHONE_12_0
        NSLog(@"Recieved a dynamic link: %@", userActivity.webpageURL);
        BOOL handled = [[FIRDynamicLinks dynamicLinks] handleUniversalLink:userActivity.webpageURL
                            completion:^(FIRDynamicLink * _Nullable dynamicLink, NSError * _Nullable error) {
                                if (error) {
                                    NSLog(@"(continueUserActivity) There was an error while retrieving the dynamic link:\n %@", error);
                                    return;
                                }

                                if (dynamicLink) {
                                    if (dynamicLink.url == nil) {
                                        NSLog(@"(continueUserActivity) Dynamiclink recieved but it does not contain any url.");
                                        return;
                                    }

                                    FirebaseDynamicLinksPlugin* dl = [self.viewController getCommandInstance:@"FirebaseDynamicLinks"];
                                    [dl postDynamicLink:dynamicLink];
                                    return;
                                }
                            }];
        return handled;
}

@end
