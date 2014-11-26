//
//  ListTableViewCell.m
//  SoulIntention
//
//  Created by Admin on 11/17/14.
//  Copyright (c) 2014 ThinkMobiles. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

#import "ListTableViewCell.h"

#import "SoulIntentionManager.h"
#import "FacebookManager.h"
#import "TwitterManager.h"
#import "AppDelegate.h"
#import "Constants.h"

#import "Post.h"

#import "UIButton+Image.h"
#import "UIView+LoadingIndicator.h"

static CGFloat const kPostImageViewWidth = 120.f;
static CGFloat const kIconWidth = 30.f;
static CGFloat const kIconHeight = 30.f;
static CGFloat const kSwipeOffset = 107.f;

typedef NS_ENUM(NSInteger, CellType) {
    CellTypeLeft = 0,
    CellTypeCenter = 1,
    CellTypeRight = 2,
};

typedef NS_ENUM(NSInteger, SwipeDirection) {
    SwipeDirectionLeft = 0,
    SwipeDirectionRight = 1,
};

typedef void(^CellSwipeHandler)(void);

@interface ListTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *postImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (weak, nonatomic) IBOutlet UIView *cellView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageWidthConstraint;

@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;

@property (assign, nonatomic) CellType cellType;
@property (strong, nonatomic) AppDelegate *appDelegate;

@end

@implementation ListTableViewCell

#pragma mark - Lifecycle

- (void)awakeFromNib
{
    [super awakeFromNib];

    [self initGestureRecognizer];
    [self setButtonImages];

    self.cellType = CellTypeCenter;
    self.appDelegate = [UIApplication sharedApplication].delegate;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cellStateChanged:) name:kListCellSwipeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favouriteStatusChanged:) name:kFavouriteFlagChangedNotification object:nil];
}

- (void)prepareForReuse
{
    [super prepareForReuse];

    self.imageWidthConstraint.constant = 0;
    [self layoutIfNeeded];

    [self.postImageView cancelImageRequestOperation];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIEdgeInsets)layoutMargins
{
    return UIEdgeInsetsZero;
}

#pragma mark - Custom Accessors

- (void)setPost:(Post *)post
{
    _post = post;

    self.titleLabel.text = _post.title.uppercaseString;
    self.descriptionLabel.text = _post.text;
    self.dateLabel.text = [NSString stringWithFormat:@"%@ By %@", _post.updateDate, _post.author];

    UIImage *normalImage = [UIImage imageNamed:kFavouriteButtonImage];
    UIImage *highlightedImage = [UIImage imageNamed:kFavouriteButtonHighlightedImage];
    [self.favoriteButton setNormalImage:_post.isFavourite ? highlightedImage : normalImage
                       highlightedImage:_post.isFavourite ? normalImage : highlightedImage
                                   size:CGSizeMake(kIconWidth, kIconHeight)];

    __weak ListTableViewCell *weakSelf = self;
    void(^loadImageHandler)(UIImage*, NSInteger) = ^(UIImage *image, NSInteger width){
        weakSelf.postImageView.image = image;
        weakSelf.imageWidthConstraint.constant = width;
        [weakSelf layoutIfNeeded];
    };
    NSURL *url = [NSURL URLWithString:[_post.images firstObject]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.postImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        NSLog(@"Post image load success");
        loadImageHandler(image, kPostImageViewWidth);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"Post image load error: %@", [error localizedDescription]);
        loadImageHandler(nil, 0);
    }];
}

#pragma mark - Private Methods

- (void)setButtonImages
{
    [self.facebookButton setNormalImage:[UIImage imageNamed:kFacebookButtonImage]
                       highlightedImage:[UIImage imageNamed:kFacebookButtonHighlightedImage]
                                   size:CGSizeMake(kIconWidth, kIconHeight)];
    [self.twitterButton setNormalImage:[UIImage imageNamed:kTwitterButtonImage]
                      highlightedImage:[UIImage imageNamed:kTwitterButtonHighlightedImage]
                                  size:CGSizeMake(kIconWidth, kIconHeight)];
}

- (void)swipeWithOffset:(CGFloat)offset toDirection:(NSInteger)direction completitionHandler:(CellSwipeHandler)handler
{
    if (direction == SwipeDirectionLeft) {
        offset = -offset;
    }

    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.cellView.frame = CGRectOffset(self.cellView.frame, offset, 0.f);
    } completion:^(BOOL finished) {
        if (handler) {
            handler();
        }
    }];
}

#pragma mark - Notifications

- (void)cellStateChanged:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    if ([userInfo valueForKey:@"postId"] == self.post.postId) {
        return;
    }

    switch (self.cellType) {
        case CellTypeCenter:
            break;
        case CellTypeLeft:
            [self swipeWithOffset:kSwipeOffset toDirection:SwipeDirectionRight completitionHandler:nil];
            break;
        case CellTypeRight:
            [self swipeWithOffset:kSwipeOffset toDirection:SwipeDirectionLeft completitionHandler:nil];
            break;
    }
    self.cellType = CellTypeCenter;
}

- (void)favouriteStatusChanged:(NSNotification *)note
{
    if (self.post.postId == note.userInfo[@"postId"]) {
        self.post.isFavourite = [(NSNumber *)note.userInfo[@"isFavourite"] boolValue];
        [self swipeWithOffset:kSwipeOffset toDirection:SwipeDirectionLeft completitionHandler:^{
            UIImage *normalImage = [UIImage imageNamed:kFavouriteButtonImage];
            UIImage *highlightedImage = [UIImage imageNamed:kFavouriteButtonHighlightedImage];
            [self.favoriteButton setNormalImage:self.post.isFavourite ? highlightedImage : normalImage
                               highlightedImage:self.post.isFavourite ? normalImage : highlightedImage
                                           size:CGSizeMake(kIconWidth, kIconHeight)];
        }];
        self.cellType = CellTypeCenter;
    }
}

#pragma mark - Public

- (UIImage *)getPostImage
{
    return self.postImageView.image;
}

#pragma mark - IBActions

- (IBAction)favoriteButtonTouchUpInside:(id)sender
{
    NSLog(@"ListTableViewCell favorite button pressed");
    [self showLoadingIndicator];
    NSDictionary *notificationDictionary = @{@"postId" : self.post.postId, @"isFavourite" : @(!self.post.isFavourite)};
    __weak ListTableViewCell *weakSelf = self;
    if (self.post.isFavourite) {
        [[SoulIntentionManager sharedManager] removeFromFavouritesPostWithId:self.post.postId completitionHandler:^(BOOL success, NSArray *result, NSError *error) {
            [weakSelf hideLoadingIndicator];
            if (error) {
                [weakSelf.appDelegate showAlertViewWithTitle:@"Error" message:@"Failed to remove post from favourites"];
                return;
            } else {
                [weakSelf.appDelegate.favouritesIdsArray removeObject:weakSelf.post.postId];
                [[NSNotificationCenter defaultCenter] postNotificationName:kFavouriteFlagChangedNotification object:nil userInfo:notificationDictionary];
            }
        }];
    } else {
        [[SoulIntentionManager sharedManager] addToFavouritesPostWithId:self.post.postId completitionHandler:^(BOOL success, NSArray *result, NSError *error) {
            [weakSelf hideLoadingIndicator];
            if (error) {
                [weakSelf.appDelegate showAlertViewWithTitle:@"Error" message:@"Failed to add post to favourites"];
                return;
            } else {
                [weakSelf.appDelegate.favouritesIdsArray addObject:weakSelf.post.postId];
                [[NSNotificationCenter defaultCenter] postNotificationName:kFavouriteFlagChangedNotification object:nil userInfo:notificationDictionary];
            }
        }];
    }
}

- (IBAction)facebookButtonTouchUpInside:(id)sender {
    NSLog(@"ListTableViewCell facebook button pressed");
    [[FacebookManager sharedManager] presentShareDialogWithText:self.titleLabel.text url:[NSURL URLWithString:kMainPageURLString]];
}

- (IBAction)twitterButtonTouchUpInside:(id)sender {
    NSLog(@"ListTableViewCell twitter button pressed");
    [[TwitterManager sharedManager] presentShareDialogWithText:self.titleLabel.text url:[NSURL URLWithString:kMainPageURLString]];
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

- (void)swipeToRightWithGestureRecognizer:(UISwipeGestureRecognizer *)gestureRecogniser
{
    switch (self.cellType) {
        case CellTypeRight:
            return; //no need to post notification
        case CellTypeLeft:
            [self swipeWithOffset:kSwipeOffset toDirection:SwipeDirectionRight completitionHandler:nil];
            self.cellType = CellTypeCenter;
            break;
        case CellTypeCenter:
            [self swipeWithOffset:kSwipeOffset toDirection:SwipeDirectionRight completitionHandler:nil];
            self.cellType = CellTypeRight;
            break;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kListCellSwipeNotification object:nil userInfo:@{@"postId" : self.post.postId}];
}

- (void)swipeToLeftWithGestureRecognizer:(UISwipeGestureRecognizer *)gestureRecogniser
{
    switch (self.cellType) {
        case CellTypeRight:
            [self swipeWithOffset:kSwipeOffset toDirection:SwipeDirectionLeft completitionHandler:nil];
            self.cellType = CellTypeCenter;
            break;
        case CellTypeLeft:
            return; //no need to post notification
        case CellTypeCenter:
            [self swipeWithOffset:kSwipeOffset toDirection:SwipeDirectionLeft completitionHandler:nil];
            self.cellType = CellTypeLeft;
            break;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kListCellSwipeNotification object:nil userInfo:@{@"postId" : self.post.postId}];
}

@end
