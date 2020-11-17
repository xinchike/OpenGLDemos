//
//  LYPoint.h
//  OpenGLDemos
//
//  Created by cqh on 2017/10/27.
//  Copyright © 2017年 cqh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface LYPoint : NSObject

@property (nonatomic, strong)NSNumber *mX;
@property (nonatomic, strong)NSNumber *mY;

- (instancetype)initWithCGPoint:(CGPoint)point;
@end
