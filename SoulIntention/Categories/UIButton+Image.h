//
//  UIButton+Image.h
//  SoulIntention
//
//  Created by Aleksey on 11/21/14.
//  Copyright (c) 2014 ThinkMobiles. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Image)

+ (UIBarButtonItem *)createBarButtonItemWithNormalImage:(UIImage *)normalImage highlightedImage:(UIImage *)highlightedImage size:(CGSize)size isHighlighted:(BOOL)isHighlighted actionTarget:(id)target selector:(SEL)selector;

- (void)setNormalImage:(UIImage *)normalImage highlightedImage:(UIImage *)highlightedImage size:(CGSize)size;

@end
