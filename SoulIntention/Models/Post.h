//
//  Post.h
//  SoulIntention
//
//  Created by Aleksey on 11/17/14.
//  Copyright (c) 2014 ThinkMobiles. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Post : NSObject

@property (strong, nonatomic) NSNumber *postId;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *details;
@property (strong, nonatomic) NSDate *created_at;
@property (strong, nonatomic) NSString *author;
@property (strong, nonatomic) NSArray *images;

@end
