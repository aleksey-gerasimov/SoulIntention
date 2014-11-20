//
//  FacebookManager.m
//  SoulIntention
//
//  Created by Aleksey on 11/17/14.
//  Copyright (c) 2014 ThinkMobiles. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import <Social/Social.h>

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
    if ([FBDialogs canPresentShareDialog]) {
        [FBDialogs presentShareDialogWithLink:link name:name caption:caption description:description picture:picture clientState:nil handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
            if (error) {
                NSLog(@"Facebook present share dialog error: %@", [error localizedDescription]);
            } else {
                NSLog(@"Facebook present share dialog success");
            }
        }];
    } else {
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
            } else {
                NSLog(@"Facebook present feed dialog modally success");
            }
        }];
    }
}

@end
