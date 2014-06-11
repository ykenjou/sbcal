//
//  SBWeekDayVireCell.m
//  SBCal
//
//  Created by kenjou yutaka on 2014/06/11.
//  Copyright (c) 2014年 kenjou yutaka. All rights reserved.
//

#import "SBWeekDayVireCell.h"

@implementation SBWeekDayVireCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.restorationIdentifier = @"cellIdentifier";
        
        /*
        CGFloat borderWidth = 0.5f;
        CGRect myContetRect = CGRectInset(self.contentView.bounds, -borderWidth, -borderWidth);
        
        CGFloat borderBgWidth = 0.5f;
        CGRect myContetBgRect = CGRectInset(self.contentView.bounds, -borderBgWidth, -borderBgWidth);
        
        UIView *bgview = [[UIView alloc] initWithFrame:myContetBgRect];
        bgview.layer.borderColor = [UIColor blueColor].CGColor;
        bgview.layer.borderWidth = borderBgWidth;
        //self.selectedBackgroundView = bgview;
        
        UIView *myContentView = [[UIView alloc] initWithFrame:myContetRect];
        myContentView.layer.borderColor = [UIColor colorWithRed:0.588 green:0.588 blue:0.588 alpha:1.0].CGColor;
        myContentView.layer.borderWidth = borderWidth;
        [self.contentView addSubview:myContentView];
         */

    }
    return self;
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
