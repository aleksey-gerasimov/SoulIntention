//
//  ListViewController.h
//  SoulIntention
//
//  Created by Admin on 11/17/14.
//  Copyright (c) 2014 ThinkMobiles. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ListStyle) {
    ListStyleAll,
    ListStyleFavorite
};

@interface ListViewController : UIViewController

@property (assign, nonatomic) ListStyle listStyle;

@end
