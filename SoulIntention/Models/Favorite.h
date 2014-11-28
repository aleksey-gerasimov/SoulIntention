//
//  Favorite.h
//  SoulIntention
//
//  Created by Aleksey on 11/20/14.
//  Copyright (c) 2014 ThinkMobiles. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Post;

@interface Favorite : NSObject

@property (strong, nonatomic) NSString *postId;
@property (strong, nonatomic) Post *post;

@end
