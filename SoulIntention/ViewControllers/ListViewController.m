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
@property (assign, nonatomic) FilterType filterType;

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
    self.needsUpdate = YES;
    self.filterType = FilterTypeMostRecent;

    __weak ListViewController *weakSelf = self;
    switch (self.listStyle) {
        case ListStyleAll: {
            [[NSNotificationCenter defaultCenter] addObserverForName:kSessionStartedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
                [weakSelf getAllPostsOrderedBy:weakSelf.filterType offset:0];
            }];
            [[NSNotificationCenter defaultCenter] addObserverForName:kSetFilterTypeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
                [weakSelf.allPosts removeAllObjects];
                NSNumber *updatedFilterType = note.userInfo[@"filterType"];
                [weakSelf getAllPostsOrderedBy:updatedFilterType.integerValue offset:0];
            }];
            [[NSNotificationCenter defaultCenter] addObserverForName:kSearchForPostsNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
                weakSelf.filterType = FilterTypeMostRecent;
                [weakSelf.allPosts removeAllObjects];
                [weakSelf searchForPostsWithTitle:note.userInfo[@"text"] offset:0];
            }];
            break;
        }
        case ListStyleFavorite: {
            [[NSNotificationCenter defaultCenter] addObserverForName:kSessionStartedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
                [weakSelf getFavoritePostsWithOffset:0];
            }];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFavoritePosts:) name:kFavoriteFlagChangedNotification object:nil];
            break;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.needsUpdate && self.appDelegate.sessionStarted) {
        self.listStyle == ListStyleAll ? [self getAllPostsOrderedBy:self.filterType offset:0] : [self getFavoritePostsWithOffset:0];
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
    [[NSNotificationCenter defaultCenter] postNotificationName:kHideSearchBarNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private Methods

- (void)showPosts:(NSArray *)posts
{
    self.posts = [posts copy];
    [self.tableView reloadData];
    self.isLoadingPosts = NO;
    self.needsUpdate = NO;
}

#pragma mark All Posts

- (void)getAllPostsOrderedBy:(FilterType)filterType offset:(NSInteger)offset
{
    self.filterType = filterType;
    self.searchText = @"";
    self.isLoadingPosts = YES;
    [self.view showLoadingIndicator];
    __weak ListViewController *weakSelf = self;
    [[SoulIntentionManager sharedManager] getPostsOrderedBy:self.filterType offset:offset limit:kPostsLimit completitionHandler:^(BOOL success, NSArray *result, NSError *error) {
        [weakSelf.view hideLoadingIndicator];
        if (error) {
            [weakSelf.appDelegate showAlertViewWithTitle:@"Error" message:@"Failed to load posts"];
            weakSelf.isLoadingPosts = NO;
        } else {
            [weakSelf.allPosts addObjectsFromArray:result];
        }
        [weakSelf showPosts:weakSelf.allPosts];
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
        } else {
            NSLog(@"Found %lu posts with title \"%@\", offset = %li, limit = %li", (unsigned long)[result count], text, (long)offset, (long)kPostsLimit);
            [weakSelf.allPosts addObjectsFromArray:result];
        }
        [weakSelf showPosts:weakSelf.allPosts];
    }];
}

#pragma mark Favorite Posts

- (void)getFavoritePostsWithOffset:(NSInteger)offset
{
    self.isLoadingPosts = YES;
    [self.view showLoadingIndicator];
    __weak ListViewController *weakSelf = self;
    [[SoulIntentionManager sharedManager] getFavoritesWithOffset:offset limit:kPostsLimit completitionHandler:^(BOOL success, NSArray *result, NSError *error) {
        [weakSelf.view hideLoadingIndicator];
        if (error) {
            [weakSelf.appDelegate showAlertViewWithTitle:@"Error" message:@"Failed to load favorite posts"];
            weakSelf.isLoadingPosts = NO;
        } else {
            [weakSelf.favoritePosts addObjectsFromArray:[result valueForKey:@"post"]];
        }
        [weakSelf showPosts:weakSelf.favoritePosts];
    }];
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
    postViewController.postImage = cell.postImage;
    [self.navigationController pushViewController:postViewController animated:YES];
}

#pragma mark - ScrollView Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kHideSearchBarNotification object:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.isLoadingPosts || scrollView.decelerating) {
        return;
    }

    CGFloat scrollViewContentOffsetY = scrollView.contentOffset.y;
    if (scrollViewContentOffsetY <= -kLoadingPostsOnScrollOffset) {
        [self.allPosts removeAllObjects];
        [self.favoritePosts removeAllObjects];
        self.listStyle == ListStyleAll ? [self getAllPostsOrderedBy:self.filterType offset:0] : [self getFavoritePostsWithOffset:0];
        return;
    }

    CGFloat scrollViewHeight = CGRectGetHeight(scrollView.frame);
    CGFloat scrollViewContentHeight = scrollView.contentSize.height;
    if (scrollViewHeight > scrollViewContentHeight) {
        return;
    }
    if (scrollViewHeight + scrollViewContentOffsetY > scrollViewContentHeight + kLoadingPostsOnScrollOffset) {
        NSLog(@"Loading more posts with offset %lu", (unsigned long)self.posts.count);
        switch (self.listStyle) {
            case ListStyleAll:
                self.searchText.length > 0 ? [self searchForPostsWithTitle:self.searchText offset:self.posts.count] : [self getAllPostsOrderedBy:self.filterType offset:self.posts.count];
                break;
            case ListStyleFavorite:
                [self getFavoritePostsWithOffset:self.posts.count];
                break;
        }
    }
}

@end
