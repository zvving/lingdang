//
//  BXOrderListViewController.m
//  lingdang
//
//  Created by zengming on 13-8-17.
//  Copyright (c) 2013年 baixing.com. All rights reserved.
//

#import "BXOrderListViewController.h"
#import "BXFootListViewController.h"

@interface BXOrderListViewController ()

@end

@implementation BXOrderListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"订单管理";
    
    __block BXOrderListViewController *weakSelf = self;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"切至食客"
                                                                             style:UIBarButtonItemStylePlain
                                                                           handler:^(id sender)
    {
        [weakSelf dismissViewControllerAnimated:YES completion:^{
            [[EGOCache globalCache] removeCacheForKey:kCacheIsAdminMode];
        }];
    }];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"菜谱管理"
                                                                              style:UIBarButtonItemStylePlain
                                                                            handler:^(id sender)
    {
        BXFootListViewController *footVC =
        [[BXFootListViewController alloc] initWithNibName:@"BXFootListViewController_iPhone"
                                                   bundle:nil];
        footVC.isAdminMode = YES;
        [weakSelf.navigationController pushViewController:footVC animated:YES];
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
