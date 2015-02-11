//
//  FilterType.m
//  SoulIntentions
//
//  Created by Aleksey on 2/11/15.
//  Copyright (c) 2015 ThinkMobiles. All rights reserved.
//

#import "Filter.h"

@implementation Filter

#pragma mark - Public Static

+ (instancetype)sharedInstance
{
    static Filter *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [Filter new];
    });
    return sharedInstance;
}

#pragma mark - Lifecycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        _allFilters = @[@"By Date",
                            @"By Rate"];
        _selectedIndex = @0;
    }
    return self;
}

#pragma mark - Custom Accessors

- (NSString *)selectedFilter
{
    return self.allFilters[self.selectedIndex.integerValue];
}

@end
