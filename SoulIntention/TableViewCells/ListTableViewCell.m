//
//  ListTableViewCell.m
//  SoulIntention
//
//  Created by Admin on 11/17/14.
//  Copyright (c) 2014 ThinkMobiles. All rights reserved.
//

#import "ListTableViewCell.h"

#import "SoulIntentionManager.h"
#import "FacebookManager.h"
#import "TwitterManager.h"
#import "AppDelegate.h"
#import "Constants.h"

#import "Post.h"

#import "UIButton+Image.h"
#import "UIView+LoadingIndicator.h"

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

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (weak, nonatomic) IBOutlet UIView *cellView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cellViewCenterXConstraint;

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

    self.cellType = CellTypeCenter;
    self.appDelegate = [UIApplication sharedApplication].delegate;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cellStateChanged:) name:kListCellSwipeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favoriteStatusChanged:) name:kFavoriteFlagChangedNotification object:nil];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    if (self.cellType != CellTypeCenter) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kListCellSwipeNotification object:nil userInfo:@{@"postId" : @""}];
    }
}

- (void)dealloc
{
    NSLog(@"%@ dealloc", NSStringFromClass([self class]));
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
    [self changeFavoriteButtonToFavorite:_post.isFavorite];
}

#pragma mark - Private

- (void)changeFavoriteButtonToFavorite:(BOOL)favorite
{
    UIImage *normalImage = [UIImage imageNamed:kFavoriteButtonImage];
    UIImage *highlightedImage = [UIImage imageNamed:kFavoriteButtonHighlightedImage];
    [self.favoriteButton setNormalImage:favorite ? highlightedImage : normalImage
                       highlightedImage:favorite ? normalImage : highlightedImage];
}

- (void)swipeWithOffset:(CGFloat)offset toDirection:(NSInteger)direction animate:(BOOL)animate completitionHandler:(CellSwipeHandler)handler
{
    if (direction == SwipeDirectionLeft) {
        offset = -offset;
    }
    self.cellViewCenterXConstraint.constant = self.cellViewCenterXConstraint.constant - offset;

    if (animate) {
        [UIView animateWithDuration:kAnimationDuration animations:^{
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            if (handler) {
                handler();
            }
        }];
    } else {
        [self layoutIfNeeded];
        if (handler) {
            handler();
        }
    }
}

#pragma mark - Notifications

- (void)cellStateChanged:(NSNotification *)notification
{
    NSString *postId = (NSString *)[notification.userInfo valueForKey:@"postId"];
    if ([postId isEqualToString:self.post.postId]) {
        return;
    }

    BOOL animate = (BOOL)[notification.userInfo valueForKey:@"animate"];
    switch (self.cellType) {
        case CellTypeCenter:
            break;
        case CellTypeLeft:
            [self swipeWithOffset:kSwipeOffset toDirection:SwipeDirectionRight animate:animate completitionHandler:nil];
            break;
        case CellTypeRight:
            [self swipeWithOffset:kSwipeOffset toDirection:SwipeDirectionLeft animate:animate completitionHandler:nil];
            break;
    }
    self.cellType = CellTypeCenter;
}

- (void)favoriteStatusChanged:(NSNotification *)note
{
    if ([self.post.postId isEqualToString:note.userInfo[@"postId"]]) {
        self.post.isFavorite = [(NSNumber *)note.userInfo[@"isFavorite"] boolValue];
        [self changeFavoriteButtonToFavorite:self.post.isFavorite];
    }
}

#pragma mark - IBActions

- (IBAction)favoriteButtonTouchUpInside:(id)sender
{
    [self showLoadingIndicator];
    NSDictionary *notificationDictionary = @{@"postId" : self.post.postId, @"isFavorite" : @(!self.post.isFavorite)};
    __weak ListTableViewCell *weakSelf = self;
    if (self.post.isFavorite) {
        [[SoulIntentionManager sharedManager] removeFromFavoritesPostWithId:self.post.postId completitionHandler:^(BOOL success, NSArray *result, NSError *error) {
            [weakSelf hideLoadingIndicator];
            if (error) {
                [weakSelf.appDelegate showAlertViewWithTitle:@"Error" message:@"Failed to remove post from favorites"];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:kFavoriteFlagChangedNotification object:nil userInfo:notificationDictionary];
            }
        }];
    } else {
        [[SoulIntentionManager sharedManager] addToFavoritesPostWithId:self.post.postId completitionHandler:^(BOOL success, NSArray *result, NSError *error) {
            [weakSelf hideLoadingIndicator];
            if (error) {
                [weakSelf.appDelegate showAlertViewWithTitle:@"Error" message:@"Failed to add post to favorites"];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:kFavoriteFlagChangedNotification object:nil userInfo:notificationDictionary];
            }
        }];
    }
}

- (IBAction)facebookButtonTouchUpInside:(id)sender {
    [[FacebookManager sharedManager] presentShareDialogWithText:self.titleLabel.text url:[NSURL URLWithString:kMainPageURLString]];
}

- (IBAction)twitterButtonTouchUpInside:(id)sender {
    [[TwitterManager sharedManager] presentShareDialogWithText:self.titleLabel.text url:[NSURL URLWithString:kMainPageURLString]];
}


#pragma mark - Swipe Gesture Recognizer

- (void)initGestureRecognizer
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapWithGestureRecognizer:)];

    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToLeftWithGestureRecognizer:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToRightWithGestureRecognizer:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionLeft;

    [self.cellView addGestureRecognizer:tap];
    [self.cellView addGestureRecognizer:swipeLeft];
    [self.cellView addGestureRecognizer:swipeRight];
}

- (void)tapWithGestureRecognizer:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([self.delegate respondsToSelector:@selector(cellSelectedWithPost:)]) {
        [self.delegate cellSelectedWithPost:self.post];
    }
}

- (void)swipeToRightWithGestureRecognizer:(UISwipeGestureRecognizer *)gestureRecogniser
{
    switch (self.cellType) {
        case CellTypeRight:
            return; //no need to post notification
        case CellTypeLeft:
            [self swipeWithOffset:kSwipeOffset toDirection:SwipeDirectionRight animate:YES completitionHandler:nil];
            self.cellType = CellTypeCenter;
            break;
        case CellTypeCenter:
            [self swipeWithOffset:kSwipeOffset toDirection:SwipeDirectionRight animate:YES completitionHandler:nil];
            self.cellType = CellTypeRight;
            break;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kListCellSwipeNotification object:nil userInfo:@{@"postId" : self.post.postId, @"animate" : @YES}];
}

- (void)swipeToLeftWithGestureRecognizer:(UISwipeGestureRecognizer *)gestureRecogniser
{
    switch (self.cellType) {
        case CellTypeRight:
            [self swipeWithOffset:kSwipeOffset toDirection:SwipeDirectionLeft animate:YES completitionHandler:nil];
            self.cellType = CellTypeCenter;
            break;
        case CellTypeLeft:
            return; //no need to post notification
        case CellTypeCenter:
            [self swipeWithOffset:kSwipeOffset toDirection:SwipeDirectionLeft animate:YES completitionHandler:nil];
            self.cellType = CellTypeLeft;
            break;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kListCellSwipeNotification object:nil userInfo:@{@"postId" : self.post.postId, @"animate" : @YES}];
}

@end
