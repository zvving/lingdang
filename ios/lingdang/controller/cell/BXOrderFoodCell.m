//
//  BXOrderFoodCell.m
//  lingdang
//
//  Created by minjie on 13-9-15.
//  Copyright (c) 2013年 baixing.com. All rights reserved.
//

#import "BXOrderFoodCell.h"

@implementation BXOrderFoodCell

@synthesize amountLabel;
@synthesize foodLabel;
@synthesize priceLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
