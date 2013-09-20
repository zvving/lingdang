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

+ (NSString *)parseClassName {
    return @"food";
}

+ (instancetype)object
{
    return [[BXFood alloc] initWithClassName:[BXFood parseClassName]];
}

+ (PFQuery *)query
{
    return [PFQuery queryWithClassName:[self parseClassName]];
}

- (void)setPToShop:(BXShop *)pToShop
{
    [self setObject:pToShop?:@"" forKey:@"pToShop"];
}

- (BXShop *)pToShop
{
    return [self objectForKey:@"pToShop"];
}

- (void)setName:(NSString *)name
{
    [self setObject:name?:@"" forKey:@"name"];
}

- (NSString *)name
{
    return [self objectForKey:@"name"];
}

- (void)setPrice:(float)price
{
    [self setObject:@(price) forKey:@"price"];
}

- (float)price
{
    return [[self objectForKey:@"price"] floatValue];
}

- (void)setShopName:(NSString *)shopName
{
    [self setObject:shopName?:@"" forKey:@"shopName"];
}

- (NSString *)shopName
{
    return [self objectForKey:@"shopName"];
}

- (AVFile *)image
{
    AVFile *avfile = [self objectForKey:@"image"];
    if (avfile == nil || [avfile isMemberOfClass:[NSNull class]]) {
        return nil;
    }
    return avfile;
}

- (void)setImage:(AVFile *)image
{
    if (image != nil && [image.objectId isEqualToString: self.objectId] == false) {
        [self setObject:image forKey:@"image"];
    }
}

@end
