//
//  ListTableViewCell.h
//  SoulIntention
//
//  Created by Admin on 11/17/14.
//  Copyright (c) 2014 ThinkMobiles. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Post;

@protocol ListTableViewCellDelegate <NSObject>

@optional
- (void)cellSelectedWithPost:(Post *)post;

@end

@interface ListTableViewCell : UITableViewCell

@property (weak, nonatomic) id<ListTableViewCellDelegate> delegate;
@property (strong, nonatomic) Post *post;

@end
