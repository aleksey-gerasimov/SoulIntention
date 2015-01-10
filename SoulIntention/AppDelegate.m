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

#pragma mark - Lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self customizeNavigationBar];
    [self prepareForWorkWithServer];
    
    self.postHeaderBackgroundColorsArray = @[UIColorFromRGB(0x754684),
                                             UIColorFromRGB(0x834c71),
                                             UIColorFromRGB(0x955a99),
                                             UIColorFromRGB(0xa04f85),
                                             UIColorFromRGB(0xb571a1),
                                             UIColorFromRGB(0x7d354e)];
    self.postHeaderTitleFontNamesArray = @[@"IndieFlower",
                                           @"ShadowsIntoLightTwo-Regular",
                                           @"ArchitectsDaughter",
                                           @"CoveredByYourGrace"];

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

#pragma mark - Private

- (void)customizeNavigationBar
{
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:86/255.f green:58/255.f blue:97/255.f alpha:1.f]];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlackTranslucent];
    [[UINavigationBar appearance] setTranslucent:NO];
}

- (void)prepareForWorkWithServer
{
    self.sessionStarted = NO;
    NSString *deviceId = [[UIDevice currentDevice].identifierForVendor UUIDString];
    NSLog(@"Device ID = %@", deviceId);
    [self.window.rootViewController.view showLoadingIndicator];
    __weak AppDelegate *weakSelf = self;
    [[SoulIntentionManager sharedManager] startSessionWithDeviceId:deviceId completitionHandler:^(BOOL success, NSArray *result, NSError *error) {
        if (error) {
            [weakSelf.window.rootViewController.view hideLoadingIndicator];
            [weakSelf showAlertViewWithTitle:@"Error" message:@"Failed to start session"];
            return;
        }

        [weakSelf.window.rootViewController.view hideLoadingIndicator];
        weakSelf.sessionStarted = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:kSessionStartedNotification object:nil userInfo:nil];
    }];
}

- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

@end
