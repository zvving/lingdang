//
//  BXDateSelectView.m
//  lingdang
//
//  Created by minjie on 13-9-14.
//  Copyright (c) 2013年 baixing.com. All rights reserved.
//

#import "BXDateSelectView.h"

@implementation BXDateSelectView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIToolbar* toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel:)];
        UIBarButtonItem* okButton = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleBordered target:self action:@selector(ok:)];
        UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                               target:nil
                                                                               action:nil];
        toolbar.items = [NSArray arrayWithObjects:cancelButton,space,okButton,nil];
        [self addSubview:toolbar];
        
        _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 44, 320, self.frame.size.height-44)];
        _datePicker.maximumDate = [NSDate date];
        _datePicker.minimumDate = [NSDate dateWithTimeInterval:3600*24*10 sinceDate:[NSDate date]];
        _datePicker.datePickerMode = UIDatePickerModeDate;
        
        
        [self addSubview:_datePicker];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)cancel:(id)sender
{
    [self.delegate cancelSelectInView:self];
}

-(void)ok:(id)sender
{
    [self.delegate selectInView:self didSelectWithDate:_datePicker.date];
}

-(void)resetDate:(NSDate*)date
{
    [_datePicker setDate:date];
}
@end
