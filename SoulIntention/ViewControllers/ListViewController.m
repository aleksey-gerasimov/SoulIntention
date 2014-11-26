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

static NSInteger const kLoadingPostsOnScrollOffset = 20;

@interface ListViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) NSMutableArray *allPosts;
@property (strong, nonatomic) NSMutableArray *favouritePosts;
@property (strong, nonatomic) NSArray *posts;
@property (strong, nonatomic) NSString *searchText;
@property (assign, nonatomic) BOOL isLoadingPosts;

@end

@implementation ListViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.appDelegate = [UIApplication sharedApplication].delegate;
    self.allPosts = [NSMutableArray new];
    self.favouritePosts = [NSMutableArray new];
    self.posts = [NSArray new];

    __weak ListViewController *weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:kSessionStartedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        self.listStyle == ListStyleAll ? [self getAllPostsWithOffset:0] : [self getFavouritePostsWithOffset:0];
    }];
    switch (self.listStyle) {
        case ListStyleAll: {
            [[NSNotificationCenter defaultCenter] addObserverForName:kSearchForPostsNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
                [weakSelf.allPosts removeAllObjects];
                [weakSelf searchForPostsWithTitle:note.userInfo[@"text"] offset:0];
            }];
            break;
        }
        case ListStyleFavourite: {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFavouritePosts:) name:kFavouriteRemovedNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserverForName:kFavouriteAddedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
                [weakSelf.favouritePosts removeAllObjects];
                weakSelf.posts = [NSArray new];
            }];
            break;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self.posts count] == 0 && self.appDelegate.sessionStarted) {
        self.listStyle == ListStyleAll ? [self getAllPostsWithOffset:0] : [self getFavouritePostsWithOffset:0];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([self.navigationController.viewControllers count] < 2) {
        [self.allPosts removeAllObjects];
        [self.favouritePosts removeAllObjects];
        self.posts = [NSArray new];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kListCellSwipeNotification object:nil userInfo:@{@"postId" : @""}];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private Methods

- (void)showPosts:(NSArray *)posts
{
    for (NSInteger i=0; i<[posts count]; i++) {
        Post *post = posts[i];
        post.isFavourite = [self.appDelegate.favouritesIdsArray containsObject:post.postId] ? YES : NO;
    }
    self.posts = posts;
    [self.tableView reloadData];
    self.isLoadingPosts = NO;
}

#pragma mark All Posts

- (void)getAllPostsWithOffset:(NSInteger)offset
{
    self.searchText = @"";
    self.isLoadingPosts = YES;
    [self.view showLoadingIndicator];
    __weak ListViewController *weakSelf = self;
    [[SoulIntentionManager sharedManager] getPostsWithOffset:offset limit:kPostsLimit completitionHandler:^(BOOL success, NSArray *result, NSError *error) {
        [weakSelf.view hideLoadingIndicator];
        if (error) {
            [weakSelf.appDelegate showAlertViewWithTitle:@"Error" message:@"Failed to load posts"];
            weakSelf.isLoadingPosts = NO;
            return;
        } else {
            [weakSelf.allPosts addObjectsFromArray:result];
            [weakSelf showPosts:weakSelf.allPosts];
        }
    }];
}

- (void)searchForPostsWithTitle:(NSString *)text offset:(NSInteger)offset
{
    self.searchText = text;
    self.isLoadingPosts = YES;
    [self.view showLoadingIndicator];
    __weak ListViewController *weakSelf = self;
    [[SoulIntentionManager sharedManager] searchForPostsWithTitle:text offset:offset limit:kPostsLimit completitionHandler:^(BOOL success, NSArray *result, NSError *error) {
        [weakSelf.view hideLoadingIndicator];
        if (error) {
            [weakSelf.appDelegate showAlertViewWithTitle:@"Error" message:@"Failed to make search"];
            return;
        } else {
            NSLog(@"Found %lu posts with title \"%@\", offset = %li, limit = %li", (unsigned long)[result count], text, (long)offset, (long)kPostsLimit);
            [weakSelf.allPosts addObjectsFromArray:result];
            [weakSelf showPosts:weakSelf.allPosts];
        }
    }];
}

#pragma mark Favourite Posts

- (void)getFavouritePostsWithOffset:(NSInteger)offset
{
    self.isLoadingPosts = YES;
    [self.view showLoadingIndicator];
    __weak ListViewController *weakSelf = self;
    [[SoulIntentionManager sharedManager] getFavouritesWithOffset:offset limit:kPostsLimit completitionHandler:^(BOOL success, NSArray *result, NSError *error) {
        [weakSelf.view hideLoadingIndicator];
        if (error) {
            [weakSelf.appDelegate showAlertViewWithTitle:@"Error" message:@"Failed to load favourite posts"];
            weakSelf.isLoadingPosts = NO;
            return;
        } else {
            [weakSelf.favouritePosts addObjectsFromArray:[result valueForKey:@"post"]];
            [weakSelf showPosts:weakSelf.favouritePosts];
        }
    }];
}

- (void)updateFavouritePosts:(NSNotification *)note
{
    NSString *postId = note.userInfo[@"postId"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"postId != %@", postId];
    [self.favouritePosts filteredArrayUsingPredicate:predicate];// = [self.favouritePosts filteredArrayUsingPredicate:predicate];
    self.posts = self.favouritePosts;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kAnimationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    });
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

#pragma mark - ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.isLoadingPosts || scrollView.decelerating) {
        return;
    }

    CGFloat scrollViewHeight = CGRectGetHeight(scrollView.frame);
    CGFloat scrollViewConterntOffsetY = scrollView.contentOffset.y;
    CGFloat scrollViewContentHeight = scrollView.contentSize.height;
    if (scrollViewHeight + scrollViewConterntOffsetY > scrollViewContentHeight + kLoadingPostsOnScrollOffset) {
        NSLog(@"Loading more posts with offset %lu", self.posts.count);
        switch (self.listStyle) {
            case ListStyleAll:
                self.searchText.length > 0 ? [self searchForPostsWithTitle:self.searchText offset:self.posts.count] : [self getAllPostsWithOffset:self.posts.count];
                break;
            case ListStyleFavourite:
                [self getFavouritePostsWithOffset:self.posts.count];
                break;
        }
    }
}

@end
