//
//  InitialViewController.m
//  SoulIntentions
//
//  Created by Aleksey on 1/22/15.
//  Copyright (c) 2015 ThinkMobiles. All rights reserved.
//

#import "InitialViewController.h"

#import "Constants.h"

@interface InitialViewController ()

@end

@implementation InitialViewController

- (IBAction)linkButtonPress:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kMainPageURLString]];
}

- (void)dealloc
{
    NSLog(@"%@ dealloc", NSStringFromClass([self class]));
}

@end
