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
#import "Post.h"

static NSInteger const PostsOffset = 1;
static NSInteger const PostsLimit = 5;


@interface ListViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *posts;

@end

@implementation ListViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.posts = [NSArray new];
    [self getPosts];
}

#pragma mark - Private Methods

- (void)getPosts{
    [[SoulIntentionManager sharedManager] getPostsWithOffset:PostsOffset limit:PostsLimit completitionHandler:^(BOOL success, NSArray *result, NSError *error) {
        self.posts = result;
        [self.tableView reloadData];
    }];
}

#pragma mark - TableView DataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"listCell"];
    
    if (self.posts != nil) {
        cell.post = self.posts[indexPath.row];
    }
    
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
