//
//  BXOrderListViewController.h
//  lingdang
//
//  Created by zengming on 13-8-17.
//  Copyright (c) 2013年 baixing.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    ShowByShop,
    ShowByUser
}eShowType;

@interface BXOrderListViewController : UIViewController

@property (nonatomic, assign) eShowType     showType;

@end
