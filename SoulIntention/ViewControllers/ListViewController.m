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

#import "UIView+LoadingIndicator.h"

static NSInteger const kLoadingPostsOnScrollOffset = 20;

@interface ListViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) NSMutableArray *allPosts;
@property (strong, nonatomic) NSMutableArray *favoritePosts;
@property (strong, nonatomic) NSArray *posts;
@property (strong, nonatomic) NSString *searchText;
@property (assign, nonatomic) BOOL isLoadingPosts;
@property (assign, nonatomic) BOOL needsUpdate;
@property (assign, nonatomic) BOOL noFavorites;

@end

@implementation ListViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.appDelegate = [UIApplication sharedApplication].delegate;
    self.allPosts = [NSMutableArray new];
    self.favoritePosts = [NSMutableArray new];
    self.posts = [NSArray new];
    self.searchText = @"";
    self.needsUpdate = YES;

    __weak ListViewController *weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:kSessionStartedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        weakSelf.searchText = @"";
        weakSelf.listStyle == ListStyleAll ? [weakSelf.allPosts removeAllObjects] : [weakSelf.favoritePosts removeAllObjects];
        weakSelf.listStyle == ListStyleAll ? [weakSelf getAllPostsWithOffset:0] : [weakSelf getFavoritePostsWithOffset:0];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:kSetSortTypeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        weakSelf.listStyle == ListStyleAll ? [weakSelf.allPosts removeAllObjects] : [weakSelf.favoritePosts removeAllObjects];
        weakSelf.listStyle == ListStyleAll ? [weakSelf getAllPostsWithOffset:0] : [weakSelf getFavoritePostsWithOffset:0];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:kSearchForPostsNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        weakSelf.searchText = note.userInfo[@"text"];
        weakSelf.listStyle == ListStyleAll ? [weakSelf.allPosts removeAllObjects] : [weakSelf.favoritePosts removeAllObjects];
        weakSelf.listStyle == ListStyleAll ? [weakSelf getAllPostsWithOffset:0] : [weakSelf getFavoritePostsWithOffset:0];
    }];
    if (self.listStyle == ListStyleFavorite) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFavoritePosts:) name:kFavoriteFlagChangedNotification object:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.needsUpdate && self.appDelegate.sessionStarted) {
        self.listStyle == ListStyleAll ? [self getAllPostsWithOffset:0] : [self getFavoritePostsWithOffset:0];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([self.navigationController.viewControllers count] < 2) {
        [self.allPosts removeAllObjects];
        [self.favoritePosts removeAllObjects];
        self.needsUpdate = YES;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kListCellSwipeNotification object:nil userInfo:@{@"postId" : @""}];
    [[NSNotificationCenter defaultCenter] postNotificationName:kHideSortViewAndSearchBarNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private

- (void)showPosts:(NSArray *)posts
{
    self.posts = [posts copy];
    [self.tableView reloadData];
    self.isLoadingPosts = NO;
    self.needsUpdate = NO;
}

#pragma mark All Posts

- (void)getAllPostsWithOffset:(NSInteger)offset
{
    self.isLoadingPosts = YES;
    [self.view showLoadingIndicator];
    __weak ListViewController *weakSelf = self;
    if (self.searchText.length == 0) {
        [[SoulIntentionManager sharedManager] getPostsWithOffset:offset limit:kPostsLimit completitionHandler:^(BOOL success, NSArray *result, NSError *error) {
            [weakSelf.view hideLoadingIndicator];
            if (error) {
                [weakSelf.appDelegate showAlertViewWithTitle:@"Error" message:@"Failed to load posts"];
            } else {
                [weakSelf.allPosts addObjectsFromArray:result];
            }
            [weakSelf showPosts:weakSelf.allPosts];
        }];
    } else {
        [[SoulIntentionManager sharedManager] searchForPostsWithTitle:self.searchText offset:offset limit:kPostsLimit completitionHandler:^(BOOL success, NSArray *result, NSError *error) {
            [weakSelf.view hideLoadingIndicator];
            if (error) {
                [weakSelf.appDelegate showAlertViewWithTitle:@"Error" message:@"Failed to make search"];
            } else {
                NSLog(@"Found %lu posts with title \"%@\", offset = %li, limit = %li", (unsigned long)[result count], self.searchText, (long)offset, (long)kPostsLimit);
                [weakSelf.allPosts addObjectsFromArray:result];
            }
            [weakSelf showPosts:weakSelf.allPosts];
        }];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kListCellSwipeNotification object:nil userInfo:@{@"postId" : @""}];
}

#pragma mark Favorite Posts

- (void)getFavoritePostsWithOffset:(NSInteger)offset
{
    self.isLoadingPosts = YES;
    [self.view showLoadingIndicator];
    __weak ListViewController *weakSelf = self;
    [[SoulIntentionManager sharedManager] getFavoritesWithSearchText:self.searchText offset:offset limit:kPostsLimit completitionHandler:^(BOOL success, NSArray *result, NSError *error) {
        [weakSelf.view hideLoadingIndicator];
        if (error) {
            [weakSelf.appDelegate showAlertViewWithTitle:@"Error" message:self.searchText.length > 0 ? @"Failed to make search" : @"Failed to load favorite posts"];
        } else {
            [weakSelf.favoritePosts addObjectsFromArray:result];
        }
        [weakSelf showPosts:weakSelf.favoritePosts];
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:kListCellSwipeNotification object:nil userInfo:@{@"postId" : @""}];
}

- (void)updateFavoritePosts:(NSNotification *)note
{
    if ([(NSNumber *)note.userInfo[@"isFavorite"] boolValue]) {
        [self.favoritePosts removeAllObjects];
        self.needsUpdate = YES;
        return;
    }

    NSString *postId = note.userInfo[@"postId"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"postId != %@", postId];
    [self.favoritePosts filterUsingPredicate:predicate];
    self.posts = [self.favoritePosts copy];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kAnimationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    });
    [[NSNotificationCenter defaultCenter] postNotificationName:kListCellSwipeNotification object:nil userInfo:@{@"postId" : @"", @"animate" : @YES}];
    [[NSNotificationCenter defaultCenter] postNotificationName:kHideSortViewAndSearchBarNotification object:nil];
}

#pragma mark - TableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = self.posts.count;
    self.tableView.allowsSelection = YES;
    self.noFavorites = NO;
    if (self.listStyle == ListStyleFavorite) {
        self.noFavorites = self.posts.count == 0 ? YES : NO;
        numberOfRows = self.noFavorites ? 1 : self.posts.count;
        self.tableView.separatorStyle = self.noFavorites ? UITableViewCellSeparatorStyleNone : UITableViewCellSeparatorStyleSingleLine;
        self.tableView.allowsSelection = self.noFavorites ? NO : YES;
    }
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.listStyle == ListStyleFavorite && self.noFavorites) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"noFavoritesPlaceholderCell"];
        return cell;
    } else {
        ListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"listCell"];
        cell.post = self.posts[indexPath.row];
        return cell;
    }
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PostViewController *postViewController = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([PostViewController class])];
    postViewController.post = self.posts[indexPath.row];
    ListTableViewCell *cell = (ListTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    postViewController.postImage = cell.postImage;
    [self.navigationController pushViewController:postViewController animated:YES];
}

#pragma mark - ScrollView Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kHideSortViewAndSearchBarNotification object:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.isLoadingPosts || scrollView.decelerating) {
        return;
    }

    CGFloat scrollViewContentOffsetY = scrollView.contentOffset.y;
    if (scrollViewContentOffsetY <= -kLoadingPostsOnScrollOffset) {
        self.searchText = @"";
        self.listStyle == ListStyleAll ? [self.allPosts removeAllObjects] : [self.favoritePosts removeAllObjects];
        self.listStyle == ListStyleAll ? [self getAllPostsWithOffset:0] : [self getFavoritePostsWithOffset:0];
        return;
    }

    CGFloat scrollViewHeight = CGRectGetHeight(scrollView.frame);
    CGFloat scrollViewContentHeight = scrollView.contentSize.height;
    if (scrollViewHeight > scrollViewContentHeight) {
        return;
    }
    if (scrollViewHeight + scrollViewContentOffsetY > scrollViewContentHeight + kLoadingPostsOnScrollOffset) {
        NSLog(@"Loading more posts with offset %lu", (unsigned long)self.posts.count);
        self.listStyle == ListStyleAll ? [self getAllPostsWithOffset:self.posts.count] : [self getFavoritePostsWithOffset:self.posts.count];
    }
}

@end
