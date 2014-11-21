//
//  AppDelegate.h
//  SoulIntention
//
//  Created by Aleksey on 11/17/14.
//  Copyright (c) 2014 ThinkMobiles. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kSessionStartedNotification;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (assign, nonatomic) BOOL sessionStarted;
@property (strong, nonatomic) NSMutableArray *favouritesIdsArray;

@end

