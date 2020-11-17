//
//  PaintGLView.h
//  OpenGLDemos
//
//  Created by cqh on 2017/10/25.
//  Copyright © 2017年 cqh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PaintGLView : UIView

@property(nonatomic, readwrite) CGPoint location;
@property(nonatomic, readwrite) CGPoint previousLocation;


- (void)erase;

- (void)setBrushColorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue;
@end
