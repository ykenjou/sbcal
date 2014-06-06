//
//  SBListViewController.m
//  SBCal
//
//  Created by kenjou yutaka on 2014/05/21.
//  Copyright (c) 2014年 kenjou yutaka. All rights reserved.
//

#import "SBListViewController.h"

@interface SBListViewController ()

@property(nonatomic) UITableView *tableView;
@property(strong,nonatomic) NSTimer *handleTimer;

@end

@implementation SBListViewController

float sectionHeight = 28.0f;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //_eventStore = [EKEventStore new];
        _eventMg = [SBEventManager sharedInstance];
        _ekData = [getEKData new];
        _eventCalendar = [EKCalendar calendarForEntityType:EKEntityTypeEvent eventStore:_eventMg.sharedEventKitStore];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    UINavigationBar *naviBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 20, screenRect.size.width, 44)];
    naviBar.delegate = self;
    
    UINavigationItem *item = [[UINavigationItem alloc] init];
    
    UILabel *title = [[UILabel alloc] init];
    title.frame = CGRectMake(0, 0, 200, 44);
    title.text = @"予定リスト";
    title.font = [UIFont fontWithName:@"Helvetica-Bold" size:17.0f];
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor whiteColor];
    
    item.titleView = title;

    //「今日」ボタンの表示
    UIBarButtonItem *todayButton = [[UIBarButtonItem alloc] initWithTitle:@"今日" style:UIBarButtonItemStyleBordered target:self action:@selector(todayScroll:)];
    todayButton.tintColor = [UIColor whiteColor];
    
    item.rightBarButtonItem = todayButton;
    
    [naviBar pushNavigationItem:item animated:NO];
    
    //naviBar.tintColor = [UIColor whiteColor];
    
    naviBar.barTintColor = [UIColor colorWithRed:0.392 green:0.38 blue:0.812 alpha:1.0];
    naviBar.translucent = NO;
     
    [self.view addSubview:naviBar];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, screenRect.size.width, screenRect.size.height - 44 - 44 - 20) style:UITableViewStylePlain];
    _tableView.delegate =self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    _tableView.showsVerticalScrollIndicator = NO;
    
    //ナビゲーションバー非透過設定
    self.navigationController.navigationBar.translucent = NO;
    
    //タブバー非透過設定
    self.tabBarController.tabBar.translucent = NO;
    
    calendarAccessCheck *check = [calendarAccessCheck new];
    [check EKAccessCheck];
    
    self.sections = [_ekData EKDataDictionary:_eventMg.sharedEventKitStore];
    
    NSArray *unsortedDays = [self.sections allKeys];
    //NSLog(@"unsort : %@",[unsortedDays description]);
    
    NSDate *now = [NSDate date];
    NSDate *nowZeroTime = [DataUtility dateAtBeginningOfDayForDate:now];
    
    //NSLog(@"nowzero %@",nowZeroTime);
    
    _isNowDate = [unsortedDays containsObject:nowZeroTime];
    //NSLog(@"isNowDate %hhd",_isNowDate);
    
    
    if (!_isNowDate) {
        EKEvent *nowEnptyEvent = [EKEvent eventWithEventStore:_eventMg.sharedEventKitStore];
        [nowEnptyEvent setTitle:@"予定が登録されていません"];
        [nowEnptyEvent setAllDay:YES];
        NSMutableArray *nowEnptyArray = [NSMutableArray arrayWithObject:nowEnptyEvent];
        [_sections setObject:nowEnptyArray forKey:nowZeroTime];
        unsortedDays = [_sections allKeys];
    }
    
    self.sortedDays = [unsortedDays sortedArrayUsingSelector:@selector(compare:)];
    
    _nowDayObjectIndex = [_sortedDays indexOfObject:nowZeroTime];
    
    //NSLog(@"sortedDays %@",[self.sortedDays description]);
    
    //NSLog(@"ekDictionary = %@",[self.sections description]);
    
    //NSLog(@"_nowdayIndex %d",_nowDayObjectIndex);
    
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeftTab:)];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRightTab:)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipeRight];
    
    
    //初期スクロール設定
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:_nowDayObjectIndex];
    [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
}

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

-(void)swipeLeftTab:(id)sendar
{
    NSUInteger selectedIndex = [self.tabBarController selectedIndex];
    [self.tabBarController setSelectedIndex:selectedIndex+1];
}

-(void)swipeRightTab:(id)sendar
{
    NSLog(@"swipeRight");
}

-(void)todayScroll:(UIBarButtonItem *)btn
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:_nowDayObjectIndex];
    [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

//viewの表示直前の処理
-(void)viewWillAppear:(BOOL)animated
{
    [self calendarChangeNotification];
    [super viewWillAppear:animated];
}

-(void)calendarChangeNotification
{
    [_eventMg.sharedEventKitStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (granted) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:EKEventStoreChangedNotification object:_eventMg.sharedEventKitStore];
        }
    }];
}

-(void)handleNotification:(NSNotification *)note
{
    [_handleTimer invalidate];
    _handleTimer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(reloadTable:) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:_handleTimer forMode:NSDefaultRunLoopMode];
}

-(void)reloadTable:(NSNotification *)notification
{
    _sections = [_ekData EKDataDictionary:_eventMg.sharedEventKitStore];
    
    NSArray *unsortedDays = [_sections allKeys];
    
    NSDate *now = [NSDate date];
    NSDate *nowZeroTime = [DataUtility dateAtBeginningOfDayForDate:now];
    
    _isNowDate = [unsortedDays containsObject:nowZeroTime];
    //NSLog(@"isNowDate %hhd",_isNowDate);
    
    if (!_isNowDate) {
        EKEvent *nowEnptyEvent = [EKEvent eventWithEventStore:_eventMg.sharedEventKitStore];
        [nowEnptyEvent setTitle:@"予定が登録されていません"];
        [nowEnptyEvent setAllDay:YES];
        NSMutableArray *nowEnptyArray = [NSMutableArray arrayWithObject:nowEnptyEvent];
        [_sections setObject:nowEnptyArray forKey:nowZeroTime];
        unsortedDays = [_sections allKeys];
    }
    
    _sortedDays = [unsortedDays sortedArrayUsingSelector:@selector(compare:)];
    
    _nowDayObjectIndex = [_sortedDays indexOfObject:nowZeroTime];
    
    NSLog(@"reloadTable");
    
    [self.tableView reloadData];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sections count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDate *dateRepresentingThisDay = [self.sortedDays objectAtIndex:section];
    NSArray *eventsOnThisDay = [self.sections objectForKey:dateRepresentingThisDay];
    return [eventsOnThisDay count];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSDateFormatter *ymdFormatter = [NSDateFormatter new];
    ymdFormatter.dateFormat = @"yyyy年 M月d日";
    
    NSDateFormatter *mdFormatter = [NSDateFormatter new];
    mdFormatter.dateFormat = @"M月d日";
    
    NSDateFormatter *yearFormatter = [NSDateFormatter new];
    yearFormatter.dateFormat = @"yyyy";
    
    NSDate *now = [NSDate date];
    NSDate *nextDate = [NSDate dateWithTimeIntervalSinceNow:24*60*60];
    NSString *nextDateString = [ymdFormatter stringFromDate:nextDate];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *nowComps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit fromDate:now];
    NSInteger calWeekDay = nowComps.weekday;
    //NSLog(@"calweekDay,%d",calWeekDay);
    
    NSString *nowDateString = [ymdFormatter stringFromDate:now];
    NSString *nowYear = [yearFormatter stringFromDate:now];
    
    UIView *sectionView = [UIView new];
    UIColor *sectionBackColor = [UIColor colorWithRed:0.969 green:0.969 blue:0.969 alpha:1.0f];
    sectionView.backgroundColor = sectionBackColor;
    sectionView.frame = CGRectMake(0, 0, 320.0f, sectionHeight);
    
    NSDate *dateRepresentingThisDay = [self.sortedDays objectAtIndex:section];
    
    NSArray *eventsOnThisDay = [self.sections objectForKey:dateRepresentingThisDay];
    
    //NSLog(@"eventsOnThisDay %@",[eventsOnThisDay description]);
    
    
    BOOL HoliDay;
    NSString *calendarTitle;
    EKEvent *event;
    event = [eventsOnThisDay firstObject];
    calendarTitle = event.calendar.title;
    //NSLog(@"calendarTitle : %@",calendarTitle);
    
    HoliDay = YES;
    
    for (int i = 0;i < [eventsOnThisDay count];i++) {
        event = [eventsOnThisDay objectAtIndex:i];
        calendarTitle = event.calendar.title;
        if ([calendarTitle isEqualToString: @"日本の祝日"]) {
            HoliDay = YES;
            break;
        } else {
            HoliDay = NO;
        }
    }
    
    NSString *ThisDayString = [ymdFormatter stringFromDate:dateRepresentingThisDay];
    NSString *ThisYearString = [yearFormatter stringFromDate:dateRepresentingThisDay];
    //NSLog(@"thisDayString %@",ThisDayString);
    
    NSString *daySubString;
    
    if ([nowDateString isEqualToString:ThisDayString])
    {
        daySubString = @"今日の予定";
    } else if ([nextDateString isEqualToString:ThisDayString]) {
        daySubString = @"明日の予定";
    } else {
          daySubString = @"";
      }
    
    BOOL thisYear;
    
    if ([nowYear isEqualToString:ThisYearString]) {
        thisYear = YES;
    } else {
        thisYear = NO;
    }
    
    
    NSDateComponents *comps = [calendar components:NSWeekdayCalendarUnit fromDate:dateRepresentingThisDay];
    NSInteger weekday = comps.weekday;
    static NSString * const weekArray[] = {nil,@"（日）",@"（月）",@"（火）",@"（水）",@"（木）",@"（金）",@"（土）"};
    
    static NSString * const weekArrayHoliday[] = {nil,@"（日･祝）",@"（月･祝）",@"（火･祝）",@"（水･祝）",@"（木･祝）",@"（金･祝）",@"（土･祝）"};
    
    if (weekday > 7) {
        weekday = 0;
    }
    
    NSString *dateString;
    
    if (thisYear) {
        dateString = [mdFormatter stringFromDate:dateRepresentingThisDay];
    } else {
        dateString = [ymdFormatter stringFromDate:dateRepresentingThisDay];
    }
    
    NSString *weekdayString;
    
    if (HoliDay) {
        weekdayString = weekArrayHoliday[weekday];
    } else {
        weekdayString = weekArray[weekday];
    }
    
    //NSString *weekdayString = weekArray[weekday];
    NSString *dateWeekString = [NSString stringWithFormat:@"%@%@ %@",dateString,weekdayString,daySubString];
    
    UILabel *sectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 310.0f, sectionHeight)];
    /* if ([nowDateString isEqualToString:ThisDayString]){
        sectionLabel.textColor = [UIColor colorWithRed:0.282 green:0.024 blue:0.647 alpha:1.0];
    } else */if (weekday == 1|| HoliDay) {
        sectionLabel.textColor = [UIColor redColor];
    } else if (weekday == 7) {
        sectionLabel.textColor = [UIColor blueColor];
    } else {
        sectionLabel.textColor = [UIColor blackColor];
    }
    sectionLabel.text = dateWeekString;
    sectionLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0f];
    
    [sectionView addSubview:sectionLabel];
    return sectionView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return sectionHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    NSDate *cellDate = [self.sortedDays objectAtIndex:indexPath.section];
    NSArray *eventsOnThisDay = [self.sections objectForKey:cellDate];
    EKEvent *event = [eventsOnThisDay objectAtIndex:indexPath.row];
    
    _eventCalendar = event.calendar;
    
    //EKCalendar *calendar = event.calendar;
    NSString *eventCalendarTitle = _eventCalendar.title;
    UIColor *eventCalendarColor = [UIColor colorWithCGColor:_eventCalendar.CGColor];
    
    NSDate *eventStartDate = [DataUtility dateAtBeginningOfDayForDate:event.startDate];
    NSDate *eventEndDate = [DataUtility dateAtBeginningOfDayForDate:event.endDate];
    
    //NSLog(@"cellDate %@ startDate %@ endDate %@",cellDate,eventStartDate,eventEndDate);
    
    NSString *dateStatus = @"";
    
    //cellDateが開始日と終了日と同じ
    if ([cellDate compare:eventStartDate] == NSOrderedSame && [cellDate compare:eventEndDate] == NSOrderedSame) {
        dateStatus = @"complete";
    }
    
    //cellDateが開始日のみ同じ
    if ([cellDate compare:eventStartDate] == NSOrderedSame && [cellDate compare:eventEndDate] != NSOrderedSame) {
        dateStatus = @"startDateOnly";
    }
    
    //cellDateが終了日のみ同じ
    if ([cellDate compare:eventStartDate] != NSOrderedSame && [cellDate compare:eventEndDate] == NSOrderedSame) {
        dateStatus = @"endDateOnly";
    }
    
    //cellDateが開始日でも終了日でもない
    if ([cellDate compare:eventStartDate] != NSOrderedSame && [cellDate compare:eventEndDate] != NSOrderedSame) {
        dateStatus = @"continue";
    }
    
    UILabel *eventTitle = [[UILabel alloc] initWithFrame:CGRectMake(85, 13, 200, 20)];
    UIFont *eventTitleFont = [UIFont fontWithName:@"Helvetica" size:15.0f];
    eventTitle.font = eventTitleFont;
    eventTitle.textColor = [UIColor blackColor];
    eventTitle.text = event.title;
    eventTitle.numberOfLines = 1;
    eventTitle.tag = 1;
    eventTitle.lineBreakMode = NSLineBreakByTruncatingTail;
    //eventTitle.backgroundColor = [UIColor grayColor];
    [eventTitle sizeToFit];
    
    float timeWidth = 45.0f;
    //static float timeMarginLeft = 10.0f;
    //static float blockMarginLeft = 10.0f;
    
    UILabel *eventTimeLabel = [[UILabel alloc] init];
    UIFont * eventTimeLabelFont = [UIFont fontWithName:@"Helvetica" size:12.0f];
    eventTimeLabel.font = eventTimeLabelFont;
    eventTimeLabel.textColor = [UIColor blackColor];
    eventTimeLabel.tag = 2;
    //eventTimeLabel.backgroundColor = [UIColor grayColor];
    
    NSDateFormatter *timeDateFormat = [NSDateFormatter new];
    [timeDateFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"US"]];
    
    [timeDateFormat setDateFormat:@"H:mm"];
    
    BOOL oneLineTime = NO;
    
    if ([eventCalendarTitle isEqualToString:@"日本の祝日"])
    {
        eventTimeLabel.text = @"祝日";
        oneLineTime = YES;
    } else if ([_eventCalendar.title isEqualToString:@"Birthdays"]) {
        eventTimeLabel.text = @"誕生日";
        oneLineTime = YES;
    } else if (event.allDay) {
        eventTimeLabel.text = @"終日";
        oneLineTime = YES;
    } else if ([dateStatus isEqualToString:@"continue"]) {
        eventTimeLabel.text = @"継続";
        oneLineTime = YES;
    } else {
        
        if ([dateStatus isEqualToString:@"complete"] || [dateStatus isEqualToString:@"startDateOnly"] || [dateStatus isEqualToString:@"endDateOnly"]) {
            
            NSString *startTime;
            NSString *endTime;
        
            if ([dateStatus isEqualToString:@"complete"]) {
                startTime = [timeDateFormat stringFromDate:event.startDate];
                endTime = [timeDateFormat stringFromDate:event.endDate];
            }
        
            if ([dateStatus isEqualToString:@"startDateOnly"]) {
                startTime = [timeDateFormat stringFromDate:event.startDate];
                endTime = @"継続";
            }
        
            if ([dateStatus isEqualToString:@"endDateOnly"]) {
                startTime = @"終了";
                endTime = [timeDateFormat stringFromDate:event.endDate];
            }
        
            NSAttributedString *startAttributeTime = [[NSAttributedString alloc] initWithString:startTime attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
        
            NSAttributedString *endAttributeTime = [[NSAttributedString alloc] initWithString:endTime attributes:@{NSForegroundColorAttributeName: [UIColor grayColor]}];
        
            NSAttributedString *newLine = [[NSAttributedString alloc] initWithString:@"\n"];
        
            NSMutableAttributedString *timeString = [[NSMutableAttributedString alloc] initWithAttributedString:startAttributeTime];
            [timeString appendAttributedString:newLine];
            [timeString appendAttributedString:endAttributeTime];
            eventTimeLabel.attributedText = timeString;
        }
    }
    eventTimeLabel.numberOfLines = 0;
    [eventTimeLabel sizeToFit];
    
    if (oneLineTime) {
        eventTimeLabel.frame = CGRectMake(5, 15, timeWidth, eventTimeLabel.frame.size.height);
    } else {
        eventTimeLabel.frame = CGRectMake(5, 9, timeWidth, eventTimeLabel.frame.size.height);
    }
    eventTimeLabel.textAlignment = NSTextAlignmentRight;
    
    UIImage *circle = [self imageWithColor:eventCalendarColor];
    UIImageView *circleView = [[UIImageView alloc] initWithImage:circle];
    circleView.center = CGPointMake(70, 22);
    circleView.tag = 3;
    
    if (event.location) {
        UILabel *locationTitle = [[UILabel alloc] initWithFrame:CGRectMake(85, 32, 200, 20)];
        locationTitle.text = event.location;
        locationTitle.numberOfLines = 1;
        locationTitle.font = [UIFont fontWithName:@"Helvetica" size:12.0f];
        locationTitle.tag = 4;
        [cell addSubview:locationTitle];
        
        UIImage *mapIcon = [UIImage imageNamed:@"map.png"];
        UIImageView *mapIconView = [[UIImageView alloc] initWithImage:mapIcon];
        mapIconView.frame = CGRectMake(67, 37, 7, 10);
        mapIconView.tag = 5;
        [cell addSubview:mapIconView];
    }
    
    [cell addSubview:circleView];
    [cell addSubview:eventTitle];
    [cell addSubview:eventTimeLabel];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cell touch");
}

-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[cell viewWithTag:1] removeFromSuperview];
    [[cell viewWithTag:2] removeFromSuperview];
    [[cell viewWithTag:3] removeFromSuperview];
    [[cell viewWithTag:4] removeFromSuperview];
    [[cell viewWithTag:5] removeFromSuperview];
}

/*
 -(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
 {
 return 55.0f;
 }
 */

-(UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 10, 10);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
