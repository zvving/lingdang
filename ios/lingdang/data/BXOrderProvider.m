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

    order.user = [AVUser currentUser];
    order.status = 0;
    order.isPaid = NO;
    
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

    [query addDescendingOrder:@"updatedAt"];
    [query includeKey:@"pToShop"];
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
    [query addDescendingOrder:@"updatedAt"];
    
    
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

#warning TODO 这里server端需要检测order的status，如果非0的话，不允许删除
- (void)deleteOrder:(BXOrder *) order
          onSuccess:(void (^)(void)) sucBlock
             onFail:(void (^)(NSError *err)) errBlock
{
    AVUser *currentUser = [AVUser currentUser];
    if ([order.user.objectId isEqualToString:currentUser.objectId] == NO) {
        NSError *error = [[NSError alloc] initWithDomain:nil
                                                        code:0
                                                    userInfo:@{@"msg": @"你没有权限操作"}];
        [self processError:error withBlock:errBlock];
        return;
    }
    
    [order deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error != nil) {
            if (error) {
                NSError *err = [[NSError alloc] initWithDomain:nil
                                                          code:error.code
                                                      userInfo:@{@"msg":@"取消失败，请稍后重试"}];

                [self processError:err withBlock:errBlock];
            }
        }
        
        if (succeeded && sucBlock) {
            sucBlock();
        }
    }];
}

- (void)processError:(NSError *)error
           withBlock:(void (^)(NSError *err)) errBlock
{
    if (error != nil) {
        errBlock(error);
    } else {
        [SVProgressHUD showErrorWithStatus:error.userInfo[@"msg"]];
    }
}

@end
