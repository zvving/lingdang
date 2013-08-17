//
//  BXUserProvider.h
//  lingdang
//
//  Created by zengming on 13-8-17.
//  Copyright (c) 2013年 baixing.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BXUserProvider : NSObject

BCSINGLETON_IN_H(BXUserProvider)

- (void)audoLoginWithUsername:(NSString*)username
                      success:(void(^)(PFUser* user))sucBlock
                         fail:(void(^)(NSError* err))failBlock;

@end
