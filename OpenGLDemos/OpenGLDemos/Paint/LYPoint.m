//
//  LYPoint.m
//  OpenGLDemos
//
//  Created by cqh on 2017/10/27.
//  Copyright © 2017年 cqh. All rights reserved.
//

#import "LYPoint.h"

@implementation LYPoint

- (instancetype)initWithCGPoint:(CGPoint)point
{
    if (self = [super init]) {
        self.mX = [NSNumber numberWithFloat:point.x];
        self.mY = [NSNumber numberWithFloat:point.y];
    }
    return self;
}
@end
