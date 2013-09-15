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

/**
 *  [{'food':{bxfood}, 'amount': number},...]
 */
@property (strong, nonatomic) NSMutableArray    * foodItems;

BCSINGLETON_IN_H(BXMyShopCarViewController);

@end
