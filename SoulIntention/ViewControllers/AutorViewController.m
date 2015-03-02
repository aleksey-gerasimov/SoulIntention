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

@interface AutorViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *authorImageView;
@property (weak, nonatomic) IBOutlet UITextView *authorTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *authorImageViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *authorImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *authorTextViewHeightConstraint;

@property (strong, nonatomic) AppDelegate *appDelegate;
@property (assign, nonatomic) BOOL isLoadingInfo;

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
    NSLog(@"%@ dealloc", NSStringFromClass([self class]));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Custom Accessors

- (void)setIsLoadingInfo:(BOOL)isLoadingInfo
{
    _isLoadingInfo = isLoadingInfo;
    
    if (isLoadingInfo) {
        CGPoint contentOffset = self.scrollView.contentOffset;
        self.scrollView.scrollEnabled = NO;
        self.scrollView.contentOffset = contentOffset;
        [UIView animateWithDuration:kAnimationDuration animations:^{
            self.scrollView.contentOffset = CGPointZero;
        } completion:^(BOOL finished) {
            self.scrollView.scrollEnabled = YES;
        }];
    }
}

#pragma mark - Private

- (void)getAuthorInfo
{
    self.isLoadingInfo = YES;
    [self.view showLoadingIndicator];
    __weak AutorViewController *weakSelf = self;
    [[SoulIntentionManager sharedManager] getAuthorDescriptionWithCompletitionHandler:^(BOOL success, NSArray *result, NSError *error) {
        [weakSelf.view hideLoadingIndicator];
        weakSelf.isLoadingInfo = NO;
        if (error) {
            [weakSelf.appDelegate showAlertViewWithTitle:@"Error" message:@"Failed to get author info"];
            return;
        }
        Author *author = [result firstObject];

        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithData:[author.info dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = kDescriptionLineSpacing;
        NSDictionary *dictionary = @{NSParagraphStyleAttributeName : paragraphStyle};
        [attributedString addAttributes:dictionary range:NSMakeRange(0, attributedString.length)];
        weakSelf.authorTextView.attributedText = attributedString;

        CGFloat textViewWidth = CGRectGetWidth(weakSelf.view.frame) - CGRectGetMinX(weakSelf.authorTextView.frame) - (CGRectGetWidth(weakSelf.view.frame) - CGRectGetMaxX(weakSelf.authorTextView.frame));
        CGFloat textViewHeight = CGRectGetHeight(weakSelf.view.frame) - CGRectGetMinY(weakSelf.authorTextView.frame);
        CGSize textViewSize = CGSizeMake(textViewWidth, textViewHeight);

        CGRect requiredTextRect = [attributedString boundingRectWithSize:textViewSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        CGFloat ceilWidth = ceil(CGRectGetWidth(requiredTextRect));
        CGFloat ceilHeight = ceil(CGRectGetHeight(requiredTextRect));
        requiredTextRect = CGRectMake(CGRectGetMinX(requiredTextRect), CGRectGetMinY(requiredTextRect), ceilWidth, ceilHeight);

        CGSize requiredSize = [weakSelf.authorTextView sizeThatFits:requiredTextRect.size];
        weakSelf.authorTextViewHeightConstraint.constant = requiredSize.height > textViewSize.height ? requiredSize.height : textViewSize.height;
        [weakSelf.view layoutIfNeeded];

        [weakSelf getAuthorImageWithURL:author.imageURL];
    }];
}

- (void)getAuthorImageWithURL:(NSString *)imageURL
{
    self.authorImageViewHeightConstraint.constant = 0.0;
    [self.view layoutIfNeeded];

    if (imageURL.length == 0) {
        NSLog(@"AuthorViewController no image");
        return;
    }

    __weak AutorViewController *weakSelf = self;
    NSURL *url = [NSURL URLWithString:imageURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"AuthorViewController image load success");
        weakSelf.authorImageView.image = [UIImage imageWithData:responseObject];
        weakSelf.authorImageViewHeightConstraint.constant = kImageHeight;
        [weakSelf.view layoutIfNeeded];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"AuthorViewController image load error: %@", [error localizedDescription]);
    }];
    [operation start];
}

#pragma mark - ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.isLoadingInfo || scrollView.decelerating) {
        return;
    }
    
    CGFloat scrollViewContentOffsetY = scrollView.contentOffset.y;
    if (scrollViewContentOffsetY <= -kLoadingOnScrollOffsetY) {
        [self getAuthorInfo];
    }
}

@end
