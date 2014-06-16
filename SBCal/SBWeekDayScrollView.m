//
//  SBWeekDayScrollView.m
//  SBCal
//
//  Created by kenjou yutaka on 2014/06/12.
//  Copyright (c) 2014年 kenjou yutaka. All rights reserved.
//

#import "SBWeekDayScrollView.h"

@interface SBWeekDayScrollView ()

@property (nonatomic) UIView *rightView;
@property (nonatomic) UIView *leftView;
@property (nonatomic) CGPoint rightViewCenter;
@property (nonatomic) CGPoint leftViewCenter;
@property (nonatomic) float rightPosition;

@end

@implementation SBWeekDayScrollView

- (id)initWithFrame:(CGRect)frame rightPosition:(float)position
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.delegate = self;
        
        _rightView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width - 10, 0, 10, self.frame.size.height)];
        _rightView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.7];
        [self addSubview:_rightView];
        _rightViewCenter = [_rightView center];
        
        _rightView.layer.zPosition = MAXFLOAT;
        
        UIView *rightTriangle = [[SBRightTriangleView alloc] initWithFrame:CGRectMake(2, self.frame.size.height / 2 - 4, 5, 8)];
        [_rightView addSubview:rightTriangle];
        
        _leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, self.frame.size.height)];
        _leftView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.7];
        _leftView.hidden = YES;
        [self addSubview:_leftView];
        _leftViewCenter = [_leftView center];
        
        _leftView.layer.zPosition = MAXFLOAT;
        
        UIView *leftTriangle = [[SBLeftTriangleView alloc] initWithFrame:CGRectMake(2, self.frame.size.height / 2 - 4, 5, 8)];
        [_leftView addSubview:leftTriangle];
        
        _rightPosition = position;
        
        
        
        //NSLog(@"%f",_rightPosition);
        
         
    }
    return self;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    /*
    CGPoint origin = [scrollView contentOffset];
    [scrollView setContentOffset:CGPointMake(origin.x, 0.0)];
     */
    //NSLog(@"scroll");
    CGPoint contentOffset = [scrollView contentOffset];
    CGPoint newRightCenter = CGPointMake(_rightViewCenter.x + contentOffset.x, _rightViewCenter.y + contentOffset.y);
    [_rightView setCenter:newRightCenter];
    
    CGPoint newLeftCenter = CGPointMake(_leftViewCenter.x + contentOffset.x, _leftViewCenter.y + contentOffset.y);
    [_leftView setCenter:newLeftCenter];
    
    if (contentOffset.x > 0) {
        _leftView.hidden = NO;
    } else {
        _leftView.hidden = YES;
    }
    
    if (contentOffset.x >= _rightPosition) {
        _rightView.hidden = YES;
    } else {
        _rightView.hidden = NO;
    }
    
    //NSLog(@"%f",contentOffset.x);
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
