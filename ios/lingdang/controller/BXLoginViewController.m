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

- (IBAction)login:(id)sender;

@end

@implementation BXLoginViewController

- (void)viewDidLoad
{
    _usernameTf.borderStyle = UITextBorderStyleRoundedRect;
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


- (IBAction)login:(id)sender
{
    NSString *userName = _usernameTf.text;
    if (userName.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入您的大名"];
        return ;
    }
    [SVProgressHUD showWithStatus:@"登录中" maskType:SVProgressHUDMaskTypeGradient];
    [[BXUserProvider sharedInstance] autoLoginWithUsername:_usernameTf.text
                                                   success:^(AVUser *user)
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

}
@end
