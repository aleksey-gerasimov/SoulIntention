//
//  PostViewController.m
//  SoulIntention
//
//  Created by Admin on 11/17/14.
//  Copyright (c) 2014 ThinkMobiles. All rights reserved.
//

#import "PostViewController.h"

#import "SoulIntentionManager.h"
#import "FacebookManager.h"
#import "TwitterManager.h"
#import "AppDelegate.h"
#import "Constants.h"

#import "Post.h"

#import "UIButton+Image.h"
#import "UIView+LoadingIndicator.h"

//static CGFloat const kIconWidth = 22.f;
//static CGFloat const kIconHeight = 22.f;

@interface PostViewController ()

@property (weak, nonatomic) IBOutlet UIView *postTitleView;
@property (weak, nonatomic) IBOutlet UILabel *postTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *postTitleRatingView;
@property (weak, nonatomic) IBOutlet UIImageView *postImageView;
@property (weak, nonatomic) IBOutlet UITextView *postTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *postImageViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *postImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *postTextViewHeightConstraint;

@end

@implementation PostViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Soul Intentions";

    [self showImage];
    [self showText];
    [self setCustomBarButtonItems];
    [self customizeTitleView];

    self.postTextView.textContainerInset = UIEdgeInsetsMake(0.0, 6.0, 0.0, 6.0);
    self.postImageViewWidthConstraint.constant = CGRectGetWidth([UIScreen mainScreen].bounds);
    [self.view layoutIfNeeded];

    __weak PostViewController *weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:kFavoriteFlagChangedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        weakSelf.post.isFavorite = [(NSNumber *)note.userInfo[@"isFavorite"] boolValue];
        UIImage *normalImage = [UIImage imageNamed:kFavoriteNavigationButtonImage];
        UIImage *highlightedImage = [UIImage imageNamed:kFavoriteNavigationButtonHighlightedImage];
        UIBarButtonItem *barButtonItem = [weakSelf.navigationItem.rightBarButtonItems lastObject];
        UIButton *favoriteButton = (UIButton *)barButtonItem.customView;
        [favoriteButton setNormalImage:weakSelf.post.isFavorite ? highlightedImage : normalImage
                      highlightedImage:weakSelf.post.isFavorite ? normalImage : highlightedImage
                                  size:CGSizeMake(kIconWidth, kIconHeight)];
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private Methods

- (void)showText
{
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n%@ By %@", self.post.text, self.post.updateDate, self.post.author]];

    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.firstLineHeadIndent = 10;
    paragraphStyle.headIndent = 10;
    paragraphStyle.tailIndent = -10;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:16];
    NSDictionary *attributes = @{NSParagraphStyleAttributeName : paragraphStyle, NSFontAttributeName : font};
    [text setAttributes:attributes range:NSMakeRange(0, self.post.text.length)];

    font = [UIFont fontWithName:@"HelveticaNeue" size:13];
    attributes = @{NSParagraphStyleAttributeName : paragraphStyle, NSFontAttributeName : font, NSForegroundColorAttributeName : [UIColor grayColor]};
    [text setAttributes:attributes range:NSMakeRange(self.post.text.length, 2+self.post.updateDate.length+4+self.post.author.length)];

    self.postTextView.attributedText = text;

    CGFloat textViewWidth = CGRectGetWidth(self.view.frame) - CGRectGetMinX(self.postTextView.frame) - (CGRectGetWidth(self.view.frame) - CGRectGetMaxX(self.postTextView.frame));
    CGFloat textViewHeight = CGRectGetHeight(self.view.frame) - CGRectGetMinY(self.postTextView.frame);
    CGSize textViewSize = CGSizeMake(textViewWidth, textViewHeight);

    CGRect requiredTextRect = [text boundingRectWithSize:textViewSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    CGFloat ceilWidth = ceil(CGRectGetWidth(requiredTextRect));
    CGFloat ceilHeight = ceil(CGRectGetHeight(requiredTextRect));
    requiredTextRect = CGRectMake(CGRectGetMinX(requiredTextRect), CGRectGetMinY(requiredTextRect), ceilWidth, ceilHeight);

    CGSize requiredSize = [self.postTextView sizeThatFits:requiredTextRect.size];
    self.postTextViewHeightConstraint.constant = requiredSize.height > textViewSize.height ? requiredSize.height : textViewSize.height;
    [self.view layoutIfNeeded];
}

- (void)showImage
{
    self.postImageView.image = self.postImage;
    if (self.postImage) {
        self.postImageViewHeightConstraint.constant = 180;
    } else {
        self.postImageViewHeightConstraint.constant = 0;
    }
    [self.view layoutIfNeeded];
}

- (void)setCustomBarButtonItems
{
    CGSize size = CGSizeMake(kIconWidth, kIconHeight);
    UIImage *normalImage = [UIImage imageNamed:kFavoriteNavigationButtonImage];
    UIImage *highlightedImage = [UIImage imageNamed:kFavoriteNavigationButtonHighlightedImage];
    UIBarButtonItem *favoriteBarButtonItem = [UIButton createBarButtonItemWithNormalImage:normalImage highlightedImage:highlightedImage size:size isHighlighted:self.post.isFavorite actionTarget:self selector:@selector(favoriteButtonPressed:)];
    self.navigationItem.rightBarButtonItem = favoriteBarButtonItem;

    normalImage = [UIImage imageNamed:kBackButtonImage];
    UIBarButtonItem *backBarButtonItem = [UIButton createBarButtonItemWithNormalImage:normalImage highlightedImage:normalImage size:size isHighlighted:NO actionTarget:self selector:@selector(backButtonPressed:)];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
}

- (void)customizeTitleView
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSInteger randomIndex = arc4random_uniform((int)appDelegate.postHeaderBackgroundColorsArray.count);
    self.postTitleView.backgroundColor = appDelegate.postHeaderBackgroundColorsArray[randomIndex];

    randomIndex = arc4random_uniform((int)appDelegate.postHeaderTitleFontNamesArray.count);
    self.postTitleLabel.font = [UIFont fontWithName:appDelegate.postHeaderTitleFontNamesArray[randomIndex] size:35.0];
    self.postTitleLabel.text = self.post.title;

    self.postTitleRatingView.backgroundColor = self.navigationController.navigationBar.barTintColor;
    [self changeRatingTo:roundf(self.post.rate.floatValue)];
}

- (void)changeRatingTo:(NSInteger)rating
{
    for (UIButton *subview in self.postTitleRatingView.subviews) {
        if (subview.tag == 0) {
            continue;
        }
        [subview setImage:subview.tag > rating ? [UIImage imageNamed:@"ic_star"] : [UIImage imageNamed:@"ic_star_select"] forState:UIControlStateNormal];
    }
}

#pragma mark - IBActions

- (IBAction)facebookButtonPressed:(id)sender
{
    [[FacebookManager sharedManager] presentShareDialogWithText:self.post.title url:[NSURL URLWithString:kMainPageURLString]];
}

- (IBAction)twitterButtonPressed:(id)sender
{
    [[TwitterManager sharedManager] presentShareDialogWithText:self.post.title url:[NSURL URLWithString:kMainPageURLString]];
}

- (IBAction)favoriteButtonPressed:(id)sender
{
    [self.view showLoadingIndicator];
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NSDictionary *notificationDictionary = @{@"postId" : self.post.postId, @"isFavorite" : @(!self.post.isFavorite)};
    __weak PostViewController *weakSelf = self;
    if (self.post.isFavorite) {
        [[SoulIntentionManager sharedManager] removeFromFavoritesPostWithId:self.post.postId completitionHandler:^(BOOL success, NSArray *result, NSError *error) {
            [weakSelf.view hideLoadingIndicator];
            if (error) {
                [appDelegate showAlertViewWithTitle:@"Error" message:@"Failed to remove post from favorites"];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:kFavoriteFlagChangedNotification object:nil userInfo:notificationDictionary];
            }
        }];
    } else {
        [[SoulIntentionManager sharedManager] addToFavoritesPostWithId:self.post.postId completitionHandler:^(BOOL success, NSArray *result, NSError *error) {
            [weakSelf.view hideLoadingIndicator];
            if (error) {
                [appDelegate showAlertViewWithTitle:@"Error" message:@"Failed to add post to favorites"];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:kFavoriteFlagChangedNotification object:nil userInfo:notificationDictionary];
            }
        }];
    }
}

- (IBAction)starButtonPressed:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSString *rateString = @(button.tag).stringValue;
    [[SoulIntentionManager sharedManager] ratePostWithId:self.post.postId rating:rateString completitionHandler:^(BOOL success, NSArray *result, NSError *error) {
        if (error) {
            return;
        }
        self.post.rate = rateString;
        [self changeRatingTo:button.tag];
    }];
}

- (IBAction)backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
