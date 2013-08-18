//
//  BXLoginViewController.m
//  lingdang
//
//  Created by zengming on 13-8-17.
//  Copyright (c) 2013年 baixing.com. All rights reserved.
//

#import "BXLoginViewController.h"
#import "BXUserProvider.h"


@interface BXLoginViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameTf;

@end

@implementation BXLoginViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    PFUser *user = [PFUser currentUser];
    _usernameTf.text = user.username ?: [[UIDevice currentDevice] name];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [_usernameTf becomeFirstResponder];
    });
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [SVProgressHUD showWithStatus:@"登录中" maskType:SVProgressHUDMaskTypeGradient];
    [[BXUserProvider sharedInstance] audoLoginWithUsername:textField.text
                                                   success:^(PFUser *user)
    {
        [SVProgressHUD showSuccessWithStatus:@"登录成功"];
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    } fail:^(NSError *err) {
        [SVProgressHUD showErrorWithStatus:@"登录失败"];
    }];
    
    return YES;
}

@end
