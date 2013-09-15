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

@interface BXFoodInfoViewController () 

@property (weak, nonatomic) IBOutlet UITextField *nameTf;
@property (weak, nonatomic) IBOutlet UITextField *priceTf;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *shopNameLabel;

@property (nonatomic, strong) NSArray *         shopData;

// post action

// private
- (IBAction)addShopButtonClicked:(id)sender;

@end

@implementation BXFoodInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = _food ? @"更新菜品" : @"新增菜品";
    
    _shopNameLabel.text = _shop.name;
}


#pragma mark - refresh data

- (IBAction)addShopButtonClicked:(id)sender {
    [SVProgressHUD showWithStatus:@"新增菜品中" maskType:SVProgressHUDMaskTypeGradient];
    [[BXFoodProvider sharedInstance] addFoodWithName:_nameTf.text price:([_priceTf.text floatValue]) shop:_shop imageStr:nil upImgUser:nil success:^(BXFood *food) {
        NSString *title = [NSString stringWithFormat:@"%@已新增", food.name];
        [SVProgressHUD showSuccessWithStatus:title];
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.navigationController popViewControllerAnimated:YES];
        });
    } fail:^(NSError *err) {
        [SVProgressHUD showErrorWithStatus:@"新增店铺失败"];
    }];
}

@end
