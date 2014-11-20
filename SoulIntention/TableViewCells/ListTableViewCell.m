//
//  ListTableViewCell.m
//  SoulIntention
//
//  Created by Admin on 11/17/14.
//  Copyright (c) 2014 ThinkMobiles. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

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
    [super awakeFromNib];
    [self initGestureRecognizer];
    [self setButtonImages];
    self.cellType = CellTypeCenter;
    [self subscribeToNotificationCenter];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.postImageView cancelImageRequestOperation];
}

- (UIEdgeInsets)layoutMargins
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cellStateChanged:) name:@"Swipe" object:nil];
}

- (void)cellStateChanged:(NSNotification *)notification
{
    if ([notification object] != self.post.postId) {
        switch (self.cellType) {
            case CellTypeCenter:
                break;
            case CellTypeLeft:
                [self swipeToDirection:SwipeDirectionRight];
                self.cellType = CellTypeCenter;
                break;
            case CellTypeRight:
                [self swipeToDirection:SwipeDirectionLeft];
                self.cellType = CellTypeCenter;
                break;
        }
    }
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
       
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Swipe" object:self.post.postId];
    }];
    
}

- (void)swipeToDirection:(NSInteger)direction
{
    CGFloat offset = SWIPE_OFFSET;
    if (direction == SwipeDirectionLeft) {
        offset = -offset;
    }
    
    [UIView animateWithDuration:0.5f animations:^{
        self.cellView.frame = CGRectOffset(self.cellView.frame, offset, 0.f);
        self.socialView.frame = CGRectOffset(self.socialView.frame, offset, 0.f);
        self.favoriteView.frame = CGRectOffset(self.favoriteView.frame, offset, 0.f);
    }];
}

#pragma mark - Custom Setters

- (void)setPost:(Post *)post
{
    _post = post;
    
    self.titleLabel.text = _post.title;
    self.descriptionLabel.text = _post.text;
    self.dateLabel.text = [NSString stringWithFormat:@"%@ %@", _post.creationDate, _post.author];
#warning IF !image
   /* self.imageWidthConstraint.constant = 0;
    [self layoutIfNeeded];*/

    __weak ListTableViewCell *weakSelf = self;
#warning URL should be changed after custom setter is set in Post model
//    NSString *urlString = [NSString stringWithFormat:@"%@/%@", kBaseURLString, [_post.images firstObject][@"image_url"]];
//    urlString = [urlString stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
    NSURL *url = [NSURL URLWithString:[_post.images firstObject]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.postImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        NSLog(@"Post image load success");
        weakSelf.postImageView.image = image;
        weakSelf.imageWidthConstraint.constant = 120;
        [weakSelf layoutIfNeeded];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"Post image load error: %@", [error localizedDescription]);
        weakSelf.imageWidthConstraint.constant = 0;
        [weakSelf layoutIfNeeded];
    }];
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
