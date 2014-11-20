//
//  UIImage+ScaleImage.m
//  SoulIntention
//
//  Created by Admin on 11/18/14.
//  Copyright (c) 2014 ThinkMobiles. All rights reserved.
//

#import "UIImage+ScaleImage.h"

@implementation UIImage (ScaleImage)

+ (UIImage *)imageWithImage:(UIImage*)image scaleToSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
