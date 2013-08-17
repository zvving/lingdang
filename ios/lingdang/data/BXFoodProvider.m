//
//  BXFoodProvider.m
//  lingdang
//
//  Created by zengming on 13-8-17.
//  Copyright (c) 2013年 baixing.com. All rights reserved.
//

#import "BXFoodProvider.h"

@implementation BXFoodProvider

BCSINGLETON_IN_M(BXFoodProvider)

- (void)addFoodWithName:(NSString*)name
                  price:(int)price
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

- (void)allFood:(void(^)(NSArray* food))sucBlock
           fail:(void(^)(NSError* err))failBlock;
{
    PFQuery *query = [BXFood query];
//    [query addAscendingOrder:];
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
