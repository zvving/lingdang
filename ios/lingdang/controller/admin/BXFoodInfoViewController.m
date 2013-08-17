//
//  BXFoodInfoViewController.m
//  lingdang
//
//  Created by zengming on 13-8-17.
//  Copyright (c) 2013年 baixing.com. All rights reserved.
//

#import "BXFoodInfoViewController.h"

#import "BXShop.h"

#import "BXShopProvider.h"
#import "BXFoodProvider.h"

@interface BXFoodInfoViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *           bgView;
@property (weak, nonatomic) IBOutlet UIPickerView *     shopPicker;
@property (weak, nonatomic) IBOutlet UITextField *      nameTf;
@property (weak, nonatomic) IBOutlet UITextField *      priceTf;

@property (nonatomic, strong) NSArray *         shopData;

// post action
- (void)preAddFoodAction;
- (void)addFoodWithShop:(BXShop *)shop;

// private
- (void)reloadShopData;

@end

@implementation BXFoodInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = _food ? @"更新菜品" : @"新增菜品";
    
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@"完成"
                                     style:UIBarButtonItemStyleDone
                                   handler:^(id sender)
    {
        [self preAddFoodAction];
    }];
    
    [_bgView whenTapped:^{
        [self.view endEditing:YES];
    }];
    
    
    [self reloadShopData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

#pragma mark - post action

- (void)preAddFoodAction
{
    if (_nameTf.text.length == 0 || _priceTf.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"名称、价格不可为空"];
        return;
    }
    
    int selectedShopIdx = [_shopPicker selectedRowInComponent:0];
    if (selectedShopIdx < _shopData.count) {
        BXShop *shop = _shopData[selectedShopIdx];
        [self addFoodWithShop:shop];
    } else {
        UIAlertView *shopAlert = [UIAlertView alertViewWithTitle:@"新店铺名称："];
        shopAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [shopAlert addButtonWithTitle:@"取消"];
        __block UIAlertView *weakAlert = shopAlert;
        __block BXFoodInfoViewController *weakSelf = self;
        [shopAlert addButtonWithTitle:@"确定" handler:^{
            UITextField *tf = [weakAlert textFieldAtIndex:0];
            if (tf.text.length == 0) {
                [SVProgressHUD showErrorWithStatus:@"店铺名称不可为空"];
                return;
            }
            [SVProgressHUD showWithStatus:@"新增店铺中" maskType:SVProgressHUDMaskTypeGradient];
            [[BXShopProvider sharedInstance] addShopWithName:tf.text success:^(BXShop *shop) {
                [SVProgressHUD showSuccessWithStatus:@"店铺已添加"];
                [weakSelf addFoodWithShop:shop];
                [weakSelf reloadShopData];
            } fail:^(NSError *err) {
                [SVProgressHUD showErrorWithStatus:@"新增店铺失败"];
            }];
        }];
        [shopAlert show];
    }
}

- (void)addFoodWithShop:(BXShop *)shop
{
    [SVProgressHUD showWithStatus:@"新增菜品中" maskType:SVProgressHUDMaskTypeGradient];
    
    [[BXFoodProvider sharedInstance] addFoodWithName:_nameTf.text
                                               price:[_priceTf.text floatValue]
                                                shop:shop
                                             success:^(BXFood *food)
    {
        [SVProgressHUD showSuccessWithStatus:@"新菜品已添加"];
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.navigationController popViewControllerAnimated:YES];
        });
    } fail:^(NSError *err) {
        [SVProgressHUD showErrorWithStatus:@"新菜品添加失败"];
    }];
    
}

#pragma mark -

- (void)reloadShopData;
{
    [[BXShopProvider sharedInstance] allShops:^(NSArray *shops) {
        self.shopData = shops;
        [_shopPicker reloadAllComponents];
        
        if (_food) { // select food.shop_p
            BXShop *shop = _food.pToShop;
            int idx = [_shopData indexOfObject:shop];
            [_shopPicker selectRow:idx inComponent:0 animated:YES];
        } else {
            [_shopPicker selectRow:_shopData.count inComponent:0 animated:YES];
        }
    } fail:^(NSError *err) {
        self.shopData = nil;
        [_shopPicker reloadAllComponents];
    }];
}

#pragma mark - UIPickerViewDataSource & UIPickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _shopData.count + 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (row < _shopData.count) {
        BXShop *shop = _shopData[row];
        return shop.name;
    }
    return @"新增一个店铺";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{

}

@end
