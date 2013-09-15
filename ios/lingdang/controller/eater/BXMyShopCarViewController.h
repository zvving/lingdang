//
//  BXMyShopCarViewController.h
//  lingdang
//
//  Created by neoman on 9/15/13.
//  Copyright (c) 2013 baixing.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BXShop;

@interface BXMyShopCarViewController : UIViewController

@property (strong, nonatomic) NSMutableArray    * foodItems;

/**
 *  食客只能在一个店铺下单
 */
@property (strong, nonatomic) BXShop            * shop;


BCSINGLETON_IN_H(BXMyShopCarViewController);

@end
