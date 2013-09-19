//
//  BXPushProvider.m
//  lingdang
//
//  Created by zengming on 9/19/13.
//  Copyright (c) 2013 baixing.com. All rights reserved.
//

#import "BXPushProvider.h"
#import <AVOSCloud/thirdParty/AFNetworking/AFNetworking.h>

@implementation BXPushProvider

BCSINGLETON_IN_M(BXPushProvider)

- (void)pushAllWithTitle:(NSString*)title
{
    [self pushRequestWithTitle:title installationId:nil];
}

- (void)pushUser:(AVUser*)targetUser withTitle:(NSString*)title
{
    NSString *installationId = [targetUser objectForKey:@"installationId"];
    if (installationId) {
        [self pushRequestWithTitle:title installationId:installationId];
    } else {
        [SVProgressHUD showErrorWithStatus:@"device token 没找到"];
    }
}

- (void)pushUserId:(NSString*)userId withTitle:(NSString*)title
{
    AVQuery *query = [AVUser query];
    AVUser *targetUser = (AVUser*)[query getObjectWithId:userId];
    [self pushUser:targetUser withTitle:title];
}

- (void)pushRequestWithTitle:(NSString*)title installationId:(NSString*)installationId
{
    NSURL *url = [NSURL URLWithString:@"https://cn.avoscloud.com/1/push"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:kAVOSAppId forHTTPHeaderField:@"X-AVOSCloud-Application-Id"];
    [request setValue:kAVOSClientKey forHTTPHeaderField:@"X-AVOSCloud-Application-Key"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{
                          @"data" : @{
                                  @"alert" : title ?: @"空信息"
                                  }
                          }];
    
    if (installationId) {
        [dic addEntriesFromDictionary:@{
                                        @"where" : @{
                                                    @"objectId" : installationId
                                                    }
                                        }];
    }
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic
                                                       options:0 // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    if (error) {
        NSLog(@"json error: %@", error);
    } else {
        [request setHTTPBody:jsonData];
    }
    
    [request setHTTPMethod:@"POST"];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"json:%@", JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"error:%@", error);
    }];
    [operation start];
}



@end
