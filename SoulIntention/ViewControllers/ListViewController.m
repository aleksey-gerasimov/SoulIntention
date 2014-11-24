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
    __weak ListViewController *weakSelf = self;
    [[SoulIntentionManager sharedManager] getPostsWithOffset:kPostsOffset limit:kPostsLimit completitionHandler:^(BOOL success, NSArray *result, NSError *error) {
        if (error) {
            return;
        } else {
            [weakSelf showPosts:result];
        }
    }];
}

- (void)getFavouritePosts
{
    __weak ListViewController *weakSelf = self;
    [[SoulIntentionManager sharedManager] getFavouritesWithOffset:kPostsOffset limit:kPostsLimit completitionHandler:^(BOOL success, NSArray *result, NSError *error) {
        if (error) {
            return;
        } else {
            [weakSelf showFavouritePosts:[result valueForKey:@"post"]];
        }
    }];
}

- (void)showPosts:(NSArray *)posts
{
    self.allPosts = posts;
    for (NSInteger i=0; i<[self.posts count]; i++) {
        Post *post = self.posts[i];
        post.isFavourite = [self.appDelegate.favouritesIdsArray containsObject:post.postId] ? YES : NO;
    }
    self.posts = self.allPosts;
    [self.tableView reloadData];
}

- (void)showFavouritePosts:(NSArray *)posts
{
    self.favouritePosts = posts;
    for (NSInteger i=0; i<[self.posts count]; i++) {
        Post *post = self.posts[i];
        post.isFavourite = [self.appDelegate.favouritesIdsArray containsObject:post.postId] ? YES : NO;
    }
    self.posts = self.favouritePosts;
    [self.tableView reloadData];
}

#pragma mark - TableView DataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"listCell"];
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
