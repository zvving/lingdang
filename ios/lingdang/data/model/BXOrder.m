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

- (void)setFoodNameArr:(NSArray *)foodNameArr
{
    [self setObject:foodNameArr forKey:@"foodNameArr"];
}

- (NSArray *)foodNameArr
{
    return [self objectForKey:@"foodNameArr"];
}

- (void)setFoodPriceArr:(NSArray *)foodPriceArr
{
    [self setObject:foodPriceArr forKey:@"foodPriceArr"];
}

- (NSArray *)foodPriceArr
{
    return [self objectForKey:@"foodPriceArr"];
}

- (void)setFoodAmountArr:(NSArray *)foodAmountArr
{
    [self setObject:foodAmountArr forKey:@"foodAmountArr"];
}

- (NSArray *)foodAmountArr
{
    return [self objectForKey:@"foodAmountArr"];
}

- (BXShop *)shop
{
    return [BXShop fixAVOSObject:[self objectForKey:@"pToShop"]];
}

- (void)setShop:(BXShop *)shop
{
    [self setObject:shop forKey:@"pToShop"];
}

-(BXOrder*)merge:(BXOrder*)order
{
    NSMutableArray *foodItems = [[NSMutableArray alloc] initWithArray:self.foodItems];
    
    for (NSDictionary *foodItem in order.foodItems) {
       NSUInteger index = [foodItems indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
           if ([[[obj objectForKey:@"food"] objectId] isEqualToString:[[foodItem objectForKey:@"food"] objectId]]) {
               *stop = YES;
               return YES;
           }
           return NO;
        }];
        if (index == NSNotFound) {
            [foodItems addObject:foodItem];
        } else {
            NSMutableDictionary *mergedFoodItem = [[NSMutableDictionary alloc] init];
            [mergedFoodItem setObject:foodItem[@"food"] forKey:@"food"];
            NSDictionary *oldFoodItem = [foodItems objectAtIndex:index] ;
            NSInteger oldAmount = [[oldFoodItem objectForKey:@"amount"] integerValue];
            NSInteger anoAmount = [[foodItem objectForKey:@"amount"]integerValue];
            [mergedFoodItem setObject:@(oldAmount + anoAmount) forKey:@"amount"];
            
            [foodItems replaceObjectAtIndex:index withObject:mergedFoodItem];
        }
    }
    
    self.foodItems = foodItems;
    return self;
}
@end
