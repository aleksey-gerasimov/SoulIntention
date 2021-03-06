//
//  AppDelegate.h
//  SoulIntention
//
//  Created by Aleksey on 11/17/14.
//  Copyright (c) 2014 ThinkMobiles. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) NSString *deviceId;
@property (assign, nonatomic) BOOL sessionStarted;
@property (strong, nonatomic) NSArray *postHeaderBackgroundColorsArray;
@property (strong, nonatomic) NSArray *postHeaderTitleFontNamesArray;

- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message;
- (void)prepareForWorkWithPushNotifications;
- (void)resetBadgeIcon;

@end

