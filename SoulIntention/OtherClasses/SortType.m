//
//  SortType.m
//  SoulIntentions
//
//  Created by Aleksey on 2/11/15.
//  Copyright (c) 2015 ThinkMobiles. All rights reserved.
//

#import "SortType.h"

@interface SortType ()

@property (strong, nonatomic) NSArray *sortsForRequestArray;

@end

@implementation SortType

#pragma mark - Public Static

+ (instancetype)sharedInstance
{
    static SortType *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [SortType new];
    });
    return sharedInstance;
}

#pragma mark - Lifecycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        _allSorts = @[@"By Date",
                      @"By Rating"];
        _sortsForRequestArray = @[@"date",
                                  @"rate"];
        _selectedIndex = @0;
    }
    return self;
}

- (NSString *)transformSortTypeForServerRequest
{
    return self.sortsForRequestArray[self.selectedIndex.integerValue];
}

@end
