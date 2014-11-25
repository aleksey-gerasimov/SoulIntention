//
//  ListViewController.m
//  SoulIntention
//
//  Created by Admin on 11/17/14.
//  Copyright (c) 2014 ThinkMobiles. All rights reserved.
//

#import "ListViewController.h"

#import "ListTableViewCell.h"
#import "PostViewController.h"

#import "SoulIntentionManager.h"
#import "AppDelegate.h"
#import "Constants.h"

#import "Post.h"
#import "Favourite.h"

#import "UIView+LoadingIndicator.h"

typedef NS_ENUM(NSUInteger, ListViewControllerType) {
    ListViewControllerTypeSouls = 0,
    ListViewControllerTypeFavorites = 1,
};

@interface ListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) NSArray *allPosts;
@property (strong, nonatomic) NSArray *favouritePosts;
@property (strong, nonatomic) NSArray *posts;

@end

@implementation ListViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.appDelegate = [UIApplication sharedApplication].delegate;
    self.allPosts = [NSArray new];
    self.favouritePosts = [NSArray new];
    self.posts = [NSArray new];

    __weak ListViewController *weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:kSessionStartedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        self.listStyle == ListStyleAll ? [self getAllPosts] : [self getFavouritePosts];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:kSearchForPostsNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [weakSelf showPosts:note.userInfo[@"result"]];
    }];
    if (self.listStyle == ListStyleFavourite) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFavouritePosts:) name:kFavouriteRemovedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserverForName:kFavouriteAddedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            weakSelf.posts = [NSArray new];
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self.posts count] == 0 && self.appDelegate.sessionStarted) {
        self.listStyle == ListStyleAll ? [self getAllPosts] : [self getFavouritePosts];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([self.navigationController.viewControllers count] < 2) {
        self.posts = [NSArray new];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kListCellSwipeNotification object:nil userInfo:@{@"postId" : @""}];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private Methods

- (void)getAllPosts
{
    [self.view showLoadingIndicator];
    __weak ListViewController *weakSelf = self;
    [[SoulIntentionManager sharedManager] getPostsWithOffset:kPostsOffset limit:kPostsLimit completitionHandler:^(BOOL success, NSArray *result, NSError *error) {
        [weakSelf.view hideLoadingIndicator];
        if (error) {
            [weakSelf.appDelegate showAlertViewWithTitle:@"Error" message:@"Failed to load posts"];
            return;
        } else {
            [weakSelf showPosts:result];
        }
    }];
}

- (void)getFavouritePosts
{
    [self.view showLoadingIndicator];
    __weak ListViewController *weakSelf = self;
    [[SoulIntentionManager sharedManager] getFavouritesWithOffset:kPostsOffset limit:kPostsLimit completitionHandler:^(BOOL success, NSArray *result, NSError *error) {
        [weakSelf.view hideLoadingIndicator];
        if (error) {
            [weakSelf.appDelegate showAlertViewWithTitle:@"Error" message:@"Failed to load favourite posts"];
            return;
        } else {
            [weakSelf showFavouritePosts:[result valueForKey:@"post"]];
        }
    }];
}

- (void)showPosts:(NSArray *)posts
{
    self.allPosts = posts;
    for (NSInteger i=0; i<[self.allPosts count]; i++) {
        Post *post = self.allPosts[i];
        post.isFavourite = [self.appDelegate.favouritesIdsArray containsObject:post.postId] ? YES : NO;
    }
    self.posts = self.allPosts;
    [self.tableView reloadData];
}

- (void)showFavouritePosts:(NSArray *)posts
{
    self.favouritePosts = posts;
    for (NSInteger i=0; i<[self.favouritePosts count]; i++) {
        Post *post = self.favouritePosts[i];
        post.isFavourite = [self.appDelegate.favouritesIdsArray containsObject:post.postId] ? YES : NO;
    }
    self.posts = self.favouritePosts;
    [self.tableView reloadData];
}

- (void)updateFavouritePosts:(NSNotification *)note
{
    NSString *postId = note.userInfo[@"postId"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"postId != %@", postId];
    self.favouritePosts = [self.favouritePosts filteredArrayUsingPredicate:predicate];
    self.posts = self.favouritePosts;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kAnimationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    });

//    ListTableViewCell *cell = note.userInfo[@"cell"];
//    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
//    if (!indexPath) {
//        return;
//    }
//
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"postId != %@", cell.post.postId];
//    self.favouritePosts = [self.favouritePosts filteredArrayUsingPredicate:predicate];
//    self.posts = self.favouritePosts;
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kAnimationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
//    });
}

#pragma mark - TableView DataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"listCell"];
    cell.post = self.posts[indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   return self.posts.count;
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PostViewController *postViewController = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([PostViewController class])];
    postViewController.post = self.posts[indexPath.row];
    ListTableViewCell *cell = (ListTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    postViewController.postImage = cell.postImageView.image;
    [self.navigationController pushViewController:postViewController animated:YES];
}

@end
