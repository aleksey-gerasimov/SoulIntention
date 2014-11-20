//
//  AutorViewController.m
//  SoulIntention
//
//  Created by Admin on 11/18/14.
//  Copyright (c) 2014 ThinkMobiles. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

#import "AutorViewController.h"
#import "SoulIntentionManager.h"
#import "Author.h"
#import "AppDelegate.h"

@interface AutorViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *authorImageView;
@property (weak, nonatomic) IBOutlet UITextView *authorTextView;

@end

@implementation AutorViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    if (appDelegate.sessionStarted) {
        [self getAuthorInfo];
    }

    __weak AutorViewController *weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:kSessionStartedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [weakSelf getAuthorInfo];
    }];
}

- (void)getAuthorInfo
{
    __weak AutorViewController *weakSelf = self;
    [[SoulIntentionManager sharedManager] getAuthorDescriptionWithCompletitionHandler:^(BOOL success, NSArray *result, NSError *error) {
        if (error) {
            return;
        }

        Author *author = [result firstObject];
        weakSelf.authorTextView.text = author.info;
        NSURL *url = [NSURL URLWithString:author.imageURL];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [weakSelf.authorImageView setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"autor_img.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            NSLog(@"AuthorViewController image load success");
            weakSelf.authorImageView.image = image;
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            NSLog(@"AuthorViewController image load error: %@", [error localizedDescription]);
        }];
    }];
}

@end
