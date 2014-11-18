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

- (void)presentShareDialogWithText:(NSString *)text image:(NSURL *)image url:(NSURL *)url
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *viewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        if (text) {
            [viewController setInitialText:text];
        }
        if (image) {
            UIImage *picture = [UIImage imageWithData:[NSData dataWithContentsOfURL:image]];
            [viewController addImage:picture];
        }
        if (url) {
            [viewController addURL:url];
        }
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate.window.rootViewController presentViewController:viewController animated:YES completion:nil];
    } else {
        NSLog(@"Facebook is not available on the device");
        [self presentShareDialogWithName:text caption:nil description:nil link:url picture:image];
    }
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
