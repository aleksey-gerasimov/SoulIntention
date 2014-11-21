//
//  ListTableViewCell.h
//  SoulIntention
//
//  Created by Admin on 11/17/14.
//  Copyright (c) 2014 ThinkMobiles. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kListCellSwipeNotification;

@class Post;

@interface ListTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *postImageView;

@property (strong, nonatomic) Post *post;

@end
