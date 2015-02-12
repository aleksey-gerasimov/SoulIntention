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

@property (weak, nonatomic) SortType *sort;

@end

@implementation SortViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupBorder];

    self.sort = [SortType sharedInstance];

    __weak SortViewController *weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:kShowFilterViewNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [weakSelf.tableView reloadData];
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:kShowFilterViewNotification];
}

#pragma mark - Private

- (void)setupBorder
{
    self.tableView.layer.cornerRadius = 5.0;
    self.tableView.layer.borderWidth = 3.0;
    UIViewController *initialViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateInitialViewController];
    self.tableView.layer.borderColor = initialViewController.view.backgroundColor.CGColor;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sort.allSorts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sortCell" forIndexPath:indexPath];
    cell.textLabel.text = self.sort.allSorts[indexPath.row];
    BOOL isSelected = indexPath.row == self.sort.selectedIndex.integerValue ? YES : NO;
    if (isSelected && !cell.selected) {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    return cell;
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.sort.selectedIndex = @(indexPath.row);
    [[NSNotificationCenter defaultCenter] postNotificationName:kSetFilterTypeNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kHideFilterViewAndSearchBarNotification object:nil];
}

@end
