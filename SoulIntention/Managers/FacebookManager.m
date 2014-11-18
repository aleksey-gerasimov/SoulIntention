//
//  FacebookManager.m
//  SoulIntention
//
//  Created by Aleksey on 11/17/14.
//  Copyright (c) 2014 ThinkMobiles. All rights reserved.
//

#import "FacebookManager.h"

//typedef void(^CheckPermissionBlock)(NSError *error);

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




/*
- (void)addLoginButtonOnView:(UIView *)parentView
{
    FBLoginView *loginView = [FBLoginView new];
    loginView.center = parentView.center;
    [parentView addSubview:loginView];
}
*/
/*
- (void)showShareDialogOnViewController:(UIViewController *)viewController text:(NSString *)text image:(UIImage *)image url:(NSURL *)url
{
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
*/
/*
- (void)shareWithFacebookText:(NSString *)text image:(UIImage *)image
{
    [self checkForPermission:@"publish_actions" completitionHandler:^(NSError *error) {
        if (error) {
            return;
        }
        NSDictionary *params = @{@"message" : text,
                                 @"picture" : UIImageJPEGRepresentation(image, 1.0)};
        [FBRequestConnection startWithGraphPath:@"me/feed" parameters:params HTTPMethod:@"POST" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (error) {
                NSLog(@"Facebook post message error: %@", error);
            } else {
                NSLog(@"Facebook post message success");
            }
        }];
    }];
}
*/
/*
- (void)checkForPermission:(NSString *)permission completitionHandler:(CheckPermissionBlock)completitionHandler
{
    if (!FBSession.activeSession.isOpen) {
        [self loginWithLoginUI:NO handler:completitionHandler];
        return;
    }

    [FBRequestConnection startWithGraphPath:@"me/permissions" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (error) {
            NSLog(@"Facebook check permissions error: %@", [error localizedDescription]);
            if (completitionHandler) {
                completitionHandler(error);
            }
            return;
        }

        if ([FBSession.activeSession.permissions containsObject:permission]) {
            if (completitionHandler) {
                completitionHandler(error);
            }
        } else {
            NSLog(@"Facebook need permission %@", permission);
            [FBSession.activeSession requestNewPublishPermissions:@[permission] defaultAudience:FBSessionDefaultAudienceFriends completionHandler:^(FBSession *session, NSError *error) {
                if (error) {
                    NSLog(@"Facebook request permission %@ error: %@", permission, [error localizedDescription]);
                    if (completitionHandler) {
                        completitionHandler(error);
                    }
                    return;
                }

                NSLog(@"Facebook FBSession.activeSession.permissions = %@", FBSession.activeSession.permissions);
                if (![FBSession.activeSession.permissions containsObject:permission]) {
                    NSLog(@"Facebook request permission ignored by user");
                    error = [NSError errorWithDomain:@"DeniedByUser" code:0 userInfo:nil];
                }
                if (completitionHandler) {
                    completitionHandler(error);
                }
            }];
        }
    }];
}
*/
/*
- (void)loginWithLoginUI:(BOOL)allowLoginUI handler:(CheckPermissionBlock)handler
{
    if (!FBSession.activeSession.isOpen) {
        [FBSession openActiveSessionWithPublishPermissions:@[@"publish_actions"] defaultAudience:FBSessionDefaultAudienceFriends allowLoginUI:allowLoginUI completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            if (error) {
                NSLog(@"Facebook login error: %@", [error localizedDescription]);
            } else {
                NSLog(@"Facebook login success");
            }
            if (handler) {
                handler(error);
            }
        }];
    }
}
*/
@end
