//
//  SoulIntentionManager.h
//  SoulIntention
//
//  Created by Aleksey on 11/17/14.
//  Copyright (c) 2014 ThinkMobiles. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^CompletitionHandler)(BOOL success, NSArray *result, NSError *error);

@interface SoulIntentionManager : NSObject

+ (instancetype)sharedManager;

- (void)startSessionWithDeviceId:(NSString *)deviceId completitionHandler:(CompletitionHandler)handler;

- (void)getPostsWithOffset:(NSInteger)offset limit:(NSInteger)limit completitionHandler:(CompletitionHandler)handler;
- (void)getFavouritesWithOffset:(NSInteger)offset limit:(NSInteger)limit completitionHandler:(CompletitionHandler)handler;
- (void)addToFavouritesPostWithId:(NSString *)postId completitionHandler:(CompletitionHandler)handler;
- (void)removeFromFavouritesPostWithId:(NSString *)postId completitionHandler:(CompletitionHandler)handler;

- (void)getAuthorDescriptionWithCompletitionHandler:(CompletitionHandler)handler;

@end
