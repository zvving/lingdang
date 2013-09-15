//
//  BXDateSelectView.h
//  lingdang
//
//  Created by minjie on 13-9-14.
//  Copyright (c) 2013年 baixing.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BXDateSelectView;

@protocol BXDateSelectViewDelegate <NSObject>

- (void) cancelSelectInView:(BXDateSelectView*)selectView;
- (void) selectInView:(BXDateSelectView*)selectView didSelectWithDate:(NSDate*)date;

@end

@interface BXDateSelectView : UIView<UIPickerViewDataSource,UIPickerViewDelegate>
{
    UIPickerView* _datePicker;
}

@property (nonatomic,assign) id<BXDateSelectViewDelegate> delegate;



-(void)cancel:(id)sender;

-(void)ok:(id)sender;

-(void)resetDate:(NSDate*)date;

@end
