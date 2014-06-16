//
//  SBWeekDayScrollView.h
//  SBCal
//
//  Created by kenjou yutaka on 2014/06/12.
//  Copyright (c) 2014年 kenjou yutaka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBRightTriangleView.h"
#import "SBLeftTriangleView.h"

@interface SBWeekDayScrollView : UIScrollView<UIScrollViewDelegate>

- (id)initWithFrame:(CGRect)frame rightPosition:(float)position;

@end
