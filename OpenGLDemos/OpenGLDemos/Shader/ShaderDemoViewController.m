//
//  ShaderDemoViewController.m
//  OpenGLDemos
//
//  Created by cqh on 2017/10/5.
//  Copyright © 2017年 cqh. All rights reserved.
//

#import "ShaderDemoViewController.h"
#import "CQHGLView.h"

@interface ShaderDemoViewController ()

@property (nonatomic, strong) CQHGLView *glView;
@end

@implementation ShaderDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.glView.frame = self.view.bounds;
//    [self.view addSubview:self.glView];
//    self.view = self.glView;
//    self.view.backgroundColor = [UIColor redColor];
    self.view = [[CQHGLView alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (CQHGLView *)glView
{
    if (!_glView) {
        _glView = [[CQHGLView alloc] init];
    }
    return _glView;
}

@end
