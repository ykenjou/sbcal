//
//  calendarDayCell.m
//  fascal
//
//  Created by kenjou yutaka on 2014/02/14.
//  Copyright (c) 2014年 kenjou yutaka. All rights reserved.
//

#import "calendarDayCell.h"
#import <QuartzCore/QuartzCore.h>

@interface calendarDayCell ()
@property (nonatomic,readonly,strong) UIImageView *imageView;
@property (nonatomic,readonly,strong) UIView *overlayView;

@end

@implementation calendarDayCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.restorationIdentifier = @"cellIdentifier";
        
        CGFloat borderWidth = 0.5f;
        CGRect myContetRect = CGRectInset(self.contentView.bounds, -borderWidth, -borderWidth);
        
        CGFloat borderBgWidth = 0.5f;
        CGRect myContetBgRect = CGRectInset(self.contentView.bounds, -borderBgWidth, -borderBgWidth);
        
        UIView *bgview = [[UIView alloc] initWithFrame:myContetBgRect];
        bgview.layer.borderColor = [UIColor blueColor].CGColor;
        bgview.layer.borderWidth = borderBgWidth;
        //self.selectedBackgroundView = bgview;
        
        UIView *myContentView = [[UIView alloc] initWithFrame:myContetRect];
        myContentView.layer.borderColor = [UIColor colorWithRed:0.588 green:0.588 blue:0.588 alpha:1.0].CGColor;
        myContentView.layer.borderWidth = borderWidth;
        [self.contentView addSubview:myContentView];
        
    }
    return self;
}

-(void)setDate:(NSDate *)date nowDate:(NSDate *)nowDate events:(NSArray *)events rowIndexs:(NSMutableDictionary *)rowIndexs eventStore:(EKEventStore *)eventStore
{
    _cellDate = date;
    _nowDate = nowDate;
    _events = events;
    _rowIndexs = rowIndexs;
    _eventStore = eventStore;
    
    [self setNeedsDisplay];
}

-(void)prepareForReuse
{
    [super prepareForReuse];
}

/*
-(void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    [self setNeedsDisplay];
}
 */


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    /*
    NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    BOOL Holiday = NO;
    NSDateComponents *weekDayComp = [calendar components:NSWeekdayCalendarUnit fromDate:_cellDate];
    NSInteger weekDay = weekDayComp.weekday;
    
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    float labelHeight = 13.0f;
    
    NSInteger rows = 0;
    NSInteger restRows = 0;
    if ([_events count] > 4) {
        rows = 4;
        restRows = [_events count] - 4;
    } else {
        rows = [_events count];
    }
    
    //日付ラベル処理
    NSDateComponents *cellDateComponents = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit fromDate:_cellDate];
    
    NSDateComponents *nowDateComponents = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:_nowDate];
    
    UILabel *dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(1, 1, self.bounds.size.width - 2,13)];
    //NSString *strYear = @(cellDateComponents.year).stringValue;
    NSString *strMonth = @(cellDateComponents.month).stringValue;
    NSString *strDay = @(cellDateComponents.day).stringValue;
    NSString *labelStr;
    
    if (cellDateComponents.day == 1) {
        labelStr = [NSString stringWithFormat:@"%@月%@日",strMonth,strDay];
    } else {
        labelStr = [NSString stringWithFormat:@"%@",strDay];
    }
    
    dayLabel.text = labelStr;
    dayLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12.0f];
    dayLabel.numberOfLines = 1;
    dayLabel.adjustsFontSizeToFitWidth = NO;
    dayLabel.lineBreakMode = NSLineBreakByClipping;
    
    //土日の日付の文字色設定
    if (cellDateComponents.weekday == 1 || Holiday)
    {
        dayLabel.textColor = [UIColor redColor];
    } else if (cellDateComponents.weekday == 7)
    {
        dayLabel.textColor = [UIColor blueColor];
    }
    
    dayLabel.backgroundColor = [UIColor clearColor];
    dayLabel.tag = 1;
    
    //日付が今日だった場合の処理
    if (nowDateComponents.year == cellDateComponents.year && nowDateComponents.month == cellDateComponents.month && nowDateComponents.day == cellDateComponents.day) {
        //self.contentView.backgroundColor = [UIColor colorWithRed:0.949 green:0.973 blue:0.992 alpha:1.0];
        dayLabel.backgroundColor = [UIColor colorWithRed:0.282 green:0.024 blue:0.647 alpha:1.0];
        dayLabel.textColor = [UIColor whiteColor];
    }
    
    
    [self.contentView addSubview:dayLabel];
    
    self.backgroundColor = [UIColor whiteColor];
    
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    NSInteger seconds = [timeZone secondsFromGMT];
    
    if (_events) {
        for (int i = 0; i < rows; i++) {
            
            if ([[_events objectAtIndex:i] isKindOfClass:[EKEvent class]]) {
                EKEvent *event = [EKEvent eventWithEventStore:_eventStore];
                event = [_events objectAtIndex:i];
                
                
                NSString *title = event.title;
                UIFont *font = [UIFont fontWithName:@"Helvetica" size:10.0f];
                NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
                style.lineBreakMode = NSLineBreakByTruncatingTail;
                style.alignment = NSTextAlignmentLeft;
                
                NSDictionary *attribute = @{NSForegroundColorAttributeName: [UIColor blackColor],
                                            NSFontAttributeName: font,
                                            NSParagraphStyleAttributeName: style
                                            };
                
                [title drawInRect:CGRectMake(0, labelHeight * i + 13, 100, 10) withAttributes:attribute];
     
                
                //NSLog(@"event %@" ,event);
                NSDate *eventStartDate = [[DataUtility dateAtBeginningOfDayForDate:event.startDate] dateByAddingTimeInterval:seconds];
                NSDate *eventEndDate = [[DataUtility dateAtBeginningOfDayForDate:event.endDate] dateByAddingTimeInterval:seconds];
                
                NSInteger restDays = [DataUtility daysBetween:eventStartDate and:eventEndDate]+1;
                NSInteger restDaysContinue = [DataUtility daysBetween:_cellDate and:eventEndDate]+1;
                
                //NSLog(@"cellDate %@ restDays %d",cellDate,restDays);
                
                NSString *eventDateStatus = @"";
                if ([eventStartDate compare:_cellDate] == NSOrderedSame && [eventEndDate compare:_cellDate] == NSOrderedSame) {
                    eventDateStatus = @"complete";
                }
                if ([eventStartDate compare:_cellDate] == NSOrderedSame && [eventEndDate compare:_cellDate] != NSOrderedSame) {
                    eventDateStatus = @"startOnly";
                }
                if ([eventStartDate compare:_cellDate] != NSOrderedSame && [eventEndDate compare:_cellDate] == NSOrderedSame) {
                    eventDateStatus = @"endOnly";
                }
                if ([eventStartDate compare:_cellDate] != NSOrderedSame && [eventEndDate compare:_cellDate] !=NSOrderedSame) {
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
                    eventView.frame = CGRectMake(1, (labelHeight * numInt) + 3 , self.bounds.size.width - 2, 12.0);
                    eventView.layer.borderWidth = 0.5f;
                    eventLabel.frame = CGRectMake(4, 1.5 , 38.6, 10.0);
                }
                
                if ([eventDateStatus isEqualToString:@"continue"]) {
                    eventView.frame = CGRectMake(0, (labelHeight * numInt) + 3 , self.bounds.size.width, 12.0);
                    //[dayCell sendSubviewToBack:eventView];
                }
                
                if ([eventDateStatus isEqualToString:@"startOnly"]) {
                    eventView.frame = CGRectMake(1, (labelHeight * numInt) + 3 , self.bounds.size.width -1, 12.0);
                    eventLabel.frame = CGRectMake(4, 1.5 , self.bounds.size.width * restDays -5, 10.0);
                    //NSLog(@"%f",dayCell.bounds.size.width * restDays);
                }
                
                if ([eventDateStatus isEqualToString:@"endOnly"]) {
                    eventView.frame = CGRectMake(0, (labelHeight * numInt) + 3 , self.bounds.size.width -1, 12.0);
                }
                
                if (![eventDateStatus isEqualToString:@"complete"]) {
                    eventView.backgroundColor = alphaColor;
                } else {
                    eventView.backgroundColor = [UIColor whiteColor];
                }
                
                if ([eventDateStatus isEqualToString:@"continue"] && weekDay == 1) {
                    eventLabel.text = event.title;
                    eventLabel.frame = CGRectMake(1, 1.5 , self.bounds.size.width * restDaysContinue - 1, 10.0);
                }
                
                if ([eventDateStatus isEqualToString:@"endOnly"] && weekDay == 1) {
                    eventLabel.text = event.title;
                    eventLabel.frame = CGRectMake(1, 1.5 , self.bounds.size.width -2, 10.0);
                }
                
                [eventView addSubview:eventLabel];
                
                [self.contentView addSubview:eventView];
                
                
                if (!Holiday) {
                    if ([event.calendar.title  isEqual: @"日本の祝日"])
                    {
                        Holiday = YES;
                    }
                }
                
            } else if ([[_events objectAtIndex:i] isKindOfClass:[EKReminder class]]) {
                //NSLog(@"reminder");
                
                EKReminder *reminder = [EKReminder reminderWithEventStore:_eventStore];
                reminder = [_events objectAtIndex:i];
                
                NSNumber *num = [_rowIndexs objectForKey:reminder.calendarItemIdentifier];
                int numInt = num.intValue;
                //NSLog(@"num %d",numInt);
                
                UIView *eventView = [UIView new];
                eventView.layer.borderColor = [UIColor lightGrayColor].CGColor;
                eventView.frame = CGRectMake(1, (labelHeight * numInt) + 3 , self.bounds.size.width - 2, 12.0);
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
                [self.contentView addSubview:eventView];
                
            }
        }
    }
    
    //三角の追加
    if (restRows > 0) {
        SBTriangleView *triangle = [[SBTriangleView alloc] initWithFrame:CGRectMake(31.6, 56, 14, 14)];
        UILabel *restRowsLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 5, 9, 9)];
        restRowsLabel.textColor = [UIColor whiteColor];
        NSString *restRowsLabelText = [NSString stringWithFormat:@"%ld",(long)restRows];
        restRowsLabel.text = restRowsLabelText;
        restRowsLabel.font = [UIFont fontWithName:@"Helvetica" size:9.0f];
        
        triangle.tag = 11;
        
        [triangle addSubview:restRowsLabel];
        [self.contentView addSubview:triangle];
    }
    */
    
}


@end
