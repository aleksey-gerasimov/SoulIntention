//
//  Constants.h
//  SoulIntention
//
//  Created by Aleksey on 11/21/14.
//  Copyright (c) 2014 ThinkMobiles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

extern NSString *const kBaseURLString;
extern NSString *const kMainPageURLString;

extern NSString *const kSessionStartedNotification;
extern NSString *const kRemoteNotificationRecievedNotification;

extern NSInteger const kPostsLimit;
extern NSString *const kSetSortTypeNotification;
extern NSString *const kShowSortViewNotification;
extern NSString *const kSearchForPostsNotification;
extern NSString *const kHideSortViewAndSearchBarNotification;

extern CGFloat const kAnimationDuration;
extern CGFloat const kLoadingOnScrollOffsetY;
extern NSString *const kListCellSwipeNotification;

extern NSString *const kFavoriteFlagChangedNotification;

extern NSString *const kBackButtonImage;
extern NSString *const kBackButtonHighlightedImage;
extern NSString *const kLogoButtonImage;
extern NSString *const kLogoButtonHighlightedImage;
extern NSString *const kSearchButtonImage;
extern NSString *const kSearchButtonHighlightedImage;
extern NSString *const kSortButtonImage;
extern NSString *const kSortButtonHighlightedImage;
extern NSString *const kFacebookButtonImage;
extern NSString *const kFacebookButtonHighlightedImage;
extern NSString *const kTwitterButtonImage;
extern NSString *const kTwitterButtonHighlightedImage;
extern NSString *const kFavoriteButtonImage;
extern NSString *const kFavoriteButtonHighlightedImage;
extern NSString *const kFavoriteNavigationButtonImage;
extern NSString *const kFavoriteNavigationButtonHighlightedImage;
extern NSString *const kStarButtonImage;
extern NSString *const kStarButtonHighlightedImage;

CGFloat const kImageHeight;
extern CGFloat const kIconWidth;
extern CGFloat const kIconHeight;

@interface Constants : NSObject

@end
