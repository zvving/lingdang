//
//  BXPushProvider.h
//  lingdang
//
//  Created by zengming on 9/19/13.
//  Copyright (c) 2013 baixing.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BXPushProvider : NSObject


BCSINGLETON_IN_H(BXPushProvider)


- (void)pushAllWithTitle:(NSString*)title;

- (void)pushUserId:(NSString*)userId withTitle:(NSString*)title;

- (void)pushUser:(AVUser*)targetUser withTitle:(NSString*)title;


@end
