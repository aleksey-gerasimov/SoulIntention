//
//  SocialManager.h
//  SoulIntention
//
//  Created by Aleksey on 11/19/14.
//  Copyright (c) 2014 ThinkMobiles. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SocialManager : NSObject

+ (instancetype)sharedManager;

- (BOOL)presentShareDialogWithText:(NSString *)text url:(NSURL *)url;

@end
