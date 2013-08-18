//
//  BXFoodProvider.h
//  lingdang
//
//  Created by zengming on 13-8-17.
//  Copyright (c) 2013年 baixing.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BXFood.h"
#import "BXShop.h"

@interface BXFoodProvider : NSObject

BCSINGLETON_IN_H(BXFoodProvider)

- (void)addFoodWithName:(NSString*)name
                  price:(float)price
                   shop:(BXShop*)shop
                success:(void(^)(BXFood* food))sucBlock
                   fail:(void(^)(NSError* err))failBlock;

- (void)allFood:(void(^)(NSArray* food))sucBlock
           fail:(void(^)(NSError* err))failBlock;

- (void)updateFood:(BXFood *)food
         onSuccess:(void(^)(void))sucBlock
            onFail:(void(^)(NSError *err))failBlock;

@end
