//
//  Post.h
//  SoulIntention
//
//  Created by Aleksey on 11/17/14.
//  Copyright (c) 2014 ThinkMobiles. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Post : NSObject

@property (strong, nonatomic) NSString *postId;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSString *rate;
@property (strong, nonatomic) NSString *updateDate;
@property (strong, nonatomic) NSString *author;
@property (strong, nonatomic) NSArray *images;
@property (assign, nonatomic) BOOL isFavorite;

@end
