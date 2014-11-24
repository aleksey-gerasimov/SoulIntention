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

#import "UIView+LoadingIndicator.h"

NSInteger const kAuthorImageViewHeight = 180;

@interface AutorViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *authorImageView;
@property (weak, nonatomic) IBOutlet UITextView *authorTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *authorImageViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *authorImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *authorTextViewHeightConstraint;

@property (strong, nonatomic) AppDelegate *appDelegate;

@end

@implementation AutorViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.authorImageViewWidthConstraint.constant = CGRectGetWidth([UIScreen mainScreen].bounds);
    [self.view layoutIfNeeded];

    self.appDelegate = [UIApplication sharedApplication].delegate;
    if (self.appDelegate.sessionStarted) {
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
    [self.view showLoadingIndicator];
    __weak AutorViewController *weakSelf = self;
    [[SoulIntentionManager sharedManager] getAuthorDescriptionWithCompletitionHandler:^(BOOL success, NSArray *result, NSError *error) {
        [weakSelf.view hideLoadingIndicator];
        if (error) {
            [weakSelf.appDelegate showAlertViewWithTitle:@"Error" message:@"Failed to get author info"];
            return;
        }
        Author *author = [result firstObject];

        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:[author.info dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
        weakSelf.authorTextView.attributedText = attributedString;
        [weakSelf.authorTextView sizeToFit];
        weakSelf.authorTextViewHeightConstraint.constant = CGRectGetHeight(weakSelf.authorTextView.frame);

        void(^loadImageHandler)(UIImage*, NSInteger) = ^(UIImage *image, NSInteger height){
            weakSelf.authorImageView.image = image;
            weakSelf.authorImageViewHeightConstraint.constant = height;
            [weakSelf.view layoutIfNeeded];
        };
        NSURL *url = [NSURL URLWithString:author.imageURL];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [weakSelf.authorImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            NSLog(@"AuthorViewController image load success");
            loadImageHandler(image, kAuthorImageViewHeight);
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            NSLog(@"AuthorViewController image load error: %@", [error localizedDescription]);
            loadImageHandler(nil, 0);
        }];
    }];
}

@end
