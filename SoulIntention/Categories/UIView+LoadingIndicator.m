//
//  UIView+LoadingIndicator.m
//  SoulIntention
//
//  Created by Aleksey on 11/24/14.
//  Copyright (c) 2014 ThinkMobiles. All rights reserved.
//

#import "UIView+LoadingIndicator.h"

#import "AppDelegate.h"

NSInteger const kLoadingIndicatorBackgroundViewTag = 214;
NSInteger const kLoadingIndicatorViewTag = 215;

@interface UIView ()

@property (strong, nonatomic, readonly) AppDelegate *appDelegate;

@end

@implementation UIView (LoadingIndicator)

- (AppDelegate *)appDelegate
{
    return [UIApplication sharedApplication].delegate;
}

- (void)showLoadingIndicator
{
    UIActivityIndicatorView *loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    loadingIndicator.hidesWhenStopped = YES;
    loadingIndicator.tag = kLoadingIndicatorViewTag;
    [loadingIndicator startAnimating];

    UIView *backgroundView = [UIView new];
    backgroundView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    backgroundView.frame = self.bounds;
    backgroundView.tag = kLoadingIndicatorBackgroundViewTag;

    [backgroundView addSubview:loadingIndicator];
    loadingIndicator.center = backgroundView.center;
    [self.appDelegate.window.rootViewController.view addSubview:backgroundView];
}

- (void)hideLoadingIndicator
{
    UIView *backgroundView = [self.appDelegate.window.rootViewController.view viewWithTag:kLoadingIndicatorBackgroundViewTag];
    UIActivityIndicatorView *loadingIndicator = (UIActivityIndicatorView *)[backgroundView viewWithTag:kLoadingIndicatorViewTag];
    [loadingIndicator stopAnimating];
    [loadingIndicator removeFromSuperview];
    [backgroundView removeFromSuperview];
}

@end
