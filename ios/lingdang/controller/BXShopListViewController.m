//
//  BXShopListViewController.m
//  lingdang
//
//  Created by neoman on 9/14/13.
//  Copyright (c) 2013 baixing.com. All rights reserved.
//

#import "BXShopListViewController.h"
#import "BXOrderListViewController.h"
#import "BXFoodListViewController.h"
#import "BXMyOrderViewController.h"
#import "BXLoginViewController.h"
#import "BXFoodInfoViewController.h"
#import "BXShopProvider.h"
#import "BXShopAddViewController.h"

#import "BXShop.h"

@interface BXShopListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *shopTable;
@property (weak, nonatomic) IBOutlet UIButton *addShopButton;

@property (nonatomic, strong) BXOrderListViewController         *orderListVC;

@property (nonatomic, strong) UINavigationController            *adminNav;
@property (nonatomic, strong) BXLoginViewController             *loginVC;

@property (nonatomic, strong) NSArray                           *shops;

@end

@implementation BXShopListViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = _isAdminMode ? @"管理店铺" : @"浏览店铺";
    _addShopButton.hidden = !_isAdminMode;
    
    self.shopTable.allowsSelectionDuringEditing = YES;
    
    self.orderListVC = [[BXOrderListViewController alloc] init];
    self.loginVC = [[BXLoginViewController alloc] init];
    self.adminNav = [[UINavigationController alloc] initWithRootViewController:_orderListVC];
    
    _adminNav.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    [self buildBarButtons];
    
    // load the data;
    __weak BXShopListViewController *weakself = self;
    [_shopTable addPullToRefreshWithActionHandler:^{
        [[BXShopProvider sharedInstance] allShops:^(NSArray *shops) {
            weakself.shops = shops;
            [weakself.shopTable reloadData];
            double delayInSeconds = 0.1;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [weakself.shopTable.pullToRefreshView stopAnimating];
            });
            
        } fail:^(NSError *err) {
            [weakself.shopTable.pullToRefreshView stopAnimating];
        }];
    }];
    
    [_shopTable triggerPullToRefresh];
    
    // resigter notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showMyOrder:)
                                                 name:kNotificationGoMyOrder
                                               object:nil];
}

- (void)buildBarButtons
{
    __block BXShopListViewController *weakSelf = self;
    
    if (_isAdminMode)// 管理 food 界面
    {
        UIBarButtonItem* rightItem =
        [[UIBarButtonItem alloc] initWithTitle:@"编辑"
                                         style:UIBarButtonItemStyleBordered
                                       handler:^(id sender)
         {
             if (self.shopTable.editing)
             {
                 self.shopTable.editing = NO;
                 ((UIBarButtonItem*)sender).title = @"编辑";;
             }
             else
             {
                 self.shopTable.editing = YES;
                 ((UIBarButtonItem*)sender).title = @"完成";;
             }
             
         }];

        rightItem.possibleTitles = [NSSet setWithObjects:@"编辑", @"完成", nil];
        self.navigationItem.rightBarButtonItem = rightItem;
        
    }
    else // 订餐界面
    {
        
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
             [weakSelf showMyOrder:nil];
         }];
        
        if ([AVUser currentUser] == nil) {
            [self presentViewController:_loginVC animated:NO completion:nil];
        } else {
            // 缓存 食客、管家状态，下次启动自动显示缓存状态
            if ([[EGOCache globalCache] hasCacheForKey:kCacheIsAdminMode]) {
                [weakSelf presentViewController:_adminNav animated:NO completion:nil];
            }
        }
    }
    
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_shops count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"shopCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    BXShop *shop = _shops[indexPath.row];
    NSString *msg = [NSString stringWithFormat:@"%@ (%@)", [shop objectForKey:@"name"], [shop objectForKey:@"shipInfo"]];
    cell.textLabel.text = msg;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.shopTable.editing)
    {
        BXShopAddViewController *shopEdit = [[BXShopAddViewController alloc] init];
        shopEdit.curShop = _shops[indexPath.row];
        [self.navigationController pushViewController:shopEdit animated:YES];
    }
    else
    {
    
        BXFoodListViewController *foodListVC = [[BXFoodListViewController alloc]init];
        foodListVC.shop = _shops[indexPath.row];
        foodListVC.isAdminMode = _isAdminMode;
        [self.navigationController pushViewController:foodListVC animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [SVProgressHUD showWithStatus:@"删除店铺中" maskType:SVProgressHUDMaskTypeGradient];
        
        BXShop* shop = _shops[indexPath.row];
        [[BXShopProvider sharedInstance] deleteShop:shop success:^{
            [SVProgressHUD showErrorWithStatus:@"删除店铺成功"];
            [self.shopTable triggerPullToRefresh];
        } fail:^(NSError *err) {
            [SVProgressHUD showErrorWithStatus:@"删除店铺失败"];
        }];
    }
}

- (IBAction)addShopButtonClicked:(id)sender
{
    BXShopAddViewController *shopAdd = [[BXShopAddViewController alloc] init];
    [self.navigationController pushViewController:shopAdd animated:YES];
}

- (void)showMyOrder:(NSNotification *)notification
{
    BXMyOrderViewController *myOrdersVC = [[BXMyOrderViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:myOrdersVC];
    [self presentViewController:nav animated:YES completion:nil];
}

@end
