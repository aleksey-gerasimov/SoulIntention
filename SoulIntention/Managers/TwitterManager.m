//
//  TwitterManager.m
//  SoulIntention
//
//  Created by Aleksey on 11/17/14.
//  Copyright (c) 2014 ThinkMobiles. All rights reserved.
//

//#import <STTwitter/STTwitter.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>

#import "TwitterManager.h"
#import "AppDelegate.h"

static NSString *const TSTwitterPostRequestURL = @"https://api.twitter.com/1.1/statuses/update_with_media.json";

@interface TwitterManager ()

//@property (strong, nonatomic) STTwitterAPI *twitterAPI;
@property (strong, nonatomic) ACAccount *twitterAccount;

@end

@implementation TwitterManager

+ (instancetype)sharedManager
{
    static TwitterManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [TwitterManager new];
        //instance.twitterAPI = [STTwitterAPI twitterAPIOSWithFirstAccount];
    });
    return instance;
}

- (void)presentShareDialogWithText:(NSString *)text image:(NSURL *)image url:(NSURL *)url
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        SLComposeViewController *viewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        if (text) {
            [viewController setInitialText:text];
        }
        if (image) {
#warning Synhronous load; should be replaced after API released
            UIImage *picture = [UIImage imageWithData:[NSData dataWithContentsOfURL:image]];
            [viewController addImage:picture];
        }
        if (url) {
            [viewController addURL:url];
        }
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate.window.rootViewController presentViewController:viewController animated:YES completion:nil];
    } else {
        NSLog(@"Twitter is not available on the device");
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Please, setup your twitter account in Settings" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

//#pragma mark - Private
//
//- (void)login
//{
//    if (!self.twitterAccount) {
//        ACAccountStore *accountStore = [[ACAccountStore alloc] init];
//        ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
//        [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
//            if(granted) {
//                NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
//                if (accountsArray.count) {
//                    NSLog(@"Twitter account access recieved");
//                    self.twitterAccount = [accountsArray firstObject];
//                } else {
//                    NSLog(@"Twitter account not found");
//                    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"TwitterLogin"];
//                }
//            }
//            else {
//                NSLog(@"Twitter account access denied");
//                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"TwitterLogin"];
//            }
//        }];
//    }
//}
//
//- (void)shareWithTwitterText:(NSString *)text image:(UIImage *)image
//{
//    if (!self.twitterAccount) {
//        [self login];
//        return;
//    }
//
//    NSDictionary *tweetDetails;
//    NSURL *url = [NSURL URLWithString:TSTwitterPostRequestURL];
//    tweetDetails = @{@"status":text};
//    SLRequest *post = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:url parameters:tweetDetails];
//    NSData *data = UIImageJPEGRepresentation(image, 1.0f);
//    [post addMultipartData:data withName:@"media[]" type:@"image/jpeg" filename:nil];
//    [post setAccount:self.twitterAccount];
//    [post performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
//        if (error) {
//            NSLog(@"Twitter share error: %@", error);
//        } else {
//            NSLog(@"Twitter share success");
//        }
//    }];
//}

@end
