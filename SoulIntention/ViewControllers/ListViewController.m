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

#import "Post.h"
#import "Favourite.h"

static NSInteger const PostsOffset = 0;
static NSInteger const PostsLimit = 5;

typedef NS_ENUM(NSUInteger, ListViewControllerType) {
    ListViewControllerTypeSouls = 0,
    ListViewControllerTypeFavorites = 1,
};

@interface ListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) NSArray *posts;

@end

@implementation ListViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.appDelegate = [UIApplication sharedApplication].delegate;
    self.posts = [NSArray new];
    if (self.appDelegate.sessionStarted) {
        [self getPosts];
    }

    __weak ListViewController *weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:kSessionStartedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [weakSelf getPosts];
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:kListCellSwipeNotification object:nil userInfo:@{@"postId" : @""}];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private Methods

- (void)getPosts
{
    __weak ListViewController *weakSelf = self;
    [[SoulIntentionManager sharedManager] getPostsWithOffset:PostsOffset limit:PostsLimit completitionHandler:^(BOOL success, NSArray *result, NSError *error) {
        if (error) {
            return;
        } else {
            weakSelf.posts = result;
            for (NSInteger i=0; i<[weakSelf.posts count]; i++) {
                Post *post = weakSelf.posts[i];
                post.isFavourite = [weakSelf.appDelegate.favouritesIdsArray containsObject:post.postId] ? YES : NO;
            }
            [weakSelf.tableView reloadData];
        }
    }];
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
    [self.navigationController pushViewController:postViewController animated:YES];
}

@end
