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

@property (nonatomic, strong) NSMutableArray *             orderData;


@end

@implementation BXMyOrderViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.navigationBar.barTintColor = kColorEaterYellow;
    
    self.title = @"我的订单";
    
    // set ui & actions
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStyleBordered handler:^(id sender) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    // init the data
    __weak BXMyOrderViewController *weakself = self;
    [self.tableView addPullToRefreshWithActionHandler:^{
        [[BXOrderProvider sharedInstance] myOrders:^(NSArray *orders) {
            weakself.orderData = [[NSMutableArray alloc] initWithArray:orders];
            [self.tableView reloadData];
            [weakself.tableView.pullToRefreshView stopAnimating];
        } fail:^(NSError *err) {
            [weakself.tableView.pullToRefreshView stopAnimating];
        }];
    }];
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
        
        UILabel *hintLabel = nil;
        switch (order.status) {
            case kOrderStatusEditable:
                [cmdCell.cmdButton setTitle:@"取消订单" forState:UIControlStateNormal];
                [cmdCell.cmdButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                [cmdCell.cmdButton addTarget:self action:@selector(editOrderAction:) forControlEvents:UIControlEventTouchUpInside];
                cmdCell.cmdButton.tag = TagFromSctionAndRow(indexPath.section, indexPath.row);
                break;
            case kOrderStatusArrived: case kOrderStatusOrdered:
                hintLabel = [[UILabel alloc] init];
                hintLabel.text = order.status == kOrderStatusOrdered ? @"已下单！" : @"饭到了！";
                hintLabel.font = [UIFont boldSystemFontOfSize:15.0f];
                [hintLabel sizeToFit];
                cmdCell.cmdButton.hidden = YES;
                cmdCell.accessoryView = hintLabel;
                break;
        }

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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.f, 24.0f)];
    view.backgroundColor = [UIColor clearColor];
    
    static NSDateFormatter *ndf = nil;
    if (ndf == nil) {
        ndf = [[NSDateFormatter alloc] init];
        ndf.dateFormat = @"MM月dd日HH:mm";
    }
    
    BXOrder *order = _orderData[section];
    UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(10.0f, section == 0? 12.0f : 0.0f, 300.0f, 24.0f)];
    label.text = [ndf stringFromDate: order.createdAt];
    [view addSubview:label];

    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 36.0f;
    }
    return 24.0f;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark button actions

- (void)editOrderAction: (UIButton *)sender
{
    NSInteger section = SectionFromTag(sender.tag);
    BXOrder *order = self.orderData[section];
    
    __weak BXMyOrderViewController *weakself = self;
    [[BXOrderProvider sharedInstance] deleteOrder:order onSuccess:^{
        [weakself.orderData removeObjectAtIndex: section];
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:section];
        
        // pls check http://t.cn/z8ncg24
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            [weakself.tableView reloadData];
        }];
        [weakself.tableView beginUpdates];
        [weakself.tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
        [weakself.tableView endUpdates];
    
        [CATransaction commit];

    } onFail:nil];
}

@end
