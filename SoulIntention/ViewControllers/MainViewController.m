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
    [self setButtonsTarget];
}

#pragma mark - IBAction

- (IBAction)searchButtonTouchUp:(id)sender {
    NSLog(@"Search Button");
}

- (void)menuButtonTouchUpInside:(id)sender {
    UIButton *button = (UIButton*)sender;
    
    switch (button.tag) {
        case SoulsChildViewController:{
            NSLog(@"SoulsChildViewController");
            [self displayChildViewControllersWithTag: button.tag];
            break;
        }
        case AutorChildViewController:{
            NSLog(@"AutorChildViewController");
            [self displayChildViewControllersWithTag: button.tag];
            break;
        }
        case FavoritesChildViewController:{
            NSLog(@"FavoritesChildViewController");
            [self displayChildViewControllersWithTag: 0];
            break;
        }
        default:
            break;
    }
}

#pragma mark - Private Methods

- (void)initializeChildViewControllers{
    PostViewController *postViewController = [self.storyboard instantiateViewControllerWithIdentifier: NSStringFromClass([PostViewController class])];
    ListViewController *listViewController = [self.storyboard instantiateViewControllerWithIdentifier: NSStringFromClass([ListViewController class])];
    
    [self.childViewControllers addObject: listViewController];
    [self.childViewControllers addObject: postViewController];
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
