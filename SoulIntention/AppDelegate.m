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
#import "Constants.h"

#import "UIView+LoadingIndicator.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:86/255.f green:58/255.f blue:97/255.f alpha:1.f]];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlackTranslucent];
    [[UINavigationBar appearance] setTranslucent:NO];

    self.sessionStarted = NO;
    self.favoritesIdsArray = [NSMutableArray new];
    [self.window.rootViewController.view showLoadingIndicator];
    NSString *deviceId = [[UIDevice currentDevice].identifierForVendor UUIDString];
    NSLog(@"Device ID = %@", deviceId);
    __weak AppDelegate *weakSelf = self;
    [[SoulIntentionManager sharedManager] startSessionWithDeviceId:deviceId completitionHandler:^(BOOL success, NSArray *result, NSError *error) {
        if (error) {
            [weakSelf.window.rootViewController.view hideLoadingIndicator];
            [weakSelf showAlertViewWithTitle:@"Error" message:@"Failed to connect to the server"];
            return;
        }

        [[SoulIntentionManager sharedManager] getFavoritesIdsWithCompletitionHandler:^(BOOL success, NSArray *result, NSError *error) {
            [weakSelf.window.rootViewController.view hideLoadingIndicator];
            if (error) {
                [weakSelf showAlertViewWithTitle:@"Error" message:@"Failed to get favorites indexes"];
                return;
            }
            weakSelf.sessionStarted = YES;
            weakSelf.favoritesIdsArray = [[result valueForKey:@"postId"] mutableCopy];
            [[NSNotificationCenter defaultCenter] postNotificationName:kSessionStartedNotification object:nil userInfo:nil];
            NSLog(@"Favorites Ids: \n%@", weakSelf.favoritesIdsArray);
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

- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

@end
