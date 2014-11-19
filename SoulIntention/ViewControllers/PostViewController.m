//
//  PostViewController.m
//  SoulIntention
//
//  Created by Admin on 11/17/14.
//  Copyright (c) 2014 ThinkMobiles. All rights reserved.
//

#import "PostViewController.h"
#import "FacebookManager.h"
#import "TwitterManager.h"
#import "UIImage+ScaleImage.h"

static CGFloat const ICON_WIDTH = 22.f;
static CGFloat const ICON_HEIGHT = 22.f;

@interface PostViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *postPictureHeightConstraint;

@end

@implementation PostViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setCustomBarButtonItems];
}

#pragma mark - Private Methods

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

- (void)facebookButtonPressed
{
    NSLog(@"PostViewController facebook button press");
}

- (void)twitterButtonPressed
{
    NSLog(@"PostViewController twitter button press");
}

- (void)favoriteButtonPressed
{
    NSLog(@"PostViewController favorite button press");
}

#pragma mark - Custom Setters

- (void)setPost:(Post *)post
{
    _post = post;
    if (!_post.pictures) {
        self.postPictureHeightConstraint.constant = 0;
        [self.view layoutIfNeeded];
    }
}

@end
