//
//  getEKData.m
//  LisCal
//
//  Created by kenjou yutaka on 2014/05/04.
//  Copyright (c) 2014年 kenjou yutaka. All rights reserved.
//

#import "DataUtility.h"
#import "calendarAccessCheck.h"
#import "getEKData.h"

@implementation getEKData

-(void)EKDataDictionary:(EKEventStore *)eventStore
{
        
        NSDate *now = [NSDate date];
        NSDate *preStartDate = [DataUtility dateAtBeginningOfDayForDate:now];
        NSDate *startDate = [DataUtility dateByAddingMonthsFirstDay:-3 toDate:preStartDate];
        NSDate *endDate = [DataUtility dateByAddingYears:1 toDate:preStartDate];
        
        //NSLog(@"startDate %@",startDate);
        
        SBEventManager *eventMG = [SBEventManager sharedInstance];
        eventStore = eventMG.sharedEventKitStore;
        NSPredicate *searchPrecidate= [eventStore predicateForEventsWithStartDate:startDate endDate:endDate calendars:nil];
    
        NSArray *events = [eventStore eventsMatchingPredicate:searchPrecidate];
        
        NSMutableDictionary *eventsByDay = [NSMutableDictionary new];
        
        self.sections = [NSMutableDictionary dictionary];
        for (EKEvent *event in events) {
            NSDate *eventStartDate = [DataUtility dateAtBeginningOfDayForDate:event.startDate];
            
            NSDate *eventEndDate = [DataUtility dateAtBeginningOfDayForDate:event.endDate];
            //NSLog(@"Date %@ - %@",eventStartDate, eventEndDate);
            NSDate *eventEndDatePlusOne = [DataUtility dateByAddingdDays:1 toDate:eventEndDate];
            
            
            NSDate *tmpDate = [eventStartDate copy];
            while ([tmpDate compare:eventEndDatePlusOne] != NSOrderedSame) {
                if ([eventsByDay objectForKey:tmpDate]) {
                    [((NSMutableArray *) [eventsByDay objectForKey:tmpDate]) addObject:event];
                } else {
                    [eventsByDay setObject:@[event].mutableCopy forKey:tmpDate];
                }
                tmpDate = [DataUtility dateByAddingdDays:1 toDate:tmpDate];
            }
            //NSLog(@"eventsByDay %@",eventsByDay);
            
            /*
            NSMutableArray *eventsOnThisDay = [self.sections objectForKey:eventStartDate];
            if (eventsOnThisDay == nil) {
                eventsOnThisDay = [NSMutableArray array];
                [self.sections setObject:eventsOnThisDay forKey:eventStartDate];
            }
            [eventsOnThisDay addObject:event];
             */
        }
        NSMutableDictionary *eventsByDaySorted = [NSMutableDictionary new];
        NSArray *unsortedDays = [eventsByDay allKeys];
        NSArray *sortedDays = [unsortedDays sortedArrayUsingSelector:@selector(compare:)];
        NSArray *eventsByKey = [NSArray new];
        
        for (int i = 0; i < [eventsByDay count]; i++) {
            eventsByKey = [eventsByDay objectForKey:sortedDays[i]];
            NSArray *eventsByKeySorted = [eventsByKey sortedArrayUsingComparator:^NSComparisonResult(EKEvent *obj1,EKEvent *obj2){
                return [obj1.startDate compare:obj2.startDate];
            }];
            [eventsByDaySorted setObject:eventsByKeySorted forKey:sortedDays[i]];
        }
        
        
        NSPredicate *reminderPrecidate = [eventStore predicateForIncompleteRemindersWithDueDateStarting:startDate ending:endDate calendars:nil];
        //NSPredicate *reminderPrecidate = [eventStore predicateForRemindersInCalendars:nil];
        
        //NSArray *reminderEvent = [eventStore eventsMatchingPredicate:reminderPrecidate];
        
        
        NSMutableDictionary *reminderByDay = [NSMutableDictionary new];
        NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
        [eventStore fetchRemindersMatchingPredicate:reminderPrecidate completion:^(NSArray *reminders) {
            for (EKReminder *reminder in reminders) {
                NSDate *dueDate = [DataUtility dateAtBeginningOfDayForDate:[calendar dateFromComponents:reminder.dueDateComponents]];
                
                [reminderByDay setObject:reminder forKey:dueDate];
            }
            
            
            NSMutableDictionary *combineEvents = [eventsByDaySorted mutableCopy];
            for (NSString *key in [reminderByDay allKeys]) {
                NSMutableArray *reminderArray = [NSMutableArray new];
                [reminderArray addObject:[reminderByDay objectForKey:key]];
                NSMutableArray *eventsArray = [NSMutableArray new];
                if ([combineEvents objectForKey:key]) {
                    NSArray *events = [combineEvents objectForKey:key];
                    for (int i = 0; i < [events count]; i++) {
                        [eventsArray addObject:[events objectAtIndex:i]];
                    }
                }
                if (eventsArray) {
                    for (int i = 0; i < [reminderArray count]; i++) {
                        EKReminder *reminder = [reminderArray objectAtIndex:i];
                        [eventsArray addObject:reminder];
                    }
                    [combineEvents setObject:eventsArray forKey:key];
                } else {
                    [combineEvents setObject:eventsArray forKey:key];
                }
            }
            [self dateReload:combineEvents];
            
        }];
    //return eventsByDaySorted;
    
}

-(void)dateReload:(NSDictionary *)dictionary
{
    [self.delegate dateReloadDelegate:dictionary];
    NSLog(@"dateReload");
}

@end
