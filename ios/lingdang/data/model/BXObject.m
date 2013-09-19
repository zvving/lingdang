//
//  BXObject.m
//  lingdang
//
//  Created by zengming on 13-8-18.
//  Copyright (c) 2013年 baixing.com. All rights reserved.
//

#import "BXObject.h"
#import <objc/runtime.h>
#import "NSObject+Properties.h"


@implementation BXObject

+ (NSString *)parseClassName {
    return @"demo";
}

+ (instancetype)object
{
    return [[BXObject alloc] initWithClassName:[BXObject parseClassName]];
}

+ (AVQuery*)query;
{
    return [AVQuery queryWithClassName:[self parseClassName]];
}

#pragma mark - NSCoding AVObject 缓存用不了，呜呜呜

- (void)encodeWithCoder:(NSCoder *)aCoder {
    NSArray *properties = [self propertyNames];
    NSObject *obj = nil;
    for (NSString* property in properties) {
        obj = [self valueForKey:property];
        [aCoder encodeObject:obj forKey:property];
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    NSArray *properties = [self propertyNames];
    NSObject *obj = nil;
    for (NSString* propertyStr in properties) {
        obj = [aDecoder decodeObjectForKey:propertyStr];
        [self setValue:obj forKey:propertyStr];
    }
    return self;
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
