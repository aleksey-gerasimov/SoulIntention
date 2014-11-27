//
//  FacebookManager.m
//  SoulIntention
//
//  Created by Aleksey on 11/17/14.
//  Copyright (c) 2014 ThinkMobiles. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>

#import "FacebookManager.h"

#import "AppDelegate.h"

@implementation FacebookManager

#pragma mark - Lifecycle

+ (instancetype)sharedManager
{
    static FacebookManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [FacebookManager new];
    });
    return instance;
}

#pragma mark - Public

- (BOOL)presentShareDialogWithText:(NSString *)text url:(NSURL *)url
{
    if (![super presentShareDialogWithText:text url:url]) {
        [self presentShareDialogWithName:text caption:nil description:nil link:url picture:nil];
    }
    return YES;
}

#pragma mark - Private

- (void)presentShareDialogWithName:(NSString *)name caption:(NSString *)caption description:(NSString *)description link:(NSURL *)link picture:(NSURL *)picture
{
    __weak AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    if (name) {
        parameters[@"name"] = name;
    }
    if (caption) {
        parameters[@"caption"] = caption;
    }
    if (description) {
        parameters[@"description"] = description;
    }
    if (link) {
        parameters[@"link"] = link.absoluteString;
    }
    if (picture) {
        parameters[@"picture"] = picture.absoluteString;
    }

    [FBWebDialogs presentFeedDialogModallyWithSession:nil parameters:parameters handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
        if (error) {
            NSLog(@"Facebook present feed dialog modally error: %@", [error localizedDescription]);
            [appDelegate showAlertViewWithTitle:@"Error" message:@"Failed to present facebook feed dialog"];
        } else {
            NSLog(@"Facebook present feed dialog modally success");
            if ([resultURL.absoluteString containsString:@"post_id="]) {
                [appDelegate showAlertViewWithTitle:@"Success" message:@"You have successfully shared with facebook"];
            } else {
                [appDelegate showAlertViewWithTitle:@"Error" message:@"Failed to share with facebook"];
            }
        }
    }];
}

@end
