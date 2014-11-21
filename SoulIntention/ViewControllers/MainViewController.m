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

#import "UIImage+ScaleImage.h"

static CGFloat const ICON_WIDTH = 30.f;
static CGFloat const ICON_HEIGHT = 30.f;
static NSInteger const LIST_VIEW_CONTROLLER = 0;

typedef NS_ENUM(NSUInteger, ChildViewControllers) {
    SoulsChildViewController = 0,
    AutorChildViewController = 1,
    FavoritesChildViewController = 2,
};

@interface MainViewController ()

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *postsButton;
@property (weak, nonatomic) IBOutlet UIButton *autorButton;
@property (weak, nonatomic) IBOutlet UIButton *favoritesButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *postsButtonWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *underlineLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *underlineWidthConstraint;

@property (strong, nonatomic) NSMutableArray *childViewControllers;
@property (strong, nonatomic) UIViewController *currentViewController;

@end

@implementation MainViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.childViewControllers = [NSMutableArray new];
    
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

#pragma mark - IBAction

- (IBAction)searchButtonTouchUp:(id)sender
{
    NSLog(@"Search Button Press");
    __weak MainViewController *weakSelf = self;
    [[SoulIntentionManager sharedManager] searchForPostsWithTitle:@"test" offset:kPostsOffset limit:kPostsLimit completitionHandler:^(BOOL success, NSArray *result, NSError *error) {
        if (error) {
            return;
        }
        NSLog(@"Found %lu posts with title \"%@\", offset = %li, limit = %li", (unsigned long)[result count], @"text", (long)kPostsOffset, (long)kPostsLimit);
        [weakSelf menuButtonTouchUpInside:weakSelf.postsButton];
        [[NSNotificationCenter defaultCenter] postNotificationName:kSearchForPostsNotification object:nil userInfo:@{@"result" : result}];
    }];
}

- (void)menuButtonTouchUpInside:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    switch (button.tag) {
        case SoulsChildViewController:
            [self displayChildViewControllersWithTag:button.tag];
            self.underlineLeadingConstraint.constant = -2*self.postsButtonWidthConstraint.constant;
            [self.view layoutIfNeeded];
            break;
        case AutorChildViewController:
            [self displayChildViewControllersWithTag:button.tag];
            self.underlineLeadingConstraint.constant = -self.postsButtonWidthConstraint.constant;
            [self.view layoutIfNeeded];
            break;
        case FavoritesChildViewController:
            [self displayChildViewControllersWithTag:button.tag];
            self.underlineLeadingConstraint.constant = 0;
            [self.view layoutIfNeeded];
            break;
    }
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
    AutorViewController *autorViewController = [self.storyboard instantiateViewControllerWithIdentifier: NSStringFromClass([AutorViewController class])];
    ListViewController *favoritesViewController = [self.storyboard instantiateViewControllerWithIdentifier: NSStringFromClass([ListViewController class])];
    
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
}

@end
