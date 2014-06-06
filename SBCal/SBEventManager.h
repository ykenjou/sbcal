//
//  SBEventManager.h
//  SBCal
//
//  Created by kenjou yutaka on 2014/05/23.
//  Copyright (c) 2014年 kenjou yutaka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

@interface SBEventManager : NSObject

@property (nonatomic, retain) EKEventStore *sharedEventKitStore;
+(SBEventManager *)sharedInstance;

@end
