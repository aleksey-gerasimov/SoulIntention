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

#define LIST_VIEW_CONTROLLER 0

typedef NS_ENUM(NSUInteger, ChildViewControllers) {
    SoulsChildViewController = 0,
    AutorChildViewController = 1,
    FavoritesChildViewController = 2,
};

@interface MainViewController ()

@property (strong, nonatomic) NSMutableArray *childViewControllers;
@property (strong, nonatomic) UIViewController *currentViewController;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *soulsButton;
@property (weak, nonatomic) IBOutlet UIButton *autorButton;
@property (weak, nonatomic) IBOutlet UIButton *favoritesButton;

@end

@implementation MainViewController

#pragma mark - Lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
    self.childViewControllers = [NSMutableArray new];
    
    [self initializeChildViewControllers];
    [self setFirstViewController];
    [self setButtonsTarget];
    [self setCustomBarButtons];
}

#pragma mark - IBAction

- (IBAction)searchButtonTouchUp:(id)sender {
    NSLog(@"Search Button");
}

- (void)menuButtonTouchUpInside:(id)sender {
    UIButton *button = (UIButton*)sender;
    
    switch (button.tag) {
        case SoulsChildViewController:{
            [self displayChildViewControllersWithTag:button.tag];
            break;
        }
        case AutorChildViewController:{
            [self displayChildViewControllersWithTag:button.tag];
            break;
        }
        case FavoritesChildViewController:{
            [self displayChildViewControllersWithTag:LIST_VIEW_CONTROLLER];
            break;
        }
        default:
            break;
    }
}

#pragma mark - Private Methods

- (void)setCustomBarButtons{
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_logo"] style:UIBarButtonItemStylePlain target:self action:nil];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_search"] style:UIBarButtonItemStyleDone target:self action:@selector(searchButtonTouchUp:)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

- (void)initializeChildViewControllers{
    PostViewController *postViewController = [self.storyboard instantiateViewControllerWithIdentifier: NSStringFromClass([PostViewController class])];
    ListViewController *listViewController = [self.storyboard instantiateViewControllerWithIdentifier: NSStringFromClass([ListViewController class])];
    
    [self.childViewControllers addObject: listViewController];
    [self.childViewControllers addObject: postViewController];
}

- (void)setFirstViewController{
    [self displayChildViewControllersWithTag:LIST_VIEW_CONTROLLER];
}

- (void)setButtonsTarget{
    [self.soulsButton addTarget:self action:@selector(menuButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    self.soulsButton.tag = 0;
    [self.autorButton addTarget:self action:@selector(menuButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    self.autorButton.tag = 1;
    [self.favoritesButton addTarget:self action:@selector(menuButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    self.favoritesButton.tag = 2;
}

- (void)displayChildViewControllersWithTag:(NSInteger)tag{

    if (self.currentViewController == [self.childViewControllers objectAtIndex: tag]) {
        return;
    }
    
    [self.currentViewController removeFromParentViewController];
    [self.currentViewController.view removeFromSuperview];
    
    self.currentViewController = [self.childViewControllers objectAtIndex: tag];
    [self addChildViewController: self.currentViewController];
    self.currentViewController.view.frame = self.containerView.bounds;
    [self.containerView addSubview:self.currentViewController.view];
    [self.currentViewController didMoveToParentViewController:self];
}

@end
