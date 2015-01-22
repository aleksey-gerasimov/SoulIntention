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

+ (UIBarButtonItem *)createBarButtonItemWithNormalImage:(UIImage *)normalImage highlightedImage:(UIImage *)highlightedImage size:(CGSize)size isHighlighted:(BOOL)isHighlighted actionTarget:(id)target selector:(SEL)selector
{
    UIButton *button = [UIButton new];
    [button setNormalImage:isHighlighted ? highlightedImage : normalImage
          highlightedImage:isHighlighted ? normalImage : highlightedImage
                      size:size];
    button.frame = CGRectMake(0.0, 0.0, size.width, size.height);
//    [button sizeToFit];

    if (target && selector) {
        [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    }

    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:(UIView *)button];
    return barButtonItem;
}

- (void)setNormalImage:(UIImage *)normalImage highlightedImage:(UIImage *)highlightedImage size:(CGSize)size
{
    [self setBackgroundImage:normalImage forState:UIControlStateNormal];
    [self setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
//    [self setImage:[UIImage imageWithImage:normalImage scaleToSize:size] forState:UIControlStateNormal];
//    [self setImage:[UIImage imageWithImage:highlightedImage scaleToSize:size] forState:UIControlStateHighlighted];
}

@end
