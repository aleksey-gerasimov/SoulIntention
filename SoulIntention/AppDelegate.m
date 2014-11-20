//
//  AppDelegate.m
//  SoulIntention
//
//  Created by Aleksey on 11/17/14.
//  Copyright (c) 2014 ThinkMobiles. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>

#import "AppDelegate.h"
#import "SoulIntentionManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[UINavigationBar appearance] setBarTintColor: [UIColor colorWithRed: 86/255.f green: 58/255.f blue: 97/255.f alpha: 1.f]];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlackTranslucent];
    [[UINavigationBar appearance] setTranslucent: NO];

    NSString *deviceId = [[UIDevice currentDevice].identifierForVendor UUIDString];
    [[SoulIntentionManager sharedManager] startSessionWithDeviceId:deviceId completitionHandler:^(BOOL success, NSArray *result, NSError *error) {
        [[SoulIntentionManager sharedManager] getFavouritesIdsWithCompletitionHandler:^(BOOL success, NSArray *result, NSError *error) {
            if (error) {
                return;
            }
            NSLog(@"result = %@", result);
        }];
    }];

    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBAppCall handleDidBecomeActive];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}

@end
