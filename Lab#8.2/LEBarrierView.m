
//
//  LEBarrierView.m
//  Lab#8.2
//
//  Created by Evgheny on 30.11.16.
//  Copyright © 2016 Eugheny_Levin. All rights reserved.
//

#import "LEBarrierView.h"

@implementation LEBarrierView

-(instancetype)initWithFrame:(CGRect)frame{

    if (self = [super initWithFrame:frame])
        
    self.backgroundColor = [UIColor clearColor];
    return self;
    
}
-(void)drawRect:(CGRect)rect{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(ctx, 4);
    CGRect bounds = rect;
    CGContextMoveToPoint(ctx, CGRectGetMinX(bounds), CGRectGetMidY(bounds));
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(bounds),CGRectGetMidY(bounds));
    CGContextStrokePath(ctx);

}

@end
