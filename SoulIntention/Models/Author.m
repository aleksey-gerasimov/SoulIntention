//
//  Author.m
//  SoulIntention
//
//  Created by Aleksey on 11/19/14.
//  Copyright (c) 2014 ThinkMobiles. All rights reserved.
//

#import "Author.h"

#import "Constants.h"

@implementation Author

- (void)setImageURL:(NSString *)imageURL
{
    imageURL = [imageURL stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
    _imageURL = [NSString stringWithFormat:@"%@/%@", kBaseURLString, imageURL];
}

@end
