//
//  SortType.h
//  SoulIntentions
//
//  Created by Aleksey on 2/11/15.
//  Copyright (c) 2015 ThinkMobiles. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SortType : NSObject

@property (strong, nonatomic) NSArray *allSorts;
@property (assign, nonatomic) NSNumber *selectedIndex;

+ (instancetype)sharedInstance;

- (NSString *)transformSortTypeForServerRequest;

@end
