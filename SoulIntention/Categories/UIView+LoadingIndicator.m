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

@property (strong, nonatomic, readonly) UIView *rootView;

@end

@implementation UIView (LoadingIndicator)

- (UIView *)rootView
{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    return appDelegate.window.rootViewController.view;
}

- (void)showLoadingIndicator
{
    UIActivityIndicatorView *loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    loadingIndicator.hidesWhenStopped = YES;
    loadingIndicator.tag = kLoadingIndicatorViewTag;
    [loadingIndicator startAnimating];

    UIView *backgroundView = [UIView new];
    backgroundView.backgroundColor = [UIColor blackColor];
    backgroundView.alpha = 0.6;
    backgroundView.frame = self.rootView.bounds;
    backgroundView.tag = kLoadingIndicatorBackgroundViewTag;

    [backgroundView addSubview:loadingIndicator];
    loadingIndicator.center = backgroundView.center;
    [self.rootView addSubview:backgroundView];
}

- (void)hideLoadingIndicator
{
    UIView *backgroundView = [self.rootView viewWithTag:kLoadingIndicatorBackgroundViewTag];
    UIActivityIndicatorView *loadingIndicator = (UIActivityIndicatorView *)[backgroundView viewWithTag:kLoadingIndicatorViewTag];
    [loadingIndicator stopAnimating];
    [loadingIndicator removeFromSuperview];
    [backgroundView removeFromSuperview];
}

@end
