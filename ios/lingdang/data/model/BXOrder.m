//
//  BXOrder.m
//  lingdang
//
//  Created by zengming on 13-8-17.
//  Copyright (c) 2013年 baixing.com. All rights reserved.
//

#import "BXOrder.h"

@implementation BXOrder

+ (NSString *)parseClassName {
    return @"order";
}

+ (instancetype)object
{
    return [[BXOrder alloc] initWithClassName:[BXOrder parseClassName]];
}

//+ (instancetype)object
//{
//    return [super objectWithClassName:[self parseClassName]];
//}
//
//+ (instancetype)objectWithoutDataWithObjectId:(NSString *)objectId
//{
//    return [super objectWithoutDataWithClassName:[self parseClassName]
//                                        objectId:objectId];
//}
//
//+ (PFQuery *)query
//{
//    return [PFQuery queryWithClassName:[self parseClassName]];
//}

- (void)setPToFood:(BXFood *)pToFood
{
    [self setObject:pToFood forKey:@"pToFood"];
}

- (BXFood *)pToFood
{
    return [self objectForKey:@"pToFood"];
}

- (void)setPToUser:(AVUser *)pToUser
{
    [self setObject:pToUser forKey:@"pToUser"];
}

- (AVUser *)pToUser
{
    return [self objectForKey:@"pToUser"];
}

- (void)setCount:(int)count
{
    [self setObject:@(count) forKey:@"count"];
}

- (int)count
{
    return [[self objectForKey:@"count"] intValue];
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

- (void)setShopName:(NSString *)shopName
{
    [self setObject:shopName?:@"" forKey:@"shopName"];
}

- (NSString *)shopName
{
    return [self objectForKey:@"shopName"];
}

- (void)setFoodName:(NSString *)foodName
{
    [self setObject:foodName?:@"" forKey:@"foodName"];
}

- (NSString *)foodName
{
    return [self objectForKey:@"foodName"];
}

- (void)setUserName:(NSString *)userName
{
    [self setObject:userName?:@"" forKey:@"userName"];
}

- (NSString *)userName
{
    return [self objectForKey:@"userName"];
}

@end
