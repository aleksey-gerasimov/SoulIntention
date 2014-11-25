//
//  SoulIntentionManager.m
//  SoulIntention
//
//  Created by Aleksey on 11/17/14.
//  Copyright (c) 2014 ThinkMobiles. All rights reserved.
//

#import <RestKit/RestKit.h>

#import "SoulIntentionManager.h"

#import "Constants.h"

#import "Post.h"
#import "Favourite.h"
#import "Author.h"

NSString *const kStartSession = @"/startMobile";
NSString *const kPosts = @"/post";
NSString *const kFavourites = @"/favourite";
NSString *const kFavouritesIds = @"/favouriteId";
NSString *const kSearchPosts = @"/searchPost";
NSString *const kAuthorDescription = @"/about";

@interface PostId : NSObject

@property (strong, nonatomic) NSString *postId;

@end

@implementation PostId

//

@end

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

//    RKObjectMapping *objectMapping = [RKObjectMapping mappingForClass:[PostId class]];
//    [objectMapping addAttributeMappingsFromDictionary:@{@"postId" : @"postId"}];
//    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:[objectMapping inverseMapping] objectClass:[NSMutableDictionary class] rootKeyPath:nil method:RKRequestMethodDELETE];
//    [self.restManager addRequestDescriptor:requestDescriptor];
//    self.restManager.requestSerializationMIMEType = RKMIMETypeJSON;
//    [self.restManager.HTTPClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];

    NSMutableArray *responseDescriptors = [NSMutableArray new];
    //Start session
    RKObjectMapping *emptyMapping = [RKObjectMapping mappingForClass:nil];
    [responseDescriptors addObject:[RKResponseDescriptor responseDescriptorWithMapping:emptyMapping method:RKRequestMethodPOST pathPattern:kStartSession keyPath:@"" statusCodes:nil]];

    //Get posts
    RKObjectMapping *postMapping = [RKObjectMapping mappingForClass:[Post class]];
    [postMapping addAttributeMappingsFromDictionary:@{@"id" : @"postId",
                                                      @"title" : @"title",
                                                      @"details" : @"text",
                                                      @"updated_at" : @"updateDate",
                                                      @"author.full_name" : @"author",
                                                      @"images" : @"images"}];
    [responseDescriptors addObject:[RKResponseDescriptor responseDescriptorWithMapping:postMapping method:RKRequestMethodGET pathPattern:kPosts keyPath:@"" statusCodes:nil]];
    //Get favourite posts
    RKObjectMapping *favouriteMapping = [RKObjectMapping mappingForClass:[Favourite class]];
    [favouriteMapping addAttributeMappingsFromDictionary:@{@"post_id" : @"postId"}];
    [favouriteMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"post" toKeyPath:@"post" withMapping:postMapping]];
    [responseDescriptors addObject:[RKResponseDescriptor responseDescriptorWithMapping:favouriteMapping method:RKRequestMethodGET pathPattern:kFavourites keyPath:@"" statusCodes:nil]];
    //Get favourite posts ids
    [responseDescriptors addObject:[RKResponseDescriptor responseDescriptorWithMapping:favouriteMapping method:RKRequestMethodGET pathPattern:kFavouritesIds keyPath:@"" statusCodes:nil]];
    //Add post to favourites
    [responseDescriptors addObject:[RKResponseDescriptor responseDescriptorWithMapping:emptyMapping method:RKRequestMethodPOST pathPattern:kFavourites keyPath:@"" statusCodes:nil]];
    //Remove post from favourites
    [responseDescriptors addObject:[RKResponseDescriptor responseDescriptorWithMapping:emptyMapping method:RKRequestMethodDELETE pathPattern:kFavourites keyPath:@"" statusCodes:nil]];

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

#pragma mark - Start Session

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

#pragma mark - Posts methods

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

- (void)getFavouritesIdsWithCompletitionHandler:(CompletitionHandler)handler
{
    [self.restManager getObjectsAtPath:kFavouritesIds parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"SoulIntentionManager get favourites Ids success");
        if (handler) {
            handler(YES, [mappingResult array], nil);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"SoulIntentionManager get favourites Ids error: %@", [error localizedDescription]);
        if (handler) {
            handler(NO, nil, error);
        }
    }];
}

- (void)addToFavouritesPostWithId:(NSString *)postId completitionHandler:(CompletitionHandler)handler
{
    NSDictionary *parameters = @{@"postId" : postId};
    [self.restManager postObject:nil path:kFavourites parameters:parameters success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"SoulIntentionManager add to favourites post with id %@ success", postId);
        if (handler) {
            handler(YES, nil, nil);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"SoulIntentionManager add to favourites post with id %@ error: %@", postId, [error localizedDescription]);
        if (handler) {
            handler(NO, nil, error);
        }
    }];
}

- (NSURLRequest *)createUrlRequestWithUrlAddress:(NSString *)_stringUrlAddress bodyData:(NSData *)_bodyData requestType:(NSString *)_requestType
{

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];

    NSURL *urlAddress = [NSURL URLWithString:_stringUrlAddress];
    [request setURL:urlAddress];
    [request setHTTPMethod:_requestType];
    [request setHTTPBody:_bodyData];
    [request setValue:@"must-revalidate" forHTTPHeaderField:@"Cashe-Control"];
    [request setTimeoutInterval:30.0f];
    [request setCachePolicy:NSURLRequestUseProtocolCachePolicy];
    if ([_requestType isEqualToString:@"PATCH"]){
        [request setValue:@"PATCH" forHTTPHeaderField:@"X-HTTP-Method-Override"];
    }
    return request;
}


- (void)removeFromFavouritesPostWithId:(NSString *)postId completitionHandler:(CompletitionHandler)handler
{
//    NSDictionary *parameters = @{@"postId" : postId};

//    NSString *string = [NSString stringWithFormat:@"%@%@", kBaseURLString, kFavourites];
//    NSURL *url = [[NSURL alloc] initWithString:string];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
//    [request setHTTPMethod:@"DELETE"];
////    [request setValue:@"Basic: someValue" forHTTPHeaderField:@"Authorization"];
//    [request setValue:postId forHTTPHeaderField:@"postId"];
//    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    NSString *body = [NSString stringWithFormat:@"postId=%@", postId];
//    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
//    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
////    op.responseSerializer = [AFJSONResponseSerializer serializer];
//    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"SoulIntentionManager remove from favourites post with id %@ success", postId);
//        if (handler) {
//            handler(YES, nil, nil);
//        }
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"SoulIntentionManager remove from favourites post with id %@ error: %@", postId, [error localizedDescription]);
//        if (handler) {
//            handler(NO, nil, error);
//        }
//    }];
//    [op start];

//    NSString *urlString = [NSString stringWithFormat:@"%@%@", kBaseURLString, kFavourites];
//    NSData *requestBody = [NSKeyedArchiver archivedDataWithRootObject:parameters];
//    NSURLRequest *request = [self createUrlRequestWithUrlAddress:urlString bodyData:requestBody requestType:@"DELETE"];
//    RKObjectMapping * scrapedDataMapping = [RKObjectMapping mappingForClass:nil];
//    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:scrapedDataMapping
//                                                                                            method:RKRequestMethodDELETE
//                                                                                       pathPattern:kFavourites
//                                                                                           keyPath:@""
//                                                                                       statusCodes:nil];
//    NSLog(@"request = %@", request);
//    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[responseDescriptor]];
//    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
//        NSLog(@"SoulIntentionManager remove from favourites post with id %@ success", postId);
//        if (handler) {
//            handler(YES, nil, nil);
//        }
//    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
//        NSLog(@"SoulIntentionManager remove from favourites post with id %@ error: %@", postId, [error localizedDescription]);
//        if (handler) {
//            handler(NO, nil, error);
//        }
//    }];
//    [operation start];

//    PostId *post = [PostId new];
//    post.postId = postId;
//    [self.restManager.HTTPClient deletePath:kFavourites parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"SoulIntentionManager remove from favourites post with id %@ success", postId);
//        if (handler) {
//            handler(YES, nil, nil);
//        }
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"SoulIntentionManager remove from favourites post with id %@ error: %@", postId, [error localizedDescription]);
//        if (handler) {
//            handler(NO, nil, error);
//        }
//    }];

    [self.restManager deleteObject:nil path:[NSString stringWithFormat:@"%@/%@", kFavourites, postId] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"SoulIntentionManager remove from favourites post with id %@ success", postId);
        if (handler) {
            handler(YES, nil, nil);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"SoulIntentionManager remove from favourites post with id %@ error: %@", postId, [error localizedDescription]);
        if (handler) {
            handler(NO, nil, error);
        }
    }];

//    NSString *string = [NSString stringWithFormat:@"%@%@", kBaseURLString, kFavourites];
//    NSURL *url = [[NSURL alloc] initWithString:string];
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
//    request.HTTPMethod = @"DELETE";
////    request.allHTTPHeaderFields = parameters;
////    NSLog(@"request body = %@", request.allHTTPHeaderFields);
//    request.HTTPBody = [NSKeyedArchiver archivedDataWithRootObject:parameters];
////    NSLog(@"request body = %@", [NSKeyedUnarchiver unarchiveObjectWithData:request.HTTPBody]);
//    NSLog(@"request %@", request);
//    [NSURLConnection connectionWithRequest:request delegate:nil];

//    RKObjectRequestOperation *operation = [self.restManager objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
//        NSLog(@"SoulIntentionManager remove from favourites post with id %@ success", postId);
//        if (handler) {
//            handler(YES, nil, nil);
//        }
//    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
//        NSLog(@"SoulIntentionManager remove from favourites post with id %@ error: %@", postId, [error localizedDescription]);
//        if (handler) {
//            handler(NO, nil, error);
//        }
//    }];
//    [self.restManager enqueueObjectRequestOperation:operation];
}

#pragma mark Search

- (void)searchForPostsWithTitle:(NSString *)title offset:(NSInteger)offset limit:(NSInteger)limit completitionHandler:(CompletitionHandler)handler
{
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    parameters[@"title"] = title;
    if (offset) {
        parameters[@"offset"] = @(offset);
    }
    if (limit) {
        parameters[@"limit"] = @(limit);
    }
    [self.restManager getObjectsAtPath:kSearchPosts parameters:parameters success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"SoulIntentionManager search for posts with title \"%@\" success", title);
        if (handler) {
            handler(YES, [mappingResult array], nil);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"SoulIntentionManager search for posts with title \"%@\" error: %@", title, [error localizedDescription]);
        if (handler) {
            handler(NO, nil, error);
        }
    }];
}

#pragma mark - Author

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
