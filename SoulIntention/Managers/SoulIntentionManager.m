//
//  SoulIntentionManager.m
//  SoulIntention
//
//  Created by Aleksey on 11/17/14.
//  Copyright (c) 2014 ThinkMobiles. All rights reserved.
//

#import <RestKit/RestKit.h>

#import "SoulIntentionManager.h"

#import "AppDelegate.h"
#import "SortType.h"
#import "Constants.h"

#import "Post.h"
//#import "Favorite.h"
#import "Author.h"

static NSString *const kStartSession = @"/startMobile";
static NSString *const kEndSession = @"/endMobile";
static NSString *const kDeviceToken = @"/deviceToken";
static NSString *const kPosts = @"/post";
static NSString *const kFavorites = @"/favourite";
//static NSString *const kFavoritesIds = @"/favouriteId";
static NSString *const kSearchPosts = @"/searchPost";
static NSString *const kAuthorDescription = @"/about";
static NSString *const kRate = @"/rate";
static NSInteger const kSessionClosedStatusCode = 403;

@interface SoulIntentionManager ()

@property (strong, nonatomic) RKObjectManager *restManager;
@property (strong, nonatomic) AppDelegate *appDelegate;

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
        instance.appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    });
    return instance;
}

#pragma mark - Private

- (void)configureManager
{
    NSMutableArray *responseDescriptors = [NSMutableArray new];
    //Start session
    RKObjectMapping *emptyMapping = [RKObjectMapping mappingForClass:nil];
    [responseDescriptors addObject:[RKResponseDescriptor responseDescriptorWithMapping:emptyMapping method:RKRequestMethodPOST pathPattern:kStartSession keyPath:@"" statusCodes:nil]];
    //End session
    [responseDescriptors addObject:[RKResponseDescriptor responseDescriptorWithMapping:emptyMapping method:RKRequestMethodGET pathPattern:kEndSession keyPath:@"" statusCodes:nil]];

    //Get posts
    RKObjectMapping *postMapping = [RKObjectMapping mappingForClass:[Post class]];
    [postMapping addAttributeMappingsFromDictionary:@{@"id" : @"postId",
                                                      @"title" : @"title",
                                                      @"details" : @"text",
                                                      @"rate.rate" : @"rate",
                                                      @"updated_at" : @"updateDate",
                                                      @"author.full_name" : @"author",
                                                      @"images" : @"images",
                                                      @"favourite" : @"isFavorite"}];
    [responseDescriptors addObject:[RKResponseDescriptor responseDescriptorWithMapping:postMapping method:RKRequestMethodGET pathPattern:kPosts keyPath:@"" statusCodes:nil]];
    //Get favorite posts
//    RKObjectMapping *favoriteMapping = [RKObjectMapping mappingForClass:[Favorite class]];
//    [favoriteMapping addAttributeMappingsFromDictionary:@{@"post_id" : @"postId"}];
//    [favoriteMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"post" toKeyPath:@"post" withMapping:postMapping]];
    [responseDescriptors addObject:[RKResponseDescriptor responseDescriptorWithMapping:postMapping method:RKRequestMethodGET pathPattern:kFavorites keyPath:@"" statusCodes:nil]];
    //Get favorite posts ids
//    [responseDescriptors addObject:[RKResponseDescriptor responseDescriptorWithMapping:favoriteMapping method:RKRequestMethodGET pathPattern:kFavoritesIds keyPath:@"" statusCodes:nil]];
    //Add post to favorites
    [responseDescriptors addObject:[RKResponseDescriptor responseDescriptorWithMapping:emptyMapping method:RKRequestMethodPOST pathPattern:kFavorites keyPath:@"" statusCodes:nil]];
    //Remove post from favorites
    [responseDescriptors addObject:[RKResponseDescriptor responseDescriptorWithMapping:emptyMapping method:RKRequestMethodDELETE pathPattern:kFavorites keyPath:@"" statusCodes:nil]];

    //Rate post
    [responseDescriptors addObject:[RKResponseDescriptor responseDescriptorWithMapping:emptyMapping method:RKRequestMethodPOST pathPattern:kRate keyPath:@"" statusCodes:nil]];

    //Search for posts
    [responseDescriptors addObject:[RKResponseDescriptor responseDescriptorWithMapping:postMapping method:RKRequestMethodGET pathPattern:kSearchPosts keyPath:@"" statusCodes:nil]];

    //Get author description
    RKObjectMapping *authorMapping = [RKObjectMapping mappingForClass:[Author class]];
    [authorMapping addAttributeMappingsFromDictionary:@{@"full_name" : @"name",
                                                        @"about_info" : @"info",
                                                        @"image_url" : @"imageURL"}];
    [responseDescriptors addObject:[RKResponseDescriptor responseDescriptorWithMapping:authorMapping method:RKRequestMethodGET pathPattern:kAuthorDescription keyPath:@"" statusCodes:nil]];

    [self.restManager addResponseDescriptorsFromArray:responseDescriptors];
}

#pragma mark - Public

#pragma mark Start Session

- (void)startSessionWithDeviceId:(NSString *)deviceId completitionHandler:(CompletitionHandler)handler
{
    NSDictionary *parameters = @{@"deviceId": deviceId};
    [self.restManager postObject:nil path:kStartSession parameters:parameters success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"SoulIntentionManager start session success");
        self.appDelegate.sessionStarted = YES;
        [self.appDelegate prepareForWorkWithPushNotifications];
        if (handler) {
            handler(YES, nil, nil);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"SoulIntentionManager start session error: %@", [error localizedDescription]);
        self.appDelegate.sessionStarted = NO;
        if (handler) {
            handler(NO, nil, error);
        }
    }];
}

- (void)endSessionWithCompletitionHandler:(CompletitionHandler)handler
{
    [self.restManager getObjectsAtPath:kEndSession parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"SoulIntentionManager end session success");
        if (handler) {
            handler(YES, nil, nil);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if (operation.HTTPRequestOperation.response.statusCode == kSessionClosedStatusCode) {
            NSLog(@"SoulIntentionManager session is already ended");
            if (handler) {
                handler(YES, nil, nil);
            }
        } else {
            NSLog(@"SoulIntentionManager end session error: %@", [error localizedDescription]);
            if (handler) {
                handler(NO, nil, error);
            }
        }
    }];
}

- (void)registerForNotificationsWithDeviceToken:(NSString *)deviceToken completitionHandler:(CompletitionHandler)handler
{
    NSDictionary *parameters = @{@"deviceToken" : deviceToken};
    [self.restManager postObject:nil path:kDeviceToken parameters:parameters success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"SoulIntentionManager register for notifications success");
        if (handler) {
            handler(YES, nil, nil);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"SoulIntentionManager register for notifications error: %@", [error localizedDescription]);
        if (handler) {
            handler(NO, nil, error);
        }
    }];
}

#pragma mark Posts methods

- (void)getPostsWithOffset:(NSInteger)offset limit:(NSInteger)limit completitionHandler:(CompletitionHandler)handler
{
    __weak SoulIntentionManager *weakSelf = self;
    NSMutableDictionary *parameters = [@{@"limit" : @(limit), @"offset" : @(offset)} mutableCopy];
    parameters[@"orderBy"] = [[SortType sharedInstance] transformSortTypeForServerRequest];
    [self.restManager getObjectsAtPath:kPosts parameters:parameters success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"SoulIntentionManager get posts success");
        if (handler) {
            handler(YES, [mappingResult array], nil);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"SoulIntentionManager get posts error: %@", [error localizedDescription]);
        if (operation.HTTPRequestOperation.response.statusCode == kSessionClosedStatusCode) {
            NSError *originalError = error;
            [weakSelf startSessionWithDeviceId:self.appDelegate.deviceId completitionHandler:^(BOOL success, NSArray *result, NSError *error) {
                if (success) {
                    [weakSelf getPostsWithOffset:offset limit:limit completitionHandler:handler];
                } else {
                    if (handler) {
                        handler(NO, nil, originalError);
                    }
                }
            }];
        } else {
            if (handler) {
                handler(NO, nil, error);
            }
        }
    }];
}

- (void)getFavoritesWithSearchText:(NSString *)title offset:(NSInteger)offset limit:(NSInteger)limit completitionHandler:(CompletitionHandler)handler
{
    __weak SoulIntentionManager *weakSelf = self;
    NSMutableDictionary *parameters = [@{@"title" : title, @"limit" : @(limit), @"offset" : @(offset)} mutableCopy];
    parameters[@"orderBy"] = [[SortType sharedInstance] transformSortTypeForServerRequest];
    [self.restManager getObjectsAtPath:kFavorites parameters:parameters success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"SoulIntentionManager get favorites success");
        if (handler) {
            handler(YES, [mappingResult array], nil);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"SoulIntentionManager get favorites error: %@", [error localizedDescription]);
        if (operation.HTTPRequestOperation.response.statusCode == kSessionClosedStatusCode) {
            NSError *originalError = error;
            [weakSelf startSessionWithDeviceId:self.appDelegate.deviceId completitionHandler:^(BOOL success, NSArray *result, NSError *error) {
                if (success) {
                    [weakSelf getFavoritesWithSearchText:(NSString *)title offset:offset limit:limit completitionHandler:handler];
                } else {
                    if (handler) {
                        handler(NO, nil, originalError);
                    }
                }
            }];
        } else {
            if (handler) {
                handler(NO, nil, error);
            }
        }
    }];
}

//- (void)getFavoritesIdsWithCompletitionHandler:(CompletitionHandler)handler
//{
//    __weak SoulIntentionManager *weakSelf = self;
//    [self.restManager getObjectsAtPath:kFavoritesIds parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
//        NSLog(@"SoulIntentionManager get favorites Ids success");
//        if (handler) {
//            handler(YES, [mappingResult array], nil);
//        }
//    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
//        NSLog(@"SoulIntentionManager get favorites Ids error: %@", [error localizedDescription]);
//        if (operation.HTTPRequestOperation.response.statusCode == kSessionClosedStatusCode) {
//            NSError *originalError = error;
//            [weakSelf startSessionWithDeviceId:self.appDelegate.deviceId completitionHandler:^(BOOL success, NSArray *result, NSError *error) {
//                if (success) {
//                    [weakSelf getFavoritesIdsWithCompletitionHandler:handler];
//                } else {
//                    if (handler) {
//                        handler(NO, nil, originalError);
//                    }
//                }
//            }];
//        } else {
//            if (handler) {
//                handler(NO, nil, error);
//            }
//        }
//    }];
//}

- (void)addToFavoritesPostWithId:(NSString *)postId completitionHandler:(CompletitionHandler)handler
{
    __weak SoulIntentionManager *weakSelf = self;
    NSDictionary *parameters = @{@"postId" : postId};
    [self.restManager postObject:nil path:kFavorites parameters:parameters success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"SoulIntentionManager add to favorites post with id %@ success", postId);
        if (handler) {
            handler(YES, nil, nil);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"SoulIntentionManager add to favorites post with id %@ error: %@", postId, [error localizedDescription]);
        if (operation.HTTPRequestOperation.response.statusCode == kSessionClosedStatusCode) {
            NSError *originalError = error;
            [weakSelf startSessionWithDeviceId:self.appDelegate.deviceId completitionHandler:^(BOOL success, NSArray *result, NSError *error) {
                if (success) {
                    [weakSelf addToFavoritesPostWithId:postId completitionHandler:handler];
                } else {
                    if (handler) {
                        handler(NO, nil, originalError);
                    }
                }
            }];
        } else {
            if (handler) {
                handler(NO, nil, error);
            }
        }
    }];
}

//- (NSURLRequest *)createUrlRequestWithUrlAddress:(NSString *)_stringUrlAddress bodyData:(NSData *)_bodyData requestType:(NSString *)_requestType
//{
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
//    NSURL *urlAddress = [NSURL URLWithString:_stringUrlAddress];
//    [request setURL:urlAddress];
//    [request setHTTPMethod:_requestType];
//    [request setHTTPBody:_bodyData];
//    [request setValue:@"must-revalidate" forHTTPHeaderField:@"Cashe-Control"];
//    [request setTimeoutInterval:30.0f];
//    [request setCachePolicy:NSURLRequestUseProtocolCachePolicy];
//    if ([_requestType isEqualToString:@"PATCH"]){
//        [request setValue:@"PATCH" forHTTPHeaderField:@"X-HTTP-Method-Override"];
//    }
//    return request;
//}

- (void)removeFromFavoritesPostWithId:(NSString *)postId completitionHandler:(CompletitionHandler)handler
{
    __weak SoulIntentionManager *weakSelf = self;
    [self.restManager deleteObject:nil path:[NSString stringWithFormat:@"%@/%@", kFavorites, postId] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"SoulIntentionManager remove from favorites post with id %@ success", postId);
        if (handler) {
            handler(YES, nil, nil);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"SoulIntentionManager remove from favorites post with id %@ error: %@", postId, [error localizedDescription]);
        if (operation.HTTPRequestOperation.response.statusCode == kSessionClosedStatusCode) {
            NSError *originalError = error;
            [weakSelf startSessionWithDeviceId:self.appDelegate.deviceId completitionHandler:^(BOOL success, NSArray *result, NSError *error) {
                if (success) {
                    [weakSelf removeFromFavoritesPostWithId:postId completitionHandler:handler];
                } else {
                    if (handler) {
                        handler(NO, nil, originalError);
                    }
                }
            }];
        } else {
            if (handler) {
                handler(NO, nil, error);
            }
        }
    }];
}

#pragma mark Rate

- (void)ratePostWithId:(NSString *)postId rating:(NSString *)rating completitionHandler:(CompletitionHandler)handler
{
    __weak SoulIntentionManager *weakSelf = self;
    NSDictionary *parameters = @{@"postId" : postId, @"rate" : rating};
    [self.restManager postObject:nil path:kRate parameters:parameters success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"SoulIntentionManager rate post with id %@ rating %@ success", postId, rating);
        if (handler) {
            handler(YES, nil, nil);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"SoulIntentionManager rate post with id %@ rating %@ error: %@", postId, rating, [error localizedDescription]);
        if (operation.HTTPRequestOperation.response.statusCode == kSessionClosedStatusCode) {
            NSError *originalError = error;
            [weakSelf startSessionWithDeviceId:self.appDelegate.deviceId completitionHandler:^(BOOL success, NSArray *result, NSError *error) {
                if (success) {
                    [weakSelf ratePostWithId:postId rating:rating completitionHandler:handler];
                } else {
                    if (handler) {
                        handler(NO, nil, originalError);
                    }
                }
            }];
        } else {
            if (handler) {
                handler(NO, nil, error);
            }
        }
    }];
}

#pragma mark Search

- (void)searchForPostsWithTitle:(NSString *)title offset:(NSInteger)offset limit:(NSInteger)limit completitionHandler:(CompletitionHandler)handler
{
    __weak SoulIntentionManager *weakSelf = self;
    NSMutableDictionary *parameters = [@{@"title" : title, @"limit" : @(limit), @"offset" : @(offset)} mutableCopy];
    parameters[@"orderBy"] = [[SortType sharedInstance] transformSortTypeForServerRequest];
    [self.restManager getObjectsAtPath:kSearchPosts parameters:parameters success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"SoulIntentionManager search for posts with title \"%@\" success", title);
        if (handler) {
            handler(YES, [mappingResult array], nil);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"SoulIntentionManager search for posts with title \"%@\" error: %@", title, [error localizedDescription]);
        if (operation.HTTPRequestOperation.response.statusCode == kSessionClosedStatusCode) {
            NSError *originalError = error;
            [weakSelf startSessionWithDeviceId:self.appDelegate.deviceId completitionHandler:^(BOOL success, NSArray *result, NSError *error) {
                if (success) {
                    [weakSelf searchForPostsWithTitle:title offset:offset limit:limit completitionHandler:handler];
                } else {
                    if (handler) {
                        handler(NO, nil, originalError);
                    }
                }
            }];
        } else {
            if (handler) {
                handler(NO, nil, error);
            }
        }
    }];
}

#pragma mark Author

- (void)getAuthorDescriptionWithCompletitionHandler:(CompletitionHandler)handler
{
    __weak SoulIntentionManager *weakSelf = self;
    [self.restManager getObjectsAtPath:kAuthorDescription parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"SoulIntentionManager get author description success");
        if (handler) {
            handler(YES, [mappingResult array], nil);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"SoulIntentionManager get author description error: %@", [error localizedDescription]);
        if (operation.HTTPRequestOperation.response.statusCode == kSessionClosedStatusCode) {
            NSError *originalError = error;
            [weakSelf startSessionWithDeviceId:self.appDelegate.deviceId completitionHandler:^(BOOL success, NSArray *result, NSError *error) {
                if (success) {
                    [weakSelf getAuthorDescriptionWithCompletitionHandler:handler];
                } else {
                    if (handler) {
                        handler(NO, nil, originalError);
                    }
                }
            }];
        } else {
            if (handler) {
                handler(NO, nil, error);
            }
        }
    }];
}

@end
