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

#import "UIButton+Image.h"
#import "UIView+LoadingIndicator.h"

//static CGFloat const kIconWidth = 30.f;
//static CGFloat const kIconHeight = 30.f;

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
@property (assign, nonatomic) FilterType filterType;
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
    [self setButtonsTarget];
    [self setCustomBarButtons];

    NSInteger screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    self.postsButtonWidthConstraint.constant = screenWidth/3;
    self.underlineWidthConstraint.constant = screenWidth + screenWidth*2/3;
    self.underlineLeadingConstraint.constant = -2*self.postsButtonWidthConstraint.constant;
    [self.view layoutIfNeeded];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideSearchBar) name:kHideSearchBarNotification object:nil];
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
        [self.searchBar becomeFirstResponder];
    } else {
        self.searchBar.text = @"";
        [self.searchBar resignFirstResponder];
    }
    
    __weak MainViewController *weakSelf = self;
    [UIView animateWithDuration:kAnimationDuration animations:^{
        weakSelf.containerView.alpha = _searchBarIsShown ? 0.2 : 1.0;
        weakSelf.searchBarTopConstraint.constant = _searchBarIsShown ? 0 : -CGRectGetHeight(weakSelf.searchBar.frame);
        [weakSelf.view layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
}

- (void)setFilterType:(FilterType)filterType
{
    _filterType = filterType > FilterTypeMostRated ? FilterTypeMostRecent : filterType;

    CGSize size = CGSizeMake(kIconWidth, kIconHeight);
    UIImage *normalImage = self.filterType == FilterTypeMostRecent ? [UIImage imageNamed:kFilterDateButtonImage] : [UIImage imageNamed:kFilterRateButtonImage];
    UIBarButtonItem *filterBarButtonItem = [UIButton createBarButtonItemWithNormalImage:normalImage highlightedImage:normalImage size:size isHighlighted:NO actionTarget:self selector:@selector(filterButtonTouchUp:)];
    self.navigationItem.rightBarButtonItems = @[self.navigationItem.rightBarButtonItems.firstObject, filterBarButtonItem];
}

#pragma mark - Private Methods

- (void)setCustomBarButtons
{
    CGSize size = CGSizeMake(kIconWidth, kIconHeight);

    UIImage *normalImage = [UIImage imageNamed:kLogoButtonImage];
    UIBarButtonItem *logoBarButtonItem = [UIButton createBarButtonItemWithNormalImage:normalImage highlightedImage:normalImage size:size isHighlighted:NO actionTarget:nil selector:nil];
    self.navigationItem.leftBarButtonItem = logoBarButtonItem;

    normalImage = [UIImage imageNamed:kSearchButtonImage];
    UIBarButtonItem *searchBarButtonItem = [UIButton createBarButtonItemWithNormalImage:normalImage highlightedImage:normalImage size:size isHighlighted:NO actionTarget:self selector:@selector(searchButtonTouchUp:)];
    self.navigationItem.rightBarButtonItems = @[searchBarButtonItem];

    self.filterType = FilterTypeMostRecent;
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

    [self hideSearchBar];
}

- (void)hideSearchBar
{
    if (self.searchBarIsShown) {
        self.searchBarIsShown = NO;
    }
}

#pragma mark - IBAction

- (IBAction)searchButtonTouchUp:(id)sender
{
    self.searchBarIsShown = !self.searchBarIsShown;
}

- (IBAction)filterButtonTouchUp:(id)sender
{
    self.filterType++;
    [[NSNotificationCenter defaultCenter] postNotificationName:kSetFilterTypeNotification object:nil userInfo:@{@"filterType" : @(_filterType)}];
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
    ((UIBarButtonItem *)self.navigationItem.rightBarButtonItems.firstObject).enabled = button.tag == SoulsChildViewController;
    ((UIBarButtonItem *)self.navigationItem.rightBarButtonItems.lastObject).enabled = button.tag == SoulsChildViewController;
    [self.view layoutIfNeeded];
    [self displayChildViewControllersWithTag:button.tag];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    self.filterType = FilterTypeMostRecent;
    [[NSNotificationCenter defaultCenter] postNotificationName:kSearchForPostsNotification object:nil userInfo:@{@"text" : searchBar.text}];
    [self hideSearchBar];
}

@end
