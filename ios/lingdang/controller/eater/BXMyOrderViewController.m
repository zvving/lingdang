//
//  BXMyOrderViewController.m
//  lingdang
//
//  Created by zengming on 13-8-18.
//  Copyright (c) 2013年 baixing.com. All rights reserved.
//

#import "BXMyOrderViewController.h"
#import "BXOrderProvider.h"
#import "BXFoodListViewController.h"

#import "BXMyOrderCell.h"
#import "BXOrderCmdCell.h"

@interface BXMyOrderViewController ()<UITableViewDataSource, UITableViewDelegate>


@property (weak, nonatomic) IBOutlet UITableView *  tableView;

@property (nonatomic, strong) NSArray *             orderData;


@end

@implementation BXMyOrderViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"我的订单";
    
    // set ui & actions
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStyleBordered handler:^(id sender) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    // init the data
    __weak BXMyOrderViewController *weakself = self;
    [self.tableView addPullToRefreshWithActionHandler:^{
        [[BXOrderProvider sharedInstance] myOrders:^(NSArray *orders) {
            weakself.orderData = orders;
            [self.tableView reloadData];
            [weakself.tableView.pullToRefreshView stopAnimating];
        } fail:^(NSError *err) {
            [weakself.tableView.pullToRefreshView stopAnimating];
        }];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView triggerPullToRefresh];
}

#pragma mark - table view datasource & delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.orderData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    BXOrder *order = self.orderData[section];
    return order.foodNameArr.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BXOrder *order = self.orderData[indexPath.section];
    BOOL isCommandCell = order.foodNameArr.count == indexPath.row;
    NSString *myOrderCellID = isCommandCell ? @"MyOrderCommandID" : @"MyOrderCellID";
    
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:myOrderCellID];
    if (cell == nil) {
        NSString *nibName = nil;
        if (isCommandCell) {
            nibName = @"BXOrderCmdCell";
        } else {
            nibName = @"BXMyOrderCell";
        }
        cell = [[[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil]lastObject];
    }
    
    if (isCommandCell) {
        BXOrderCmdCell *cmdCell = (BXOrderCmdCell *)cell;
        float sum = 0;
        for (int i = 0; i < order.foodPriceArr.count; i ++) {
            float price = [order.foodPriceArr[i] floatValue];
            NSInteger amount = [order.foodAmountArr[i] integerValue];
            sum += price * amount;
        }
        
        cmdCell.priceLabel.text = [NSString stringWithFormat:@"%g元", sum];
        [cmdCell.cmdButton setTitle:@"修改订单" forState:UIControlStateNormal];
    } else {
        BXMyOrderCell *myOrderCell = (BXMyOrderCell *)cell;
        float price = [order.foodPriceArr[indexPath.row] floatValue];
        NSInteger amount = [order.foodAmountArr[indexPath.row] integerValue];
        myOrderCell.shopNameLabel.text = order.shop.name;
        myOrderCell.foodNameLabel.text = order.foodNameArr[indexPath.row];
        myOrderCell.priceLabel.text = [NSString stringWithFormat:@"￥%g", price];
        myOrderCell.amountLabel.text = [NSString stringWithFormat:@"x%d", amount];
    }
    
    return cell;
}

@end
