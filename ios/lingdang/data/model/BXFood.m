//
//  BXFood.m
//  lingdang
//
//  Created by zengming on 13-8-17.
//  Copyright (c) 2013年 baixing.com. All rights reserved.
//

#import "BXFood.h"


@implementation BXFood

@dynamic name;
@dynamic price;
@dynamic shopName;

+ (NSString *)parseClassName {
    return @"food";
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

- (void)setPToShop:(BXShop *)pToShop
{
    [self setObject:pToShop forKey:@"pToShop"];
}

- (BXShop *)pToShop
{
    return [self objectForKey:@"pToShop"];
}

@end
