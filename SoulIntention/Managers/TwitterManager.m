//
//  TwitterManager.m
//  SoulIntention
//
//  Created by Aleksey on 11/17/14.
//  Copyright (c) 2014 ThinkMobiles. All rights reserved.
//

#import "TwitterManager.h"

//static NSString *const TSTwitterPostRequestURL = @"https://api.twitter.com/1.1/statuses/update_with_media.json";

@interface TwitterManager ()

@end

@implementation TwitterManager

+ (instancetype)sharedManager
{
    static TwitterManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [TwitterManager new];
    });
    return instance;
}

- (BOOL)presentShareDialogWithText:(NSString *)text url:(NSURL *)url
{
    return [super presentShareDialogWithText:text url:url];
}

@end
