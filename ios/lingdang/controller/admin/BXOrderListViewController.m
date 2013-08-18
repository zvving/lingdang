//
//  BXOrderListViewController.m
//  lingdang
//
//  Created by zengming on 13-8-17.
//  Copyright (c) 2013年 baixing.com. All rights reserved.
//

#import "BXOrderListViewController.h"
#import "BXFoodListViewController.h"

#import "BXOrderProvider.h"

@interface BXOrderListViewController () <UITableViewDataSource, UITableViewDelegate>


@property (weak, nonatomic) IBOutlet UITableView *  tableView;

@property (nonatomic, strong) NSArray *             orderData;

@property (nonatomic, strong) NSDateFormatter       *formatter;

@end

@implementation BXOrderListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = _isAdminMode ? @"全部订单" : @"我的订单";
    
    __block BXOrderListViewController *weakSelf = self;
    
    if (_isAdminMode) {
        self.navigationItem.leftBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@"切至食客"
                                         style:UIBarButtonItemStylePlain
                                       handler:^(id sender)
         {
             [weakSelf dismissViewControllerAnimated:YES completion:^{
                 [[EGOCache globalCache] removeCacheForKey:kCacheIsAdminMode];
             }];
         }];
        
        self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@"菜单管理"
                                         style:UIBarButtonItemStylePlain
                                       handler:^(id sender)
         {
             BXFoodListViewController *foodVC =
             [[BXFoodListViewController alloc] initWithNibName:@"BXFoodListViewController_iPhone"
                                                        bundle:nil];
             foodVC.isAdminMode = YES;
             [weakSelf.navigationController pushViewController:foodVC animated:YES];
         }];
    }

    
    [_tableView addPullToRefreshWithActionHandler:^{
        
        void (^sucBlock)(NSArray *orders) = ^(NSArray *orders){
            weakSelf.orderData = orders;
            [_tableView reloadData];
            [_tableView.pullToRefreshView stopAnimating];
        };
        
        void (^failBlock)(NSError *err) = ^(NSError *err) {
            [SVProgressHUD showErrorWithStatus:@"获取订单失败"];
            [_tableView.pullToRefreshView stopAnimating];
        };
        
        if (_isAdminMode) {
            [[BXOrderProvider sharedInstance] allOrders:sucBlock fail:failBlock];
        } else {
            [[BXOrderProvider sharedInstance] myOrders:sucBlock fail:failBlock];
        }

    }];
    
    [_tableView triggerPullToRefresh];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _orderData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"orderCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
    }
    
    BXOrder *order = _orderData[indexPath.row];
    NSArray *statusArr = @[@"等", @"已订", @"已达", @"已存"];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ 想吃 %@", order.userName, order.foodName];
    cell.detailTextLabel.text =
    [NSString stringWithFormat:@"%@ %@",
     [self.formatter stringFromDate:order.createdAt],
     statusArr[order.status]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    BXFood *food = _foodData[indexPath.row];
//    
//    if (_isAdminMode) { // 管家管理菜单界面
//        
//    } else { // 食客下单界面
//        UIActionSheet *as = [UIActionSheet actionSheetWithTitle:@"这顿就它了？"];
//        [as setDestructiveButtonWithTitle:food.name handler:^{
//            [SVProgressHUD showWithStatus:@"排队中"
//                                 maskType:SVProgressHUDMaskTypeGradient];
//            [[BXOrderProvider sharedInstance] addOrderWithFood:food
//                                                         count:1
//                                                       success:^(BXOrder *order)
//             {
//                 [SVProgressHUD showSuccessWithStatus:@"已下单"];
//             } fail:^(NSError *err) {
//                 [SVProgressHUD showErrorWithStatus:@"网络异常"];
//             }];
//            
//            
//            [tableView deselectRowAtIndexPath:indexPath animated:YES];
//        }];
//        [as setCancelButtonWithTitle:@"取消" handler:^{
//            [tableView deselectRowAtIndexPath:indexPath animated:YES];
//        }];
//        [as showInView:self.view];
//        
//    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    
}

#pragma mark - get & set

// inside the implementation (.m)
// When you need, just use self.formatter
- (NSDateFormatter *)formatter {
    if (! _formatter) {
        _formatter = [[NSDateFormatter alloc] init];
        _formatter.dateFormat = @"M-dd HH:mm:ss"; // twitter date format
    }
    return _formatter;
}

@end
