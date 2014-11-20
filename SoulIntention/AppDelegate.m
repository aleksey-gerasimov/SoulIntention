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

NSString *const kSessionStartedNotification = @"SessionStartedNotification";

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[UINavigationBar appearance] setBarTintColor: [UIColor colorWithRed: 86/255.f green: 58/255.f blue: 97/255.f alpha: 1.f]];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlackTranslucent];
    [[UINavigationBar appearance] setTranslucent: NO];
//FA8C98BA-4020-4352-A39F-9E2FBEDE6C40
//FA8C98BA-4020-4352-A39F-9E2FBEDE6C40
    self.sessionStarted = NO;
    self.favouritesIdsArray = [NSArray new];
    __weak AppDelegate *weakSelf = self;
    NSString *deviceId = [[UIDevice currentDevice].identifierForVendor UUIDString];
    NSLog(@"Device ID = %@", deviceId);
    [[SoulIntentionManager sharedManager] startSessionWithDeviceId:deviceId completitionHandler:^(BOOL success, NSArray *result, NSError *error) {
        [[SoulIntentionManager sharedManager] getFavouritesIdsWithCompletitionHandler:^(BOOL success, NSArray *result, NSError *error) {
            if (error) {
                return;
            }
            weakSelf.sessionStarted = YES;
            weakSelf.favouritesIdsArray = [result valueForKey:@"postId"];
            [[NSNotificationCenter defaultCenter] postNotificationName:kSessionStartedNotification object:nil userInfo:nil];
            NSLog(@"Favourites Ids: \n%@", [result valueForKey:@"postId"]);
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
