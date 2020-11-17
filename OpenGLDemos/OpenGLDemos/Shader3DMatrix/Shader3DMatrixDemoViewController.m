//
//  Shader3DMatrixDemoViewController.m
//  OpenGLDemos
//
//  Created by cqh on 2017/10/12.
//  Copyright © 2017年 cqh. All rights reserved.
//

#import "Shader3DMatrixDemoViewController.h"
#import "GL3DMatrixView.h"

@interface Shader3DMatrixDemoViewController ()

@property (nonatomic, assign)BOOL bX;
@property (nonatomic, assign)BOOL bY;

@property (nonatomic, strong)GL3DMatrixView *myView;
@property (nonatomic, strong)NSTimer *myTimer;

@property (nonatomic, strong)UIButton *xButton;
@property (nonatomic, strong)UIButton *yButton;

@end

@implementation Shader3DMatrixDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.myView.frame = self.view.bounds;
    [self.view addSubview:self.myView];
    
//    self.view = [[GL3DMatrixView alloc] init];
    
    self.xButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 150, 150, 20)];
    [self.xButton setTitle:@"开始绕X轴旋转" forState:UIControlStateNormal];
    [self.xButton addTarget:self action:@selector(xButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.xButton];
    
    self.yButton = [[UIButton alloc] initWithFrame:CGRectMake(170, 150, 150, 20)];
    [self.yButton setTitle:@"开始绕Y轴旋转" forState:UIControlStateNormal];
    [self.yButton addTarget:self action:@selector(yButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.myView addSubview:self.yButton];
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self stopTimer];
}

- (void)dealloc
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (GL3DMatrixView *)myView
{
    if (!_myView) {
        _myView = [[GL3DMatrixView alloc] init];
    }
    return _myView;
}

- (void)setBX:(BOOL)bX
{
    _bX = bX;
    NSString *title = _bX ? @"停止绕X轴旋转" : @"开始绕X轴旋转";
    [self.xButton setTitle:title forState:UIControlStateNormal];
}

- (void)setBY:(BOOL)bY
{
    _bY = bY;
    NSString *title = _bY ? @"停止绕Y轴旋转" : @"开始绕Y轴旋转";
    [self.yButton setTitle:title forState:UIControlStateNormal];
}

- (IBAction)xButtonPressed:(id)sender
{
    [self startTimer];
    self.bX = !self.bX;
    
}

- (IBAction)yButtonPressed:(id)sender
{
    [self startTimer];
    self.bY = !self.bY;
}

- (void)startTimer
{
    if (!_myTimer) {
        self.myTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
    }
}

- (void)stopTimer
{
    if (_myTimer) {
        [_myTimer invalidate];
        self.myTimer = nil;
    }
    
}

- (void)onTimer
{
    self.myView.xDegree += self.bX * 5;
    self.myView.yDegree += self.bY * 5;
    [self.myView render];
}


@end
