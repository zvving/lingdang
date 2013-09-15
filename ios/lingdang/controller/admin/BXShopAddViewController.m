//
//  BXShopAddViewController.m
//  lingdang
//
//  Created by zengming on 9/15/13.
//  Copyright (c) 2013 baixing.com. All rights reserved.
//

#import "BXShopAddViewController.h"
#import "BXShopProvider.h"

@interface BXShopAddViewController ()

@property (weak, nonatomic) IBOutlet UITextField *shopNameTf;
@property (weak, nonatomic) IBOutlet UITextField *phoneTf;
@property (weak, nonatomic) IBOutlet UITextField *shipInfoTf;

@end

@implementation BXShopAddViewController

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
    
    self.title = @"新增店铺";
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)addButtonClicked:(id)sender
{
    [SVProgressHUD showWithStatus:@"新增店铺中" maskType:SVProgressHUDMaskTypeGradient];
    [[BXShopProvider sharedInstance] addShopWithName:_shopNameTf.text
                                               phone:_phoneTf.text
                                            shipInfo:_shipInfoTf.text
                                             success:^(BXShop *shop)
    {
        NSString *title = [NSString stringWithFormat:@"%@已新增", shop.name];
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
