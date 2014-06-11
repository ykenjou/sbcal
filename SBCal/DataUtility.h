//
//  DataUtility.h
//  fascal
//
//  Created by kenjou yutaka on 2014/02/13.
//  Copyright (c) 2014年 kenjou yutaka. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataUtility : NSObject
+(NSDate *)adjustZeroClock:(NSDate*)date withCalendar:(NSCalendar *)calendar;
+(NSInteger)daysBetween:(NSDate *)startDate and:(NSDate *)endDate;
+(NSDate *)dateAtBeginningOfDayForDate:(NSDate *)inputDate;
+(NSDate *)dateByAddingYears:(NSInteger)numberOfYears toDate:(NSDate *)inputDate;
+(NSDate *)dateByAddingMonthsFirstDay:(NSInteger)numberOfMonths toDate:(NSDate *)inputDate;
+(NSDate *)dateByAddingdDays:(NSInteger)numberOfDays toDate:(NSDate *)inputDate;
+(NSDate *)setStartDate:(NSDate *)date;
+(NSDate *)setEndDate:(NSDate *)date;
@end
