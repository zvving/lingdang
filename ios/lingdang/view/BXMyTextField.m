//
//  BXMyTextField.m
//  lingdang
//
//  Created by neoman on 9/20/13.
//  Copyright (c) 2013 baixing.com. All rights reserved.
//

#import "BXMyTextField.h"

#define HorizonPadding          5.0f

@implementation BXMyTextField

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        UIImage *tfBackground =  [[UIImage imageNamed:@"TextFieldBack"] resizableImageWithCapInsets:UIEdgeInsetsMake(2.0f, 2.0f, 2.0f, 2.0f)];
        self.background = tfBackground;
    }
    return self;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x + HorizonPadding,
                      bounds.origin.y,
                      bounds.size.width - HorizonPadding*2,
                      bounds.size.height);
}
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}
@end