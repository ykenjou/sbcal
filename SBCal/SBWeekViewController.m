//
//  SBWeekViewController.m
//  SBCal
//
//  Created by kenjou yutaka on 2014/05/21.
//  Copyright (c) 2014年 kenjou yutaka. All rights reserved.
//

#import "SBWeekViewController.h"

@interface SBWeekViewController ()

@property (nonatomic) CGRect screenRect;
@property (nonatomic) UILabel *naviTitle;
@property (nonatomic) UICollectionView *collectionView;
@property (nonatomic) NSCalendar *calendar;
@property (nonatomic) NSDate *startDate;
@property (nonatomic) NSDate *endDate;
@property (nonatomic) NSDate *nowDate;
@property (nonatomic) NSDate *nowDateZeroTime;
@property (nonatomic) NSInteger weeks;
@property (nonatomic) NSInteger nowWeeks;
@property (nonatomic) getEKData *ekDate;
@property (nonatomic) SBEventManager *eventMg;
@property (nonatomic) NSMutableDictionary *sections;
@property (nonatomic) NSArray *sortedDays;
@property (nonatomic) NSDateFormatter *timeDateFormat;

@end

@implementation SBWeekViewController

static NSString *cellIdentifier = @"cellIdentifier";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
        _eventMg = [SBEventManager sharedInstance];
        _timeDateFormat = [NSDateFormatter new];
        [_timeDateFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"US"]];
        [_timeDateFormat setDateFormat:@"H:mm"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    _nowDate = [NSDate date];
    _startDate = [DataUtility setStartDate:_nowDate];
    _endDate = [DataUtility setEndDate:_nowDate];
    
    NSDate *nowAdjustDate = [DataUtility adjustZeroClock:_nowDate withCalendar:_calendar];
    
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    NSInteger seconds = [timeZone secondsFromGMT];
    _nowDateZeroTime = [nowAdjustDate dateByAddingTimeInterval:seconds];
    
    NSInteger days = [DataUtility daysBetween:_startDate and:_nowDateZeroTime];
    
    NSLog(@"days %ld",(long)days / 7);
    
    NSDateComponents *nowDateComponents = [_calendar components:NSWeekOfYearCalendarUnit fromDate:_nowDateZeroTime];
    NSInteger nowWeekOfYear = [nowDateComponents weekOfYear];
    //NSLog(@"nowWeekOfYear %ld",(long)nowWeekOfYear);
    
    NSDateComponents *startDateComponents = [_calendar components:NSWeekOfYearCalendarUnit fromDate:_startDate];
    NSInteger startWeekOfYear = [startDateComponents weekOfYear];
    //NSLog(@"startWeekOfYear %ld",(long)startWeekOfYear);
    
    //NSLog(@"%@",_nowDateZeroTime);
    
    _nowWeeks = (long)days / 7;

    int weekUnit = NSWeekCalendarUnit;
    
    NSDateComponents *weekDateComponents = [_calendar components:weekUnit fromDate:_startDate toDate:_endDate options:0];
    
    _weeks = [weekDateComponents week];
    
    _screenRect = [[UIScreen mainScreen] bounds];
    
    UINavigationBar *naviBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 20, _screenRect.size.width, 44)];
    naviBar.delegate = self;
    
    UINavigationItem *item = [[UINavigationItem alloc] init];
    
    _naviTitle = [[UILabel alloc] init];
    _naviTitle.frame = CGRectMake(0, 0, 240, 44);
    _naviTitle.font = [UIFont fontWithName:@"Helvetica-Bold" size:17.0f];
    _naviTitle.textAlignment = NSTextAlignmentCenter;
    _naviTitle.textColor = [UIColor whiteColor];
    
    item.titleView = _naviTitle;
    
    naviBar.barTintColor = [UIColor colorWithRed:0.392 green:0.38 blue:0.812 alpha:1.0];
    naviBar.translucent = NO;
    
    //「今週」ボタンの表示
    UIBarButtonItem *todayButton = [[UIBarButtonItem alloc] initWithTitle:@"今週" style:UIBarButtonItemStyleBordered target:self action:@selector(toWeekScroll:)];
    todayButton.tintColor = [UIColor whiteColor];
    
    item.rightBarButtonItem = todayButton;
    
    [naviBar pushNavigationItem:item animated:NO];
    
    naviBar.tintColor = [UIColor whiteColor];
    
    naviBar.barTintColor = [UIColor colorWithRed:0.392 green:0.38 blue:0.812 alpha:1.0];
    naviBar.translucent = NO;
    
    [self.view addSubview:naviBar];
    
    SBWeekDayCollectionViewFlowLayout *collectionViewLayout = [SBWeekDayCollectionViewFlowLayout new];
    [collectionViewLayout setItemSize:CGSizeMake(_screenRect.size.width, _screenRect.size.height -20 -44 -44)];
    [collectionViewLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [collectionViewLayout setMinimumInteritemSpacing:0.0f];
    [collectionViewLayout setMinimumLineSpacing:0.0f];
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, _screenRect.size.width, _screenRect.size.height -20 -44 -44) collectionViewLayout:collectionViewLayout];

    //NSLog(@"%f",(_screenRect.size.height -20 -44 -44)/7);
    [_collectionView setDataSource:self];
    [_collectionView setDelegate:self];
    
    _collectionView.pagingEnabled = YES;
    
    [_collectionView setBackgroundColor:[UIColor whiteColor]];
    
    [_collectionView registerClass:[SBWeekDayVireCell class] forCellWithReuseIdentifier:cellIdentifier];
    
    [self.view addSubview:_collectionView];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_nowWeeks inSection:0];
    [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
    
    _ekDate = [getEKData new];
    _ekDate.delegate = self;
    
    [_ekDate EKDataDictionary:_eventMg.sharedEventKitStore];
    
    
}

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)toWeekScroll:(UIBarButtonItem *)btn
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_nowWeeks inSection:0];
    [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
}

-(void)dateReloadDelegate:(NSDictionary *)dictionary
{
    NSLog(@"week comp");
    _sections = [dictionary mutableCopy];
    _sortedDays = [_sections allKeys];
    
    [_collectionView reloadData];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_nowWeeks inSection:0];
    [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 0) {
        return _weeks;
    } else {
        return 0;
    }
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SBWeekDayVireCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    NSInteger viewHeight = 65.7f;
    NSInteger eventWidth = 70.0f;
    
    NSDate *cellDate = [_calendar dateByAddingComponents:((^{
        NSDateComponents *datecomponents = [NSDateComponents new];
        datecomponents.day = indexPath.item * 7;
        return datecomponents;
    })()) toDate:_startDate options:0];
    
    
    
    NSDateFormatter *dayFormatter = [NSDateFormatter new];
    dayFormatter.dateFormat = @"d";
    
    NSDateFormatter *monthDayFormatter = [NSDateFormatter new];
    monthDayFormatter.dateFormat = @"M/d";
    
    //NSDateFormatter *monthDayFormatterKanji = [NSDateFormatter new];
    //monthDayFormatter.dateFormat = @"M月d日";
    
    NSDateFormatter *yearMonthDayFormatter = [NSDateFormatter new];
    yearMonthDayFormatter.dateFormat = @"yyyy年M月d日";
    
    //NSLog(@"cellDate %@",cellDate);
    
    static NSString * const weekArray[] = {nil,@"（日）",@"（月）",@"（火）",@"（水）",@"（木）",@"（金）",@"（土）"};
    //static NSString * const weekArray[] = {nil,@"日",@"月",@"火",@"水",@"木",@"金",@"土"};
    
    for (int i = 0; i < 7; i++) {
        
        NSDate *viewDate = [_calendar dateByAddingComponents:((^{
            NSDateComponents *datecomponents = [NSDateComponents new];
            datecomponents.day = i;
            return datecomponents;
        })()) toDate:cellDate options:0];
        
        NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
        NSInteger seconds = [timeZone secondsFromGMT];
        NSDate *gtmDate = [viewDate dateByAddingTimeInterval:-seconds];
        
        NSArray *events = [_sections objectForKey:gtmDate];
        
        //NSLog(@"events ,%@",events);
        
        //NSLog(@"viewDate %@",viewDate);
        
        UIView *dayView = [[UIView alloc] initWithFrame:CGRectMake(0, viewHeight * i, _screenRect.size.width, viewHeight)];
        UIView *underLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _screenRect.size.width, 0.5)];
        underLine.backgroundColor = [UIColor lightGrayColor];
        [dayView addSubview:underLine];
        dayView.tag = 1 + i;
        
        UIView *dayBaseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, viewHeight)];
        
        UILabel *dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 40, 40)];
        dayLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:13.0f];
        
        
        NSString *dayString = [dayFormatter stringFromDate:viewDate];
        if ([dayString isEqualToString:@"1"]) {
            dayString = [monthDayFormatter stringFromDate:viewDate];
        }
        if (i == 0) {
            dayString = [monthDayFormatter stringFromDate:viewDate];
        }
        
        NSDateComponents *comps = [_calendar components:NSWeekdayCalendarUnit fromDate:viewDate];
        NSInteger weekday = comps.weekday;
        
        UIColor *dayAndWeekColor = [UIColor blackColor];
        switch (i) {
            case 0:
                dayAndWeekColor = [UIColor redColor];
                break;
            case 6:
                dayAndWeekColor = [UIColor blueColor];
                break;
            default:
                break;
        }
        
        if ([viewDate isEqualToDate:_nowDateZeroTime]) {
            dayAndWeekColor = [UIColor whiteColor];
            dayBaseView.backgroundColor = [UIColor colorWithRed:0.282 green:0.024 blue:0.647 alpha:1.0];
        
        }
        
        NSString *weekDayString = weekArray[weekday];
        UIFont *dayStringFont = [UIFont fontWithName:@"Helvetica" size:13.0f];
        UIFont *weekStringFont = [UIFont fontWithName:@"Helvetica" size:11.0f];
        
        NSAttributedString *dayAttribute = [[NSAttributedString alloc] initWithString:dayString attributes:@{NSForegroundColorAttributeName: dayAndWeekColor,NSFontAttributeName:dayStringFont}];
        
        NSAttributedString *weekAttribute = [[NSAttributedString alloc] initWithString:weekDayString attributes:@{NSForegroundColorAttributeName: dayAndWeekColor,NSFontAttributeName:weekStringFont}];
        
        NSAttributedString *newLine = [[NSAttributedString alloc] initWithString:@"\n"];
        
        NSMutableAttributedString *dayAndWeekString = [[NSMutableAttributedString alloc] initWithAttributedString:dayAttribute];
        [dayAndWeekString appendAttributedString:newLine];
        [dayAndWeekString appendAttributedString:weekAttribute];
        
        dayLabel.attributedText = dayAndWeekString;
        dayLabel.textAlignment = NSTextAlignmentCenter;
        dayLabel.numberOfLines = 0;
        [dayLabel sizeToFit];
        
        [dayBaseView addSubview:dayLabel];
        [dayView addSubview:dayBaseView];
        
        
        if (events) {
            for (int i = 0; i < [events count]; i++) {
                if ([[events objectAtIndex:i] isKindOfClass:[EKEvent class]]) {
                    EKEvent *event = [EKEvent eventWithEventStore:_eventMg.sharedEventKitStore];
                    event = [events objectAtIndex:i];
                    
                    UIView *eventView = [[UIView alloc] initWithFrame:CGRectMake(41 + eventWidth * i, 1, eventWidth -1, viewHeight - 2)];
                    
                    UIColor *eventColor = [UIColor colorWithCGColor:event.calendar.CGColor];
                    UIColor *alphaColor = [eventColor colorWithAlphaComponent:0.1];
                    
                    eventView.layer.borderColor = [UIColor lightGrayColor].CGColor;
                    eventView.layer.borderWidth = 0.5f;
                    eventView.backgroundColor = alphaColor;
                    //eventView.backgroundColor = [UIColor whiteColor];
                    
                    UIView *eventLeftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 4, viewHeight-2)];
                    eventLeftView.backgroundColor = eventColor;
                    
                    [eventView addSubview:eventLeftView];

                    UILabel *eventTitle = [[UILabel alloc] initWithFrame:CGRectMake(6, 2, eventWidth - 8, 10)];
                    eventTitle.text = event.title;
                    eventTitle.numberOfLines = 2;
                    eventTitle.lineBreakMode = NSLineBreakByCharWrapping;
                    eventTitle.font = [UIFont fontWithName:@"Helvetica-Bold" size:10.0f];
                    [eventTitle sizeToFit];
                    
                    NSDate *eventStartDate = [DataUtility dateAtBeginningOfDayForDate:event.startDate];
                    NSDate *eventEndDate = [DataUtility dateAtBeginningOfDayForDate:event.endDate];
                    
                    NSString *dateStatus = @"";
                    
                    //cellDateが開始日と終了日と同じ
                    if ([viewDate compare:eventStartDate] == NSOrderedSame && [viewDate compare:eventEndDate] == NSOrderedSame) {
                        dateStatus = @"complete";
                    }
                    
                    //cellDateが開始日のみ同じ
                    if ([viewDate compare:eventStartDate] == NSOrderedSame && [viewDate compare:eventEndDate] != NSOrderedSame) {
                        dateStatus = @"startDateOnly";
                    }
                    
                    //cellDateが終了日のみ同じ
                    if ([viewDate compare:eventStartDate] != NSOrderedSame && [viewDate compare:eventEndDate] == NSOrderedSame) {
                        dateStatus = @"endDateOnly";
                    }
                    
                    //cellDateが開始日でも終了日でもない
                    if ([viewDate compare:eventStartDate] != NSOrderedSame && [viewDate compare:eventEndDate] != NSOrderedSame) {
                        dateStatus = @"continue";
                    }
                    
                    UILabel *eventTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(6, viewHeight - 12, eventWidth - 8, 10)];
                    eventTimeLabel.font = [UIFont fontWithName:@"Helvetica" size:9.0f];
                    eventTimeLabel.textColor = [UIColor blackColor];
                    
                    NSString *eventCalendarTitle = event.calendar.title;
                    
                    if ([eventCalendarTitle isEqualToString:@"日本の祝日"])
                    {
                        eventTimeLabel.text = @"祝日";
                    } else if ([eventCalendarTitle isEqualToString:@"Birthdays"]) {
                        eventTimeLabel.text = @"誕生日";
                    } else if (event.allDay) {
                        eventTimeLabel.text = @"終日";
                    } else if ([dateStatus isEqualToString:@"continue"]) {
                        eventTimeLabel.text = @"継続";
                    } else {
                        
                        if ([dateStatus isEqualToString:@"complete"] || [dateStatus isEqualToString:@"startDateOnly"] || [dateStatus isEqualToString:@"endDateOnly"]) {
                            
                            NSString *startTime;
                            NSString *endTime;
                            
                            if ([dateStatus isEqualToString:@"complete"]) {
                                startTime = [_timeDateFormat stringFromDate:event.startDate];
                                endTime = [_timeDateFormat stringFromDate:event.endDate];
                            }
                            
                            if ([dateStatus isEqualToString:@"startDateOnly"]) {
                                startTime = [_timeDateFormat stringFromDate:event.startDate];
                                endTime = @"継続";
                            }
                            
                            if ([dateStatus isEqualToString:@"endDateOnly"]) {
                                startTime = @"終了";
                                endTime = [_timeDateFormat stringFromDate:event.endDate];
                            }
                            
                            NSAttributedString *startAttributeTime = [[NSAttributedString alloc] initWithString:startTime attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
                            
                            NSAttributedString *endAttributeTime = [[NSAttributedString alloc] initWithString:endTime attributes:@{NSForegroundColorAttributeName: [UIColor grayColor]}];
                            
                            NSAttributedString *newLine = [[NSAttributedString alloc] initWithString:@"〜"];
                            
                            NSMutableAttributedString *timeString = [[NSMutableAttributedString alloc] initWithAttributedString:startAttributeTime];
                            [timeString appendAttributedString:newLine];
                            [timeString appendAttributedString:endAttributeTime];
                            eventTimeLabel.attributedText = timeString;
                        }
                    }

                    
                    [eventView addSubview:eventTimeLabel];
                    [eventView addSubview:eventTitle];
                    [dayView addSubview:eventView];
                    
                } else if ([[events objectAtIndex:i] isKindOfClass:[EKReminder class]]) {
                    EKReminder *reminder = [EKReminder reminderWithEventStore:_eventMg.sharedEventKitStore];
                    reminder = [events objectAtIndex:i];
                }
            }
        }
        
        
        [cell.contentView addSubview:dayView];
    }
    
    NSDateComponents *cellDateComponents = [_calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:cellDate];
    NSInteger cellDateDay = cellDateComponents.day;
    NSInteger cellDateMonth = cellDateComponents.month;
    NSInteger cellDateYear = cellDateComponents.year;
    
    NSDate *cellEndDate = [_calendar dateByAddingComponents:((^{
        NSDateComponents *datecomponents = [NSDateComponents new];
        datecomponents.day = 6;
        return datecomponents;
    })()) toDate:cellDate options:0];
    
    NSDateComponents *cellEndDateComponents = [_calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:cellEndDate];
    
    NSInteger cellEndDateDay = cellEndDateComponents.day;
    NSInteger cellEndDateMonth = cellEndDateComponents.month;
    //NSInteger cellEndDateYear = cellEndDateComponents.year;
    
    
    if (cellDateMonth == cellEndDateMonth) {
        NSString *sameMonthTitle = [[NSString alloc] initWithFormat:@"%ld年 %ld月%ld日 〜 %ld日",(long)cellDateYear, (long)cellDateMonth,(long)cellDateDay,(long)cellEndDateDay];
        
        _naviTitle.text = sameMonthTitle;
    }
    
    if (cellDateMonth != cellEndDateMonth) {
        NSString *difMonthTitle = [[NSString alloc] initWithFormat:@"%ld年 %ld月%ld日 〜 %ld月%ld日",(long)cellDateYear ,(long)cellDateMonth,(long)cellDateDay,(long)cellEndDateMonth, (long)cellEndDateDay];
        
        _naviTitle.text = difMonthTitle;
    }
    
    
    //NSLog(@"cellEnd %@",cellEndDate);
    
    return cell;
}

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
    [[cell viewWithTag:7] removeFromSuperview];
    [[cell viewWithTag:8] removeFromSuperview];
    [[cell viewWithTag:9] removeFromSuperview];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
