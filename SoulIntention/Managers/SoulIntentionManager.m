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
#import "Author.h"

NSString *const kBaseURLString = @"http://134.249.164.53:8077";
NSString *const kStartSession = @"/startMobile";
NSString *const kPosts = @"/post";
NSString *const kFavourites = @"/favourite";
NSString *const kAuthorDescription = @"/about";

@interface SoulIntentionManager ()

@property (strong, nonatomic) RKObjectManager *restManager;

@end

@implementation SoulIntentionManager

#pragma mark - Lifecycle

+ (instancetype)sharedManager
{
    static SoulIntentionManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [SoulIntentionManager new];
        NSURL *baseURL = [NSURL URLWithString:kBaseURLString];
        AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:baseURL];
        instance.restManager = [[RKObjectManager alloc] initWithHTTPClient:client];
        [instance configureManager];
    });
    return instance;
}

#pragma mark - Private

- (void)configureManager
{
    NSMutableArray *responseDescriptors = [NSMutableArray new];

    RKObjectMapping *sessionMapping = [RKObjectMapping mappingForClass:nil];
    [responseDescriptors addObject:[RKResponseDescriptor responseDescriptorWithMapping:sessionMapping method:RKRequestMethodPOST pathPattern:kStartSession keyPath:@"" statusCodes:nil]];

    RKObjectMapping *postMapping = [RKObjectMapping mappingForClass:[Post class]];
    [postMapping addAttributeMappingsFromDictionary:@{@"id" : @"postId",
                                                      @"title" : @"title",
                                                      @"details" : @"text",
                                                      @"author.full_name" : @"author",
                                                      @"images" : @"images"}];
    [responseDescriptors addObject:[RKResponseDescriptor responseDescriptorWithMapping:postMapping method:RKRequestMethodGET pathPattern:kPosts keyPath:@"" statusCodes:nil]];

    RKObjectMapping *favouriteMapping = [RKObjectMapping mappingForClass:[Post class]];
    [favouriteMapping addAttributeMappingsFromDictionary:@{@"post.id" : @"postId",
                                                           @"post.title" : @"title",
                                                           @"post.details" : @"text",
                                                           @"post.author.full_name" : @"author",
                                                           @"post.images" : @"images"}];
    [responseDescriptors addObject:[RKResponseDescriptor responseDescriptorWithMapping:favouriteMapping method:RKRequestMethodGET pathPattern:kFavourites keyPath:@"" statusCodes:nil]];

    RKObjectMapping *addToFavouritesMapping = [RKObjectMapping mappingForClass:nil];
    [responseDescriptors addObject:[RKResponseDescriptor responseDescriptorWithMapping:addToFavouritesMapping method:RKRequestMethodPOST pathPattern:kFavourites keyPath:@"" statusCodes:nil]];

    RKObjectMapping *removeFromFavouritesMapping = [RKObjectMapping mappingForClass:nil];
    [responseDescriptors addObject:[RKResponseDescriptor responseDescriptorWithMapping:removeFromFavouritesMapping method:RKRequestMethodDELETE pathPattern:kFavourites keyPath:@"" statusCodes:nil]];

    RKObjectMapping *authorMapping = [RKObjectMapping mappingForClass:[Author class]];
    [authorMapping addAttributeMappingsFromDictionary:@{@"full_name" : @"name",
                                                        @"about_info" : @"info",
                                                        @"image_url" : @"image"}];
    [responseDescriptors addObject:[RKResponseDescriptor responseDescriptorWithMapping:authorMapping method:RKRequestMethodGET pathPattern:kAuthorDescription keyPath:@"" statusCodes:nil]];

    [self.restManager addResponseDescriptorsFromArray:responseDescriptors];
}

#pragma mark - Public

- (void)startSessionWithDeviceId:(NSString *)deviceId completitionHandler:(CompletitionHandler)handler
{
    NSDictionary *parameters = @{@"deviceId": deviceId};
    [self.restManager postObject:nil path:kStartSession parameters:parameters success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"SoulIntentionManager start session success");
        if (handler) {
            handler(YES, nil, nil);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"SoulIntentionManager start session error: %@", [error localizedDescription]);
        if (handler) {
            handler(NO, nil, error);
        }
    }];
}

#pragma mark -

- (void)getPostsWithOffset:(NSInteger)offset limit:(NSInteger)limit completitionHandler:(CompletitionHandler)handler
{
    NSDictionary *parameters = @{@"limit" : @(limit), @"offset" : @(offset)};
    [self.restManager getObjectsAtPath:kPosts parameters:parameters success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"SoulIntentionManager get posts success");
        if (handler) {
            handler(YES, [mappingResult array], nil);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"SoulIntentionManager get posts error: %@", [error localizedDescription]);
        if (handler) {
            handler(NO, nil, error);
        }
    }];
}

- (void)getFavouritesWithOffset:(NSInteger)offset limit:(NSInteger)limit completitionHandler:(CompletitionHandler)handler
{
    NSDictionary *parameters = @{@"limit" : @(limit), @"offset" : @(offset)};
    [self.restManager getObjectsAtPath:kFavourites parameters:parameters success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"SoulIntentionManager get favourites success");
        if (handler) {
            handler(YES, [mappingResult array], nil);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"SoulIntentionManager get favourites error: %@", [error localizedDescription]);
        if (handler) {
            handler(NO, nil, error);
        }
    }];
}

- (void)addToFavouritesPostWithId:(NSString *)postId completitionHandler:(CompletitionHandler)handler
{
    NSDictionary *parameters = @{@"postId" : postId};
    [self.restManager postObject:nil path:kFavourites parameters:parameters success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"SoulIntentionManager add to favourites success");
        if (handler) {
            handler(YES, nil, nil);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"SoulIntentionManager add to favourites error: %@", [error localizedDescription]);
        if (handler) {
            handler(NO, nil, error);
        }
    }];
}

- (void)removeFromFavouritesPostWithId:(NSString *)postId completitionHandler:(CompletitionHandler)handler
{
    NSDictionary *parameters = @{@"postId" : postId};
    [self.restManager deleteObject:nil path:kFavourites parameters:parameters success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"SoulIntentionManager delete from favourites success");
        if (handler) {
            handler(YES, nil, nil);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"SoulIntentionManager delete from favourites error: %@", [error localizedDescription]);
        if (handler) {
            handler(NO, nil, error);
        }
    }];
}

#pragma mark -

- (void)getAuthorDescriptionWithCompletitionHandler:(CompletitionHandler)handler
{
    [self.restManager getObjectsAtPath:kAuthorDescription parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"SoulIntentionManager get author description success");
        if (handler) {
            handler(YES, [mappingResult array], nil);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"SoulIntentionManager get author description error: %@", [error localizedDescription]);
        if (handler) {
            handler(NO, nil, error);
        }
    }];
}

@end
