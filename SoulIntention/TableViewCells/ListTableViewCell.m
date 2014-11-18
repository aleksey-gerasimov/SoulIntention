//
//  ListTableViewCell.m
//  SoulIntention
//
//  Created by Admin on 11/17/14.
//  Copyright (c) 2014 ThinkMobiles. All rights reserved.
//

#import "ListTableViewCell.h"

@implementation ListTableViewCell

#pragma mark - Lifecycle

- (void)awakeFromNib {
    // Initialization code
    [self initGestureRecognizer];
}

- (void)initGestureRecognizer{
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget: self action: @selector(swipeToLeftWithGestureRecognizer:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget: self action: @selector(swipeToRightWithGestureRecognizer:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionLeft;
    
    [self.cellView addGestureRecognizer: swipeLeft];
    [self.cellView addGestureRecognizer: swipeRight];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(UIEdgeInsets)layoutMargins{
    return UIEdgeInsetsZero;
}

#pragma mark - Swipe Gesture Recognizer

- (void)swipeToRightWithGestureRecognizer:(UIGestureRecognizer*)gestureRecogniser{
    [UIView animateWithDuration:0.5f animations:^{
        self.cellView.frame = CGRectOffset(self.cellView.frame, 150.f, 0.f);
        self.socialView.frame = CGRectOffset(self.socialView.frame, 150.f, 0.f);
        self.likeView.frame = CGRectOffset(self.likeView.frame, 150.f, 0.f);
    }];
}

- (void)swipeToLeftWithGestureRecognizer:(UIGestureRecognizer*)gestureRecogniser{
    [UIView animateWithDuration:0.5f animations:^{
        self.cellView.frame = CGRectOffset(self.cellView.frame, -150.f, 0.f);
        self.socialView.frame = CGRectOffset(self.socialView.frame, -150.f, 0.f);
        self.likeView.frame = CGRectOffset(self.likeView.frame, -150.f, 0.f);
    }];
}

@end
