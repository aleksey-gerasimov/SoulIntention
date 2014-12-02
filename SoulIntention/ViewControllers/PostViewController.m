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

static CGFloat const kIconWidth = 22.f;
static CGFloat const kIconHeight = 22.f;

@interface PostViewController ()

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
    self.navigationItem.title = @"Soul Intention";

    [self showImage];
    [self showText];
    [self setCustomBarButtonItems];

    self.postTextView.textContainerInset = UIEdgeInsetsMake(0.0, 6.0, 0.0, 6.0);
    self.postImageViewWidthConstraint.constant = CGRectGetWidth([UIScreen mainScreen].bounds);
    [self.view layoutIfNeeded];

    __weak PostViewController *weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:kFavoriteFlagChangedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        weakSelf.post.isFavorite = [(NSNumber *)note.userInfo[@"isFavorite"] boolValue];
        UIImage *normalImage = [UIImage imageNamed:kFavoriteButtonImage];
        UIImage *highlightedImage = [UIImage imageNamed:kFavoriteButtonHighlightedImage];
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
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n%@\n\n%@ By %@", self.post.title.uppercaseString, self.post.text, self.post.updateDate, self.post.author]];

    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    paragraphStyle.firstLineHeadIndent = 10;
    paragraphStyle.headIndent = 10;
    paragraphStyle.tailIndent = -10;
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-bold" size:18];
    NSDictionary *attributes = @{NSParagraphStyleAttributeName : paragraphStyle, NSFontAttributeName : font};
    [text setAttributes:attributes range:NSMakeRange(0, self.post.title.length)];

    paragraphStyle = [paragraphStyle mutableCopy];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    attributes = @{NSParagraphStyleAttributeName : paragraphStyle, NSFontAttributeName : font};
    [text setAttributes:attributes range:NSMakeRange(self.post.title.length+2, self.post.text.length)];

    font = [UIFont fontWithName:@"HelveticaNeue" size:12];
    attributes = @{NSParagraphStyleAttributeName : paragraphStyle, NSFontAttributeName : font, NSForegroundColorAttributeName : [UIColor grayColor]};
    [text setAttributes:attributes range:NSMakeRange(self.post.title.length+2+self.post.text.length+2, self.post.updateDate.length+4+self.post.author.length)];

    self.postTextView.attributedText = text;
    CGSize textViewSize = CGSizeMake(CGRectGetWidth(self.view.frame) - CGRectGetMinX(self.postTextView.frame), CGRectGetHeight(self.view.frame) - CGRectGetMinY(self.postTextView.frame));
    CGRect requiredTextRect = [text boundingRectWithSize:textViewSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
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

    UIImage *normalImage = [UIImage imageNamed:kFacebookButtonImage];
    UIImage *highlightedImage = [UIImage imageNamed:kFacebookButtonHighlightedImage];
    UIBarButtonItem *facebookBarButtonItem = [UIButton createBarButtonItemWithNormalImage:normalImage highlightedImage:highlightedImage size:size isHighlighted:NO actionTarget:self selector:@selector(facebookButtonPressed:)];

    normalImage = [UIImage imageNamed:kTwitterButtonImage];
    highlightedImage = [UIImage imageNamed:kTwitterButtonHighlightedImage];
    UIBarButtonItem *twitterBarButtonItem = [UIButton createBarButtonItemWithNormalImage:normalImage highlightedImage:highlightedImage size:size isHighlighted:NO actionTarget:self selector:@selector(twitterButtonPressed:)];

    normalImage = [UIImage imageNamed:kFavoriteButtonImage];
    highlightedImage = [UIImage imageNamed:kFavoriteButtonHighlightedImage];
    UIBarButtonItem *favoriteBarButtonItem = [UIButton createBarButtonItemWithNormalImage:normalImage highlightedImage:highlightedImage size:size isHighlighted:self.post.isFavorite actionTarget:self selector:@selector(favoriteButtonPressed:)];

    self.navigationItem.rightBarButtonItems = @[facebookBarButtonItem, twitterBarButtonItem, favoriteBarButtonItem];

    normalImage = [UIImage imageNamed:kBackButtonImage];
    UIBarButtonItem *backBarButtonItem = [UIButton createBarButtonItemWithNormalImage:normalImage highlightedImage:normalImage size:size isHighlighted:NO actionTarget:self selector:@selector(backButtonPressed:)];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
}

#pragma mark - IBActions

- (IBAction)facebookButtonPressed:(id)sender
{
    NSLog(@"PostViewController facebook button press");
    [[FacebookManager sharedManager] presentShareDialogWithText:self.post.title url:[NSURL URLWithString:kMainPageURLString]];
}

- (IBAction)twitterButtonPressed:(id)sender
{
    NSLog(@"PostViewController twitter button press");
    [[TwitterManager sharedManager] presentShareDialogWithText:self.post.title url:[NSURL URLWithString:kMainPageURLString]];
}

- (IBAction)favoriteButtonPressed:(id)sender
{
    NSLog(@"PostViewController favorite button press");
    [self.view showLoadingIndicator];
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NSDictionary *notificationDictionary = @{@"postId" : self.post.postId, @"isFavorite" : @(!self.post.isFavorite)};
    __weak PostViewController *weakSelf = self;
    if (self.post.isFavorite) {
        [[SoulIntentionManager sharedManager] removeFromFavoritesPostWithId:self.post.postId completitionHandler:^(BOOL success, NSArray *result, NSError *error) {
            [weakSelf.view hideLoadingIndicator];
            if (error) {
                [appDelegate showAlertViewWithTitle:@"Error" message:@"Failed to remove post from favorites"];
                return;
            } else {
                [appDelegate.favoritesIdsArray removeObject:weakSelf.post.postId];
                [[NSNotificationCenter defaultCenter] postNotificationName:kFavoriteFlagChangedNotification object:nil userInfo:notificationDictionary];
            }
        }];
    } else {
        [[SoulIntentionManager sharedManager] addToFavoritesPostWithId:self.post.postId completitionHandler:^(BOOL success, NSArray *result, NSError *error) {
            [weakSelf.view hideLoadingIndicator];
            if (error) {
                [appDelegate showAlertViewWithTitle:@"Error" message:@"Failed to add post to favorites"];
                return;
            } else {
                [appDelegate.favoritesIdsArray addObject:weakSelf.post.postId];
                [[NSNotificationCenter defaultCenter] postNotificationName:kFavoriteFlagChangedNotification object:nil userInfo:notificationDictionary];
            }
        }];
    }
}

- (IBAction)backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
