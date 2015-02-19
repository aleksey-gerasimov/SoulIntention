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

@interface ListViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, ListTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) NSMutableArray *allPosts;
@property (strong, nonatomic) NSMutableArray *favoritePosts;
@property (strong, nonatomic) NSArray *posts;
@property (strong, nonatomic) NSString *searchText;
@property (assign, nonatomic) BOOL isLoadingPosts;
@property (assign, nonatomic) BOOL needsUpdate;
@property (assign, nonatomic) BOOL noResults;

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
        UIViewController *currentViewController = note.userInfo[@"viewController"];
        if ([weakSelf isEqual:currentViewController]) {
            weakSelf.searchText = note.userInfo[@"text"];
            weakSelf.listStyle == ListStyleAll ? [weakSelf.allPosts removeAllObjects] : [weakSelf.favoritePosts removeAllObjects];
            weakSelf.listStyle == ListStyleAll ? [weakSelf getAllPostsWithOffset:0] : [weakSelf getFavoritePostsWithOffset:0];
        }
    }];
    if (self.listStyle == ListStyleAll) {
        [[NSNotificationCenter defaultCenter] addObserverForName:kRemoteNotificationRecievedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            weakSelf.searchText = @"";
            [weakSelf.allPosts removeAllObjects];
            [weakSelf getAllPostsWithOffset:0];
        }];
    } else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFavoritePosts:) name:kFavoriteFlagChangedNotification object:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.needsUpdate && self.appDelegate.sessionStarted) {
        self.listStyle == ListStyleAll ? [self.allPosts removeAllObjects] : [self.favoritePosts removeAllObjects];
        self.listStyle == ListStyleAll ? [self getAllPostsWithOffset:0] : [self getFavoritePostsWithOffset:0];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    if (self.searchText.length > 0) {
        self.searchText = @"";
        self.needsUpdate = YES;
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:kListCellSwipeNotification object:nil userInfo:@{@"postId" : @"", @"animate" : @YES}];
    [[NSNotificationCenter defaultCenter] postNotificationName:kHideSortViewAndSearchBarNotification object:nil];
}

- (void)dealloc
{
    NSLog(@"%@ dealloc", NSStringFromClass([self class]));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Custom Accessors

- (void)setIsLoadingPosts:(BOOL)isLoadingPosts
{
    _isLoadingPosts = isLoadingPosts;
    
    if (isLoadingPosts) {
        CGPoint contentOffset = self.tableView.contentOffset;
        self.tableView.scrollEnabled = NO;
        self.tableView.contentOffset = contentOffset;
        [UIView animateWithDuration:kAnimationDuration animations:^{
            if (contentOffset.y <= kLoadingOnScrollOffsetY) {
                self.tableView.contentOffset = CGPointZero;
            } else {
                CGFloat scrollViewHeight = CGRectGetHeight(self.tableView.frame);
                CGFloat scrollViewContentHeight = self.tableView.contentSize.height;
                CGFloat contentOffsetY = scrollViewContentHeight - scrollViewHeight < 0 ? 0.0 : scrollViewContentHeight - scrollViewHeight;
                self.tableView.contentOffset = CGPointMake(0.0, contentOffsetY);
            }
        } completion:^(BOOL finished) {
            self.tableView.scrollEnabled = YES;
        }];
    }
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

    if (offset == 0 && [self.tableView numberOfRowsInSection:0] > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
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

    if (offset == 0 && [self.tableView numberOfRowsInSection:0] > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kListCellSwipeNotification object:nil userInfo:@{@"postId" : @""}];
}

- (void)updateFavoritePosts:(NSNotification *)note
{
    if ([(NSNumber *)note.userInfo[@"isFavorite"] boolValue]) {
        self.searchText = @"";
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

    if (self.parentViewController) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kListCellSwipeNotification object:nil userInfo:@{@"postId" : @"", @"animate" : @YES}];
        [[NSNotificationCenter defaultCenter] postNotificationName:kHideSortViewAndSearchBarNotification object:nil];
    }
}

#pragma mark - TableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    self.noResults = self.posts.count == 0 ? YES : NO;
    NSInteger numberOfRows = self.noResults ? 1 : self.posts.count;
    self.tableView.separatorStyle = self.noResults ? UITableViewCellSeparatorStyleNone : UITableViewCellSeparatorStyleSingleLine;
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.noResults) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"noResultsCell"];
        UILabel *label = (UILabel *)[cell viewWithTag:1];
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:2];
        if (self.searchText.length > 0) {
            label.text = @"NO RESULTS FOUND. PLEASE, REFRESH THE TABLE.";
            imageView.image = nil;
        } else {
            label.text = self.listStyle == ListStyleAll ? @"NO SOUL INTENTIONS ARE CURRENTLY AVAILABLE." : @"ADD A SOUL INTENTION TO YOUR FAVORITES TO VIEW IT HERE!";
            imageView.image = self.listStyle == ListStyleAll ? nil : [UIImage imageNamed:kNoFavoritesPlaceholderImage];
        }
        return cell;
    } else {
        ListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"listCell"];
        cell.delegate = self;
        cell.post = self.posts[indexPath.row];
        return cell;
    }
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
    if (scrollViewContentOffsetY <= -kLoadingOnScrollOffsetY) {
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
    if (scrollViewHeight + scrollViewContentOffsetY > scrollViewContentHeight + kLoadingOnScrollOffsetY) {
        NSLog(@"Loading more posts with offset %lu", (unsigned long)self.posts.count);
        self.listStyle == ListStyleAll ? [self getAllPostsWithOffset:self.posts.count] : [self getFavoritePostsWithOffset:self.posts.count];
    }
}

#pragma mark - ListTableViewCellDelegate

- (void)cellSelectedWithPost:(Post *)post
{
    PostViewController *postViewController = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([PostViewController class])];
    postViewController.post = post;
    [self.navigationController pushViewController:postViewController animated:YES];}

@end
