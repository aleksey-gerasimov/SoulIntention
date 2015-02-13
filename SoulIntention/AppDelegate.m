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

@property (strong, nonatomic) NSString *deviceToken;

@end

@implementation AppDelegate

#pragma mark - Lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self prepareForWorkWithServer];
    [self fillData];

    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:67.f/255.f green:42.f/255.f blue:78.f/255.f alpha:1.f]];

    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge categories:nil]];
    [[UIApplication sharedApplication] registerForRemoteNotifications];

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

#pragma mark - Push Notifications

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    self.deviceToken = [[[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSLog(@"Register for remote notifications success, device token = %@", self.deviceToken);
    [self prepareForWorkWithPushNotifications];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Register for remote notifications error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"Receive remote notification: %@", userInfo);
}

#pragma mark - Private

- (void)prepareForWorkWithServer
{
    self.sessionStarted = NO;
    self.deviceId = [[UIDevice currentDevice].identifierForVendor UUIDString];
    NSLog(@"Device ID = %@", self.deviceId);
    [self.window.rootViewController.view showLoadingIndicator];
    __weak AppDelegate *weakSelf = self;
    [[SoulIntentionManager sharedManager] startSessionWithDeviceId:self.deviceId completitionHandler:^(BOOL success, NSArray *result, NSError *error) {
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

- (void)fillData
{
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
}

#pragma mark - Public

- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

- (void)prepareForWorkWithPushNotifications
{
    if (self.sessionStarted && self.deviceToken.length > 0) {
        [[SoulIntentionManager sharedManager] registerForNotificationsWithDeviceToken:self.deviceToken completitionHandler:^(BOOL success, NSArray *result, NSError *error) {
            if (!success) {
                [self showAlertViewWithTitle:@"Warning" message:@"Failed to register for remote notifications"];
            }
        }];
    }
}

@end
