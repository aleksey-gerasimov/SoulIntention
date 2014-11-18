//
//  FacebookManager.h
//  SoulIntention
//
//  Created by Aleksey on 11/17/14.
//  Copyright (c) 2014 ThinkMobiles. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>

#import <Foundation/Foundation.h>

@interface FacebookManager : NSObject

+ (instancetype)sharedManager;
- (void)addLoginButtonOnView:(UIView *)parentView;
- (void)showShareDialogOnViewController:(UIViewController *)viewController text:(NSString *)text image:(UIImage *)image url:(NSURL *)url;

@end
