//
//  ListTableViewCell.m
//  SoulIntention
//
//  Created by Admin on 11/17/14.
//  Copyright (c) 2014 ThinkMobiles. All rights reserved.
//

#import "ListTableViewCell.h"
#import "FacebookManager.h"
#import "TwitterManager.h"
#import "UIImage+ScaleImage.h"
#import "SoulIntentionManager.h"

static CGFloat const ICON_WIDTH = 30.f;
static CGFloat const ICON_HEIGHT = 30.f;
static CGFloat const SWIPE_OFFSET = 107.f;

typedef NS_ENUM(NSInteger, CellType) {
    CellTypeLeft = 0,
    CellTypeCenter = 1,
    CellTypeRight = 2,
};

typedef NS_ENUM(NSInteger, SwipeDirection) {
    SwipeDirectionLeft = 0,
    SwipeDirectionRight = 1,
};

@interface ListTableViewCell ()

@property (assign, nonatomic) CellType cellType;

@end

@implementation ListTableViewCell

#pragma mark - Lifecycle

- (void)awakeFromNib
{
    [self initGestureRecognizer];
    [self setButtonImages];
    self.cellType = CellTypeCenter;
    [self subscribeToNotificationCenter];
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

- (void)subscribeToNotificationCenter
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cellStateChanged) name:@"Swipe" object:nil];
}

- (void)cellStateChanged
{
    if (self.cellType == CellTypeCenter) {
        return;
    }
    if (self.cellType == CellTypeRight) {
        [UIView animateWithDuration:0.5f animations:^{
            self.cellView.frame = CGRectOffset(self.cellView.frame, -SWIPE_OFFSET, 0.f);
            self.socialView.frame = CGRectOffset(self.socialView.frame, -SWIPE_OFFSET, 0.f);
            self.favoriteView.frame = CGRectOffset(self.favoriteView.frame, -SWIPE_OFFSET, 0.f);
        }];
    }
    if (self.cellType == CellTypeLeft) {
        [UIView animateWithDuration:0.5f animations:^{
            self.cellView.frame = CGRectOffset(self.cellView.frame, SWIPE_OFFSET, 0.f);
            self.socialView.frame = CGRectOffset(self.socialView.frame, SWIPE_OFFSET, 0.f);
            self.favoriteView.frame = CGRectOffset(self.favoriteView.frame, SWIPE_OFFSET, 0.f);
        }];
    }
    self.cellType = CellTypeCenter;
}

- (void)swipeWithOffset:(CGFloat)offset toDirection:(NSInteger)direction
{
    if (direction == SwipeDirectionLeft) {
        offset = -offset;
    }
    
    [UIView animateWithDuration:0.5f animations:^{
        self.cellView.frame = CGRectOffset(self.cellView.frame, offset, 0.f);
        self.socialView.frame = CGRectOffset(self.socialView.frame, offset, 0.f);
        self.favoriteView.frame = CGRectOffset(self.favoriteView.frame, offset, 0.f);
       
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Swipe" object:nil];
    }];
    
}

#pragma mark - Custom Setters

- (void)setPost:(Post *)post
{
    _post = post;
    
    self.titleLabel.text = _post.title;
    self.descriptionLabel.text = _post.text;
    self.dateLabel.text = [NSString stringWithFormat:@"%@ %@", _post.creationDate, _post.author];
}

#pragma mark - IBActions

- (IBAction)favoriteButtonTouchUpInside:(id)sender
{
    NSLog(@"ListTableViewCell favorite button pressed");
    [[SoulIntentionManager sharedManager] addToFavouritesPostWithId:self.post.postId completitionHandler:^(BOOL success, NSArray *result, NSError *error) {
        
    }];
}

- (IBAction)facebookButtonTouchUpInside:(id)sender {
    NSLog(@"ListTableViewCell facebook button pressed");
    [[FacebookManager sharedManager] presentShareDialogWithText:self.titleLabel.text image:nil url:nil];
}

- (IBAction)twitterButtonTouchUpInside:(id)sender {
    NSLog(@"ListTableViewCell twitter button pressed");
    [[TwitterManager sharedManager] presentShareDialogWithText:self.titleLabel.text image:nil url:nil];
}


#pragma mark - Swipe Gesture Recognizer

- (void)initGestureRecognizer
{
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToLeftWithGestureRecognizer:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToRightWithGestureRecognizer:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionLeft;
    
    [self.cellView addGestureRecognizer:swipeLeft];
    [self.cellView addGestureRecognizer:swipeRight];
}

- (void)swipeToRightWithGestureRecognizer:(UIGestureRecognizer *)gestureRecogniser
{
    switch (self.cellType) {
        case CellTypeRight:
            break;
        case CellTypeLeft:
            [self swipeWithOffset:SWIPE_OFFSET toDirection:SwipeDirectionRight];
            self.cellType = CellTypeCenter;
            break;
        case CellTypeCenter:
            [self swipeWithOffset:SWIPE_OFFSET toDirection:SwipeDirectionRight];
            self.cellType = CellTypeRight;
            break;
    }
}

- (void)swipeToLeftWithGestureRecognizer:(UIGestureRecognizer *)gestureRecogniser
{
    switch (self.cellType) {
        case CellTypeRight:
            [self swipeWithOffset:SWIPE_OFFSET toDirection:SwipeDirectionLeft];
            self.cellType = CellTypeCenter;
            break;
        case CellTypeLeft:
            break;
        case CellTypeCenter:
            [self swipeWithOffset:SWIPE_OFFSET toDirection:SwipeDirectionLeft];
            self.cellType = CellTypeLeft;
            break;
    }
}

@end
