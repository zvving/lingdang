//
//  BXViewController.m
//  lingdang
//
//  Created by zengming on 13-8-16.
//  Copyright (c) 2013年 baixing.com. All rights reserved.
//

#import "BXFoodListViewController.h"
#import "BXMyOrderViewController.h"

#import "BXShop.h"
#import "BXFoodProvider.h"


@interface BXFoodListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *shopFoods;

@end

@implementation BXFoodListViewController

- (void)viewDidLoad
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"购物车" style:UIBarButtonItemStyleBordered handler:^(id sender) {
        BXMyOrderViewController *myOrderVC = [[BXMyOrderViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:myOrderVC];
        [self presentViewController:nav animated:YES completion:nil];
    }];
    
    // load the foods accordding to the shop
    __weak BXFoodListViewController *weakself = self;
    [[BXFoodProvider sharedInstance]allFoodsInShop:self.shop onSuccess:^(NSArray *foods) {
        weakself.shopFoods = foods;
        [self.tableView reloadData];
    } onFail:nil];
}

#pragma mark tableview delegate & datasource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_shopFoods count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"foodListCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    AVObject *food = _shopFoods[indexPath.row];
    
    cell.imageView.image = [UIImage imageNamed:@"balana"];
    cell.textLabel.text = [food objectForKey:@"name"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%g", [[food objectForKey:@"price"]floatValue]];
    return cell;
}


@end
