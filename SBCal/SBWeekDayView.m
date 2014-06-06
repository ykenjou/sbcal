//
//  SBWeekDayView.m
//  SBCal
//
//  Created by kenjou yutaka on 2014/05/26.
//  Copyright (c) 2014年 kenjou yutaka. All rights reserved.
//

#import "SBWeekDayView.h"

@implementation SBWeekDayView

static float cellWidth = 45.6f;
static float weekDayFontSize = 12.0f;

+(UIView *)weekDayView:(NSInteger)rectWidth
{
    //週のラベル表示
    UIView *weekDayView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, rectWidth, 20)];
    weekDayView.backgroundColor = [UIColor whiteColor];
    UIView *underLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 19.5f, rectWidth, 0.5f)];
    underLineView.backgroundColor = [UIColor grayColor];
    
    [weekDayView addSubview:underLineView];
    
    UIFont *weekDayFont = [UIFont fontWithName:@"Helvetica" size:weekDayFontSize];
    
    UILabel *sunday = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, cellWidth, 20)];
    sunday.text = @"日";
    sunday.textAlignment = NSTextAlignmentCenter;
    sunday.font = weekDayFont;
    sunday.textColor = [UIColor redColor];
    
    UILabel *monday = [[UILabel alloc] initWithFrame:CGRectMake(cellWidth, 0, cellWidth, 20)];
    monday.text = @"月";
    monday.textAlignment = NSTextAlignmentCenter;
    monday.font = weekDayFont;
    
    UILabel *tuesday = [[UILabel alloc] initWithFrame:CGRectMake(cellWidth * 2, 0, cellWidth, 20)];
    tuesday.text = @"火";
    tuesday.textAlignment = NSTextAlignmentCenter;
    tuesday.font = weekDayFont;
    
    UILabel *wednesday = [[UILabel alloc] initWithFrame:CGRectMake(cellWidth * 3, 0, cellWidth, 20)];
    wednesday.text = @"水";
    wednesday.textAlignment = NSTextAlignmentCenter;
    wednesday.font = weekDayFont;
    
    UILabel *thursday = [[UILabel alloc] initWithFrame:CGRectMake(cellWidth * 4, 0, cellWidth, 20)];
    thursday.text = @"木";
    thursday.textAlignment = NSTextAlignmentCenter;
    thursday.font = weekDayFont;
    
    UILabel *friday = [[UILabel alloc] initWithFrame:CGRectMake(cellWidth * 5, 0, cellWidth, 20)];
    friday.text = @"金";
    friday.textAlignment = NSTextAlignmentCenter;
    friday.font = weekDayFont;
    
    UILabel *saturday = [[UILabel alloc] initWithFrame:CGRectMake(cellWidth * 6, 0, cellWidth, 20)];
    saturday.text = @"土";
    saturday.textAlignment = NSTextAlignmentCenter;
    saturday.font = weekDayFont;
    saturday.textColor = [UIColor blueColor];
    
    [weekDayView addSubview:sunday];
    [weekDayView addSubview:monday];
    [weekDayView addSubview:tuesday];
    [weekDayView addSubview:wednesday];
    [weekDayView addSubview:thursday];
    [weekDayView addSubview:friday];
    [weekDayView addSubview:saturday];
    
    return weekDayView;

}

@end
