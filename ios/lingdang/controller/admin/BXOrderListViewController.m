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

#import "BXPushProvider.h"

@interface BXOrderListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView                    *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl             *showTypeSeg;

@property (nonatomic,strong) NSDate                                 *selectDate;
@property (weak, nonatomic) IBOutlet UIButton                       *shopButton;


@property (nonatomic, strong) NSArray                               *orderData;
@property (nonatomic, strong) BXOrderShopGroup                      *orderShopGroup;

@property (strong, nonatomic) BXDateSelectView                      *dateSelectView;

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
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.navigationBar.barTintColor = kColorAdminRed;
    self.navigationController.navigationBar.translucent = YES;
    
    [self updateTitle];
    
    self.showTypeSeg.selectedSegmentIndex = self.showType;

#if TARGET_IPHONE_SIMULATOR
    
    self.navigationItem.leftBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@"切至吃货"
                                     style:UIBarButtonItemStylePlain
                                   handler:^(id sender)
    {
        [self trunToEaterModel];
    }];
    
    self.shopButton.hidden = NO;
    
#endif
    
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
        
        [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.dateSelectView.frame = CGRectMake(0, self.view.frame.size.height-206, 320, 206);
        } completion:nil];
        
    }];
    
    [_tableView addPullToRefreshWithActionHandler:^{
        [self updateData];
    }];
    
    [self updateData];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)updateData
{
    __block BXOrderListViewController *weakSelf = self;
    void (^sucBlock)(NSArray *orders) = ^(NSArray *orders){
        weakSelf.orderData = [BXOrder fixAVOSArray:orders];
        weakSelf.orderShopGroup = [BXOrderShopGroup groupByOrders:_orderData];
        [_tableView reloadData];
        [_tableView.pullToRefreshView stopAnimating];
    };
    
    void (^failBlock)(NSError *err) = ^(NSError *err) {
        [_tableView.pullToRefreshView stopAnimating];
    };
    
    [[BXOrderProvider sharedInstance] allOrders:sucBlock fail:failBlock];
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 35.0f;
    }
    return 24.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    if (self.showType == ShowByShop)
    {
        BXOrderShopGroupItem *item = _orderShopGroup.itemArr[section];
        
        title = [NSString stringWithFormat:@"%@ - %@",item.shop.name, [item.userNameArr componentsJoinedByString:@","]];
    }
    else
    {
        BXOrder* order = [_orderData objectAtIndex:section];
        title = [NSString stringWithFormat:@"%@ - %@●%@",order.createdAtStr, order.user.username,order.shop.name];
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.0f,
                                                               section==0?35-24 : 0,
                                                               300, 24)];
    label.text = title;
    label.font = [UIFont systemFontOfSize:15.0f];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                            0.0f,
                                                            320.0f,
                                                            section==0?30:24)];
    [view addSubview:label];
    return view;
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
            foodCell.priceLabel.text = [NSString stringWithFormat:@"共%g元",totalPrice];
            
            if (item.status == kOrderStatusEditable) {
                [foodCell.cmdButton setTitle:@"预订好啦" forState:UIControlStateNormal];
            } else if (item.status == kOrderStatusOrdered) {
                [foodCell.cmdButton setTitle:@"饭到啦" forState:UIControlStateNormal];
            } else if (item.status == kOrderStatusArrived) {
                [foodCell.cmdButton setTitle:@"订单完成" forState:UIControlStateNormal];
            }
            
            foodCell.cmdButton.tag = TagFromSctionAndRow(indexPath.section, indexPath.row);
            [foodCell.cmdButton addTarget:self action:@selector(changeOrderNextStatusWithButton:) forControlEvents:UIControlEventTouchUpInside];
            UILongPressGestureRecognizer *ges = [UILongPressGestureRecognizer recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
                if (state == UIGestureRecognizerStateBegan) {
                    [self changeOrderStatus:foodCell.cmdButton];
                }
            }];
            [foodCell.cmdButton addGestureRecognizer:ges];
            
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
            foodCell.priceLabel.text = [NSString stringWithFormat:@"￥%g", price];
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
            foodCell.cmdButton.tag = TagFromSctionAndRow(indexPath.section, indexPath.row);
            
            float totalPrice = 0;
            for(int i = 0;i<[order.foodNameArr count];i++)
            {
                float price = [order.foodPriceArr[i] floatValue];
                int amount = [order.foodAmountArr[i] intValue];
                totalPrice +=  amount * price;
            }
            foodCell.priceLabel.text = [NSString stringWithFormat:@"共%g元",totalPrice];
            
            foodCell.cmdButton.tintColor = order.isPaid ? [UIColor blackColor] : [UIColor blueColor];
            [foodCell.cmdButton setTitle:(order.isPaid ? @"付款完成" : @"确认付款") forState:UIControlStateNormal];
            [foodCell.cmdButton addTarget:self action:@selector(payOrder:) forControlEvents:UIControlEventTouchUpInside];
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
            foodCell.priceLabel.text = [NSString stringWithFormat:@"￥%g", price];
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

- (void)trunToEaterModel
{
    [[EGOCache globalCache] removeCacheForKey:kCacheIsAdminMode];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) updateTitle
{
    NSDate* now = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps =  [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:now];
    int nowYear= [comps year];
    int nowMonth = [comps month];
    int nowDay = [comps day];
    
    calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    comps =  [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:self.selectDate];
    int selYear= [comps year];
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


#pragma mark - Shake

-(BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        UIActionSheet *as = [UIActionSheet actionSheetWithTitle:@"隐藏功能"];
        [as setDestructiveButtonWithTitle:@"切至吃货模式" handler:^{
            [self trunToEaterModel];
        }];
        [as addButtonWithTitle:@"管理店铺、菜品" handler:^{
            [self shopButtonClicked:nil];
        }];
        [as setCancelButtonWithTitle:@"取消" handler:nil];
        [as showInView:self.view];
    }
}

#pragma mark button actions
- (void)payOrder: (UIButton *)sender
{
    NSUInteger section = SectionFromTag(sender.tag);
    BXOrder *order = self.orderData[section];
    
    if (self.showType == ShowByUser) {
        order.isPaid = ! order.isPaid;
        __weak BXOrderListViewController *weakself = self;
        [order saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                order.isPaid = NO;
                [SVProgressHUD showErrorWithStatus:@"服务异常，稍后重试"];
            }
            if (succeeded) {
                [weakself.tableView reloadData];
            }
        }];
    }
}

- (void)changeOrderStatus:(UIButton *)sender
{
    void (^block)(int status) = ^(int status) {
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [self changeOrderStatus:status withButton:sender block:^(BOOL succeeded, NSError *error) {
            [self updateData];
            [SVProgressHUD dismiss];
        }];
    };
    
    
    UIActionSheet *as = [UIActionSheet actionSheetWithTitle:@"修改订单状态"];
    
    [as addButtonWithTitle:@"刚下单，未预订" handler:^{
        block(kOrderStatusEditable);
    }];
    [as addButtonWithTitle:@"已预订，未送达" handler:^{
        block(kOrderStatusOrdered);
    }];
    [as addButtonWithTitle:@"已送达，订单完成" handler:^{
        block(kOrderStatusArrived);
    }];
    [as setCancelButtonWithTitle:@"取消" handler:nil];
    [as showInView:self.view];
}

- (void)changeOrderNextStatusWithButton:(UIButton*)btn
{
    NSUInteger section = SectionFromTag(btn.tag);
    BXOrderShopGroupItem *item= self.orderShopGroup.itemArr[section];
    
    NSInteger currentStatus = item.status;
    NSInteger nextStatus = 0;
    if (currentStatus == kOrderStatusEditable) {
        nextStatus = kOrderStatusOrdered;
    } else if(currentStatus == kOrderStatusOrdered) {
        nextStatus = kOrderStatusArrived;
    } else if(currentStatus == kOrderStatusArrived) {
        return;
    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [self changeOrderStatus:nextStatus withButton:btn block:^(BOOL succeeded, NSError *error) {
        [self updateData];
        [SVProgressHUD dismiss];
    }];

}

- (void)changeOrderStatus:(int)status withButton:(UIButton*)btn block:(PFBooleanResultBlock)block
{
    NSUInteger section = SectionFromTag(btn.tag);
    BXOrderShopGroupItem *item= self.orderShopGroup.itemArr[section];
    for (int i = 0; i < [item.orders count]; i++) {
        BXOrder *order = item.orders[i];
        order.status = status;
        NSString *title = nil;
        if (status == kOrderStatusOrdered) {
            title = @"饭已经帮你订好了，混球!";
        } else if(status == kOrderStatusArrived) {
            title = @"混球，饭好了，赶紧过来吃!";
        }
        [[BXPushProvider sharedInstance]pushUser:order.user withTitle:title];
    }
    [AVObject saveAllInBackground:item.orders block:^(BOOL succeeded, NSError *error) {
        if (!succeeded) {
            [SVProgressHUD showErrorWithStatus:@"更新订单失败"];
        }
        if (block) {
            block(succeeded, error);
        }
    }];
}

@end
