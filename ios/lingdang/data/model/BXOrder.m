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

- (void)setFoodItems:(NSArray *)foodItems
{
    [self setObject:foodItems forKey:@"foodItems"];
}

- (NSArray *)foodItems
{
    return [self objectForKey:@"foodItems"];
}

- (NSString*)shopName
{
    NSEnumerator *enumerator = [self.foodItems objectEnumerator];
    BXFood* key = [enumerator nextObject];
    return key.shopName;
}

- (BXShop*)shop
{
    NSEnumerator *enumerator = [self.foodItems objectEnumerator];
    BXFood* key = [enumerator nextObject];
    return key.pToShop;
}

-(BXOrder*) merge:(BXOrder*)order
{
//    [order.foodItems enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
//    {
//        if (![self.foodItems objectForKey:key])
//        {
//            [self.foodItems setValue:obj forKey:key];
//        }
//        else
//        {
//            int oldAmount = [[self.foodItems objectForKey:key] integerValue];
//            int newAmount = oldAmount + [obj integerValue];
//            [self.foodItems setValue:[NSNumber numberWithInt:newAmount] forKey:key];
//        }
//    }];
    
    return self;
}
@end
