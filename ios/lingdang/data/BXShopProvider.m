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
                  phone:(NSString*)phone
               shipInfo:(NSString*)shipInfo
                success:(void(^)(BXShop* shop))sucBlock
                   fail:(void(^)(NSError* err))failBlock;
{
    // 先不检查重复
//    // 根据 name 查找已有 店铺
//    AVQuery *query = [BXShop query];
//    [query whereKey:kDBColName equalTo:name];
//    BXShop *shop = (BXShop*) [query getFirstObject];
//    if (shop) {
//        if (sucBlock) {
//            sucBlock(shop);
//        }
//    } else { // 新增店铺
    BXShop *newShop = [BXShop object];
    newShop.name = name;
    newShop.phone = phone;
    newShop.shipInfo = shipInfo;
    
    [newShop saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded && sucBlock) {
            sucBlock(newShop);
        } else if (failBlock) {
            failBlock(error);
        }
    }];
//    }
}

- (void)allShops:(void(^)(NSArray* shops))sucBlock
            fail:(void(^)(NSError* err))failBlock;
{
    PFQuery *query = [BXShop query];
    [query addAscendingOrder:kDBColName];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:@"获取店铺信息失败"];
            if (failBlock) {
                failBlock(error);
            }
        } else {
            if (sucBlock) {
                sucBlock([BXShop fixAVOSArray:objects]);
            }
        }
    }];
}

- (void)deleteShop:(BXShop*)shop
           success:(void(^)())sucBlock
              fail:(void(^)(NSError* err))failBlock
{
    [shop deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            if (failBlock) {
                failBlock(error);
            }
        } else {
            if (sucBlock) {
                sucBlock();
            }
        }
    }];
}

- (void)updateShop:(BXShop*)shop
           success:(void(^)(BXShop* shop))sucBlock
              fail:(void(^)(NSError* err))failBlock
{
    [shop saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            if (failBlock) {
                failBlock(error);
            }
        } else {
            if (sucBlock) {
                sucBlock(shop);
            }
        }
    }];
}
@end
