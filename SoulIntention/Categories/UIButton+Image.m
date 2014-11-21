//
//  UIButton+Image.m
//  SoulIntention
//
//  Created by Aleksey on 11/21/14.
//  Copyright (c) 2014 ThinkMobiles. All rights reserved.
//

#import "UIButton+Image.h"

#import "UIImage+ScaleImage.h"

@implementation UIButton (Image)

- (void)setNormalImage:(UIImage *)normalImage highlightedImage:(UIImage *)highlightedImage size:(CGSize)size
{
    [self setImage:[UIImage imageWithImage:normalImage scaleToSize:size] forState:UIControlStateNormal];
    [self setImage:[UIImage imageWithImage:highlightedImage scaleToSize:size] forState:UIControlStateHighlighted];
}

@end
