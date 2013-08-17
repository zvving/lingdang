//
//  BCSingleton.h
//  Baochuan
//
//  Created by zengming on 13-5-2.
//  Copyright (c) 2013年 Baixing. All rights reserved.
//

#ifndef Baochuan_BCSingleton_h
#define Baochuan_BCSingleton_h


#define BCSINGLETON_IN_H(classname) \
+ (classname *)sharedInstance;\
+ (void)releaseSingleton;


#define BCSINGLETON_IN_M(classname) \
\
__strong static id _shared##classname = nil; \
\
+ (classname *)sharedInstance { \
@synchronized(self) \
{ \
if (_shared##classname == nil) \
{ \
_shared##classname = [[super allocWithZone:NULL] init]; \
} \
} \
return _shared##classname; \
} \
\
+ (id)allocWithZone:(NSZone *)zone \
{ \
return [self sharedInstance]; \
} \
\
- (id)copyWithZone:(NSZone *)zone \
{ \
return self; \
}\
+ (void)releaseSingleton \
{ \
_shared##classname = nil; \
}


#endif
