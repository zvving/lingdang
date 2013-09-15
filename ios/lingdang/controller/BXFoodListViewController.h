//
//  BXViewController.h
//  lingdang
//
//  Created by zengming on 13-8-16.
//  Copyright (c) 2013年 baixing.com. All rights reserved.
//
// 同时应用在食客浏览菜单、管家菜单管理。isAdminMode 区分

#import <UIKit/UIKit.h>

@class BXShop;

@interface BXFoodListViewController : UIViewController

@property (nonatomic, strong)  BXShop *             shop;

@end
