//
//  ListTableViewCell.m
//  SoulIntention
//
//  Created by Admin on 11/17/14.
//  Copyright (c) 2014 ThinkMobiles. All rights reserved.
//

#define ICON_WIDTH 31.f
#define ICON_HEIGHT 31.f
#define SWIPE_OFFSET 107.f

#import "ListTableViewCell.h"
#import "UIImage+ScaleImage.h"

typedef NS_ENUM(NSInteger, ActiveCellType) {
    ActiveCellTypeLeft = 0,
    ActiveCellTypeCenter = 1,
    ActiveCellTypeRight = 2,
};

@interface ListTableViewCell ()

@property (assign, nonatomic) ActiveCellType cellType;

@end

@implementation ListTableViewCell

#pragma mark - Lifecycle

- (void)awakeFromNib {
    [self initGestureRecognizer];
    [self setButtonImages];
    self.cellType = ActiveCellTypeCenter;
}

-(UIEdgeInsets)layoutMargins{
    return UIEdgeInsetsZero;
}

#pragma mark - Private Methods

- (void)setButtonImages{
    [self.favoriteButton setImage:[UIImage imageWithImage:[UIImage imageNamed:@"ic_favorite_nawbar"] scaleToSize:CGSizeMake(ICON_WIDTH, ICON_HEIGHT)] forState:UIControlStateNormal];
    [self.favoriteButton setImage:[UIImage imageWithImage:[UIImage imageNamed:@"ic_favorite_nawbar_select"] scaleToSize:CGSizeMake(ICON_WIDTH, ICON_HEIGHT)] forState:UIControlStateHighlighted];
    
    [self.facebookButton setImage:[UIImage imageWithImage:[UIImage imageNamed:@"ic_facebook_share"] scaleToSize:CGSizeMake(ICON_WIDTH, ICON_HEIGHT)] forState:UIControlStateNormal];
    [self.facebookButton setImage:[UIImage imageWithImage:[UIImage imageNamed:@"ic_facebook_share_select"] scaleToSize:CGSizeMake(ICON_WIDTH, ICON_HEIGHT)] forState:UIControlStateHighlighted];
    
    [self.twitterButton setImage:[UIImage imageWithImage:[UIImage imageNamed:@"ic_twitter_share"] scaleToSize:CGSizeMake(ICON_WIDTH, ICON_HEIGHT)] forState:UIControlStateNormal];
    [self.twitterButton setImage:[UIImage imageWithImage:[UIImage imageNamed:@"ic_twitter_share_select"] scaleToSize:CGSizeMake(ICON_WIDTH, ICON_HEIGHT)] forState:UIControlStateHighlighted];
}

- (void)initGestureRecognizer{
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget: self action: @selector(swipeToLeftWithGestureRecognizer:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget: self action: @selector(swipeToRightWithGestureRecognizer:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionLeft;
    
    [self.cellView addGestureRecognizer: swipeLeft];
    [self.cellView addGestureRecognizer: swipeRight];
}

- (void)swipeRightWithOffset:(CGFloat)offset{
    [UIView animateWithDuration:0.5f animations:^{
        self.cellView.frame = CGRectOffset(self.cellView.frame, offset, 0.f);
        self.socialView.frame = CGRectOffset(self.socialView.frame, offset, 0.f);
        self.favoriteView.frame = CGRectOffset(self.favoriteView.frame, offset, 0.f);
    }];
}

- (void)swipeLeftWithOffset:(CGFloat)offset{
    [UIView animateWithDuration:0.5f animations:^{
        self.cellView.frame = CGRectOffset(self.cellView.frame, -offset, 0.f);
        self.socialView.frame = CGRectOffset(self.socialView.frame, -offset, 0.f);
        self.favoriteView.frame = CGRectOffset(self.favoriteView.frame, -offset, 0.f);
    }];
}

#pragma mark - IBActions

- (IBAction)favoriteButtonTouchUpInside:(id)sender {
    NSLog(@"favorite button");
}

- (IBAction)facebookButtonTouchUpInside:(id)sender {
    NSLog(@"facebook button");
}

- (IBAction)twitterButtonTouchUpInside:(id)sender {
    NSLog(@"twitter button");
}


#pragma mark - Swipe Gesture Recognizer

- (void)swipeToRightWithGestureRecognizer:(UISwipeGestureRecognizer*)gestureRecogniser{
    switch (self.cellType) {
        case ActiveCellTypeRight:{
            break;
        }
        case ActiveCellTypeLeft:{
            [self swipeRightWithOffset:SWIPE_OFFSET];
            self.cellType = ActiveCellTypeCenter;
            break;
        }
        case ActiveCellTypeCenter:{
            [self swipeRightWithOffset:SWIPE_OFFSET];
            self.cellType = ActiveCellTypeRight;
            break;
        }
        default:
            break;
    }
}

- (void)swipeToLeftWithGestureRecognizer:(UIGestureRecognizer*)gestureRecogniser{
    switch (self.cellType) {
        case ActiveCellTypeRight:{
            [self swipeLeftWithOffset:SWIPE_OFFSET];
            self.cellType = ActiveCellTypeCenter;
            break;
        }
        case ActiveCellTypeLeft:{
            break;
        }
        case ActiveCellTypeCenter:{
            [self swipeLeftWithOffset:SWIPE_OFFSET];
            self.cellType = ActiveCellTypeLeft;
            break;
        }
        default:
            break;
    }
}

@end
