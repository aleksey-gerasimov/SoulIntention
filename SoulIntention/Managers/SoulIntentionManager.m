//
//  SoulIntentionManager.m
//  SoulIntention
//
//  Created by Aleksey on 11/17/14.
//  Copyright (c) 2014 ThinkMobiles. All rights reserved.
//

#import <RestKit/RestKit.h>

#import "SoulIntentionManager.h"
#import "Post.h"

NSString *const kBaseURLString = @"";

@interface SoulIntentionManager ()

@property (strong, nonatomic) RKObjectManager *restManager;

@end

@implementation SoulIntentionManager

+ (instancetype)sharedManager
{
    static SoulIntentionManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [SoulIntentionManager new];
        NSURL *baseURL = [NSURL URLWithString:kBaseURLString];
        AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:baseURL];
        instance.restManager = [[RKObjectManager alloc] initWithHTTPClient:client];
        [instance prepear];
    });
    return instance;
}

- (void)prepear
{
    RKObjectMapping *postMapping = [RKObjectMapping mappingForClass:[Post class]];
    [postMapping addAttributeMappingsFromArray:@[@"title", @"text", @"date", @"author", @"pictures"]];

    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:postMapping method:RKRequestMethodGET pathPattern:@"" keyPath:@"" statusCodes:nil];
    [self.restManager addResponseDescriptor:responseDescriptor];
}

@end
