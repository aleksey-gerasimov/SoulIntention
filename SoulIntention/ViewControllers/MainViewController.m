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
#import "SortType.h"
#import "AppDelegate.h"
#import "Constants.h"

#import "UIButton+Image.h"
#import "UIView+LoadingIndicator.h"

typedef NS_ENUM(NSUInteger, ChildViewControllers) {
    SoulsChildViewController = 0,
    AutorChildViewController = 1,
    FavoritesChildViewController = 2,
};

@interface MainViewController () <UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UIView *menuView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sortViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sortViewTopConstraint;
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
@property (assign, nonatomic) BOOL sortViewIsShown;
@property (assign, nonatomic) BOOL searchBarIsShown;

@end

@implementation MainViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.childViewControllers = [NSMutableArray new];
    _sortViewIsShown = NO;
    _searchBarIsShown = NO;
    
    [self initializeChildViewControllers];
    [self setupMenuView];
    [self setCustomBarButtons];

    self.sortViewHeightConstraint.constant = 30*[SortType sharedInstance].allSorts.count;
    self.sortViewTopConstraint.constant = -self.sortViewHeightConstraint.constant;
    [self.view layoutIfNeeded];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideFilterViewAndSearchBar) name:kHideSortViewAndSearchBarNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Custom Accessors

- (void)setSearchBarIsShown:(BOOL)searchBarIsShown
{
    _searchBarIsShown = searchBarIsShown;
    if (_searchBarIsShown) {
        self.searchBar.text = @"";
        [self.searchBar becomeFirstResponder];
    } else {
        [self.searchBar resignFirstResponder];
    }
    
    __weak MainViewController *weakSelf = self;
    [UIView animateWithDuration:kAnimationDuration animations:^{
        weakSelf.containerView.alpha = _searchBarIsShown ? 0.2 : 1.0;
        weakSelf.searchBarTopConstraint.constant = _searchBarIsShown ? 0 : -CGRectGetHeight(weakSelf.searchBar.frame);
        [weakSelf.view layoutIfNeeded];
    }];

    if (_searchBarIsShown && self.sortViewIsShown) {
        self.sortViewIsShown = NO;
    }
}

- (void)setSortViewIsShown:(BOOL)sortViewIsShown
{
    _sortViewIsShown = sortViewIsShown;

    __weak MainViewController *weakSelf = self;
    [UIView animateWithDuration:kAnimationDuration animations:^{
        weakSelf.sortViewTopConstraint.constant = _sortViewIsShown ? 0 : -weakSelf.sortViewHeightConstraint.constant;
        [weakSelf.view layoutIfNeeded];
    }];

    if (_sortViewIsShown) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowSortViewNotification object:self];
        if (self.searchBarIsShown) {
            self.searchBarIsShown = NO;
        }
    }
}

#pragma mark - Private Methods

- (void)setCustomBarButtons
{
    CGSize size = CGSizeMake(kIconWidth, kIconHeight);

    UIImage *normalImage = [UIImage imageNamed:kLogoButtonImage];
    UIImage *highlightedImage = [UIImage imageNamed:kLogoButtonHighlightedImage];
    UIBarButtonItem *logoBarButtonItem = [UIButton createBarButtonItemWithNormalImage:normalImage highlightedImage:highlightedImage size:size isHighlighted:NO actionTarget:self selector:@selector(logoButtonTouchUp:)];
    self.navigationItem.leftBarButtonItem = logoBarButtonItem;

    normalImage = [UIImage imageNamed:kSearchButtonImage];
    highlightedImage = [UIImage imageNamed:kSearchButtonHighlightedImage];
    UIBarButtonItem *searchBarButtonItem = [UIButton createBarButtonItemWithNormalImage:normalImage highlightedImage:highlightedImage size:size isHighlighted:NO actionTarget:self selector:@selector(searchButtonTouchUp:)];

    normalImage = [UIImage imageNamed:kSortButtonImage];
    highlightedImage = [UIImage imageNamed:kSortButtonHighlightedImage];
    UIBarButtonItem *filterBarButtonItem = [UIButton createBarButtonItemWithNormalImage:normalImage highlightedImage:highlightedImage size:size isHighlighted:NO actionTarget:self selector:@selector(filterButtonTouchUp:)];

    self.navigationItem.rightBarButtonItems = @[searchBarButtonItem, filterBarButtonItem];
}

- (void)initializeChildViewControllers
{
    ListViewController *soulsViewController = [self.storyboard instantiateViewControllerWithIdentifier: NSStringFromClass([ListViewController class])];
    soulsViewController.listStyle = ListStyleAll;
    AutorViewController *autorViewController = [self.storyboard instantiateViewControllerWithIdentifier: NSStringFromClass([AutorViewController class])];
    ListViewController *favoritesViewController = [self.storyboard instantiateViewControllerWithIdentifier: NSStringFromClass([ListViewController class])];
    favoritesViewController.listStyle = ListStyleFavorite;
    
    [self.childViewControllers addObject:soulsViewController];
    [self.childViewControllers addObject:autorViewController];
    [self.childViewControllers addObject:favoritesViewController];

    [self displayChildViewControllersWithTag:[self.childViewControllers indexOfObject:soulsViewController]];
}

- (void)setupMenuView
{
    self.menuView.backgroundColor = self.navigationController.navigationBar.barTintColor;

    NSInteger screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    self.postsButtonWidthConstraint.constant = screenWidth/3;
    self.underlineWidthConstraint.constant = screenWidth + screenWidth*2/3;
    self.underlineLeadingConstraint.constant = -2*self.postsButtonWidthConstraint.constant;
    [self.view layoutIfNeeded];

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

    [self hideFilterViewAndSearchBar];
}

- (void)hideFilterViewAndSearchBar
{
    if (self.searchBarIsShown) {
        self.searchBarIsShown = NO;
    }
    if (self.sortViewIsShown) {
        self.sortViewIsShown = NO;
    }
}

#pragma mark - IBAction

- (IBAction)logoButtonTouchUp:(id)sender
{
    [self menuButtonTouchUpInside:self.postsButton];
}

- (IBAction)searchButtonTouchUp:(id)sender
{
    self.searchBarIsShown = !self.searchBarIsShown;
}

- (IBAction)filterButtonTouchUp:(id)sender
{
    self.sortViewIsShown = !self.sortViewIsShown;
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
    ((UIBarButtonItem *)self.navigationItem.rightBarButtonItems.firstObject).enabled = button.tag != AutorChildViewController;
    ((UIBarButtonItem *)self.navigationItem.rightBarButtonItems.lastObject).enabled = button.tag != AutorChildViewController;
    [self.view layoutIfNeeded];
    [self displayChildViewControllersWithTag:button.tag];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self hideFilterViewAndSearchBar];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSearchForPostsNotification object:nil userInfo:@{@"text" : searchBar.text}];
}

@end
