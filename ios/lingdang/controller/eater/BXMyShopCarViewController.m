//
//  BXMyShopCarViewController.m
//  lingdang
//
//  Created by neoman on 9/15/13.
//  Copyright (c) 2013 baixing.com. All rights reserved.
//

#import "BXMyShopCarViewController.h"
#import "BXOrder.h"
#import "BXFood.h"

@interface BXMyShopCarViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView        * tableview;

@property (nonatomic, strong) IBOutlet UIView           * footerView;

@end

@implementation BXMyShopCarViewController

BCSINGLETON_IN_M(BXMyShopCarViewController);

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.foodItems = [[NSMutableArray alloc] init];
        self.title = @"购物车";
        
        __weak BXMyShopCarViewController *weakself = self;
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStyleBordered handler:^(id sender) {
            [weakself dismissViewControllerAnimated:YES completion:nil];
        }];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"清空" style:UIBarButtonItemStyleDone handler:^(id sender) {
            [weakself.foodItems removeAllObjects];
            [weakself.tableview reloadData];
        }];
    }
    return self;
}

- (void)viewDidLoad
{
    self.tableview.tableFooterView = self.footerView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableview reloadData];
}

#pragma mark - table view data souce methods & delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    self.tableview.tableFooterView.hidden = _foodItems.count > 0? NO : YES;
    return _foodItems.count > 0 ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _foodItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellidentifier = @"FOODITEMCELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellidentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellidentifier];
    }
    
    NSDictionary *foodItem = _foodItems[indexPath.row];
    BXFood *food = [foodItem objectForKey:@"food"];
    NSInteger amount = [[foodItem objectForKey:@"amount"] integerValue];
    cell.textLabel.text = [NSString stringWithFormat:@"%@(%g元/份)", food.name, food.price];
    UILabel *amountLabel = [[UILabel alloc] init];
    amountLabel.text = [NSString stringWithFormat:@"%d份",amount];
    amountLabel.backgroundColor = [UIColor clearColor];
    [amountLabel sizeToFit];
    cell.accessoryView = amountLabel;
    return cell;
}

- (IBAction)createOrder:(id)sender
{
    BXOrder *order = [BXOrder object];
    order.pToUser = [AVUser currentUser];
    order.status = 0;
    order.isPaid = NO;
    NSMutableArray *foodArr = [NSMutableArray array];
    NSMutableArray *priceArr = [NSMutableArray array];
    NSMutableArray *amountArr = [NSMutableArray array];
    __block BXShop *shop = nil;
    [_foodItems enumerateObjectsUsingBlock:^(NSDictionary* dic, NSUInteger idx, BOOL *stop) {
        BXFood *f = dic[@"food"];
        int i = [dic[@"amount"] intValue];
        [foodArr addObject:f.name];
        [priceArr addObject:@(f.price)];
        [amountArr addObject:@(i)];
        if (!shop) {
            shop = f.pToShop;
        }
        
    }];
    order.foodNameArr = foodArr;
    order.foodPriceArr = priceArr;
    order.foodAmountArr = amountArr;
    order.shop = shop;
    
    [order saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSString *msg = nil;
        if (error) {
            msg = @"下单失败，给cc些反馈";
            [SVProgressHUD showErrorWithStatus:msg];
        }else {
            msg = @"下单成功\n请等候通知";
            
            [self.foodItems removeAllObjects];
            [self.tableview reloadData];
            [self dismissViewControllerAnimated:NO completion:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationGoMyOrder
                                                                    object:nil];
            }];
        }
    }];
}

@end
