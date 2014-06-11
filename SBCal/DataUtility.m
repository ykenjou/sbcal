//
//  DataUtility.m
//  fascal
//
//  Created by kenjou yutaka on 2014/02/13.
//  Copyright (c) 2014年 kenjou yutaka. All rights reserved.
//

#import "DataUtility.h"

@implementation DataUtility

+(NSDate *)adjustZeroClock:(NSDate*)date withCalendar:(NSCalendar *)calendar
{
    NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
    return [calendar dateFromComponents:components];
}


//日と日の間の日数をカウントするクラスメソッド
+(NSInteger)daysBetween:(NSDate *)startDate and:(NSDate *)endDate
{
    NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    startDate = [DataUtility adjustZeroClock:startDate withCalendar:calendar];
    endDate = [DataUtility adjustZeroClock:endDate withCalendar:calendar];
    
    NSDateComponents *components = [calendar components:NSDayCalendarUnit fromDate:startDate toDate:endDate options:0];
    NSUInteger days = [components day];
    
    return days;
}

+(NSDate *)dateAtBeginningOfDayForDate:(NSDate *)inputDate
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSTimeZone *timezone = [NSTimeZone systemTimeZone];
    [calendar setTimeZone:timezone];
    
    NSDateComponents *dateCompos = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:inputDate];
    
    [dateCompos setHour:0];
    [dateCompos setMinute:0];
    [dateCompos setSecond:0];
    
    NSDate *beginningOfDay = [calendar dateFromComponents:dateCompos];
    return beginningOfDay;
}

+(NSDate *)dateByAddingYears:(NSInteger)numberOfYears toDate:(NSDate *)inputDate
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];;
    
    NSDateComponents *dateComps = [[NSDateComponents alloc] init];
    [dateComps setYear:numberOfYears];
    
    NSDate *newDate = [calendar dateByAddingComponents:dateComps toDate:inputDate options:0];
    
    
    return newDate;
}

+(NSDate *)dateByAddingdDays:(NSInteger)numberOfDays toDate:(NSDate *)inputDate
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];;
    
    NSDateComponents *dateComps = [[NSDateComponents alloc] init];
    [dateComps setDay:numberOfDays];
    
    NSDate *newDate = [calendar dateByAddingComponents:dateComps toDate:inputDate options:0];
    
    return newDate;
}

+(NSDate *)dateByAddingMonthsFirstDay:(NSInteger)numberOfMonths toDate:(NSDate *)inputDate
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];;
    
    NSDateComponents *dateComps = [[NSDateComponents alloc] init];
    [dateComps setMonth:numberOfMonths];
    
    NSDate *newDate = [calendar dateByAddingComponents:dateComps toDate:inputDate options:0];
    
    NSDateComponents *firstDayComps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekdayCalendarUnit fromDate:newDate];
    [firstDayComps setDay:1];
    
    newDate = [calendar dateFromComponents:firstDayComps];
    
    return newDate;
}

+(NSDate *)dateByAddingYears:(int)years months:(int)months days:(int)days
{
    NSDateComponents* dateComponents = [[NSDateComponents alloc]init];
    [dateComponents setYear:years];
    [dateComponents setMonth:months];
    [dateComponents setDay:days];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    return [calendar dateByAddingComponents:dateComponents toDate:self options:0];
}

+(NSDate *)setStartDate:(NSDate *)date
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDate *nowDate = date;
    
    NSDate *pastDate = [calendar dateByAddingComponents:((^{
        NSDateComponents *datecomponents = [NSDateComponents new];
        datecomponents.month = -3;
        return datecomponents;
    })()) toDate:nowDate options:0];
    
    NSDateComponents *pastComponents = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekdayCalendarUnit fromDate:pastDate];
    [pastComponents setDay:1];
    
    pastDate = [calendar dateFromComponents:pastComponents];
    
    pastComponents = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit fromDate:pastDate];
    
    NSInteger pastWeekDay = pastComponents.weekday;
    
    NSDate *firstDate = [calendar dateByAddingComponents:((^{
        NSDateComponents *datecomponents = [NSDateComponents new];
        datecomponents.day = -pastWeekDay + 1;
        return datecomponents;
    })()) toDate:pastDate options:0];
    
    NSDateComponents *firstDateComponents = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:firstDate];
    
    date = [calendar dateFromComponents:firstDateComponents];
    
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    NSInteger seconds = [timeZone secondsFromGMTForDate:nowDate];
    date = [date dateByAddingTimeInterval:seconds];
    return date;
}

+(NSDate *)setEndDate:(NSDate *)date
{
    NSDate *nowDate = date;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *futureDate = [calendar dateByAddingComponents:((^{
        NSDateComponents *datecomponents = [NSDateComponents new];
        datecomponents.month = 11;
        return datecomponents;
    })()) toDate:nowDate options:0];
    
    NSDateComponents *futureDateComponents = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:futureDate];
    
    futureDate = [calendar dateFromComponents:futureDateComponents];
    
    NSDate *preEndDate = [calendar dateByAddingComponents:((^{
        NSDateComponents *datecomponents = [NSDateComponents new];
        datecomponents.month = 1;
        datecomponents.day = -1;
        return datecomponents;
    })()) toDate:futureDate options:0];
    
    futureDateComponents = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit fromDate:preEndDate];
    NSInteger weekDay = futureDateComponents.weekday;
    
    if (weekDay != 7) {
        weekDay = 7 - weekDay;
        preEndDate = [calendar dateByAddingComponents:((^{
            NSDateComponents *datecomponents = [NSDateComponents new];
            datecomponents.day = weekDay;
            return datecomponents;
        })()) toDate:preEndDate options:0];
    }
    
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    NSInteger seconds = [timeZone secondsFromGMTForDate:nowDate];
    preEndDate = [preEndDate dateByAddingTimeInterval:seconds];
    
    return preEndDate;
}

//nsdateをセット
/*+(NSDate *)dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day
{
    NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [NSDateComponents new];
    [components setYear:year];
    [components setMonth:month];
    [components setDay:day];
    return [calendar dateFromComponents:components];
}*/

@end
