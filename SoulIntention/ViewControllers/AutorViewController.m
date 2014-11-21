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
#import "AppDelegate.h"
#import "Constants.h"

#import "Author.h"

NSInteger const kAuthorImageViewHeight = 180;

@interface AutorViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *authorImageView;
@property (weak, nonatomic) IBOutlet UITextView *authorTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *authorImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *authorImageViewWidthConstraint;

@end

@implementation AutorViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.authorImageViewWidthConstraint.constant = CGRectGetWidth([UIScreen mainScreen].bounds);

    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    if (appDelegate.sessionStarted) {
        [self getAuthorInfo];
    }

    __weak AutorViewController *weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:kSessionStartedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [weakSelf getAuthorInfo];
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private

- (void)getAuthorInfo
{
    __weak AutorViewController *weakSelf = self;
    [[SoulIntentionManager sharedManager] getAuthorDescriptionWithCompletitionHandler:^(BOOL success, NSArray *result, NSError *error) {
        if (error) {
            return;
        }
        Author *author = [result firstObject];

        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:[author.info dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
        weakSelf.authorTextView.attributedText = attributedString;

        NSURL *url = [NSURL URLWithString:author.imageURL];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [weakSelf.authorImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            NSLog(@"AuthorViewController image load success");
            weakSelf.authorImageView.image = image;
            weakSelf.authorImageViewHeightConstraint.constant = kAuthorImageViewHeight;
            [weakSelf.view layoutIfNeeded];
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            NSLog(@"AuthorViewController image load error: %@", [error localizedDescription]);
            weakSelf.authorImageViewHeightConstraint.constant = 0;
            [weakSelf.view layoutIfNeeded];
        }];
    }];
}

@end
