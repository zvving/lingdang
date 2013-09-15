//
//  BXShopProvider.h
//  lingdang
//
//  Created by zengming on 13-8-17.
//  Copyright (c) 2013年 baixing.com. All rights reserved.
//

#import "BXShop.h"

@interface BXShopProvider : NSObject

BCSINGLETON_IN_H(BXShopProvider)

- (void)addShopWithName:(NSString*)name
                  phone:(NSString*)phone
               shipInfo:(NSString*)shipInfo
                success:(void(^)(BXShop* shop))sucBlock
                   fail:(void(^)(NSError* err))failBlock;

- (void)allShops:(void(^)(NSArray* shops))sucBlock
            fail:(void(^)(NSError* err))failBlock;

- (void)deleteShop:(BXShop*)shop
           success:(void(^)())sucBlock
              fail:(void(^)(NSError* err))failBlock;
@end
