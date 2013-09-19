//
//  BXPushProvider.m
//  lingdang
//
//  Created by zengming on 9/19/13.
//  Copyright (c) 2013 baixing.com. All rights reserved.
//

#import "BXPushProvider.h"
#import <AFNetworking.h>

@implementation BXPushProvider

- (void)push
{
    NSURL *url = [NSURL URLWithString:@"https://cn.avoscloud.com/1/installations"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"App.net Global Stream: %@", JSON);
    } failure:nil];
    [operation start];
}

@end
