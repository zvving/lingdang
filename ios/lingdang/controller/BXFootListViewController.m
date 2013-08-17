//
//  BXViewController.m
//  lingdang
//
//  Created by zengming on 13-8-16.
//  Copyright (c) 2013年 baixing.com. All rights reserved.
//

#import "BXFootListViewController.h"
#import "BXOrderListViewController.h"
#import "BXLoginViewController.h"
#import "BXFoodInfoViewController.h"


@interface BXFootListViewController ()

@property (nonatomic, strong) BXOrderListViewController *   orderListVC;
@property (nonatomic, strong) UINavigationController *      adminNav;
@property (nonatomic, strong) BXLoginViewController *       loginVC;

@end

@implementation BXFootListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.orderListVC = [[BXOrderListViewController alloc] init];
    self.loginVC = [[BXLoginViewController alloc] init];
    self.adminNav = [[UINavigationController alloc] initWithRootViewController:_orderListVC];
    _adminNav.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    __block BXFootListViewController *weakSelf = self;
    
    if (_isAdminMode) {
        self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@"增加"
                                         style:UIBarButtonItemStylePlain
                                       handler:^(id sender)
        {
            BXFoodInfoViewController *footInfoVC = [[BXFoodInfoViewController alloc] init];
            [self.navigationController pushViewController:footInfoVC animated:YES];
        }];
    } else {
        self.navigationItem.leftBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@"切至管家"
                                         style:UIBarButtonItemStylePlain
                                       handler:^(id sender)
         {
             [[EGOCache globalCache] setString:@"YES" forKey:kCacheIsAdminMode];
             [weakSelf presentViewController:_adminNav animated:YES completion:nil];
         }];
        

        // 摇动退出
        /*
            UIAlertView *alert = [UIAlertView alertViewWithTitle:@"注销"];
            [alert setCancelBlock:nil];
            [alert addButtonWithTitle:@"注销" handler:^{
                [self presentViewController:_loginVC animated:YES completion:^{
                    [PFUser logOut];
                }];
            }];
            [alert show];
         */
        
        if ([PFUser currentUser] == nil) {
            [self presentViewController:_loginVC animated:NO completion:nil];
        } else {
            // 缓存 食客、管家状态，下次启动自动显示缓存状态
            if ([[EGOCache globalCache] hasCacheForKey:kCacheIsAdminMode]) {
                [weakSelf presentViewController:_adminNav animated:NO completion:nil];
            }
        }
    }

    

    

    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    PFUser *user = [PFUser currentUser];
    self.title = _isAdminMode ? @"菜单管理" : [NSString stringWithFormat:@"%@ 的菜单", user.username];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
