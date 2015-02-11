//
//  FilterViewController.m
//  SoulIntentions
//
//  Created by Aleksey on 2/11/15.
//  Copyright (c) 2015 ThinkMobiles. All rights reserved.
//

#import "FilterViewController.h"

#import "Filter.h"
#import "Constants.h"

@interface FilterViewController ()

@property (strong, nonatomic) Filter *filter;

@end

@implementation FilterViewController

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
//{
//    if (![keyPath isEqualToString:@"selectedIndex"]) {
//        return;
//    }
//    NSLog(@"change = %@", change);
//    NSNumber *oldValue = (NSNumber *)change[@"old"];
//    NSArray *indexPaths = self.tableView.indexPathsForSelectedRows;
//    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
//        if (indexPath.row == oldValue.integerValue) {
//            [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
//        }
//    }];
//}

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.filter = [Filter sharedInstance];
    __weak FilterViewController *weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:kShowFilterViewNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [weakSelf.tableView reloadData];
    }];
//    [self.filter addObserver:self forKeyPath:@"selectedIndex" options:NSKeyValueObservingOptionOld context:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:kShowFilterViewNotification];
//    [self.filter removeObserver:self forKeyPath:@"selectedIndex"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.filter.allFilters.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"filterCell" forIndexPath:indexPath];
    cell.textLabel.text = self.filter.allFilters[indexPath.row];
    BOOL isSelected = indexPath.row == self.filter.selectedIndex.integerValue ? YES : NO;
    if (isSelected && !cell.selected) {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    return cell;
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.filter.selectedIndex = @(indexPath.row);
    [[NSNotificationCenter defaultCenter] postNotificationName:kSetFilterTypeNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kHideFilterViewAndSearchBarNotification object:nil];
}

@end
