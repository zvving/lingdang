//
//  BXViewController.m
//  lingdang
//
//  Created by zengming on 13-8-16.
//  Copyright (c) 2013年 baixing.com. All rights reserved.
//

#import "BXFoodListViewController.h"
#import "BXMyOrderViewController.h"
#import "BXOrder.h"

#import "BXShop.h"
#import "BXFoodProvider.h"


@interface BXFoodListViewController () <UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView        * tableView;

@property (strong, nonatomic) IBOutlet UIView           * containerView;
@property (weak, nonatomic)   IBOutlet UINavigationBar  * amountBar;
@property (weak, nonatomic)   IBOutlet UIPickerView     * amountPicker;

@property (strong, nonatomic) NSArray                   * shopFoods;

@property (strong, nonatomic) BXOrder                   * order;
@property (strong, nonatomic) BXFood                    * food;

@end

@implementation BXFoodListViewController

- (void)viewDidLoad
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"购物车" style:UIBarButtonItemStyleBordered handler:^(id sender) {
        BXMyOrderViewController *myOrderVC = [[BXMyOrderViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:myOrderVC];
        [self presentViewController:nav animated:YES completion:nil];
    }];
    
    // set containerUI
    __weak BXFoodListViewController *weakself = self;
    void (^removeSelf)(void) = ^(void){
        [UIView beginAnimations:@"pickerDown" context:nil];
        [UIView animateWithDuration:2.5f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
            CGRect selfRect = self.containerView.frame;
            self.containerView.frame = CGRectMake(0, CGRectGetMaxY(selfRect) + CGRectGetHeight(selfRect), CGRectGetWidth(selfRect), CGRectGetHeight(selfRect));
        } completion:^(BOOL finished) {
            if (finished) {
                [_containerView removeFromSuperview];
            }
        }];
        [UIView commitAnimations];
        self.tableView.userInteractionEnabled = YES;
    };
    UINavigationItem *item = [_amountBar.items lastObject];
    item.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStyleBordered handler:^(id sender) {
        removeSelf();
    }];
    item.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"确定" style:UIBarButtonItemStyleDone handler:^(id sender) {
        removeSelf();
    }];
    
    // load the foods accordding to the shop
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
    
    BXFood *food = _shopFoods[indexPath.row];
    
    cell.imageView.image = [UIImage imageNamed:@"balana"];
    cell.textLabel.text = food.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%g", food.price];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSIndexPath *previouse = nil;
    if (previouse !=nil && previouse.row != indexPath.row) {
        UITableViewCell *previousCell = [tableView cellForRowAtIndexPath:previouse];
        previousCell.accessoryType = UITableViewCellAccessoryNone;
    }
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    previouse = indexPath;
    
    _food = _shopFoods[indexPath.row];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // animate the present
    CGRect bounds = self.view.bounds;
    CGRect originRect = _containerView.frame;
    _containerView.frame = CGRectMake(0, bounds.size.height, CGRectGetWidth(originRect), CGRectGetHeight(originRect));
    [self.view addSubview:_containerView];
    self.tableView.userInteractionEnabled = NO;
    [UIView beginAnimations:@"pickerUp" context:nil];
    [UIView animateWithDuration:2.0f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGRect dstRect = CGRectMake(0, bounds.size.height - originRect.size
                                    .height, CGRectGetWidth(originRect), CGRectGetHeight(originRect));
        _containerView.frame = dstRect;
    } completion:nil];
    [UIView commitAnimations];
}

#pragma mark - picker view delegate & datasouce methods

//fisrt datasource methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 6;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"%d份", row + 1];
}
@end
