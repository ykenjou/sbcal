//
//  SBDayViewController.m
//  SBCal
//
//  Created by kenjou yutaka on 2014/05/21.
//  Copyright (c) 2014年 kenjou yutaka. All rights reserved.
//

#import "SBDayViewController.h"

@interface SBDayViewController ()

@end

@implementation SBDayViewController

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
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    UINavigationBar *naviBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 20, screenRect.size.width, 44)];
    naviBar.delegate = self;
    
    UINavigationItem *item = [[UINavigationItem alloc] init];
    
    UILabel *naviTitle = [[UILabel alloc] init];
    naviTitle.frame = CGRectMake(0, 0, 200, 44);
    naviTitle.text = @"今日の予定";
    naviTitle.font = [UIFont fontWithName:@"Helvetica-Bold" size:17.0f];
    naviTitle.textAlignment = NSTextAlignmentCenter;
    naviTitle.textColor = [UIColor whiteColor];
    
    item.titleView = naviTitle;
    
    [naviBar pushNavigationItem:item animated:NO];
    
    naviBar.barTintColor = [UIColor colorWithRed:0.392 green:0.38 blue:0.812 alpha:1.0];
    naviBar.translucent = NO;
    
    [self.view addSubview:naviBar];
    
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
