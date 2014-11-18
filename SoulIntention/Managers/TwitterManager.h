//
//  TwitterManager.h
//  SoulIntention
//
//  Created by Aleksey on 11/17/14.
//  Copyright (c) 2014 ThinkMobiles. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TwitterManager : NSObject

+ (instancetype)sharedManager;

- (void)presentShareDialogWithText:(NSString *)text image:(NSURL *)image url:(NSURL *)url;

@end
