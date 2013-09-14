//
//  BXOrder.m
//  lingdang
//
//  Created by zengming on 13-8-17.
//  Copyright (c) 2013年 baixing.com. All rights reserved.
//

#import "BXOrder.h"

@implementation BXOrder

+ (NSString *)parseClassName
{
    return @"order";
}

+ (instancetype)object
{
    return [[BXOrder alloc] initWithClassName:[BXOrder parseClassName]];
}

- (void)setPToUser:(AVUser *)pToUser
{
    [self setObject:pToUser forKey:@"pToUser"];
}

- (AVUser *)pToUser
{
    return [self objectForKey:@"pToUser"];
}

- (void)setStatus:(int)status
{
    [self setObject:@(status) forKey:@"status"];
}

- (int)status
{
    return [[self objectForKey:@"status"] intValue];
}

- (void)setIsPaid:(BOOL)isPaid
{
    [self setObject:@(isPaid) forKey:@"isPaid"];
}

- (BOOL)isPaid
{
    return [[self objectForKey:@"isPaid"] boolValue];
}

- (void)setFoodItems:(NSDictionary *)foodItems
{
    [self setObject:foodItems forKey:@"foodItems"];
}

- (NSDictionary *)foodItems
{
    return [self objectForKey:@"foodItems"];
}

@end
