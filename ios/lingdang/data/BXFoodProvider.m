//
//  BXFoodProvider.m
//  lingdang
//
//  Created by zengming on 13-8-17.
//  Copyright (c) 2013年 baixing.com. All rights reserved.
//

#import "BXFoodProvider.h"
#import <AVQuery.h>

@implementation BXFoodProvider

BCSINGLETON_IN_M(BXFoodProvider)

- (void)addFoodWithName:(NSString*)name
                  price:(float)price
                   shop:(BXShop*)shop
                success:(void(^)(BXFood* food))sucBlock
                   fail:(void(^)(NSError* err))failBlock;
{
    BXFood *food = [BXFood object];
    food.name = name;
    food.price = price;
    food.pToShop = shop;
    [food saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            if (sucBlock) {
                sucBlock(food);
            }
        } else {
            if (failBlock) {
                failBlock(error);
            }
        }
    }];
}

- (void)deleteFood:(BXFood *)food
         onSuccess:(void(^)(void))sucBlock
            onFail:(void(^)(NSError *err))failBlock
{
    [food deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            if (succeeded) {
                sucBlock();
            }
        } else {
            if (failBlock) {
                failBlock(error);
            }
        }
    }];
}

- (void)updateFood:(BXFood *)food
         onSuccess:(void(^)(void))sucBlock
            onFail:(void(^)(NSError *err))failBlock
{
    [food saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            if (succeeded) {
                sucBlock();
            }
        } else {
            if (failBlock) {
                failBlock(error);
            }
        }
    }];
}

- (void)allFoodsInShop:(AVObject *)shop
            onSuccess:(void(^)(NSArray* food))sucBlock
               onFail:(void(^)(NSError* err))failBlock
{
    AVQuery *query = [BXFood query];
    [query whereKey:@"pToShop" equalTo:shop];
    query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:@"获取店铺food失败，哇咔咔"];
            if (failBlock) {
                failBlock(error);
            }
        } else {
            if (sucBlock) {
                sucBlock([BXFood fixAVOSArray:objects]);
            }
        }
    }];
}


@end
