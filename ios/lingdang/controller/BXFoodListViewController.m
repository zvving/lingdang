//
//  BXViewController.m
//  lingdang
//
//  Created by zengming on 13-8-16.
//  Copyright (c) 2013年 baixing.com. All rights reserved.
//

#import "BXFoodListViewController.h"
#import "BXOrderListViewController.h"
#import "BXLoginViewController.h"
#import "BXFoodInfoViewController.h"
#import "BXFoodProvider.h"
#import "BXOrderProvider.h"


@interface BXFoodListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) BXOrderListViewController *   orderListVC;
@property (nonatomic, strong) UINavigationController *      adminNav;
@property (nonatomic, strong) BXLoginViewController *       loginVC;

@property (nonatomic, strong) NSArray *                     foodData;

@end

@implementation BXFoodListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.orderListVC = [[BXOrderListViewController alloc] init];
    self.loginVC = [[BXLoginViewController alloc] init];
    self.adminNav = [[UINavigationController alloc] initWithRootViewController:_orderListVC];
    
    _orderListVC.isAdminMode = YES;
    _adminNav.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    __block BXFoodListViewController *weakSelf = self;
    
    if (_isAdminMode) { // 管理 food 界面
        self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@"增加"
                                         style:UIBarButtonItemStylePlain
                                       handler:^(id sender)
        {
            BXFoodInfoViewController *foodInfoVC = [[BXFoodInfoViewController alloc] init];
            [self.navigationController pushViewController:foodInfoVC animated:YES];
        }];
    } else { // 订餐界面
        self.navigationItem.leftBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@"切至管家"
                                         style:UIBarButtonItemStylePlain
                                       handler:^(id sender)
         {
             [[EGOCache globalCache] setString:@"YES" forKey:kCacheIsAdminMode];
             [weakSelf presentViewController:_adminNav animated:YES completion:nil];
         }];
        
        self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@"我的订单"
                                         style:UIBarButtonItemStylePlain
                                       handler:^(id sender)
        {
            BXOrderListViewController *myOrdersVC = [[BXOrderListViewController alloc] init];
            myOrdersVC.isAdminMode = NO;
            [weakSelf.navigationController pushViewController:myOrdersVC animated:YES];
        }];

        if ([PFUser currentUser] == nil) {
            [self presentViewController:_loginVC animated:NO completion:nil];
        } else {
            // 缓存 食客、管家状态，下次启动自动显示缓存状态
            if ([[EGOCache globalCache] hasCacheForKey:kCacheIsAdminMode]) {
                [weakSelf presentViewController:_adminNav animated:NO completion:nil];
            }
        }
    }
    
    [_tableView addPullToRefreshWithActionHandler:^{
        [[BXFoodProvider sharedInstance] allFood:^(NSArray *food) {
            weakSelf.foodData = food;
            [_tableView reloadData];
            [_tableView.pullToRefreshView stopAnimating];
        } fail:^(NSError *err) {
            [SVProgressHUD showErrorWithStatus:@"获取菜单失败"];
            [_tableView.pullToRefreshView stopAnimating];
        }];
    }];
    
    [_tableView triggerPullToRefresh];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    PFUser *user = [PFUser currentUser];
    self.title = _isAdminMode ? @"菜单管理" : [NSString stringWithFormat:@"%@ 的菜单", user.username];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _foodData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"foodCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:cellId];
    }
    
    BXFood *food = _foodData[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%.1f 元", food.price];
    cell.detailTextLabel.text = food.name;  //food.pToShop.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BXFood *food = _foodData[indexPath.row];
    
    if (_isAdminMode) { // 管家管理菜单界面
        
    } else { // 食客下单界面
        UIActionSheet *as = [UIActionSheet actionSheetWithTitle:@"这顿就它了？"];
        [as setDestructiveButtonWithTitle:food.name handler:^{
            [SVProgressHUD showWithStatus:@"排队中"
                                 maskType:SVProgressHUDMaskTypeGradient];
            [[BXOrderProvider sharedInstance] addOrderWithFood:food
                                                         count:1
                                                       success:^(BXOrder *order)
            {
                [SVProgressHUD showSuccessWithStatus:@"已下单"];
            } fail:^(NSError *err) {
                [SVProgressHUD showErrorWithStatus:@"网络异常"];
            }];
            

            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }];
        [as setCancelButtonWithTitle:@"取消" handler:^{
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }];
        [as showInView:self.view];

    }

}

@end
