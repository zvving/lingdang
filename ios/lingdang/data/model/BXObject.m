//
//  BXObject.m
//  lingdang
//
//  Created by zengming on 13-8-18.
//  Copyright (c) 2013年 baixing.com. All rights reserved.
//

#import "BXObject.h"

@implementation BXObject

+ (NSString *)parseClassName {
    return @"demo";
}

+ (AVQuery*)query;
{
    return [AVQuery queryWithClassName:[self parseClassName]];
}

@end
