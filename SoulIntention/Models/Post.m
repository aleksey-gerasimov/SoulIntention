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
    NSMutableArray *newImages = [NSMutableArray new];
    NSMutableDictionary *newImage = [[NSMutableDictionary alloc] init];
    
    for (int index = 0; index < [images count]; index++) {
        [newImage setDictionary:[images objectAtIndex:index]];
        
        [newImage setObject:[NSString stringWithFormat:@"%@/%@", kBaseURLString, [newImage objectForKey:@"image_url"]]forKey:@"image_url"];
        [newImages addObject:newImage];
    }
    _images = newImages;
}

@end
