//
//  BXViewController.m
//  lingdang
//
//  Created by zengming on 13-8-16.
//  Copyright (c) 2013年 baixing.com. All rights reserved.
//

#import "BXFoodListViewController.h"
#import "BXMyOrderViewController.h"
#import "BXMyShopCarViewController.h"
#import "BXOrder.h"

#import "BXShop.h"
#import "BXFoodProvider.h"
#import "BXFoodInfoViewController.h"

static NSIndexPath *previouse = nil;

@interface BXFoodListViewController () <UITableViewDataSource, UITableViewDelegate,
UIPickerViewDataSource,UIPickerViewDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UITableView        * tableView;

@property (strong, nonatomic) IBOutlet UIView           * containerView;
@property (weak, nonatomic)   IBOutlet UINavigationBar  * amountBar;
@property (weak, nonatomic)   IBOutlet UIPickerView     * amountPicker;

@property (strong, nonatomic) NSArray                   * shopFoods;
@property (weak, nonatomic) IBOutlet UIButton *addFoodButton;

@property (strong, nonatomic) BXFood                    * food;

@property (strong, nonatomic) BXMyShopCarViewController * shopCar;

@end

@implementation BXFoodListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.shopCar = [BXMyShopCarViewController sharedInstance];
    }
    return self;
}

- (void)viewDidLoad
{
    self.title = [NSString stringWithFormat:@"%@%@的菜", _isAdminMode ? @"管理" : @"", _shop.name];
    _addFoodButton.hidden = !_isAdminMode;
    
    self.tableView.allowsSelectionDuringEditing = YES;
    
    __weak BXFoodListViewController *weakself = self;

    if (_isAdminMode)
    {
        UIBarButtonItem* rightItem =
        [[UIBarButtonItem alloc] initWithTitle:@"编辑"
                                         style:UIBarButtonItemStyleBordered
                                       handler:^(id sender)
        {
             if (self.tableView.editing)
             {
                 self.tableView.editing = NO;
                 ((UIBarButtonItem*)sender).title = @"编辑";;
             }
             else
             {
                 self.tableView.editing = YES;
                 ((UIBarButtonItem*)sender).title = @"完成";;
             }
             
        }];
        
        rightItem.possibleTitles = [NSSet setWithObjects:@"编辑", @"完成", nil];
        self.navigationItem.rightBarButtonItem = rightItem;
    }
    else
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"购物车"
                                                                              style:UIBarButtonItemStyleBordered
                                                                            handler:^(id sender)
        {
            [self presentShopCar];
        }];
    }
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                                             style:UIBarButtonItemStyleBordered
                                                                           handler:^(id sender) {
        if (weakself.shopCar.foodItems.count > 0) {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"当前餐馆点了菜但未下单，请选择"
                                                                     delegate:self
                                                            cancelButtonTitle:@"取消"
                                                       destructiveButtonTitle:@"后悔了，换家馆子"
                                                            otherButtonTitles:@"去购物车下单", nil];
            [actionSheet showInView:self.view];
            return ;
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    // set containerUI
    void (^removeSelf)(void) = ^(void){
        [UIView beginAnimations:@"pickerDown" context:nil];
        [UIView animateWithDuration:2.0f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
            CGRect selfRect = self.containerView.frame;
            self.containerView.frame = CGRectMake(0, CGRectGetMaxY(selfRect) + CGRectGetHeight(selfRect), CGRectGetWidth(selfRect), CGRectGetHeight(selfRect));
        } completion:^(BOOL finished) {
            if (finished) {
                [_containerView removeFromSuperview];
            }
        }];
        [UIView commitAnimations];
        
        UITableViewCell *cell = [weakself.tableView cellForRowAtIndexPath:previouse];
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        self.tableView.userInteractionEnabled = YES;
    };
    UINavigationItem *item = [_amountBar.items lastObject];
    item.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStyleBordered handler:^(id sender) {
        removeSelf();
    }];
    item.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"确定吃这" style:UIBarButtonItemStyleDone handler:^(id sender) {
        removeSelf();
        NSInteger amount = [_amountPicker selectedRowInComponent:0] + 1;
        
        // 合并相同的菜单
        BOOL hasFound = NO;
        NSDictionary *foundedFoodItem = nil;
        for (NSDictionary *foodItem in weakself.shopCar.foodItems) {
            BXFood *food = [foodItem objectForKey:@"food"];
            if ([food.objectId isEqualToString: _food.objectId]) {
                hasFound = YES;
                foundedFoodItem = foodItem;
                break;
            }
        }
        if (hasFound) {
            [weakself.shopCar.foodItems removeObject:foundedFoodItem];
            amount += [foundedFoodItem[@"amount"] integerValue];
        }
        NSDictionary *foodItem = @{@"food": _food, @"amount" : @(amount)};
        
        [weakself.shopCar.foodItems addObject:foodItem];
        
        [SVProgressHUD showSuccessWithStatus:@"已添加到购物车"];
    }];
    
    // load the foods accordding to the shop

    
    [self.tableView addPullToRefreshWithActionHandler:^{
        [[BXFoodProvider sharedInstance]allFoodsInShop:self.shop onSuccess:^(NSArray *foods) {
            weakself.shopFoods = foods;
            [weakself.tableView reloadData];
            [weakself.tableView.pullToRefreshView stopAnimating];
        } onFail:^(NSError *err) {
            [weakself.tableView.pullToRefreshView stopAnimating];
        }];
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView triggerPullToRefresh];
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
    if (self.tableView.editing)
    {
        BXFoodInfoViewController *foodEdit = [[BXFoodInfoViewController alloc] init];
        foodEdit.food = _shopFoods[indexPath.row];
        [self.navigationController pushViewController:foodEdit animated:YES];
    }
    else
    {
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
        [UIView animateWithDuration:1.0f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            CGRect dstRect = CGRectMake(0, bounds.size.height - originRect.size
                                    .height, CGRectGetWidth(originRect), CGRectGetHeight(originRect));
            _containerView.frame = dstRect;
        } completion:nil];
        [UIView commitAnimations];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [SVProgressHUD showWithStatus:@"删除菜品中" maskType:SVProgressHUDMaskTypeGradient];
        
        BXFood* food = _shopFoods[indexPath.row];
        [[BXFoodProvider sharedInstance] deleteFood:food onSuccess:^{
            [SVProgressHUD showErrorWithStatus:@"删除菜品成功"];
            [self.tableView triggerPullToRefresh];
        } onFail:^(NSError *err) {
            [SVProgressHUD showErrorWithStatus:@"删除菜品失败"];
        }];
    }
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
- (IBAction)addFoodButtonClicked:(id)sender
{
    BXFoodInfoViewController *foodInfo = [[BXFoodInfoViewController alloc] init];
    foodInfo.shop = _shop;
    [self.navigationController pushViewController:foodInfo animated:YES];
}

#pragma mark - uiaction sheet delegate methods

#define GoToAnotherShop     0
#define GoToShopCar         1
#define Cancel              2

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case GoToAnotherShop:
            [self.shopCar.foodItems removeAllObjects];
            [self.navigationController popViewControllerAnimated:YES];
            break;
        case GoToShopCar:
            [self presentShopCar];
            break;
    }
}

#pragma  mark private methods
- (void)presentShopCar
{
    UINavigationController *nav = [[UINavigationController alloc]
                                   initWithRootViewController:_shopCar];
    [self presentViewController:nav animated:YES completion:nil];
}

@end
