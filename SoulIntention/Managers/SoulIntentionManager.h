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
- (void)endSessionWithCompletitionHandler:(CompletitionHandler)handler;
- (void)registerForNotificationsWithDeviceToken:(NSString *)deviceToken completitionHandler:(CompletitionHandler)handler;

- (void)getPostsWithOffset:(NSInteger)offset limit:(NSInteger)limit completitionHandler:(CompletitionHandler)handler;
- (void)getFavoritesWithOffset:(NSInteger)offset limit:(NSInteger)limit completitionHandler:(CompletitionHandler)handler;
- (void)getFavoritesIdsWithCompletitionHandler:(CompletitionHandler)handler;
- (void)addToFavoritesPostWithId:(NSString *)postId completitionHandler:(CompletitionHandler)handler;
- (void)removeFromFavoritesPostWithId:(NSString *)postId completitionHandler:(CompletitionHandler)handler;

- (void)ratePostWithId:(NSString *)postId rating:(NSString *)rating completitionHandler:(CompletitionHandler)handler;

- (void)searchForPostsWithTitle:(NSString *)title offset:(NSInteger)offset limit:(NSInteger)limit completitionHandler:(CompletitionHandler)handler;

- (void)getAuthorDescriptionWithCompletitionHandler:(CompletitionHandler)handler;

@end
