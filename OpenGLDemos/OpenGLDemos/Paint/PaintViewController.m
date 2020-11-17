//
//  PaintViewController.m
//  OpenGLDemos
//
//  Created by cqh on 2017/10/25.
//  Copyright © 2017年 cqh. All rights reserved.
//

#import "PaintViewController.h"
#import "PaintGLView.h"


//CONSTANTS:

#define kBrightness             1.0
#define kSaturation             0.45

#define kPaletteHeight			30
#define kPaletteSize			5
#define kMinEraseInterval		0.5

// Padding for margins
#define kLeftMargin				10.0
#define kTopMargin				10.0
#define kRightMargin			10.0


@interface PaintViewController ()

@end

@implementation PaintViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:
                                            [NSArray arrayWithObjects:
                                             [[UIImage imageNamed:@"Red"]       imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal],
                                             [[UIImage imageNamed:@"Yellow"]    imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal],
                                             [[UIImage imageNamed:@"Green"]     imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal],
                                             [[UIImage imageNamed:@"Blue"]      imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal],
                                             [[UIImage imageNamed:@"Purple"]    imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal],
                                             nil]];
    
    [[UIImage imageNamed:@"Red"]       imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    // Compute a rectangle that is positioned correctly for the segmented control you'll use as a brush color palette
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGRect frame = CGRectMake(rect.origin.x + kLeftMargin, rect.size.height - kPaletteHeight - kTopMargin, rect.size.width - (kLeftMargin + kRightMargin), kPaletteHeight);
    segmentedControl.frame = frame;
    // When the user chooses a color, the method changeBrushColor: is called.
    [segmentedControl addTarget:self action:@selector(changeBrushColor:) forControlEvents:UIControlEventValueChanged];
    // Make sure the color of the color complements the black background
    segmentedControl.tintColor = [UIColor darkGrayColor];
    // Set the third color (index values start at 0)
    segmentedControl.selectedSegmentIndex = 2;
    
    // Add the control to the window
    [self.view addSubview:segmentedControl];
    
    // Define a starting color
    CGColorRef color = [UIColor colorWithHue:(CGFloat)2.0 / (CGFloat)kPaletteSize
                                  saturation:kSaturation
                                  brightness:kBrightness
                                       alpha:1.0].CGColor;
    const CGFloat *components = CGColorGetComponents(color);
    
    [(PaintGLView *)self.view setBrushColorWithRed:components[0] green:components[1] blue:components[2]];
    
    [[UIImage imageNamed:@"red"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

// Change the brush color
- (void)changeBrushColor:(id)sender
{
    
    // Define a new brush color
    CGColorRef color = [UIColor colorWithHue:(CGFloat)[sender selectedSegmentIndex] / (CGFloat)kPaletteSize
                                  saturation:kSaturation
                                  brightness:kBrightness
                                       alpha:1.0].CGColor;
    const CGFloat *components = CGColorGetComponents(color);
    
    // Defer to the OpenGL view to set the brush color
    [(PaintGLView *)self.view setBrushColorWithRed:components[0] green:components[1] blue:components[2]];
}
- (IBAction)erasePressed:(id)sender {
    
    
    [(PaintGLView *)self.view erase];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
