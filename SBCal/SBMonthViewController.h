//
//  SBMonthViewController.h
//  SBCal
//
//  Created by kenjou yutaka on 2014/05/21.
//  Copyright (c) 2014年 kenjou yutaka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <EventKit/EventKit.h>
#import "dayListView.h"
#import "getEKData.h"
#import "SBEventManager.h"

@interface SBMonthViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UINavigationBarDelegate,getEKDateDelegate>
{
    UICollectionView *_collectionView;
    UICollectionViewCell *dayCell;
    UILabel *monthlyLabel;
    UILabel *monthlyLabel2;
    NSInteger allDays;
    NSInteger firstDayIndex;
    NSDate *startDate;
    NSDate *endDate;
    UIColor *monthColor;
    UIColor *todayColor;
}

@property (nonatomic,copy) NSMutableDictionary *sections;
@property (nonatomic,strong) NSDateFormatter *ymdFormatter;
@property (nonatomic,strong) UIView *dayEventList;
@property (nonatomic,strong) UITableView *dayEventTable;
@property (nonatomic) dayListView *dayListView;
@property (nonatomic) CGRect screenRect;
@property (nonatomic) getEKData *ekData;
@property (nonatomic) dayListView *listView;
@property (nonatomic) UILabel *naviTitle;
@property (nonatomic) NSMutableDictionary *rowIndexs;
@property (nonatomic) NSArray *sortedDays;
@property (nonatomic) EKEvent *event;
@property (nonatomic) SBEventManager *eventMg;
@property (nonatomic) NSCalendar *calendar;

@end
