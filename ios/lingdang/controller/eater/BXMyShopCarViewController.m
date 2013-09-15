//
//  BXMyShopCarViewController.m
//  lingdang
//
//  Created by neoman on 9/15/13.
//  Copyright (c) 2013 baixing.com. All rights reserved.
//

#import "BXMyShopCarViewController.h"
#import "BXFood.h"

@interface BXMyShopCarViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableview;

@end

@implementation BXMyShopCarViewController

BCSINGLETON_IN_M(BXMyShopCarViewController);

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.foodItems = [[NSMutableArray alloc] init];
        self.title = @"购物车";
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStyleBordered handler:^(id sender) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableview reloadData];
}

#pragma mark - table view data souce methods & delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _foodItems.count > 0 ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _foodItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellidentifier = @"FOODITEMCELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellidentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellidentifier];
    }
    
    NSDictionary *foodItem = _foodItems[indexPath.row];
    BXFood *food = [foodItem objectForKey:@"food"];
    NSInteger amount = [[foodItem objectForKey:@"amount"] integerValue];
    cell.textLabel.text = [NSString stringWithFormat:@"%@(%g元/份)", food.name, food.price];
    UILabel *amountLabel = [[UILabel alloc] init];
    amountLabel.text = [NSString stringWithFormat:@"%d份",amount];
    amountLabel.backgroundColor = [UIColor clearColor];
    [amountLabel sizeToFit];
    cell.accessoryView = amountLabel;
    return cell;
}


@end
