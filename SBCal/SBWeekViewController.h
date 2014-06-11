//
//  SBWeekViewController.h
//  SBCal
//
//  Created by kenjou yutaka on 2014/05/21.
//  Copyright (c) 2014年 kenjou yutaka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "SBWeekDayCollectionViewFlowLayout.h"
#import "SBWeekDayVireCell.h"
#import "DataUtility.h"
#import "getEKData.h"
#import "SBEventManager.h"

@interface SBWeekViewController : UIViewController<UINavigationBarDelegate,UICollectionViewDataSource,UICollectionViewDelegate,getEKDateDelegate>

@end
