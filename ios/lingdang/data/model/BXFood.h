//
//  BXFood.h
//  lingdang
//
//  Created by zengming on 13-8-17.
//  Copyright (c) 2013年 baixing.com. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "BXShop.h"

#import "BXObject.h"

@interface BXFood : BXObject


@property (strong) NSString *   name;
@property (assign) float        price;


// link to BXShop
@property (strong) BXShop *     pToShop;
@property (strong) NSString *   shopName;


@end
