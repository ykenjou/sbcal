//
//  SBMainViewController.m
//  SBCal
//
//  Created by kenjou yutaka on 2014/05/19.
//  Copyright (c) 2014年 kenjou yutaka. All rights reserved.
//

#import "SBMainViewController.h"
#import "SBToolBar.h"

@interface SBMainViewController ()

@end

@implementation SBMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    SBToolBar *toolBar = [[SBToolBar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height -44, self.view.bounds.size.width, 44)];
    toolBar.delegate = self;
    [self.view addSubview:toolBar];
    toolBar.layer.zPosition = MAXFLOAT;
    
    _mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height -44 -44)];
    [self.view addSubview:_mainView];
    
    _dayViewController = [SBDayViewController new];
    [self addChildViewController:_dayViewController];
    [_dayViewController didMoveToParentViewController:self];
    
    _monthViewController = [SBMonthViewController new];
    [self addChildViewController:_monthViewController];
    [_monthViewController didMoveToParentViewController:self];
    
    _listViewController = [SBListViewController new];
    [self addChildViewController:_listViewController];
    [_listViewController didMoveToParentViewController:self];
}

-(void)removeAllView
{
    [_dayViewController.view removeFromSuperview];
    [_monthViewController.view removeFromSuperview];
    [_listViewController.view removeFromSuperview];
}

-(void)dayViewDelegate
{
    [self removeAllView];
    [_mainView addSubview:_dayViewController.view];
    
}

-(void)weekViewDelegate
{
    [self removeAllView];
}

-(void)monthViewDelegate
{
    [self removeAllView];
    [_mainView addSubview:_monthViewController.view];
    
}

-(void)listViewDelegate
{
    [self removeAllView];
    [_mainView addSubview:_listViewController.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
