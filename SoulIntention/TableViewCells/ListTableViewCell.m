//
//  ListTableViewCell.m
//  SoulIntention
//
//  Created by Admin on 11/17/14.
//  Copyright (c) 2014 ThinkMobiles. All rights reserved.
//

#import "ListTableViewCell.h"
#import "UIImage+ScaleImage.h"

static CGFloat const ICON_WIDTH = 30.f;
static CGFloat const ICON_HEIGHT = 30.f;
static CGFloat const SWIPE_OFFSET = 107.f;

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

- (void)awakeFromNib
{
    [self initGestureRecognizer];
    [self setButtonImages];
    self.cellType = ActiveCellTypeCenter;
}

-(UIEdgeInsets)layoutMargins
{
    return UIEdgeInsetsZero;
}

#pragma mark - Private Methods

- (void)setButtonImages
{
    UIImage *image = [UIImage new];
    CGSize size = CGSizeMake(ICON_WIDTH, ICON_HEIGHT);
    
    image = [UIImage imageNamed:@"ic_favorite_nawbar"];
    [self.favoriteButton setImage:[UIImage imageWithImage:image scaleToSize:size] forState:UIControlStateNormal];
    image = [UIImage imageNamed:@"ic_favorite_nawbar_select"];
    [self.favoriteButton setImage:[UIImage imageWithImage:image scaleToSize:size] forState:UIControlStateHighlighted];
    
    image = [UIImage imageNamed:@"ic_facebook_share"];
    [self.facebookButton setImage:[UIImage imageWithImage:image scaleToSize:size] forState:UIControlStateNormal];
    image = [UIImage imageNamed:@"ic_facebook_share_select"];
    [self.facebookButton setImage:[UIImage imageWithImage:image scaleToSize:size] forState:UIControlStateHighlighted];
    
    image = [UIImage imageNamed:@"ic_twitter_share"];
    [self.twitterButton setImage:[UIImage imageWithImage:image scaleToSize:size] forState:UIControlStateNormal];
    image = [UIImage imageNamed:@"ic_twitter_share_select"];
    [self.twitterButton setImage:[UIImage imageWithImage:image scaleToSize:size] forState:UIControlStateHighlighted];
}

- (void)initGestureRecognizer
{
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToLeftWithGestureRecognizer:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToRightWithGestureRecognizer:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionLeft;
    
    [self.cellView addGestureRecognizer:swipeLeft];
    [self.cellView addGestureRecognizer:swipeRight];
}

- (void)swipeRightWithOffset:(CGFloat)offset
{
    [UIView animateWithDuration:0.5f animations:^{
        self.cellView.frame = CGRectOffset(self.cellView.frame, offset, 0.f);
        self.socialView.frame = CGRectOffset(self.socialView.frame, offset, 0.f);
        self.favoriteView.frame = CGRectOffset(self.favoriteView.frame, offset, 0.f);
    }];
}

- (void)swipeLeftWithOffset:(CGFloat)offset
{
    [UIView animateWithDuration:0.5f animations:^{
        self.cellView.frame = CGRectOffset(self.cellView.frame, -offset, 0.f);
        self.socialView.frame = CGRectOffset(self.socialView.frame, -offset, 0.f);
        self.favoriteView.frame = CGRectOffset(self.favoriteView.frame, -offset, 0.f);
    }];
}

#pragma mark - IBActions

- (IBAction)favoriteButtonTouchUpInside:(id)sender
{
    NSLog(@"ListTableViewCell favorite button pressed");
}

- (IBAction)facebookButtonTouchUpInside:(id)sender
{
    NSLog(@"ListTableViewCell facebook button pressed");
}

- (IBAction)twitterButtonTouchUpInside:(id)sender
{
    NSLog(@"ListTableViewCell twitter button pressed");
}


#pragma mark - Swipe Gesture Recognizer

- (void)swipeToRightWithGestureRecognizer:(UISwipeGestureRecognizer *)gestureRecogniser
{
    switch (self.cellType) {
        case ActiveCellTypeRight:
            break;
        case ActiveCellTypeLeft:
            [self swipeRightWithOffset:SWIPE_OFFSET];
            self.cellType = ActiveCellTypeCenter;
            break;
        case ActiveCellTypeCenter:
            [self swipeRightWithOffset:SWIPE_OFFSET];
            self.cellType = ActiveCellTypeRight;
            break;
    }
}

- (void)swipeToLeftWithGestureRecognizer:(UIGestureRecognizer *)gestureRecogniser
{
    switch (self.cellType) {
        case ActiveCellTypeRight:
            [self swipeLeftWithOffset:SWIPE_OFFSET];
            self.cellType = ActiveCellTypeCenter;
            break;
        case ActiveCellTypeLeft:
            break;
        case ActiveCellTypeCenter:
            [self swipeLeftWithOffset:SWIPE_OFFSET];
            self.cellType = ActiveCellTypeLeft;
            break;
    }
}

@end
