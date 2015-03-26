//
//  Post.m
//  SoulIntention
//
//  Created by Aleksey on 11/17/14.
//  Copyright (c) 2014 ThinkMobiles. All rights reserved.
//

#import "Post.h"

@implementation Post

- (void)setPostDate:(NSString *)postDate
{
    NSString *shortDate = [postDate substringToIndex:10];
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSDate *date = [dateFormatter dateFromString:shortDate];
    dateFormatter.dateFormat = @"MMMM dd, yyyy";
    shortDate = [dateFormatter stringFromDate:date];
    _postDate = shortDate;
}

@end
