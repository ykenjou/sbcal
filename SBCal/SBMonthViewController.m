//
//  SBMonthViewController.m
//  SBCal
//
//  Created by kenjou yutaka on 2014/05/21.
//  Copyright (c) 2014年 kenjou yutaka. All rights reserved.
//

#import "SBMonthViewController.h"
#import "DataUtility.h"
#import "calendarDayCell.h"
#import "calendarFlowLayout.h"
#import "calendarAccessCheck.h"
#import "SBRemindarAccessCheck.h"
#import "SBWeekDayView.h"
#import "SBTriangleView.h"

@class calendarDayCell;

@interface SBMonthViewController ()

@property(nonatomic,strong) UILabel *overlayView;
@property(nonatomic)CGPoint offsetPoint;
@property(nonatomic,strong) NSDate *nowDate;
@property(nonatomic) NSTimer *handleTimer;

@end

@implementation SBMonthViewController

static NSString *cellIdentifier = @"cellIdentifier";
static float cellHeight = 70.0f;
static float cellWidth = 45.6f;
//static float weekDayFontSize = 12.0f;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        self.overlayView = [UILabel new];
        //_eventStore = [EKEventStore new];
        _eventMg = [SBEventManager sharedInstance];
        _calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //[self resetCalendarDate];
    _nowDate = [NSDate date];
    startDate = [DataUtility setStartDate:_nowDate];
    endDate = [DataUtility setEndDate:_nowDate];
    
    allDays = [DataUtility daysBetween:startDate and:endDate];
    firstDayIndex = [DataUtility daysBetween:startDate and:_nowDate];
    
    //[self dateChangeNotification];
    
    _screenRect = [[UIScreen mainScreen] bounds];
    
    UINavigationBar *naviBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 20, _screenRect.size.width, 44)];
    naviBar.delegate = self;
    
    UINavigationItem *item = [UINavigationItem new];
    
    _naviTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    _naviTitle.font = [UIFont fontWithName:@"Helvetica-Bold" size:17.0f];
    _naviTitle.textAlignment = NSTextAlignmentCenter;
    _naviTitle.textColor = [UIColor whiteColor];
    
    item.titleView = _naviTitle;
    
    //「今日」ボタンの表示
    UIBarButtonItem *todayButton = [[UIBarButtonItem alloc] initWithTitle:@"今日" style:UIBarButtonItemStyleBordered target:self action:@selector(todayScroll:)];
    todayButton.tintColor = [UIColor whiteColor];
    
    item.rightBarButtonItem = todayButton;
    
    [naviBar pushNavigationItem:item animated:NO];
    
    naviBar.tintColor = [UIColor whiteColor];
    
    naviBar.barTintColor = [UIColor colorWithRed:0.392 green:0.38 blue:0.812 alpha:1.0];
    naviBar.translucent = NO;
    
    [self.view addSubview:naviBar];
    
    
    calendarFlowLayout *calLayout = [calendarFlowLayout new];
    
    //float width = screenRect.size.width/7;
    float spacing = 0.1f;
    
    [calLayout setItemSize:CGSizeMake(cellWidth, cellHeight)];
    [calLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [calLayout setMinimumInteritemSpacing:spacing];
    [calLayout setMinimumLineSpacing:spacing];
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 84, _screenRect.size.width, _screenRect.size.height -20 -20 -44 -44) collectionViewLayout:calLayout];
    [_collectionView setDataSource:self];
    [_collectionView setDelegate:self];
    
    [_collectionView registerClass:[calendarDayCell class] forCellWithReuseIdentifier:cellIdentifier];
    //[_collectionView setBackgroundColor:[UIColor colorWithRed:0.857 green:0.857 blue:0.857 alpha:1.0]];
    [_collectionView setBackgroundColor:[UIColor whiteColor]];
    
    _collectionView.showsVerticalScrollIndicator = NO;//縦スクロールバーの表示制御
    
    [self.view addSubview:_collectionView];
    
    //ナビゲーションバー非透過設定
    self.navigationController.navigationBar.translucent = NO;
    
    //タブバー非透過設定
    //self.tabBarController.tabBar.translucent = NO;
    
    UIView *weekView = [SBWeekDayView weekDayView:_screenRect.size.width];
    [self.view addSubview:weekView];
    
    _ekData = [getEKData new];
    _ekData.delegate = self;
    
    [_ekData EKDataDictionary:_eventMg.sharedEventKitStore];
    

}


-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

-(void)swipeRightTab:(id)sendar
{
    NSUInteger selectedIndex = [self.tabBarController selectedIndex];
    [self.tabBarController setSelectedIndex:selectedIndex-1];
}

-(void)dateReloadDelegate:(NSDictionary *)dictionary
{
    NSLog(@"complete!");
    _sections = [dictionary mutableCopy];
    //NSLog(@"sections %@",_sections);
    
    NSArray *unsortedDays = [_sections allKeys];
    
    _sortedDays = [unsortedDays sortedArrayUsingSelector:@selector(compare:)];
    //NSLog(@"sortedDays %@",_sortedDays);
    
    //NSMutableDictionary *sortedSections = [NSMutableDictionary new];
    NSArray *eventsByKey = [NSArray new];
    
    _rowIndexs = [NSMutableDictionary new];
    
    for (int i = 0; i < [_sections count]; i++)
    {
        eventsByKey = [_sections objectForKey:_sortedDays[i]];
        
        NSDate *sortedDay = _sortedDays[i];
        NSMutableArray *reservedNum = [NSMutableArray new];
        
        BOOL isReserved = NO;
        
        for (int i = 0; i < [eventsByKey count]; i++)
        {
            if ([[eventsByKey objectAtIndex:i] isKindOfClass:[EKEvent class]]) {
                EKEvent *event = [eventsByKey objectAtIndex:i];
                NSString *eventIdentifer = event.eventIdentifier;
                NSDate *eventStartDate = [DataUtility dateAtBeginningOfDayForDate:event.startDate];
                
                if ([sortedDay compare:eventStartDate] != NSOrderedSame)
                {
                    [reservedNum addObject:[_rowIndexs objectForKey:eventIdentifer]];
                    isReserved = YES;
                }
            }
            
        }
        
        if (!isReserved) {
            for (int i = 0; i < [eventsByKey count]; i++) {
                if ([[eventsByKey objectAtIndex:i] isKindOfClass:[EKEvent class]]) {
                    EKEvent *event = [eventsByKey objectAtIndex:i];
                    NSString *eventIdentifer = event.eventIdentifier;
                    NSNumber *num = [NSNumber numberWithInt:(i + 1)];
                    [_rowIndexs setObject:num forKey:eventIdentifer];
                    
                } else if ([[eventsByKey objectAtIndex:i] isKindOfClass:[EKReminder class]]){
                    EKReminder *reminder = [eventsByKey objectAtIndex:i];
                    NSString *reminderIdentifer = reminder.calendarItemIdentifier;
                    NSNumber *num = [NSNumber numberWithInt:(i + 1)];
                    [_rowIndexs setObject:num forKey:reminderIdentifer];
                }
                
            }
        }
        
        if (isReserved) {
            
            NSMutableArray *usableNum = [NSMutableArray new];
            
            for (int i = 1; i < 100 ;i++)
            {
                BOOL isNum = NO;
                for (int ii = 0; ii < [reservedNum count]; ii++) {
                    NSNumber *checkNum = [reservedNum objectAtIndex:ii];
                    int checkInt = checkNum.intValue;
                    if (checkInt == i) {
                        isNum = YES;
                    }
                }
                if (!isNum) {
                    NSNumber *num = [NSNumber numberWithInt:i];
                    [usableNum addObject:num];
                }
            }
            
            NSMutableArray *eventsThisDayStart = [NSMutableArray new];
            for (int i = 0; i < [eventsByKey count]; i++) {
                if ([[eventsByKey objectAtIndex:i] isKindOfClass:[EKEvent class]]) {
                    EKEvent *event = [eventsByKey objectAtIndex:i];
                    NSDate *eventStartDate = [DataUtility dateAtBeginningOfDayForDate:event.startDate];
                    
                    if ([sortedDay compare:eventStartDate] == NSOrderedSame) {
                        [eventsThisDayStart addObject:event];
                    }
                } else if ([[eventsByKey objectAtIndex:i] isKindOfClass:[EKReminder class]]) {
                    EKReminder *reminder = [eventsByKey objectAtIndex:i];
                    NSDate *reminderDueDate = [DataUtility dateAtBeginningOfDayForDate:[_calendar dateFromComponents:reminder.dueDateComponents]];
                    
                    if ([sortedDay compare:reminderDueDate] == NSOrderedSame) {
                        [eventsThisDayStart addObject:reminder];
                    }
                }
                
            }
            
            for (int i = 0; i < [eventsThisDayStart count]; i++)
            {
                if ([[eventsThisDayStart objectAtIndex:i] isKindOfClass:[EKEvent class]]) {
                    EKEvent *event = [eventsThisDayStart objectAtIndex:i];
                    NSString *eventIdentifer = event.eventIdentifier;
                    [_rowIndexs setObject:[usableNum objectAtIndex:i] forKey:eventIdentifer];
                } else if ([[eventsThisDayStart objectAtIndex:i] isKindOfClass:[EKReminder class]]) {
                    EKReminder *reminder = [eventsThisDayStart objectAtIndex:i];
                    NSString *reminderIderntifer = reminder.calendarItemIdentifier;
                    [_rowIndexs setObject:[usableNum objectAtIndex:i] forKey:reminderIderntifer];
                }
                
            }
        }
    }
    
    [_collectionView reloadData];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:firstDayIndex inSection:0];
    [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self calendarChangeNotification];
    
    [super viewWillAppear:animated];
    
    //日付が変わっている場合にカレンダー表示を再設定する
    [self dateChangeNotification];
    
    //view切り替え前の位置がセットされている場合にはその位置に戻し、セットされていない場合には今日の日付の位置を表示する
    if (_offsetPoint.y == 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:firstDayIndex inSection:0];
        [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
    } else {
        [_collectionView setContentOffset:_offsetPoint];
    }
}

-(void)dateChangeNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCalendar:) name:UIApplicationSignificantTimeChangeNotification object:nil];
}

-(void)reloadCalendar:(NSNotification *)notification
{
    _nowDate = [NSDate date];
    startDate = [DataUtility setStartDate:_nowDate];
    endDate = [DataUtility setEndDate:_nowDate];
    
    allDays = [DataUtility daysBetween:startDate and:endDate];
    firstDayIndex = [DataUtility daysBetween:startDate and:_nowDate];
    [_collectionView reloadData];
    //[self resetCalendarDate];
}

-(void)handleNotification:(NSNotification *)note
{
    [_handleTimer invalidate];
    _handleTimer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(reloadView:) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:_handleTimer forMode:NSDefaultRunLoopMode];
}

-(void)resetCalendarDate
{
    _nowDate = [NSDate date];
    startDate = [DataUtility setStartDate:_nowDate];
    endDate = [DataUtility setEndDate:_nowDate];
    
    allDays = [DataUtility daysBetween:startDate and:endDate];
    firstDayIndex = [DataUtility daysBetween:startDate and:_nowDate];
    [_collectionView reloadData];
}


-(void)calendarChangeNotification
{
    [_eventMg.sharedEventKitStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (granted) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:EKEventStoreChangedNotification object:_eventMg.sharedEventKitStore];
        }
    }];
}

-(void)reloadView:(NSNotification *)notification
{
    [_handleTimer invalidate];
    [_ekData EKDataDictionary:_eventMg.sharedEventKitStore];
    
    NSLog(@"reloadView");
    
    //[_collectionView reloadData];
}


//viewが他に移る前の処理
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    /*NSDateComponents *nowDateComponent = [_calendar components:NSDayCalendarUnit fromDate:_nowDate];
     int nowDay = nowDateComponent.day;
     NSLog(@"%d",(int)nowDay);*/
    
    //現在のスクロール位置をセット
    _offsetPoint = [_collectionView contentOffset];
    //NSLog(@"%@",NSStringFromCGPoint(_offsetPoint));
}

//今日ボタンを押した時の処理
-(void)todayScroll:(UIBarButtonItem *)btn
{
    [self dateChangeNotification];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:firstDayIndex inSection:0];
    [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -collection view delegate

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 0) {
        return allDays + 1;
    } else {
        return 0;
    }
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    calendarDayCell *dayCell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    dayCell.delegate = self;
    
    NSDate *cellDate = [_calendar dateByAddingComponents:((^{
        NSDateComponents *datecomponents = [NSDateComponents new];
        datecomponents.day = indexPath.item;
        return datecomponents;
    })()) toDate:startDate options:0];
    
    //NSDateComponents *weekDayComp = [_calendar components:NSWeekdayCalendarUnit fromDate:cellDate];
    //NSInteger weekDay = weekDayComp.weekday;
    //NSLog(@"weekDay %d",weekDay);
    
    //NSLog(@"cellDate : %@",cellDate);
    
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    NSInteger seconds = [timeZone secondsFromGMT];
    NSDate *gtmDate = [cellDate dateByAddingTimeInterval:-seconds];
    
    //NSArray *events = [_sections objectForKey:gtmDate];
    
    //EKEvent *event;
    //float labelHeight = 13.0f;
    
    //BOOL Holiday = NO;
    
    /*
    NSInteger rows = 0;
    NSInteger restRows = 0;
    if ([events count] > 4) {
        rows = 4;
        restRows = [events count] - 4;
    } else {
        rows = [events count];
    }
     */
    
    [dayCell setDate:cellDate nowDate:_nowDate events:[_sections objectForKey:gtmDate] rowIndexs:_rowIndexs eventStore:_eventMg.sharedEventKitStore];
    
    
    //イベントラベル生成
    /*
    if (events) {
        for (int i = 0; i < rows; i++) {
            
            if ([[events objectAtIndex:i] isKindOfClass:[EKEvent class]]) {
                EKEvent *event = [EKEvent eventWithEventStore:_eventMg.sharedEventKitStore];
                event = [events objectAtIndex:i];
            
                //NSLog(@"event %@" ,event);
                NSDate *eventStartDate = [[DataUtility dateAtBeginningOfDayForDate:event.startDate] dateByAddingTimeInterval:seconds];
                NSDate *eventEndDate = [[DataUtility dateAtBeginningOfDayForDate:event.endDate] dateByAddingTimeInterval:seconds];
            
                NSInteger restDays = [DataUtility daysBetween:eventStartDate and:eventEndDate]+1;
                NSInteger restDaysContinue = [DataUtility daysBetween:cellDate and:eventEndDate]+1;
            
                //NSLog(@"cellDate %@ restDays %d",cellDate,restDays);
            
                NSString *eventDateStatus = @"";
                if ([eventStartDate compare:cellDate] == NSOrderedSame && [eventEndDate compare:cellDate] == NSOrderedSame) {
                    eventDateStatus = @"complete";
                }
                if ([eventStartDate compare:cellDate] == NSOrderedSame && [eventEndDate compare:cellDate] != NSOrderedSame) {
                    eventDateStatus = @"startOnly";
                }
                if ([eventStartDate compare:cellDate] != NSOrderedSame && [eventEndDate compare:cellDate] == NSOrderedSame) {
                    eventDateStatus = @"endOnly";
                }
                if ([eventStartDate compare:cellDate] != NSOrderedSame && [eventEndDate compare:cellDate] !=NSOrderedSame) {
                    eventDateStatus = @"continue";
                }
                //NSLog(@"datestatus %@",eventDateStatus);
            
                //NSLog(@"eventStartDate %@ %@ %@",eventStartDate,eventEndDate,cellDate);
                NSNumber *num = [_rowIndexs objectForKey:event.eventIdentifier];
                int numInt = num.intValue;
                //NSLog(@"numInt %@ %@",cellDate,num);
            
                UIView *eventView = [UIView new];
                eventView.layer.borderColor = [UIColor lightGrayColor].CGColor;
                eventView.tag = i + 2;
                //eventView.layer.cornerRadius = 2;
                //eventView.clipsToBounds = YES;
            
                UILabel *eventLabel = [UILabel new];
                eventLabel.textColor = [UIColor blackColor];
                eventLabel.numberOfLines = 1;
                eventLabel.adjustsFontSizeToFitWidth = NO;
                eventLabel.lineBreakMode = NSLineBreakByClipping;
                //eventLabel.lineBreakMode = NSLineBreakByTruncatingTail;
                eventLabel.font = [UIFont fontWithName:@"Helvetica" size:10.0f];
                //eventLabel.layer.zPosition = MAXFLOAT;
                //eventLabel.textAlignment = NSTextAlignmentCenter;
                //[self.view bringSubviewToFront:eventLabel];
            
                UIColor *calendarColor = [UIColor colorWithCGColor:event.calendar.CGColor];
                UIColor *alphaColor = [calendarColor colorWithAlphaComponent:0.1];
            
                //完結した予定、または開始日の場合の処理
                if ([eventDateStatus isEqualToString:@"complete"] || [eventDateStatus isEqualToString:@"startOnly"]) {
                    eventLabel.text = event.title;
                
                    UIView *leftColorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 3, 12)];
                    leftColorView.backgroundColor = [UIColor colorWithCGColor:event.calendar.CGColor];
                
                    [eventView addSubview:leftColorView];
                }
            
                if ([eventDateStatus isEqualToString:@"complete"]) {
                    eventView.frame = CGRectMake(1, (labelHeight * numInt) + 3 , dayCell.bounds.size.width - 2, 12.0);
                    eventView.layer.borderWidth = 0.5f;
                    eventLabel.frame = CGRectMake(4, 1.5 , 38.6, 10.0);
                }
            
                if ([eventDateStatus isEqualToString:@"continue"]) {
                    eventView.frame = CGRectMake(0, (labelHeight * numInt) + 3 , dayCell.bounds.size.width, 12.0);
                    //[dayCell sendSubviewToBack:eventView];
                }
            
                if ([eventDateStatus isEqualToString:@"startOnly"]) {
                    eventView.frame = CGRectMake(1, (labelHeight * numInt) + 3 , dayCell.bounds.size.width -1, 12.0);
                    eventLabel.frame = CGRectMake(4, 1.5 , dayCell.bounds.size.width * restDays -5, 10.0);
                    //NSLog(@"%f",dayCell.bounds.size.width * restDays);
                }
            
                if ([eventDateStatus isEqualToString:@"endOnly"]) {
                    eventView.frame = CGRectMake(0, (labelHeight * numInt) + 3 , dayCell.bounds.size.width -1, 12.0);
                }
                
                if (![eventDateStatus isEqualToString:@"complete"]) {
                    eventView.backgroundColor = alphaColor;
                } else {
                    eventView.backgroundColor = [UIColor whiteColor];
                }
            
                if ([eventDateStatus isEqualToString:@"continue"] && weekDay == 1) {
                    eventLabel.text = event.title;
                    eventLabel.frame = CGRectMake(1, 1.5 , dayCell.bounds.size.width * restDaysContinue - 1, 10.0);
                }
            
                if ([eventDateStatus isEqualToString:@"endOnly"] && weekDay == 1) {
                    eventLabel.text = event.title;
                    eventLabel.frame = CGRectMake(1, 1.5 , dayCell.bounds.size.width -2, 10.0);
                }
            
                [eventView addSubview:eventLabel];
            
                [dayCell.contentView addSubview:eventView];
                
                if (!Holiday) {
                    if ([event.calendar.title  isEqual: @"日本の祝日"])
                    {
                        Holiday = YES;
                    }
                }
                
            } else if ([[events objectAtIndex:i] isKindOfClass:[EKReminder class]]) {
                //NSLog(@"reminder");
                EKReminder *reminder = [EKReminder reminderWithEventStore:_eventMg.sharedEventKitStore];
                reminder = [events objectAtIndex:i];
                
                NSNumber *num = [_rowIndexs objectForKey:reminder.calendarItemIdentifier];
                int numInt = num.intValue;
                //NSLog(@"num %d",numInt);
                
                UIView *eventView = [UIView new];
                eventView.layer.borderColor = [UIColor lightGrayColor].CGColor;
                eventView.frame = CGRectMake(1, (labelHeight * numInt) + 3 , dayCell.bounds.size.width - 2, 12.0);
                eventView.layer.borderWidth = 0.5f;
                eventView.tag = i + 2;
                eventView.backgroundColor = [UIColor colorWithCGColor:reminder.calendar.CGColor];
                //eventView.layer.cornerRadius = 2;
                
                UIView *leftSquareView = [UIView new];
                leftSquareView.frame = CGRectMake(3, 3, 6, 6);
                leftSquareView.backgroundColor = [UIColor whiteColor];
                
                
                UIView *checkBoxView = [UIView new];
                checkBoxView.frame = CGRectMake(3, 3, 6, 6);
                checkBoxView.backgroundColor = [UIColor whiteColor];
                //[leftSquareView addSubview:checkBoxView];
                
                UILabel *eventLabel = [UILabel new];
                eventLabel.textColor = [UIColor whiteColor];
                eventLabel.numberOfLines = 1;
                eventLabel.adjustsFontSizeToFitWidth = NO;
                eventLabel.lineBreakMode = NSLineBreakByClipping;
                eventLabel.font = [UIFont fontWithName:@"Helvetica" size:10.0f];
                eventLabel.text = reminder.title;
                eventLabel.frame = CGRectMake(12, 1.5 ,30.6, 10.0);
                
                [eventView addSubview:leftSquareView];
                [eventView addSubview:eventLabel];
                [dayCell addSubview:eventView];
            }
        }
    }
     */
    
    //三角の追加
    /*
    if (restRows > 0) {
        SBTriangleView *triangle = [[SBTriangleView alloc] initWithFrame:CGRectMake(31.6, 56, 14, 14)];
        UILabel *restRowsLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 5, 9, 9)];
        restRowsLabel.textColor = [UIColor whiteColor];
        NSString *restRowsLabelText = [NSString stringWithFormat:@"%ld",(long)restRows];
        restRowsLabel.text = restRowsLabelText;
        restRowsLabel.font = [UIFont fontWithName:@"Helvetica" size:9.0f];
        
        triangle.tag = 11;
        
        [triangle addSubview:restRowsLabel];
        [dayCell addSubview:triangle];
    }
     */
    
    NSDateComponents *cellDateComponents = [_calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit fromDate:cellDate];
    
    NSDateComponents *nowDateComponents = [_calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:_nowDate];
    
    /*
    //日付ラベル処理
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(1, 1, cellWidth-2,13)];
    //NSString *strYear = @(cellDateComponents.year).stringValue;
    NSString *strMonth = @(cellDateComponents.month).stringValue;
    NSString *strDay = @(cellDateComponents.day).stringValue;
    NSString *labelStr;
    
    //CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    if (cellDateComponents.day == 1) {
        labelStr = [NSString stringWithFormat:@"%@月%@日",strMonth,strDay];
    } else {
        labelStr = [NSString stringWithFormat:@"%@",strDay];
    }
    
    label.text = labelStr;
    label.font = [UIFont fontWithName:@"Helvetica-Bold" size:12.0f];
    label.numberOfLines = 1;
    label.adjustsFontSizeToFitWidth = NO;
    label.lineBreakMode = NSLineBreakByClipping;
    
    //土日の日付の文字色設定
    if (cellDateComponents.weekday == 1 || Holiday)
    {
        label.textColor = [UIColor redColor];
    } else if (cellDateComponents.weekday == 7)
    {
        label.textColor = [UIColor blueColor];
    }
    
    label.backgroundColor = [UIColor clearColor];
    label.tag = 1;
    
    [dayCell.contentView addSubview:label];
    */
     
    //日付が今日だった場合の処理
    if (nowDateComponents.year == cellDateComponents.year && nowDateComponents.month == cellDateComponents.month && nowDateComponents.day == cellDateComponents.day) {
        dayCell.backgroundColor = [UIColor colorWithRed:0.949 green:0.973 blue:0.992 alpha:1.0];
    }
    
    
    //セル背景色処理
    
    dayCell.backgroundColor = [UIColor whiteColor];
    
    BOOL isMonthEven = NO;
    
    //今月が偶数月かをチェック
    if (nowDateComponents.month % 2 == 0) {
        isMonthEven = YES;
    }
    
    if (isMonthEven) {
        if (cellDateComponents.month % 2 == 1) {
            dayCell.backgroundColor = [UIColor colorWithRed:0.973 green:0.973 blue:0.973 alpha:1.0];
        }
    } else {
        if (cellDateComponents.month % 2 == 0) {
            dayCell.backgroundColor = [UIColor colorWithRed:0.973 green:0.973 blue:0.973 alpha:1.0];
        }
    }
    
    
    /*
    if (cellDateComponents.month % 2 == 0) {
        //cell.backgroundColor = [UIColor grayColor];
        dayCell.backgroundColor = [UIColor colorWithRed:0.973 green:0.973 blue:0.973 alpha:1.0];
    }*/
    
    
    NSArray *array = [NSArray arrayWithArray:[collectionView indexPathsForVisibleItems]];
    NSArray *sortedIndexPaths = [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSIndexPath *path1 = (NSIndexPath *)obj1;
        NSIndexPath *path2 = (NSIndexPath *)obj2;
        return [path1 compare:path2];
    }];
    
    NSIndexPath *firstCellIndex = [sortedIndexPaths firstObject];
    
    NSDate *naviDate = [_calendar dateByAddingComponents:((^{
        NSDateComponents *datecomponents = [NSDateComponents new];
        datecomponents.day = firstCellIndex.item + 14;
        return datecomponents;
    })()) toDate:startDate options:0];
    
    NSDateComponents *naviDateComponents = [_calendar components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:naviDate];
    
    //ナビゲーションバータイトル設定
    NSInteger titleYear = naviDateComponents.year;
    NSInteger titleMonth = naviDateComponents.month;
    NSString *title = [[NSString alloc] initWithFormat:@"%ld年 %ld月",(long)titleYear,(long)titleMonth];
    
    _naviTitle.text = title;
    return dayCell;
}

//選択時の色変更
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    //cell.contentView.backgroundColor = [UIColor blueColor];
    //cell.layer.borderWidth = 1.0f;
    //cell.layer.borderColor = [UIColor colorWithRed:0.282 green:0.024 blue:0.647 alpha:1.0].CGColor;
    
    NSDate *cellDate = [_calendar dateByAddingComponents:((^{
        NSDateComponents *datecomponents = [NSDateComponents new];
        datecomponents.day = indexPath.item;
        return datecomponents;
    })()) toDate:startDate options:0];
    //NSLog(@"cellDate %@",cellDate);
    
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    NSInteger seconds = [timeZone secondsFromGMT];
    NSDate *gtmDate = [cellDate dateByAddingTimeInterval:-seconds];
    
    NSArray *events = [_sections objectForKey:gtmDate];
    //NSLog(@"events %@",events);
    
    if ([_listView isDescendantOfView:self.view]) {
        [_listView removeFromSuperview];
        _listView = [[dayListView alloc] initWithFrame:CGRectMake(0, _screenRect.size.height - 218, _screenRect.size.width, 210) sectionDate:cellDate rowArray:events];
        [self.view addSubview:_listView];
    } else {
        
        _listView = [[dayListView alloc] initWithFrame:CGRectMake(0, _screenRect.size.height - 44, _screenRect.size.width, 210) sectionDate:cellDate rowArray:events];
        _listView.tag = 10;
        [self.view addSubview:_listView];
        
        [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveLinear animations:^ {
            _listView.frame = CGRectMake(0, _screenRect.size.height - 218, _listView.frame.size.width, _listView.frame.size.height);
        } completion:^(BOOL finished){
        }];
    }
}

//選択終了時の色変更
-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.layer.borderWidth = 0.0f;
    //cell.contentView.backgroundColor = [UIColor whiteColor];
}

//スクロールアウトした際にセルの選択状態を解除
-(void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (cell.selected) {
        //cell.contentView.backgroundColor = [UIColor whiteColor];
        
        //[self collectionView:collectionView didDeselectItemAtIndexPath:indexPath];
        //cell.layer.borderWidth = 0.0f;
    }
    
    
    [[cell viewWithTag:1] removeFromSuperview];
    [[cell viewWithTag:2] removeFromSuperview];
    [[cell viewWithTag:3] removeFromSuperview];
    [[cell viewWithTag:4] removeFromSuperview];
    [[cell viewWithTag:5] removeFromSuperview];
    [[cell viewWithTag:6] removeFromSuperview];
    [[cell viewWithTag:11] removeFromSuperview];
    [[cell viewWithTag:12] removeFromSuperview];
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    //[_collectionView setAlpha:1.0f];
    //[monthlyLabel setAlpha:0.0f];
    //[monthlyLabel2 setAlpha:0.0f];
    //NSLog(@"end anime");
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    /*
     [_collectionView setAlpha:1.0f];
     [monthlyLabel setAlpha:0.0f];
     [monthlyLabel2 setAlpha:0.0f];
     */
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.dragging) {
        //[_collectionView setAlpha:0.5f];
        //[monthlyLabel setAlpha:1.0f];
        //[monthlyLabel2 setAlpha:1.0f];
        
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([_listView isDescendantOfView:self.view]) {
        [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveLinear animations:^ {
            _listView.frame = CGRectMake(0, _screenRect.size.height-44, _listView.frame.size.width, _listView.frame.size.height);
        } completion:^(BOOL finished){
            [_listView removeFromSuperview];
        }];
    }
    
}
 
@end
