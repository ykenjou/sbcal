//
//  SBTriangleView.m
//  SBCal
//
//  Created by kenjou yutaka on 2014/05/26.
//  Copyright (c) 2014年 kenjou yutaka. All rights reserved.
//

#import "SBTriangleView.h"

@implementation SBTriangleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [[UIColor blackColor] setFill];
    
    CGContextRef cct = UIGraphicsGetCurrentContext();
    float width = self.bounds.size.width;
    float height = self.bounds.size.height;
    CGContextMoveToPoint(cct , width, 0);
    CGContextAddLineToPoint(cct, width, height);
    CGContextAddLineToPoint(cct, 0, height);
    
    CGContextFillPath(cct);
}


@end
