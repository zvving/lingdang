//
//  BXShopProvider.m
//  lingdang
//
//  Created by zengming on 13-8-17.
//  Copyright (c) 2013年 baixing.com. All rights reserved.
//

#import "BXShopProvider.h"


@implementation BXShopProvider

BCSINGLETON_IN_M(BXShopProvider)

- (void)addShopWithName:(NSString*)name
                success:(void(^)(BXShop* shop))sucBlock
                   fail:(void(^)(NSError* err))failBlock;
{
    // 根据 name 查找已有 店铺
    PFQuery *query = [BXShop query];
    [query whereKey:kDBColName equalTo:name];
    BXShop *shop = (BXShop*) [query getFirstObject];
    if (shop) {
        if (sucBlock) {
            sucBlock(shop);
        }
    } else { // 新增店铺
        BXShop *newShop = [BXShop object];
        newShop.name = name;
        if ([newShop save]) {
            if (sucBlock) {
                sucBlock(newShop);
            }
        } else {
            if (failBlock) {
                failBlock(nil);
            }
        }
    }
}

- (void)allShops:(void(^)(NSArray* shops))sucBlock
            fail:(void(^)(NSError* err))failBlock;
{
    PFQuery *query = [BXShop query];
    [query addAscendingOrder:kDBColName];
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

@end
