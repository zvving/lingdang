//
//  BXOrderProvider.m
//  lingdang
//
//  Created by zengming on 13-8-17.
//  Copyright (c) 2013年 baixing.com. All rights reserved.
//

#import "BXOrderProvider.h"

@implementation BXOrderProvider

BCSINGLETON_IN_M(BXOrderProvider)

- (void)addOrderWithFood:(BXFood*)food
                   count:(int)count
                 success:(void(^)(BXOrder* order))sucBlock
                    fail:(void(^)(NSError* err))failBlock;
{
    BXOrder *order = [BXOrder object];
    
//    order.pToFood = food;
//    order.count = 1;
    order.pToUser = [AVUser currentUser];
    order.status = 0;
    order.isPaid = NO;
    
//    order.shopName = [food objectForKey:@"shopName"];
//    order.userName = [[AVUser currentUser] username];
//    order.foodName = [food objectForKey:@"name"];
    
    [order saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            if (sucBlock) {
                sucBlock(order);
            }
        } else {
            if (failBlock) {
                failBlock(error);
            }
        }
    }];
}

- (void)allOrders:(void(^)(NSArray* orders))sucBlock
             fail:(void(^)(NSError* err))failBlock;
{
    PFQuery *query = [BXOrder query];

    [query addAscendingOrder:@"updatedAt"];
    [query includeKey:@"shop"];
    [query includeKey:@"pToUser"];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            if (failBlock) {
                failBlock(error);
            }
        } else {
            if (sucBlock) {
                sucBlock(objects);
            }
        }
    }];
}

- (void)allOrdersWithDate:(NSDate*)date
                  success:(void(^)(NSArray* orders))sucBlock
                     fail:(void(^)(NSError* err))failBlock;
{
    PFQuery *query = [BXOrder query];
    [query whereKey:@"updatedAt" greaterThan:date];
    [query whereKey:@"updatedAt" lessThan:[NSDate dateWithTimeInterval:3600*24 sinceDate:date]];
    [query addAscendingOrder:@"updatedAt"];
    
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            if (failBlock) {
                failBlock(error);
            }
        } else {
            if (sucBlock) {
                sucBlock(objects);
            }
        }
    }];
}

- (void)myOrders:(void(^)(NSArray* orders))sucBlock
            fail:(void(^)(NSError* err))failBlock;
{
    PFQuery *query = [BXOrder query];
    
    [query whereKey:@"pToUser" equalTo:[AVUser currentUser]];
    [query includeKey:@"pToShop"];
    [query addDescendingOrder:@"updatedAt"];
    query.limit = 15;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:@"加载订单数据失败"];
            if (failBlock) {
                failBlock(error);
            }
        } else {
            if (sucBlock) {
                sucBlock([BXOrder fixAVOSArray:objects]);
            }
        }
    }];
}

@end
