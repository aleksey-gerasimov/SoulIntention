//
//  SocialManager.m
//  SoulIntention
//
//  Created by Aleksey on 11/19/14.
//  Copyright (c) 2014 ThinkMobiles. All rights reserved.
//

#import <Social/Social.h>

#import "SocialManager.h"

#import "FacebookManager.h"
#import "AppDelegate.h"

@implementation SocialManager

#pragma mark - Lifecycle

+ (instancetype)sharedManager
{
    static SocialManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [SocialManager new];
    });
    return instance;
}

#pragma mark - Public

- (BOOL)presentShareDialogWithText:(NSString *)text url:(NSURL *)url
{
    BOOL success = NO;
    if ([SLComposeViewController isAvailableForServiceType:[self isKindOfClass:[FacebookManager class]] ? SLServiceTypeFacebook : SLServiceTypeTwitter]) {
        SLComposeViewController *viewController = [SLComposeViewController composeViewControllerForServiceType:[self isKindOfClass:[FacebookManager class]] ? SLServiceTypeFacebook : SLServiceTypeTwitter];
        if (text) {
            [viewController setInitialText:text];
        }
        if (url) {
            [viewController addURL:url];
        }

        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate.window.rootViewController presentViewController:viewController animated:YES completion:nil];
        success = YES;
    } else {
        NSLog(@"%@ is not available on the device", [self isKindOfClass:[FacebookManager class]] ? @"Facebook" : @"Twitter");
    }
    return success;
}

@end
