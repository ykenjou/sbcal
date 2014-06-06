//
//  SBToolBar.m
//  SBCal
//
//  Created by kenjou yutaka on 2014/05/19.
//  Copyright (c) 2014年 kenjou yutaka. All rights reserved.
//

#import "SBToolBar.h"

@implementation SBToolBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        _dayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _dayButton.frame = CGRectMake(0, 0, 44, 44);
        [_dayButton setImage:[UIImage imageNamed:@"day.png"] forState:UIControlStateNormal];
        [_dayButton addTarget:self action:@selector(buttonPush:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *day = [[UIBarButtonItem alloc] initWithCustomView:_dayButton];
        
        _weekButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _weekButton.frame = CGRectMake(0, 0, 44, 44);
        [_weekButton setImage:[UIImage imageNamed:@"week.png"] forState:UIControlStateNormal];
        [_weekButton addTarget:self action:@selector(buttonPush:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *week = [[UIBarButtonItem alloc] initWithCustomView:_weekButton];
        
        _monthButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _monthButton.frame = CGRectMake(0, 0, 44, 44);
        [_monthButton setImage:[UIImage imageNamed:@"month.png"] forState:UIControlStateNormal];
        [_monthButton addTarget:self action:@selector(buttonPush:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *month = [[UIBarButtonItem alloc] initWithCustomView:_monthButton];
        
        _addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _addButton.frame = CGRectMake(0, 0, 44, 44);
        [_addButton setImage:[UIImage imageNamed:@"add.png"] forState:UIControlStateNormal];
        [_addButton addTarget:self action:@selector(buttonPush:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithCustomView:_addButton];

        _listButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _listButton.frame = CGRectMake(0, 0, 44, 44);
        [_listButton setImage:[UIImage imageNamed:@"list.png"] forState:UIControlStateNormal];
        [_listButton addTarget:self action:@selector(buttonPush:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *list = [[UIBarButtonItem alloc] initWithCustomView:_listButton];
        
        _reminderButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _reminderButton.frame = CGRectMake(0, 0, 44, 44);
        [_reminderButton setImage:[UIImage imageNamed:@"reminder.png"] forState:UIControlStateNormal];
        [_reminderButton addTarget:self action:@selector(buttonPush:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *reminder = [[UIBarButtonItem alloc] initWithCustomView:_reminderButton];
        
        _settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _settingButton.frame = CGRectMake(0, 0, 44, 44);
        [_settingButton setImage:[UIImage imageNamed:@"setting.png"] forState:UIControlStateNormal];
        [_settingButton addTarget:self action:@selector(buttonPush:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *setting = [[UIBarButtonItem alloc] initWithCustomView:_settingButton];
        
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        self.items = [NSArray arrayWithObjects:flexibleSpace,day,flexibleSpace,week,flexibleSpace,month,flexibleSpace,add,flexibleSpace,list,flexibleSpace,reminder,flexibleSpace,setting,flexibleSpace,nil];
        
        self.barTintColor = [UIColor colorWithRed:0.392 green:0.38 blue:0.812 alpha:1.0];
        self.translucent = NO;
    }
    return self;
}

-(void)allClear
{
    [_dayButton setSelected:NO];
    [_weekButton setSelected:NO];
    [_monthButton setSelected:NO];
    [_addButton setSelected:NO];
    [_listButton setSelected:NO];
    [_reminderButton setSelected:NO];
    [_settingButton setSelected:NO];
    
    [_dayButton setImage:[UIImage imageNamed:@"day.png"] forState:UIControlStateNormal];
    [_weekButton setImage:[UIImage imageNamed:@"week.png"] forState:UIControlStateNormal];
    [_monthButton setImage:[UIImage imageNamed:@"month.png"] forState:UIControlStateNormal];
    [_addButton setImage:[UIImage imageNamed:@"add.png"] forState:UIControlStateNormal];
    [_listButton setImage:[UIImage imageNamed:@"list.png"] forState:UIControlStateNormal];
    [_reminderButton setImage:[UIImage imageNamed:@"reminder.png"] forState:UIControlStateNormal];
    [_settingButton setImage:[UIImage imageNamed:@"setting.png"] forState:UIControlStateNormal];
    
}

-(void)buttonPush:(UIButton *)button
{
    [self allClear];
    
    [button setSelected:YES];
    
    if ([_dayButton isSelected]) {
        [self dayView];
        [_dayButton setImage:[UIImage imageNamed:@"day_select.png"] forState:UIControlStateNormal];
    }
    
    if ([_weekButton isSelected]) {
        [self weekView];
        [_weekButton setImage:[UIImage imageNamed:@"week_select.png"] forState:UIControlStateNormal];
    }
    
    if ([_monthButton isSelected]) {
        [self monthView];
        [_monthButton setImage:[UIImage imageNamed:@"month_select.png"] forState:UIControlStateNormal];
    }
    
    if ([_addButton isSelected]) {
        [_addButton setImage:[UIImage imageNamed:@"add_select.png"] forState:UIControlStateNormal];
    }
    
    if ([_listButton isSelected]) {
        [self listView];
        [_listButton setImage:[UIImage imageNamed:@"list_select.png"] forState:UIControlStateNormal];
    }
    
    if ([_reminderButton isSelected]) {
        [_reminderButton setImage:[UIImage imageNamed:@"reminder_select.png"] forState:UIControlStateNormal];
    }
    
    if ([_settingButton isSelected]) {
        [_settingButton setImage:[UIImage imageNamed:@"setting_select.png"] forState:UIControlStateNormal];
    }

}

-(void)dayView
{
    [self.delegate dayViewDelegate];
}

-(void)weekView
{
    [self.delegate weekViewDelegate];
}

-(void)monthView
{
    [self.delegate monthViewDelegate];
}

-(void)listView
{
    [self.delegate listViewDelegate];
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
