//
//  PostViewController.m
//  SoulIntention
//
//  Created by Admin on 11/17/14.
//  Copyright (c) 2014 ThinkMobiles. All rights reserved.
//

#define ICON_WIDTH 22.f
#define ICON_HEIGHT 22.f

#import "PostViewController.h"
#import "UIImage+ScaleImage.h"

@interface PostViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *postPictureHeightConstraint;

@end

@implementation PostViewController

#pragma mark - Lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
    [self setCustomBarButtonItems];
}

#pragma mark - Private Methods

- (void)setCustomBarButtonItems{
    UIBarButtonItem *facebookButtonBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageWithImage:[UIImage imageNamed:@"ic_facebook"] scaleToSize:CGSizeMake(ICON_WIDTH, ICON_HEIGHT)] style:UIBarButtonItemStyleDone target:self action:@selector(facebookButtonPressed)];
    UIBarButtonItem *twitterButtonBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageWithImage:[UIImage imageNamed:@"ic_twitter"] scaleToSize:CGSizeMake(ICON_WIDTH, ICON_HEIGHT)] style:UIBarButtonItemStyleDone target:self action:@selector(twitterButtonPressed)];
    UIBarButtonItem *favoriteButtonBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageWithImage:[UIImage imageNamed:@"ic_favorite"] scaleToSize:CGSizeMake(ICON_WIDTH, ICON_HEIGHT)] style:UIBarButtonItemStyleDone target:self action:@selector(favoriteButtonPressed)];
    
    self.navigationItem.rightBarButtonItems = @[facebookButtonBarItem, twitterButtonBarItem, favoriteButtonBarItem];
    
}

- (void)facebookButtonPressed{
    NSLog(@"facebook button");
}

- (void)twitterButtonPressed{
    NSLog(@"twitter button");
}

- (void)favoriteButtonPressed{
    NSLog(@"favorite button");
}

#pragma mark - Custom Setters

- (void)setPost:(Post *)post{
    _post = post;
    if (!_post.pictures) {
        self.postPictureHeightConstraint.constant = 0;
        [self.view layoutIfNeeded];
    }
}

@end
