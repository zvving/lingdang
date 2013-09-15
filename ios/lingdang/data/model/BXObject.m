//
//  BXObject.m
//  lingdang
//
//  Created by zengming on 13-8-18.
//  Copyright (c) 2013年 baixing.com. All rights reserved.
//

#import "BXObject.h"

@implementation BXObject

+ (NSString *)parseClassName {
    return @"demo";
}

+ (AVQuery*)query;
{
    return [AVQuery queryWithClassName:[self parseClassName]];
}

+ (instancetype)fixAVOSObject:(AVObject*)avObj;
{
    id obj = [self object];
    AVObject *aObj = (AVObject*)obj;
    aObj.objectId = avObj.objectId;
    [aObj setValue:avObj.createdAt forKeyPath:@"createdAt"];
    [aObj setValue:avObj.updatedAt forKeyPath:@"updatedAt"];
    aObj.ACL = avObj.ACL;
    
    [avObj.allKeys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        id value = [avObj objectForKeyedSubscript:key];
        [obj setObject:value forKey:key];
    }];
    return obj;
}

+ (NSArray*)fixAVOSArray:(NSArray*)avArr;
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:avArr.count];
    [avArr enumerateObjectsUsingBlock:^(AVObject* avObj, NSUInteger idx, BOOL *stop) {
        id obj = [self fixAVOSObject:avObj];
        [result addObject:obj];
    }];
    return result;
}

@end
