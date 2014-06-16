//
//  SBLeftTriangleView.m
//  SBCal
//
//  Created by kenjou yutaka on 2014/06/14.
//  Copyright (c) 2014年 kenjou yutaka. All rights reserved.
//

#import "SBLeftTriangleView.h"

@implementation SBLeftTriangleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [[UIColor whiteColor] setFill];
    
    CGContextRef cct = UIGraphicsGetCurrentContext();
    float width = self.bounds.size.width;
    float height = self.bounds.size.height;
    CGContextMoveToPoint(cct , width, 0);
    CGContextAddLineToPoint(cct, 0, height / 2);
    CGContextAddLineToPoint(cct, width, height);
    
    CGContextFillPath(cct);
}

@end
