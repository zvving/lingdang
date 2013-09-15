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

@property (nonatomic, strong)       NSString *          name;
@property (nonatomic, strong)       NSString *          imageStr;
@property (nonatomic, assign)       float               price;
@property (nonatomic, strong)       BXShop *            pToShop;
@property (nonatomic, strong)       AVUser *            upImgUser;

@end
