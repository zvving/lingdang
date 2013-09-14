//
//  BXObject.h
//  lingdang
//
//  Created by zengming on 13-8-18.
//  Copyright (c) 2013年 baixing.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BXObject : AVObject

+ (instancetype)object;

+ (AVQuery*)query;

+ (instancetype)fixAVOSObject:(AVObject*)avObj;
+ (NSArray*)fixAVOSArray:(NSArray*)avArr;

@end
