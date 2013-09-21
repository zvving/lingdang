//
//  BXOrderShopGroup.m
//  lingdang
//
//  Created by zengming on 9/15/13.
//  Copyright (c) 2013 baixing.com. All rights reserved.
//

#import "BXOrderShopGroup.h"

#import "BXOrder.h"

@implementation BXOrderShopGroupItem

- (id)init
{
    self = [super init];
    if (self) {
        _orders = [NSMutableArray array];
        _foodNameArr = [NSMutableArray array];
        _foodPriceArr = [NSMutableArray array];
        _foodAmountArr = [NSMutableArray array];
    }
    return self;
}

- (void)appendOrder:(BXOrder*)order;
{
    [self.orders addObject:order];
    
    [order.foodNameArr enumerateObjectsUsingBlock:^(NSString* foodName, NSUInteger idx, BOOL *stop) {
        NSNumber *price = order.foodPriceArr[idx];
        int amount = [order.foodAmountArr[idx] intValue];
        if ([_foodNameArr containsObject:foodName]) {
            int i = [_foodNameArr indexOfObject:foodName];
            int oldAmount = [_foodAmountArr[i] intValue];
            [_foodAmountArr replaceObjectAtIndex:i withObject:@(oldAmount + amount)];
        } else {
            [_foodNameArr addObject:foodName];
            [_foodAmountArr addObject:@(amount)];
            [_foodPriceArr addObject:price];
        }
    }];

}

@end


@interface BXOrderShopGroup ()

@property (nonatomic, strong)   NSMutableDictionary *   keyMap;

@end

@implementation BXOrderShopGroup

+ (BXOrderShopGroup*)groupByOrders:(NSArray*)orders;
{
    BXOrderShopGroup *group = [[BXOrderShopGroup alloc] init];
    [orders enumerateObjectsUsingBlock:^(BXOrder *o, NSUInteger idx, BOOL *stop) {
        if (o.shop == nil || [o.shop isKindOfClass:[NSNull class]]) {
            return;
        }

        //根据店铺名和订单状态来group
        NSString *groupKey = [NSString stringWithFormat:@"%@%d", o.shop.objectId, o.status];
        if ([group.keyMap.allKeys containsObject:groupKey]) {
            BXOrderShopGroupItem *item = [group.keyMap objectForKey:groupKey];
            [item appendOrder:o];
        } else {
            BXOrderShopGroupItem *item = [[BXOrderShopGroupItem alloc] init];
            item.shop = o.shop;
            item.status = o.status;
            [item appendOrder:o];
            [group.keyMap setObject:item forKey:groupKey];
            [group.itemArr addObject:item];
        }
    }];
    return group;
}

- (id)init
{
    self = [super init];
    if (self) {
        _itemArr = [NSMutableArray array];
        _keyMap = [NSMutableDictionary dictionary];
    }
    return self;
}

@end
