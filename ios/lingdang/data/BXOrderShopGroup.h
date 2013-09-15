//
//  BXOrderShopGroup.h
//  lingdang
//
//  Created by zengming on 9/15/13.
//  Copyright (c) 2013 baixing.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BXShop;
@class BXOrder;

@interface BXOrderShopGroupItem : NSObject

@property (nonatomic, strong)       BXShop *                shop;
@property (nonatomic, strong)       NSMutableArray *        orders;


@property (nonatomic, strong)   NSMutableArray *               foodNameArr;
@property (nonatomic, strong)   NSMutableArray *               foodPriceArr;
@property (nonatomic, strong)   NSMutableArray *               foodAmountArr;

- (void)appendOrder:(BXOrder*)order;

@end

@interface BXOrderShopGroup : NSObject

+ (BXOrderShopGroup*)groupByOrders:(NSArray*)orders;

@property (nonatomic, strong)   NSMutableArray *        itemArr;

@end
