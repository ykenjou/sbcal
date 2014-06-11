//
//  dayListView.m
//  LisCal
//
//  Created by kenjou yutaka on 2014/05/10.
//  Copyright (c) 2014年 kenjou yutaka. All rights reserved.
//

#import "dayListView.h"
#import "DataUtility.h"
#import <EventKit/EventKit.h>

@interface dayListView()

@property (nonatomic) UITableView *tableView;

@end

@implementation dayListView

- (id)initWithFrame:(CGRect)frame sectionDate:(NSDate *)date rowArray:(NSArray *)array
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _screenRect = [[UIScreen mainScreen] bounds];
        _sectionDate = date;
        _rowArray = array;
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, _screenRect.size.width, 174) style:UITableViewStylePlain];
        //self.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
        //_tableView.backgroundColor = [UIColor colorWithRed:0.392 green:0.600 blue:0.922 alpha:1.0f];
        //_tableView.bounces = NO;
        UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _screenRect.size.width, 0.5f)];
        topView.backgroundColor = [UIColor grayColor];
        [self addSubview:_tableView];
        [self addSubview:topView];
        
    }
    return self;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    _count = 0;
    if ([_rowArray count] == 0) {
        _count = 1;
    } else {
        _count = [_rowArray count];
    }
    return _count;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _screenRect.size.width, 30)];
    
    UIColor *sectionBackColor = [UIColor colorWithRed:0.969 green:0.969 blue:0.969 alpha:1.0f];
    sectionView.backgroundColor = sectionBackColor;
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, _screenRect.size.width, 30)];

    NSDateFormatter *mdFormatter = [NSDateFormatter new];
    mdFormatter.dateFormat = @"M月d日";
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [calendar components:NSWeekdayCalendarUnit fromDate:_sectionDate];
    NSInteger weekday = comps.weekday;
    static NSString * const weekArray[] = {nil,@"（日）",@"（月）",@"（火）",@"（水）",@"（木）",@"（金）",@"（土）"};
    
    NSString *weekdayString = weekArray[weekday];
    NSString *dateString = [mdFormatter stringFromDate:_sectionDate];
    
    NSString *dateWeekString = [NSString stringWithFormat:@"%@%@",dateString,weekdayString];
    
    headerLabel.text = dateWeekString;
    headerLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0f];
    if (weekday == 1) {
        headerLabel.textColor = [UIColor redColor];
    } else if (weekday == 7) {
        headerLabel.textColor = [UIColor blueColor];
    } else {
        headerLabel.textColor = [UIColor blackColor];
    }
    
    [sectionView addSubview:headerLabel];
    
    //UILabel *closeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 44, 22)];
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    closeBtn.frame = CGRectMake(_screenRect.size.width - 44, 0, 44, 30);
    
    [closeBtn setTitle:@"閉じる" forState:UIControlStateNormal];
    closeBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0f];
    [closeBtn addTarget:self action:@selector(closeBtnTouch:) forControlEvents:UIControlEventTouchUpInside];
    
    [sectionView addSubview:closeBtn];
    
    return sectionView;
}

-(void)closeBtnTouch:(id)sendar
{
    [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveLinear animations:^ {
        self.frame = CGRectMake(0, _screenRect.size.height-49, self.frame.size.width, self.frame.size.height);
    } completion:^(BOOL finished){
        [self removeFromSuperview];
    }];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    NSDateFormatter *timeDateFormat = [NSDateFormatter new];
    [timeDateFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"US"]];
    [timeDateFormat setDateFormat:@"H:mm"];
    
    if ([_rowArray count] > 0) {
        
        if ([[_rowArray objectAtIndex:indexPath.row] isKindOfClass:[EKEvent class]]) {
        
            EKEvent *event = [_rowArray objectAtIndex:indexPath.row];
        
            NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
            NSInteger seconds = [timeZone secondsFromGMT];
            NSDate *cellDate = [_sectionDate dateByAddingTimeInterval:-seconds];
        
            NSDate *eventStartDate = [DataUtility dateAtBeginningOfDayForDate:event.startDate];
            NSDate *eventEndDate = [DataUtility dateAtBeginningOfDayForDate:event.endDate];
        
            //NSLog(@"_rowArray %@",_rowArray);
        
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
            
            //イベントタイトル設定
            UILabel *eventTitle = [UILabel new];
            UIFont *eventTitleFont = [UIFont fontWithName:@"Helvetica" size:15.0f];
            eventTitle.font = eventTitleFont;
            eventTitle.textColor = [UIColor blackColor];
            eventTitle.text = event.title;
            eventTitle.numberOfLines = 1;
            eventTitle.tag = 1;
            eventTitle.lineBreakMode = NSLineBreakByTruncatingTail;
            [eventTitle sizeToFit];
            
            EKCalendar *eventCalendar = event.calendar;
            NSString *eventCalendarTitle = eventCalendar.title;
            UIColor *eventCalendarColor = [UIColor colorWithCGColor:eventCalendar.CGColor];
        
            UILabel *eventTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 50, 20)];
            UIFont * eventTimeLabelFont = [UIFont fontWithName:@"Helvetica" size:11.0f];
            eventTimeLabel.font = eventTimeLabelFont;
            eventTimeLabel.textColor = [UIColor blackColor];
            eventTimeLabel.tag = 2;
            //eventTimeLabel.backgroundColor = [UIColor grayColor];
        
            BOOL oneLineTime = NO;
        
            if ([eventCalendarTitle isEqualToString:@"日本の祝日"])
            {
                eventTimeLabel.text = @"祝日";
                oneLineTime = YES;
            } else if ([eventCalendar.title isEqualToString:@"Birthdays"]){
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
                eventTimeLabel.frame = CGRectMake(5, 12, 40, eventTimeLabel.frame.size.height);
            } else {
                eventTimeLabel.frame = CGRectMake(5, 5, 40, eventTimeLabel.frame.size.height);
            }
            eventTimeLabel.textAlignment = NSTextAlignmentRight;

            UIImage *square = [self imageWithColor:eventCalendarColor];
            UIImageView *squareView = [[UIImageView alloc] initWithImage:square];
            squareView.center = CGPointMake(64, 18);
            squareView.tag = 3;
            
            //場所表示
            if (event.location && ![event.location isEqualToString:@""]) {
                UILabel *location = [[UILabel alloc] initWithFrame:CGRectMake(80, 22, 200, 11)];
                location.text = event.location;
                location.numberOfLines = 1;
                location.font = [UIFont fontWithName:@"Helvetica" size:11.0f];
                location.textColor = [UIColor grayColor];
                location.tag = 4;
                [cell addSubview:location];
                
                UIImage *mapIcon = [UIImage imageNamed:@"map.png"];
                UIImageView *mapIconView = [[UIImageView alloc] initWithImage:mapIcon];
                mapIconView.frame = CGRectMake(62, 22, 7, 10);
                mapIconView.tag = 5;
                [cell addSubview:mapIconView];
                
                eventTitle.frame = CGRectMake(80, 4, 200, 15);
                squareView.center = CGPointMake(66, 12);
            } else {
                eventTitle.frame = CGRectMake(80, 10, 200, 15);
                squareView.center = CGPointMake(66, 17);
            }
        
            [cell addSubview:eventTitle];
            [cell addSubview:eventTimeLabel];
            [cell addSubview:squareView];
        
        } else if ([[_rowArray objectAtIndex:indexPath.row] isKindOfClass:[EKReminder class]]) {
            EKReminder *reminder = [_rowArray objectAtIndex:indexPath.row];
            
            UILabel *eventTitle = [UILabel new];
            eventTitle.frame = CGRectMake(80, 10, 200, 15);
            eventTitle.font = [UIFont fontWithName:@"Helvetica" size:15.0f];
            eventTitle.textColor = [UIColor blackColor];
            eventTitle.text = reminder.title;
            eventTitle.numberOfLines = 1;
            eventTitle.tag = 1;
            eventTitle.lineBreakMode = NSLineBreakByTruncatingTail;
            [eventTitle sizeToFit];
            
            UILabel *eventTimeLabel = [UILabel new];
            eventTimeLabel.font = [UIFont fontWithName:@"Helvetica" size:11.0f];
            eventTimeLabel.textColor = [UIColor blackColor];
            eventTimeLabel.tag = 2;
            
            eventTimeLabel.textAlignment = NSTextAlignmentRight;
            eventTimeLabel.numberOfLines = 1;
            //[eventTimeLabel sizeToFit];
            
            eventTimeLabel.frame = CGRectMake(5, 13, 40, 11);
            
            NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
            NSString *dueTime = [timeDateFormat stringFromDate:[calendar dateFromComponents:reminder.dueDateComponents]];
            
            eventTimeLabel.text = dueTime;
            
            [cell addSubview:eventTimeLabel];
            [cell addSubview:eventTitle];
        }
    
    } else {
        //予定がない場合
        UILabel *noEventTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, 9, 305, 20)];
        noEventTitle.text = @"予定が登録されていません";
        noEventTitle.font = [UIFont fontWithName:@"Helvetica" size:15.0f];
        [cell addSubview:noEventTitle];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[cell viewWithTag:1] removeFromSuperview];
    [[cell viewWithTag:2] removeFromSuperview];
    [[cell viewWithTag:3] removeFromSuperview];
    [[cell viewWithTag:4] removeFromSuperview];
    [[cell viewWithTag:5] removeFromSuperview];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float height = 36.0f;
    return height;
}

-(UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 9, 9);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
