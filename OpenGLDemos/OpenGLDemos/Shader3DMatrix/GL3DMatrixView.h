//
//  GL3DMatrixView.h
//  OpenGLDemos
//
//  Created by cqh on 2017/10/12.
//  Copyright © 2017年 cqh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GL3DMatrixView : UIView
@property (nonatomic, assign)GLfloat xDegree;
@property (nonatomic, assign)GLfloat yDegree;

- (void)render;

@end

