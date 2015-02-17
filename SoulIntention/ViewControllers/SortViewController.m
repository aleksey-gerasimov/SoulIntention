//
//  SortViewController.m
//  SoulIntentions
//
//  Created by Aleksey on 2/11/15.
//  Copyright (c) 2015 ThinkMobiles. All rights reserved.
//

#import "SortViewController.h"

#import "SortType.h"
#import "Constants.h"

@interface SortViewController ()

@property (weak, nonatomic) SortType *sortType;

@end

@implementation SortViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.sortType = [SortType sharedInstance];

    __weak SortViewController *weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:kShowSortViewNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [weakSelf.tableView reloadData];
    }];
}

- (void)dealloc
{
    NSLog(@"%@ dealloc", NSStringFromClass([self class]));
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:kShowSortViewNotification];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sortType.allSorts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sortCell" forIndexPath:indexPath];

    UIViewController *initialViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateInitialViewController];
    UIView *backgroundView = [[UIView alloc] initWithFrame:cell.bounds];
    backgroundView.backgroundColor = initialViewController.view.backgroundColor;
    cell.selectedBackgroundView = backgroundView;
    cell.backgroundColor = backgroundView.backgroundColor;

    cell.textLabel.text = self.sortType.allSorts[indexPath.row];

    BOOL isSelected = indexPath.row == self.sortType.selectedIndex.integerValue ? YES : NO;
    cell.accessoryType = isSelected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

    return cell;
}

#pragma mark Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat containerHeight = CGRectGetHeight(self.tableView.superview.frame);
    CGFloat cellHeight = self.sortType.allSorts.count > 0 ? containerHeight/self.sortType.allSorts.count : containerHeight;
    return cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.sortType.selectedIndex = @(indexPath.row);
    [self.sortType.allSorts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = idx == self.sortType.selectedIndex.integerValue ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }];

    [[NSNotificationCenter defaultCenter] postNotificationName:kSetSortTypeNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kHideSortViewAndSearchBarNotification object:nil];
}

@end
