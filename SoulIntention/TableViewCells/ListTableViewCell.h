//
//  ListTableViewCell.h
//  SoulIntention
//
//  Created by Admin on 11/17/14.
//  Copyright (c) 2014 ThinkMobiles. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Post;

@interface ListTableViewCell : UITableViewCell

@property (strong, nonatomic) Post *post;
@property (strong, nonatomic, readonly) UIImage *postImage;

@end
