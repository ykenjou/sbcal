//
//  calendarFlowLayout.m
//  fascal
//
//  Created by kenjou yutaka on 2014/02/21.
//  Copyright (c) 2014年 kenjou yutaka. All rights reserved.
//

#import "calendarFlowLayout.h"

@implementation calendarFlowLayout

/*-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *answer = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
    
    for(int i = 1; i < [answer count]; ++i) {
        UICollectionViewLayoutAttributes *currentLayoutAttributes = answer[i];
        UICollectionViewLayoutAttributes *prevLayoutAttributes = answer[i - 1];
        NSInteger maximumSpacing = 0.0;
        NSInteger origin = CGRectGetMaxX(prevLayoutAttributes.frame);
        if(origin + maximumSpacing + currentLayoutAttributes.frame.size.width < self.collectionViewContentSize.width)
        {
            CGRect frame = currentLayoutAttributes.frame;
            frame.origin.x = origin + maximumSpacing;
            currentLayoutAttributes.frame = frame;
        }
    }
    return answer;
}*/

-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

@end
