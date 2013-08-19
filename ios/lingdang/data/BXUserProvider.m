//
//  BXUserProvider.m
//  lingdang
//
//  Created by zengming on 13-8-17.
//  Copyright (c) 2013年 baixing.com. All rights reserved.
//

#import "BXUserProvider.h"

@implementation BXUserProvider

BCSINGLETON_IN_M(BXUserProvider)

- (void)audoLoginWithUsername:(NSString*)username
                      success:(void(^)(AVUser* user))sucBlock
                         fail:(void(^)(NSError* err))failBlock;
{
    [AVUser logInWithUsernameInBackground:username password:kConstPassword
                                    block:^(AVUser *user, NSError *error)
    {
        if (user) {
            if (sucBlock) {
                sucBlock(user);
            }
        } else {
            // 自动登录
            AVUser *newUser = [AVUser user];
            newUser.username = username;
            newUser.password = kConstPassword;

            if ([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)]) {
                NSString *udid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
                [newUser setObject:udid forKey:@"udid"];
            }
            
            [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    if (sucBlock) {
                        sucBlock(newUser);
                    }
                } else {
                    if (failBlock) {
                        failBlock(error);
                    }
                }
            }];
        }
    }];
}

@end
