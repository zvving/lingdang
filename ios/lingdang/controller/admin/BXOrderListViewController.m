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
#import "BXDateSelectView.h"

@interface BXOrderListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *  tableView;

@property (weak, nonatomic) IBOutlet UISegmentedControl *  showTypeSeg;

@property (nonatomic,strong) NSDate* selectDate;

@property (nonatomic, strong) NSArray *             orderData;
@property (nonatomic, strong) NSMutableArray *      orderDataByShop;

@property (nonatomic, strong) NSDateFormatter       *formatter;

@property (strong, nonatomic) BXDateSelectView* dateSelectView;

@end

@implementation BXOrderListViewController

- (id)init
{
    self = [super init];
    if (self)
    {
        self.showType = ShowByShop;
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
    [[UIBarButtonItem alloc] initWithTitle:@"返回"
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
            weakSelf.orderData = orders;
            if (self.showType == ShowByShop) {
                [self mergeOrderByShop];
            }
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
        return _orderDataByShop.count;
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
        BXOrder* order = [_orderDataByShop objectAtIndex:section];
        return [order.foodItems count]+1;
    }
    else
    {
        BXOrder* order = [_orderData objectAtIndex:section];
        return [order.foodItems count]+1;
    }
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.showType == ShowByShop)
    {
        BXOrder* order = [_orderDataByShop objectAtIndex:section];
        NSString* title = [NSString stringWithFormat:@"%@ %@",order.shopName,order.shop.name];
        return title;
    }
    else
    {
        BXOrder* order = [_orderDataByShop objectAtIndex:section];
        NSString* title = [NSString stringWithFormat:@"%@ %@",order.pToUser.username,order.shop.name];
        return title;
    }
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
    
;
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ 想吃 %@", [order objectForKey:@"userName"], [order objectForKey:@"foodName"]];
    cell.detailTextLabel.text =
    [NSString stringWithFormat:@"%@ %@",
     [self.formatter stringFromDate:order.createdAt],
     statusArr[[[order objectForKey:@"status"] intValue]]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - get & set

// inside the implementation (.m)
// When you need, just use self.formatter
- (NSDateFormatter *)formatter {
    if (! _formatter) {
        _formatter = [[NSDateFormatter alloc] init];
        _formatter.dateFormat = @"H:m"; // twitter date format
    }
    return _formatter;
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
    
     __block BXOrderListViewController *weakSelf = self;
    
    void (^sucBlock)(NSArray *orders) = ^(NSArray *orders){
        weakSelf.orderData = orders;
        if (self.showType == ShowByShop) {
            [self mergeOrderByShop];
        }
        [_tableView reloadData];
        [_tableView.pullToRefreshView stopAnimating];
    };
    
    void (^failBlock)(NSError *err) = ^(NSError *err) {
        [SVProgressHUD showErrorWithStatus:@"获取订单失败"];
        [_tableView.pullToRefreshView stopAnimating];
    };
    
    [[BXOrderProvider sharedInstance] allOrdersWithDate:date success:sucBlock fail:failBlock];
    
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

- (void) mergeOrderByShop
{
    if (!self.orderDataByShop)
    {
        self.orderDataByShop = [NSMutableArray array];
    }
    
    for (BXOrder* order in self.orderData)
    {
        NSString* shopName = order.shopName;
        
        BOOL found = NO;
        for (BXOrder* shopOrder in self.orderDataByShop)
        {
            if ([shopOrder.shopName isEqualToString:shopName])
            {
                [shopOrder merge:order];
                found = YES;
                break;
            }
        }
        if (!found)
        {
            [self.orderDataByShop addObject:[order copy]];
        }
    }
    
}
@end
