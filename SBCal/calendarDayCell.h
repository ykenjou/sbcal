//
//  calendarDayCell.h
//  fascal
//
//  Created by kenjou yutaka on 2014/02/14.
//  Copyright (c) 2014年 kenjou yutaka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import "DataUtility.h"
#import "SBTriangleView.h"

@protocol calendarDayCellDelegate <NSObject>


@end

@interface calendarDayCell : UICollectionViewCell

@property (nonatomic,readonly) UIView *contentView;
@property (nonatomic) NSDate *cellDate;
@property (nonatomic) NSDate *nowDate;
@property (nonatomic) NSArray *events;
@property (nonatomic) NSMutableDictionary *rowIndexs;
@property (nonatomic) EKEventStore *eventStore;

@property (nonatomic,weak) id<calendarDayCellDelegate> delegate;

-(void)setDate:(NSDate *)date nowDate:(NSDate *)nowDate events:(NSArray *)events rowIndexs:(NSMutableDictionary *)rowIndexs eventStore:(EKEventStore *)eventStore;

@end
