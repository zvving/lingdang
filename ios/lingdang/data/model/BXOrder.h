//
//  BXOrder.h
//  lingdang
//
//  Created by zengming on 13-8-17.
//  Copyright (c) 2013年 baixing.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BXFood.h"

@interface BXOrder : PFObject <PFSubclassing>

@property (strong) BXFood *             pToFood;
@property (assign) int                  count;

@property (strong) PFUser *             pToUser;

/* 
 0 初始
 1 已订购
 2 已送达
 3 存档
 */
@property (assign) int                  status;

// 付款状态，备用
@property (assign) BOOL                 isPaid;

@end
