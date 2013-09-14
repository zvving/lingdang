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
            self.dateSelectView = [[BXDateSelectView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-206, 320, 206)];
            self.dateSelectView.delegate = self;
            [self.view addSubview:self.dateSelectView];
        }
        self.dateSelectView.hidden = NO;
        [self.dateSelectView resetDate:self.selectDate];
    }];
    
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
        
//        if (_isAdminMode) {
            [[BXOrderProvider sharedInstance] allOrders:sucBlock fail:failBlock];
//        } else {
//            [[BXOrderProvider sharedInstance] myOrders:sucBlock fail:failBlock];
//        }

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
        _formatter.dateFormat = @"H:m"; // twitter date format
    }
    return _formatter;
}

#pragma mark - delegate
- (void) cancelSelectInView:(BXDateSelectView*)selectView
{
    self.dateSelectView.hidden = YES;
}
- (void) selectInView:(BXDateSelectView*)selectView didSelectWithDate:(NSDate*)date
{
    self.dateSelectView.hidden = YES;
    self.selectDate = date;
    [self updateTitle];
}

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
@end
