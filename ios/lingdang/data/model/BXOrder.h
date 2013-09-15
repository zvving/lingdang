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

@interface BXOrder : BXObject

//下单者
@property (strong) AVUser *             pToUser;

//订单状态:0 已下单可修改,1 已预订不可修改,2 已送达
@property (assign) int                  status;

//付款状态
@property (assign) BOOL                 isPaid;

//预定的食物和数量
@property (strong) NSArray *       foodItems;


@property (readonly) NSString *         shopName;
@property (readonly) BXShop *           shop;

-(BXOrder*) merge:(BXOrder*)order;

@end
