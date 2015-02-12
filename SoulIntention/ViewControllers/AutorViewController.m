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

static NSInteger const kAuthorImageViewHeight = 180;

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

    self.authorTextView.textContainerInset = UIEdgeInsetsMake(0.0, 16.0, 0.0, 16.0);
    self.authorImageViewWidthConstraint.constant = CGRectGetWidth([UIScreen mainScreen].bounds);
    self.authorImageViewHeightConstraint.constant = 0;
    [self.view layoutIfNeeded];

    self.appDelegate = [UIApplication sharedApplication].delegate;
    if (self.appDelegate.sessionStarted) {
        [self getAuthorInfo];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAuthorInfo) name:kSessionStartedNotification object:nil];
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

        CGFloat textViewWidth = CGRectGetWidth(self.view.frame) - CGRectGetMinX(self.authorTextView.frame) - (CGRectGetWidth(self.view.frame) - CGRectGetMaxX(self.authorTextView.frame));
        CGFloat textViewHeight = CGRectGetHeight(self.view.frame) - CGRectGetMinY(self.authorTextView.frame);
        CGSize textViewSize = CGSizeMake(textViewWidth, textViewHeight);

        CGRect requiredTextRect = [attributedString boundingRectWithSize:textViewSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        CGFloat ceilWidth = ceil(CGRectGetWidth(requiredTextRect));
        CGFloat ceilHeight = ceil(CGRectGetHeight(requiredTextRect));
        requiredTextRect = CGRectMake(CGRectGetMinX(requiredTextRect), CGRectGetMinY(requiredTextRect), ceilWidth, ceilHeight);

        CGSize requiredSize = [self.authorTextView sizeThatFits:requiredTextRect.size];
        self.authorTextViewHeightConstraint.constant = requiredSize.height > textViewSize.height ? requiredSize.height : textViewSize.height;
        [self.view layoutIfNeeded];

//        [weakSelf.authorTextView sizeToFit];
//        weakSelf.authorTextViewHeightConstraint.constant = CGRectGetHeight(weakSelf.authorTextView.frame);
//        [self.view layoutIfNeeded];

        void(^loadImageHandler)(UIImage *, NSInteger) = ^(UIImage *image, NSInteger height) {
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
