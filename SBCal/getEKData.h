//
//  getEKData.h
//  LisCal
//
//  Created by kenjou yutaka on 2014/05/04.
//  Copyright (c) 2014年 kenjou yutaka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>
#import "SBEventManager.h"

@protocol getEKDateDelegate <NSObject>

-(void)dateReloadDelegate:(NSDictionary *)dictionary;

@end

@interface getEKData : NSObject
-(NSMutableDictionary *)EKDataDictionary:(EKEventStore *)eventStore;

@property (nonatomic) NSMutableDictionary *sections;
@property (nonatomic) NSArray *sortedDays;

@property (nonatomic,weak) id<getEKDateDelegate> delegate;

-(void)dateReload:(NSDictionary *)dictionary;

@end
