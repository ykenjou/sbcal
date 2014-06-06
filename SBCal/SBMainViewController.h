//
//  SBMainViewController.h
//  SBCal
//
//  Created by kenjou yutaka on 2014/05/19.
//  Copyright (c) 2014年 kenjou yutaka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "SBToolBar.h"
#import "SBDayViewController.h"
#import "SBListViewController.h"
#import "SBMonthViewController.h"

@interface SBMainViewController : UIViewController<SBToolBarDelegate>

@property (strong,nonatomic) UIView *mainView;
@property (strong,nonatomic) SBDayViewController *dayViewController;
@property (strong,nonatomic) SBListViewController *listViewController;
@property (strong,nonatomic) SBMonthViewController *monthViewController;

@end
