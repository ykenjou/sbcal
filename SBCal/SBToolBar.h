//
//  SBToolBar.h
//  SBCal
//
//  Created by kenjou yutaka on 2014/05/19.
//  Copyright (c) 2014年 kenjou yutaka. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SBToolBarDelegate<UIToolbarDelegate>

-(void)dayViewDelegate;
-(void)weekViewDelegate;
-(void)monthViewDelegate;
-(void)listViewDelegate;

@end

@interface SBToolBar : UIToolbar

@property (strong,nonatomic) UIButton *dayButton;
@property (strong,nonatomic) UIButton *weekButton;
@property (strong,nonatomic) UIButton *monthButton;
@property (strong,nonatomic) UIButton *addButton;
@property (strong,nonatomic) UIButton *listButton;
@property (strong,nonatomic) UIButton *reminderButton;
@property (strong,nonatomic) UIButton *settingButton;

@property (nonatomic,weak) id<SBToolBarDelegate> delegate;

-(void)dayView;
-(void)weekView;
-(void)monthView;
-(void)listView;

@end