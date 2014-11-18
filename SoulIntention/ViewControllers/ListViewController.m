//
//  ListViewController.m
//  SoulIntention
//
//  Created by Admin on 11/17/14.
//  Copyright (c) 2014 ThinkMobiles. All rights reserved.
//

#import "ListViewController.h"
#import "ListTableViewCell.h"

@interface ListViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ListViewController

#pragma mark - Lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
    self.tableView.allowsSelection = NO;
}

#pragma mark - Private Methods


#pragma mark - TableView DataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"listCell"];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
#warning hardcode
   return 5;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

@end
