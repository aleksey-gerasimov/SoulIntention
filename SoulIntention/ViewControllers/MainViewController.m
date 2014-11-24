//
//  MainViewController.m
//  SoulIntention
//
//  Created by Aleksey on 11/17/14.
//  Copyright (c) 2014 ThinkMobiles. All rights reserved.
//

#import "MainViewController.h"

#import "ListViewController.h"
#import "PostViewController.h"
#import "AutorViewController.h"

#import "SoulIntentionManager.h"
#import "AppDelegate.h"
#import "Constants.h"

#import "UIImage+ScaleImage.h"
#import "UIView+LoadingIndicator.h"

static CGFloat const ICON_WIDTH = 30.f;
static CGFloat const ICON_HEIGHT = 30.f;
static NSInteger const LIST_VIEW_CONTROLLER = 0;

typedef NS_ENUM(NSUInteger, ChildViewControllers) {
    SoulsChildViewController = 0,
    AutorChildViewController = 1,
    FavoritesChildViewController = 2,
};

@interface MainViewController () <UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchBarTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *postsButton;
@property (weak, nonatomic) IBOutlet UIButton *autorButton;
@property (weak, nonatomic) IBOutlet UIButton *favoritesButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *postsButtonWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *underlineLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *underlineWidthConstraint;

@property (strong, nonatomic) NSMutableArray *childViewControllers;
@property (strong, nonatomic) UIViewController *currentViewController;
@property (assign, nonatomic) BOOL searchBarIsShown;

@end

@implementation MainViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.childViewControllers = [NSMutableArray new];
    _searchBarIsShown = NO;
    
    [self initializeChildViewControllers];
    [self setFirstViewController];
    [self setButtonsTarget];
    [self setCustomBarButtons];

    NSInteger screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    self.postsButtonWidthConstraint.constant = screenWidth/3;
    self.underlineWidthConstraint.constant = screenWidth + screenWidth*2/3;
    self.underlineLeadingConstraint.constant = -2*self.postsButtonWidthConstraint.constant;
    [self.view layoutIfNeeded];
}

#pragma mark - Custom Accessors

- (void)setSearchBarIsShown:(BOOL)searchBarIsShown
{
    _searchBarIsShown = searchBarIsShown;
    __weak MainViewController *weakSelf = self;
    [UIView animateWithDuration:0.5 animations:^{
        weakSelf.searchBarTopConstraint.constant = _searchBarIsShown ? 0 : -CGRectGetHeight(weakSelf.searchBar.frame);
        [weakSelf.view layoutIfNeeded];
//        CGFloat yPosision = _searchBarIsShown ? CGRectGetMinY(weakSelf.containerView.frame) : CGRectGetMinY(weakSelf.containerView.frame) - CGRectGetHeight(weakSelf.searchBar.frame);
//        weakSelf.searchBar.frame = CGRectMake(CGRectGetMinX(weakSelf.searchBar.frame), yPosision, CGRectGetWidth(weakSelf.searchBar.frame), CGRectGetHeight(weakSelf.searchBar.frame));
    } completion:^(BOOL finished) {
        if (_searchBarIsShown) {
            [weakSelf.searchBar becomeFirstResponder];
        } else {
            [weakSelf.searchBar resignFirstResponder];
            weakSelf.searchBar.text = @"";
        }
    }];
}

#pragma mark - IBAction

- (IBAction)searchButtonTouchUp:(id)sender
{
    NSLog(@"Search Button Press");
    self.searchBarIsShown = !self.searchBarIsShown;
}

- (void)menuButtonTouchUpInside:(id)sender
{
    UIButton *button = (UIButton *)sender;
    switch (button.tag) {
        case SoulsChildViewController:
            self.underlineLeadingConstraint.constant = -2*self.postsButtonWidthConstraint.constant;
            break;
        case AutorChildViewController:
            self.underlineLeadingConstraint.constant = -self.postsButtonWidthConstraint.constant;
            break;
        case FavoritesChildViewController:
            self.underlineLeadingConstraint.constant = 0;
            break;
    }
    self.navigationItem.rightBarButtonItem.enabled = button.tag != AutorChildViewController;
    [self.view layoutIfNeeded];
    [self displayChildViewControllersWithTag:button.tag];
}

#pragma mark - Private Methods

- (void)setCustomBarButtons
{
    UIImage *image = [UIImage new];
    CGSize size = CGSizeMake(ICON_WIDTH, ICON_HEIGHT);
    
    image = [UIImage imageNamed:@"ic_logo"];
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageWithImage:image scaleToSize:size] style:UIBarButtonItemStylePlain target:self action:nil];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    
    image = [UIImage imageNamed:@"ic_search"];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageWithImage:image scaleToSize:size] style:UIBarButtonItemStyleDone target:self action:@selector(searchButtonTouchUp:)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

- (void)initializeChildViewControllers
{
    ListViewController *soulsViewController = [self.storyboard instantiateViewControllerWithIdentifier: NSStringFromClass([ListViewController class])];
    soulsViewController.listStyle = ListStyleAll;
    AutorViewController *autorViewController = [self.storyboard instantiateViewControllerWithIdentifier: NSStringFromClass([AutorViewController class])];
    ListViewController *favoritesViewController = [self.storyboard instantiateViewControllerWithIdentifier: NSStringFromClass([ListViewController class])];
    favoritesViewController.listStyle = ListStyleFavourite;
    
    [self.childViewControllers addObject:soulsViewController];
    [self.childViewControllers addObject:autorViewController];
    [self.childViewControllers addObject:favoritesViewController];
}

- (void)setFirstViewController
{
    [self displayChildViewControllersWithTag:LIST_VIEW_CONTROLLER];
}

- (void)setButtonsTarget
{
    [self.postsButton addTarget:self action:@selector(menuButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    self.postsButton.tag = SoulsChildViewController;
    [self.autorButton addTarget:self action:@selector(menuButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    self.autorButton.tag = AutorChildViewController;
    [self.favoritesButton addTarget:self action:@selector(menuButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    self.favoritesButton.tag = FavoritesChildViewController;
}

- (void)displayChildViewControllersWithTag:(NSInteger)tag
{
    if (self.currentViewController == [self.childViewControllers objectAtIndex:tag]) {
        return;
    }
    
    [self.currentViewController removeFromParentViewController];
    [self.currentViewController.view removeFromSuperview];
    
    self.currentViewController = [self.childViewControllers objectAtIndex:tag];
    [self addChildViewController:self.currentViewController];
    self.currentViewController.view.frame = self.containerView.bounds;
    [self.containerView addSubview:self.currentViewController.view];

    if (self.searchBarIsShown) {
        self.searchBarIsShown = NO;
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.searchBarIsShown = NO;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self.view showLoadingIndicator];
    __weak MainViewController *weakSelf = self;
    __weak AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [[SoulIntentionManager sharedManager] searchForPostsWithTitle:searchBar.text offset:kPostsOffset limit:kPostsLimit completitionHandler:^(BOOL success, NSArray *result, NSError *error) {
        [weakSelf.view hideLoadingIndicator];
        if (error) {
            [appDelegate showAlertViewWithTitle:@"Error" message:@"Failed to make search"];
            return;
        } else {
            NSLog(@"Found %lu posts with title \"%@\", offset = %li, limit = %li", (unsigned long)[result count], @"test", (long)kPostsOffset, (long)kPostsLimit);
//            [weakSelf menuButtonTouchUpInside:weakSelf.postsButton];
            [[NSNotificationCenter defaultCenter] postNotificationName:kSearchForPostsNotification object:nil userInfo:@{@"result" : result}];
        }
    }];
}

@end
