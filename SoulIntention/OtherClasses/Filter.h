//
//  FilterType.h
//  SoulIntentions
//
//  Created by Aleksey on 2/11/15.
//  Copyright (c) 2015 ThinkMobiles. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Filter : NSObject

@property (strong, nonatomic) NSArray *allFilters;
@property (assign, nonatomic) NSNumber *selectedIndex;
@property (weak, nonatomic) NSString *selectedFilter;

+ (instancetype)sharedInstance;

@end
