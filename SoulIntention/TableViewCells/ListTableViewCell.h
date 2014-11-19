//
//  ListTableViewCell.h
//  SoulIntention
//
//  Created by Admin on 11/17/14.
//  Copyright (c) 2014 ThinkMobiles. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"

@interface ListTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *postImageView;

@property (weak, nonatomic) IBOutlet UIView *cellView;
@property (weak, nonatomic) IBOutlet UIView *favoriteView;
@property (weak, nonatomic) IBOutlet UIView *socialView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageWidthConstraint;

@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;

@property (strong, nonatomic) Post *post;

@end
