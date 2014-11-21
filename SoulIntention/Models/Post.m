//
//  Post.m
//  SoulIntention
//
//  Created by Aleksey on 11/17/14.
//  Copyright (c) 2014 ThinkMobiles. All rights reserved.
//

#import "Post.h"

#import "SoulIntentionManager.h"

@implementation Post

- (void)setImages:(NSArray *)images
{
    NSMutableArray *urlsArray = [[images valueForKey:@"image_url"] mutableCopy];
    for (NSInteger i=0; i<[urlsArray count]; i++) {
        NSString *urlString = urlsArray[i];
        urlString = [urlString stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
        urlString = [NSString stringWithFormat:@"%@/%@", kBaseURLString, urlString];
        urlsArray[i] = urlString;
    }
    _images = urlsArray;
}

@end
