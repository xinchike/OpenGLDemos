//
//  ViewController.m
//  OpenGLDemos
//
//  Created by cqh on 2017/10/4.
//  Copyright © 2017年 cqh. All rights reserved.
//

#import "ViewController.h"
#import "OpenGLDemoTableViewController.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    OpenGLDemoTableViewController *vc = [[OpenGLDemoTableViewController alloc] init];
    [self pushViewController:vc animated:NO];
}




@end
