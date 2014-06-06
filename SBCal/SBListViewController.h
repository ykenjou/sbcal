//
//  SBListViewController.h
//  SBCal
//
//  Created by kenjou yutaka on 2014/05/21.
//  Copyright (c) 2014年 kenjou yutaka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import "getEKData.h"
#import "calendarAccessCheck.h"
#import "DataUtility.h"
#import "SBEventManager.h"

@interface SBListViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UINavigationBarDelegate,UIBarPositioningDelegate>

@property (nonatomic) NSMutableDictionary *sections;
@property (nonatomic) NSArray *sortedDays;
@property (nonatomic) NSDateFormatter *sectionDateFormatter;
@property (nonatomic) NSDateFormatter *cellDateFormatter;
@property (nonatomic,retain) EKEventStore *eventStore;
@property (nonatomic) EKCalendar *eventCalendar;
@property (nonatomic) getEKData *ekData;
@property (nonatomic) EKEvent *cellEvent;
@property (nonatomic) BOOL isNowDate;
@property (nonatomic) int nowDayObjectIndex;
@property (nonatomic) SBEventManager *eventMg;

@end
