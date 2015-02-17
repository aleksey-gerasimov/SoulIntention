//
//  Post.m
//  SoulIntention
//
//  Created by Aleksey on 11/17/14.
//  Copyright (c) 2014 ThinkMobiles. All rights reserved.
//

#import "Post.h"

@implementation Post

- (void)setUpdateDate:(NSString *)updateDate
{
    NSString *shortDate = [updateDate substringToIndex:10];
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSDate *date = [dateFormatter dateFromString:shortDate];
    dateFormatter.dateFormat = @"MMMM dd, yyyy";
    shortDate = [dateFormatter stringFromDate:date];
    _updateDate = shortDate;
}

@end
