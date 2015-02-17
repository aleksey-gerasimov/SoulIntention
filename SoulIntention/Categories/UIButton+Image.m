//
//  UIButton+Image.m
//  SoulIntention
//
//  Created by Aleksey on 11/21/14.
//  Copyright (c) 2014 ThinkMobiles. All rights reserved.
//

#import "UIButton+Image.h"

@implementation UIButton (Image)

+ (UIBarButtonItem *)createBarButtonItemWithNormalImage:(UIImage *)normalImage highlightedImage:(UIImage *)highlightedImage size:(CGSize)size isHighlighted:(BOOL)isHighlighted actionTarget:(id)target selector:(SEL)selector
{
    UIButton *button = [UIButton new];
    [button setNormalImage:isHighlighted ? highlightedImage : normalImage
          highlightedImage:isHighlighted ? normalImage : highlightedImage];
    button.frame = CGRectMake(0.0, 0.0, size.width, size.height);

    if (target && selector) {
        [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    }

    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:(UIView *)button];
    return barButtonItem;
}

- (void)setNormalImage:(UIImage *)normalImage highlightedImage:(UIImage *)highlightedImage
{
    [self setImage:normalImage forState:UIControlStateNormal];
    [self setImage:highlightedImage forState:UIControlStateHighlighted];
}

@end
