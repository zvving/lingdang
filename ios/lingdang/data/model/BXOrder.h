//
//  BXOrder.h
//  lingdang
//
//  Created by zengming on 13-8-17.
//  Copyright (c) 2013年 baixing.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BXFood.h"
#import "BXObject.h"

typedef enum {
    kOrderStatusEditable = 0,
    kOrderStatusOrdered,
    kOrderStatusArrived
} OrderStatus;

@interface BXOrder : BXObject

//下单者
@property (nonatomic, strong) AVUser *                  pToUser;

//订单状态:0 已下单可修改,1 已预订不可修改,2 已送达
@property (nonatomic, assign) OrderStatus               status;

//付款状态
@property (nonatomic, assign) BOOL                 isPaid;

//预定的食物和数量  eg:[{food:{bxfood}, amount:int}, ...]
@property (nonatomic, strong)   NSArray *               foodNameArr;
@property (nonatomic, strong)   NSArray *               foodPriceArr;
@property (nonatomic, strong)   NSArray *               foodAmountArr;
@property (nonatomic, strong)   BXShop *                shop;

-(BXOrder*) merge:(BXOrder*)order;

@end
