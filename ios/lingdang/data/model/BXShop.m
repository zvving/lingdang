//
//  BXShop.m
//  lingdang
//
//  Created by zengming on 13-8-17.
//  Copyright (c) 2013年 baixing.com. All rights reserved.
//

#import "BXShop.h"

@implementation BXShop

+ (NSString *)parseClassName {
    return @"shop";
}

+ (instancetype)object
{
    return [[BXShop alloc] initWithClassName:[BXShop parseClassName]];
}

- (void)setName:(NSString *)name
{
    [self setObject:name forKey:@"name"];
}

- (NSString *)name
{
    return [self objectForKey:@"name"];
}

- (void)setShipInfo:(NSString *)shipInfo
{
    [self setObject:shipInfo forKey:@"shipInfo"];
}

- (NSString *)shipInfo
{
    return [self objectForKey:@"shipInfo"];
}

@end
