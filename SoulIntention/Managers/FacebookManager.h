//
//  FacebookManager.h
//  SoulIntention
//
//  Created by Aleksey on 11/17/14.
//  Copyright (c) 2014 ThinkMobiles. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FacebookManager : NSObject

+ (instancetype)sharedManager;

- (void)presentShareDialogWithName:(NSString *)name caption:(NSString *)caption description:(NSString *)description link:(NSURL *)link picture:(NSURL *)picture;

@end
