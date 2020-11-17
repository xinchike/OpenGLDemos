//
//  GLKitViewController.m
//  OpenGLDemos
//
//  Created by cqh on 2017/10/4.
//  Copyright © 2017年 cqh. All rights reserved.
//

#import "GLKitViewController.h"

@interface GLKitViewController()

@property (nonatomic, strong)EAGLContext *myContext;
@property (nonatomic, strong)GLKBaseEffect *myEffect;

@end

@implementation GLKitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setupContext];
    [self setupVertexData];
    [self setupTexture];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupContext
{
    //新建OpenGLES 上下文
    self.myContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.myContext;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888; //设置颜色缓冲区格式
    
    [EAGLContext setCurrentContext:self.myContext];
}


- (void)setupVertexData
{
    //顶点数据，前三个是顶点坐标，后面两个是纹理坐标
    GLfloat vertexData[] =
    {
        0.5, -0.5, 0.0,   1.0, 0.0,  //右下
        0.5, 0.5, 0.0,    1.0, 1.0,  //右上
        -0.5, 0.5, 0.0,   0.0, 1.0,  //左上
        
        0.5, -0.5, 0.0,   1.0, 0.0,  //右下
        -0.5, 0.5, 0.0,   0.0, 1.0,  //左上
        -0.5, -0.5, 0.0,   0.0, 0.0,  //左下
    };
    
    //顶点数据缓存
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexData), vertexData, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (GLfloat *)NULL + 0);
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GL_FLOAT)*5, (GLfloat *)NULL+3);
    
}

- (void)setupTexture
{
    //纹理贴图
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"for_test" ofType:@"jpg"];
    //    NSDictionary *options = @{@(1) : GLKTextureLoaderOriginBottomLeft};   //不能用这种语法创建，否则不起作用
    NSDictionary* options = [NSDictionary dictionaryWithObjectsAndKeys:@(1), GLKTextureLoaderOriginBottomLeft, nil];//GLKTextureLoaderOriginBottomLeft 纹理坐标系是相反的
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
    
    //着色器
    self.myEffect = [[GLKBaseEffect alloc] init];
    self.myEffect.texture2d0.enabled = GL_TRUE;
    self.myEffect.texture2d0.name = textureInfo.name;
    
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.3f, 0.6f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    [self.myEffect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, 6);
}

@end
