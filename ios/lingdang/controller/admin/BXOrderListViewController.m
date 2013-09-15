//
//  BXOrderListViewController.m
//  lingdang
//
//  Created by zengming on 13-8-17.
//  Copyright (c) 2013年 baixing.com. All rights reserved.
//

#import "BXOrderListViewController.h"
#import "BXFoodListViewController.h"
#import "BXShopListViewController.h"

#import "BXOrderProvider.h"
#import "BXDateSelectView.h"
#import "BXOrderFoodCell.h"
#import "BXOrderCmdCell.h"
#import "BXOrderShopGroup.h"

@interface BXOrderListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *  tableView;

@property (weak, nonatomic) IBOutlet UISegmentedControl *  showTypeSeg;

@property (nonatomic,strong) NSDate* selectDate;

@property (nonatomic, strong) NSArray *                     orderData;
@property (nonatomic, strong) BXOrderShopGroup *            orderShopGroup;


@property (strong, nonatomic) BXDateSelectView* dateSelectView;

@end

@implementation BXOrderListViewController

- (id)init
{
    self = [super init];
    if (self)
    {
        self.showType = ShowByUser;
        self.selectDate = [NSDate date];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateTitle];
    
    self.showTypeSeg.selectedSegmentIndex = self.showType;
    
    __block BXOrderListViewController *weakSelf = self;

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
    [[UIBarButtonItem alloc] initWithTitle:@"历史订单"
                                     style:UIBarButtonItemStylePlain
                                   handler:^(id sender)
    {
        if (!self.dateSelectView)
        {
            self.dateSelectView = [[BXDateSelectView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, 320, 206)];
            self.dateSelectView.delegate = self;
            [self.view addSubview:self.dateSelectView];
        }
        self.dateSelectView.hidden = NO;
        [self.dateSelectView resetDate:self.selectDate];
        self.tableView.userInteractionEnabled = NO;
        self.showTypeSeg.userInteractionEnabled = NO;
        
        [UIView beginAnimations:nil context:nil];
        [UIView animateWithDuration:1.0f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.dateSelectView.frame = CGRectMake(0, self.view.frame.size.height-206, 320, 206);
        } completion:nil];
        [UIView commitAnimations];
        
    }];
    
    [_tableView addPullToRefreshWithActionHandler:^{
        
        void (^sucBlock)(NSArray *orders) = ^(NSArray *orders){
            
            weakSelf.orderData = [BXOrder fixAVOSArray:orders];
            weakSelf.orderShopGroup = [BXOrderShopGroup groupByOrders:_orderData];
            [_tableView reloadData];
            [_tableView.pullToRefreshView stopAnimating];
        };
        
        void (^failBlock)(NSError *err) = ^(NSError *err) {
            [SVProgressHUD showErrorWithStatus:@"获取订单失败"];
            [_tableView.pullToRefreshView stopAnimating];
        };
        
        [[BXOrderProvider sharedInstance] allOrders:sucBlock fail:failBlock];
    }];
    
    [_tableView triggerPullToRefresh];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.showType == ShowByShop)
    {
        return _orderShopGroup.itemArr.count;
    }
    else
    {
        return _orderData.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.showType == ShowByShop)
    {
        BXOrderShopGroupItem *item = _orderShopGroup.itemArr[section];
        return item.foodNameArr.count + 1;
    }
    else
    {
        BXOrder* order = [_orderData objectAtIndex:section];
        return order.foodNameArr.count + 1;
    }
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.showType == ShowByShop)
    {
        BXOrderShopGroupItem *item = _orderShopGroup.itemArr[section];
        NSString* title = [NSString stringWithFormat:@"%@",item.shop.name];
        return title;
    }
    else
    {
        BXOrder* order = [_orderData objectAtIndex:section];
        NSString* title = [NSString stringWithFormat:@"%@ %@",order.pToUser.username,order.shop.name];
        return title;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *foodCellId = @"BXOrderFoodCell";
    static NSString *cmdCellId = @"BXOrderCmdCell";
    
    
    UITableViewCell *cell = nil;
    
    if (self.showType == ShowByShop)
    {
        BXOrderShopGroupItem *item = _orderShopGroup.itemArr[indexPath.section];
        if (indexPath.row == [item.foodNameArr count])
        {
            cell = [tableView dequeueReusableCellWithIdentifier:cmdCellId];
            if (!cell)
            {
                cell = [[[NSBundle mainBundle] loadNibNamed:cmdCellId owner:nil options:nil] lastObject];
            }
            BXOrderCmdCell* foodCell = (BXOrderCmdCell*)cell;
            
            float totalPrice = 0;
            for(int i = 0;i<[item.foodNameArr count];i++)
            {
                float price = [item.foodPriceArr[i] floatValue];
                int amount = [item.foodAmountArr[i] intValue];
                totalPrice +=  amount * price;
            }
            foodCell.priceLabel.text = [NSString stringWithFormat:@"共%.1f元",totalPrice];
            
            [foodCell.cmdButton setTitle:@"按店铺" forState:UIControlStateNormal];
        }
        else
        {
            cell = [tableView dequeueReusableCellWithIdentifier:foodCellId];
            if (!cell)
            {
                cell = [[[NSBundle mainBundle] loadNibNamed:foodCellId owner:self options:nil] lastObject];
                
            }
            
            float price = [item.foodPriceArr[indexPath.row] floatValue];
            int amount = [item.foodAmountArr[indexPath.row] intValue];
            
            BXOrderFoodCell* foodCell = (BXOrderFoodCell*)cell;
            foodCell.foodLabel.text = item.foodNameArr[indexPath.row];
            foodCell.priceLabel.text = [NSString stringWithFormat:@"￥%.1f", price];
            foodCell.amountLabel.text = [NSString stringWithFormat:@"x%d", amount];
        }
    }
    else
    {
        BXOrder* order = [self.orderData objectAtIndex:indexPath.section];
        if (indexPath.row == [order.foodNameArr count])
        {
            cell = [tableView dequeueReusableCellWithIdentifier:cmdCellId];
            if (!cell)
            {
                cell = [[[NSBundle mainBundle] loadNibNamed:cmdCellId owner:nil options:nil] lastObject];
            }
            BXOrderCmdCell* foodCell = (BXOrderCmdCell*)cell;
            
            float totalPrice = 0;
            for(int i = 0;i<[order.foodNameArr count];i++)
            {
                float price = [order.foodPriceArr[i] floatValue];
                int amount = [order.foodAmountArr[i] intValue];
                totalPrice +=  amount * price;
            }
            foodCell.priceLabel.text = [NSString stringWithFormat:@"共%.1f元",totalPrice];
            
            if (order.status == 0)
            {
                [foodCell.cmdButton setTitle:@"修改订单" forState:UIControlStateNormal];
            }
            else if (order.status == 1)
            {
                [foodCell.cmdButton setTitle:@"已预定" forState:UIControlStateNormal];
            }
            else if (order.status == 2)
            {
                [foodCell.cmdButton setTitle:@"已拨打电话" forState:UIControlStateNormal];
            }
        }
        else
        {
            cell = [tableView dequeueReusableCellWithIdentifier:foodCellId];
            if (!cell)
            {
                cell = [[[NSBundle mainBundle] loadNibNamed:foodCellId owner:self options:nil] lastObject];
                
            }
            
            float price = [order.foodPriceArr[indexPath.row] floatValue];
            int amount = [order.foodAmountArr[indexPath.row] intValue];
            
            BXOrderFoodCell* foodCell = (BXOrderFoodCell*)cell;
            foodCell.foodLabel.text = order.foodNameArr[indexPath.row];
            foodCell.priceLabel.text = [NSString stringWithFormat:@"￥%.1f", price];
            foodCell.amountLabel.text = [NSString stringWithFormat:@"x%d", amount];
        }
    }
    
    

    

    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - delegate
- (void) cancelSelectInView:(BXDateSelectView*)selectView
{
    self.dateSelectView.hidden = YES;
    self.dateSelectView.frame = CGRectMake(0, self.view.frame.size.height, 320, 206);
    self.tableView.userInteractionEnabled = YES;
    self.showTypeSeg.userInteractionEnabled = YES;
}

- (void) selectInView:(BXDateSelectView*)selectView didSelectWithDate:(NSDate*)date
{
    self.dateSelectView.hidden = YES;
    
    self.dateSelectView.frame = CGRectMake(0, self.view.frame.size.height, 320, 206);
    self.tableView.userInteractionEnabled = YES;
    self.showTypeSeg.userInteractionEnabled = YES;
    self.selectDate = date;
    [self updateTitle];
    
    [self.tableView triggerPullToRefresh];
//     __block BXOrderListViewController *weakSelf = self;
//    
//    void (^sucBlock)(NSArray *orders) = ^(NSArray *orders){
//        weakSelf.orderData = [BXOrder fixAVOSArray:orders];
//        if (self.showType == ShowByShop) {
//            [self mergeOrderByShop];
//        }
//        [_tableView reloadData];
//        [_tableView.pullToRefreshView stopAnimating];
//    };
//    
//    void (^failBlock)(NSError *err) = ^(NSError *err) {
//        [SVProgressHUD showErrorWithStatus:@"获取订单失败"];
//        [_tableView.pullToRefreshView stopAnimating];
//    };
//    
//    [[BXOrderProvider sharedInstance] allOrdersWithDate:date success:sucBlock fail:failBlock];
    
}

#pragma mark - UI Action
- (IBAction)switchViewType:(id)sender
{
    UISegmentedControl* seg = sender;
    NSInteger index = seg.selectedSegmentIndex;
    self.showType = index;
    [self.tableView reloadData];
}

#pragma mark - Private Methord
- (void) updateTitle
{
    NSDate* now = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps =  [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:now];
    int nowYear=[comps year];
    int nowMonth = [comps month];
    int nowDay = [comps day];
    
    calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    comps =  [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:self.selectDate];
    int selYear=[comps year];
    int selMonth = [comps month];
    int selDay = [comps day];
    
    if (nowYear == selYear && nowMonth == selMonth && nowDay == selDay)
    {
        self.title = @"今日订单";
    }
    else
    {
        self.title = [NSString stringWithFormat:@"%d月%d日",selMonth,selDay];
    }
}

- (IBAction)shopButtonClicked:(id)sender
{
    BXShopListViewController *shopVC = [[BXShopListViewController alloc] init];
    shopVC.isAdminMode = YES;
    [self.navigationController pushViewController:shopVC animated:YES];
}
@end
