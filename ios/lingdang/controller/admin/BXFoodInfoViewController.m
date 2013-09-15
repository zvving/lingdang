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
@property (weak, nonatomic) IBOutlet UIButton *         shopNameButton;
@property (weak, nonatomic) IBOutlet UITextField *      nameTf;
@property (weak, nonatomic) IBOutlet UITextField *      priceTf;

@property (nonatomic, strong) NSArray *         shopData;

// post action
- (void)preAddFoodAction;
- (void)addFoodWithShop:(BXShop *)shop;

// private
- (void)reloadShopData;
- (IBAction)addShopButtonClicked:(id)sender;
- (IBAction)shopNameButtonClicked:(id)sender;

@end

@implementation BXFoodInfoViewController

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

#pragma mark - post action

- (void)preAddFoodAction
{
    if (_nameTf.text.length == 0 || _priceTf.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"名称、价格不可为空"];
        return;
    }
    
    int selectedShopIdx = [_shopPicker selectedRowInComponent:0];
    
    
    if (selectedShopIdx >= _shopData.count) {
        [SVProgressHUD showErrorWithStatus:@"请先新增店铺"];
        return;
    }
    
    BXShop *shop = _shopData[selectedShopIdx];
    [self addFoodWithShop:shop];
}

- (void)addFoodWithShop:(BXShop *)shop
{
    NSString *message =[NSString stringWithFormat:@"%@菜品中", _food==nil? @"新增":@"更新"];
    [SVProgressHUD showWithStatus:message maskType:SVProgressHUDMaskTypeGradient];
    
    if (_food != nil) {
        _food.name = _nameTf.text;
        _food.price = [_priceTf.text floatValue];
        _food.pToShop = shop;
        [[BXFoodProvider sharedInstance] updateFood:_food onSuccess:^{
            [SVProgressHUD showSuccessWithStatus:@"菜品已更新"];
            double delayInSeconds = 1.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self.navigationController popViewControllerAnimated:YES];
            });
        } onFail:^(NSError *err) {
            [SVProgressHUD showErrorWithStatus:@"更新菜品失败"];
        }];
    } else {
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
}

#pragma mark - refresh data

- (void)reloadShopData;
{
    [[BXShopProvider sharedInstance] allShops:^(NSArray *shops) {
        self.shopData = shops;
        [_shopPicker reloadAllComponents];
        
        if (_food) {
            // select food.shop_p
            NSString *shopName = _food.shopName;
            int idx = [_shopData indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                if ([shopName isEqualToString:[obj objectForKey:@"name"]]) {
                    *stop = YES;
                    return YES;
                }
                return NO;
            }];
            [_shopPicker selectRow:idx inComponent:0 animated:YES];
            [_shopNameButton setTitle:shopName
                             forState:UIControlStateNormal];
            
            _nameTf.text = _food.name;
            _priceTf.text = [NSString stringWithFormat:@"%.1f", _food.price];
        } else {
            if (_shopData.count > 0) {
                [_shopPicker selectRow:_shopData.count-1
                           inComponent:0
                              animated:YES];
                BXShop *shop = _shopData.lastObject;
                [_shopNameButton setTitle:[shop objectForKey:@"name"]
                                 forState:UIControlStateNormal];
            }

        }
        
        
    } fail:^(NSError *err) {
        self.shopData = nil;
        [_shopPicker reloadAllComponents];
    }];
}

- (IBAction)addShopButtonClicked:(id)sender {
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
//        [[BXShopProvider sharedInstance] addShopWithName:tf.text success:^(BXShop *shop) {
//            [SVProgressHUD showSuccessWithStatus:@"店铺已添加"];
//            [weakSelf reloadShopData];
//        } fail:^(NSError *err) {
//            [SVProgressHUD showErrorWithStatus:@"新增店铺失败"];
//        }];
    }];
    [shopAlert show];
}

- (IBAction)shopNameButtonClicked:(id)sender {
    BOOL forceShow = NO;
    if (_nameTf.isEditing || _priceTf.isEditing) {
        forceShow = YES;
    }
    [self.view endEditing:YES];
    
    float viewHeight = self.view.frame.size.height;
    
    [UIView animateWithDuration:0.25f animations:^{
        CGRect rect = _shopPicker.frame;
        rect.origin.y = ( forceShow || rect.origin.y == viewHeight ? viewHeight - rect.size.height : viewHeight );
        _shopPicker.frame = rect;
    } completion:nil];
}

#pragma mark - UIPickerViewDataSource & UIPickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _shopData.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    BXShop *shop = _shopData[row];
    return [shop objectForKey:@"name"];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (row >= _shopData.count) {
        return;
    }
    BXShop *shop = _shopData[row];
    NSString *shopName = [shop objectForKey:@"name"];
    [_shopNameButton setTitle:shopName forState:UIControlStateNormal];
}

@end
