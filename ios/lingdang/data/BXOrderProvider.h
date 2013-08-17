//
//  BXOrderProvider.h
//  lingdang
//
//  Created by zengming on 13-8-17.
//  Copyright (c) 2013年 baixing.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BXFood.h"

@interface BXOrderProvider : NSObject

BCSINGLETON_IN_H(BXOrderProvider)

- (void)addOrderWithFood:(BXFood*)food
                  count:(int)count
                success:(void(^)(BXFood* food))sucBlock
                   fail:(void(^)(NSError* err))failBlock;

- (void)allOrders:(void(^)(NSArray* orders))sucBlock
             fail:(void(^)(NSError* err))failBlock;

- (void)myOrders:(void(^)(NSArray* orders))sucBlock
             fail:(void(^)(NSError* err))failBlock;

@end
