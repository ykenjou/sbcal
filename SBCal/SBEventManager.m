//
//  SBEventManager.m
//  SBCal
//
//  Created by kenjou yutaka on 2014/05/23.
//  Copyright (c) 2014年 kenjou yutaka. All rights reserved.
//

#import "SBEventManager.h"

@implementation SBEventManager

static SBEventManager *_sharedInstance;

+(SBEventManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

+(id)allocWithZone:(NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        _sharedInstance = [super allocWithZone:zone];
    });
    
    return _sharedInstance;
}

-(id)init
{
    self = [super init];
    if (self) {
        _sharedEventKitStore = [[EKEventStore alloc] init];
    }
    
    return self;
}

-(id)copyWithZone:(NSZone *)zone
{
    return self;
}

/*
-(id)retain
{
    return self;
}
 */

/*
-(unsigned)retainCount
{
    return UINT_MAX;
}
 */

@end
