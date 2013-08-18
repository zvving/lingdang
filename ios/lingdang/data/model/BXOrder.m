//
//  BXOrder.m
//  lingdang
//
//  Created by zengming on 13-8-17.
//  Copyright (c) 2013年 baixing.com. All rights reserved.
//

#import "BXOrder.h"

@implementation BXOrder

@dynamic count;
@dynamic status;
@dynamic isPaid;

@dynamic shopName;
@dynamic foodName;
@dynamic userName;

+ (NSString *)parseClassName {
    return @"order";
}

+ (instancetype)object
{
    return [super objectWithClassName:[self parseClassName]];
}

+ (instancetype)objectWithoutDataWithObjectId:(NSString *)objectId
{
    return [super objectWithoutDataWithClassName:[self parseClassName]
                                        objectId:objectId];
}

+ (PFQuery *)query
{
    return [PFQuery queryWithClassName:[self parseClassName]];
}

- (void)setPToFood:(BXFood *)pToFood
{
    [self setObject:pToFood forKey:@"pToFood"];
}

- (BXFood *)pToFood
{
    return [self objectForKey:@"pToFood"];
}

- (void)setPToUser:(PFUser *)pToUser
{
    [self setObject:pToUser forKey:@"pToUser"];
}

- (PFUser *)pToUser
{
    return [self objectForKey:@"pToUser"];
}
@end
