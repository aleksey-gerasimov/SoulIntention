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

#import "UIImage+ScaleImage.h"

static CGFloat const ICON_WIDTH = 22.f;
static CGFloat const ICON_HEIGHT = 22.f;

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

    [self showText];
    [self showImage];
    [self setCustomBarButtonItems];

    self.postImageViewWidthConstraint.constant = CGRectGetWidth([UIScreen mainScreen].bounds);
    [self.view layoutIfNeeded];
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

    font = [UIFont fontWithName:@"HelveticaNeue-italic" size:12];
    attributes = @{NSParagraphStyleAttributeName : paragraphStyle, NSFontAttributeName : font, NSForegroundColorAttributeName : [UIColor grayColor]};
    [text setAttributes:attributes range:NSMakeRange(self.post.title.length+2+self.post.text.length+2, self.post.updateDate.length+4+self.post.author.length)];

    self.postTextView.attributedText = text;
    [self.postTextView sizeToFit];
    self.postTextViewHeightConstraint.constant = CGRectGetHeight(self.postTextView.frame);
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
    UIImage *image = [UIImage new];
    CGSize size = CGSizeMake(ICON_WIDTH, ICON_HEIGHT);
    
    image = [UIImage imageNamed:@"ic_facebook"];
    UIBarButtonItem *facebookButtonBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageWithImage:image scaleToSize:size] style:UIBarButtonItemStyleDone target:self action:@selector(facebookButtonPressed)];
    image = [UIImage imageNamed:@"ic_twitter"];
    UIBarButtonItem *twitterButtonBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageWithImage:image scaleToSize:size] style:UIBarButtonItemStyleDone target:self action:@selector(twitterButtonPressed)];
    image = [UIImage imageNamed:@"ic_favorite"];
    UIBarButtonItem *favoriteButtonBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageWithImage:image scaleToSize:size] style:UIBarButtonItemStyleDone target:self action:@selector(favoriteButtonPressed)];
    
    self.navigationItem.rightBarButtonItems = @[facebookButtonBarItem, twitterButtonBarItem, favoriteButtonBarItem];
}

- (void)facebookButtonPressed{
    NSLog(@"PostViewController facebook button press");
    [[FacebookManager sharedManager] presentShareDialogWithText:self.post.title url:nil];
}

- (void)twitterButtonPressed{
    NSLog(@"PostViewController twitter button press");
    [[TwitterManager sharedManager] presentShareDialogWithText:self.post.title url:nil];
}

- (void)favoriteButtonPressed
{
    NSLog(@"PostViewController favorite button press");
    [[SoulIntentionManager sharedManager] addToFavouritesPostWithId:self.post.postId completitionHandler:^(BOOL success, NSArray *result, NSError *error) {
        //
    }];
}

@end
