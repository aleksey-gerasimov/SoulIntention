//
//  FacebookManager.m
//  SoulIntention
//
//  Created by Aleksey on 11/17/14.
//  Copyright (c) 2014 ThinkMobiles. All rights reserved.
//

#import "FacebookManager.h"

@implementation FacebookManager

+ (instancetype)sharedManager
{
    static FacebookManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [FacebookManager new];
    });
    return instance;
}

- (void)addLoginButtonOnView:(UIView *)parentView
{
    FBLoginView *loginView = [FBLoginView new];
    loginView.center = parentView.center;
    [parentView addSubview:loginView];
}

- (void)showShareDialogOnViewController:(UIViewController *)viewController text:(NSString *)text image:(UIImage *)image url:(NSURL *)url
{
    if (![FBDialogs canPresentOSIntegratedShareDialog]) {
        NSLog(@"Facebook shareDialog cannot be presented");
        return;
    }

    if (FBSession.activeSession.state == FBSessionStateOpen || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        NSLog(@"Facebook session state = %lu", FBSession.activeSession.state);
        BOOL shareDialogShowed = [FBDialogs presentOSIntegratedShareDialogModallyFrom:viewController initialText:text image:image url:url handler:^(FBOSIntegratedShareDialogResult result, NSError *error) {
            switch (result) {
                case FBOSIntegratedShareDialogResultSucceeded:
                    NSLog(@"Facebook shareDialog succeeded");
                    break;
                case FBOSIntegratedShareDialogResultCancelled:
                    NSLog(@"Facebook shareDialog cancelled");
                    break;
                case FBOSIntegratedShareDialogResultError:
                    NSLog(@"Facebook shareDialog error: %@", error);
                    break;
            }
        }];
        NSLog(@"Facebook shareDialog showed = %i", shareDialogShowed);
    } else if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        [FBSession openActiveSessionWithPublishPermissions:@[@"publish_actions"] defaultAudience:FBSessionDefaultAudienceFriends allowLoginUI:NO completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            if (error) {
                NSLog(@"Facebook login error: %@", [error localizedDescription]);
            } else {
                NSLog(@"Facebook login success");
            }
        }];
    } else {
        [FBSession openActiveSessionWithPublishPermissions:@[@"publish_actions"] defaultAudience:FBSessionDefaultAudienceFriends allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            if (error) {
                NSLog(@"Facebook login error: %@", [error localizedDescription]);
            } else {
                NSLog(@"Facebook login success");
            }
        }];
    }
}

@end
