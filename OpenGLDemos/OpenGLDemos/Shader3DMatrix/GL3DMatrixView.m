//
//  GL3DMatrixView.m
//  OpenGLDemos
//
//  Created by cqh on 2017/10/12.
//  Copyright © 2017年 cqh. All rights reserved.
//

#import "GL3DMatrixView.h"
#import <OpenGLES/ES2/gl.h>
#import "GLESUtils.h"
#import "GLESMath.h"

@interface GL3DMatrixView()

@property (nonatomic, strong)EAGLContext *myContext;
@property (nonatomic, strong)CAEAGLLayer *myEaglLayer;
@property (nonatomic, assign)GLuint myProgram;
@property (nonatomic, assign)GLuint myVertices;

@property (nonatomic, assign)GLuint myColorRenderBuffer;
@property (nonatomic, assign)GLuint myColorFrameBuffer;

@property (nonatomic, strong)NSTimer *myTimer;

@end

@implementation GL3DMatrixView
{
//    GLfloat xDegree;
//    GLfloat yDegree;
//    
//    GLboolean bX;
//    GLboolean bY;
}

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (void)layoutSubviews
{
    [self setupLayer];
    [self setupContext];
    [self destoryRenderAndFrameBuffer];
    
    [self setupRenderBuffer];
    [self setupFrameBuffer];
    
    [self render];
}

- (void)setupLayer
{
    self.myEaglLayer = (CAEAGLLayer *)self.layer;
    [self setContentScaleFactor:[UIScreen mainScreen].scale];
    
    self.myEaglLayer.opaque = YES;
    // 设置描绘属性，在这里设置不维持渲染内容以及颜色格式为 RGBA8
    self.myEaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking,
                                           kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
}

- (void)setupContext
{
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:api];
    if (!context) {
        NSLog(@"create OpenGLES 2.0 context failed");
        exit(1);
    }
    
    if (![EAGLContext setCurrentContext:context]) {
        NSLog(@"set OpenGLES 2.0 context failed");
        exit(1);
    }
    self.myContext = context;
}

- (void)destoryRenderAndFrameBuffer
{
    glDeleteFramebuffers(1, &_myColorFrameBuffer);
    self.myColorFrameBuffer = 0;
    
    glDeleteRenderbuffers(1, &_myColorRenderBuffer);
    self.myColorRenderBuffer = 0;
}

- (void)setupRenderBuffer
{
    GLuint buffer;
    glGenRenderbuffers(1, &buffer);
    self.myColorRenderBuffer = buffer;
    
    glBindRenderbuffer(GL_RENDERBUFFER, self.myColorRenderBuffer);
    // 为 color renderbuffer 分配存储空间
    [self.myContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.myEaglLayer];
}

- (void)setupFrameBuffer
{
    GLuint buffer;
    glGenFramebuffers(1, &buffer);
    self.myColorFrameBuffer = buffer;
    
    glBindFramebuffer(GL_FRAMEBUFFER, self.myColorFrameBuffer);
    
    // 将 _colorRenderBuffer 装配到 GL_COLOR_ATTACHMENT0 这个装配点上
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.myColorRenderBuffer);
}

- (void)render
{
    glClearColor(0.0f, 1.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    CGFloat scale = [UIScreen mainScreen].scale;
    glViewport(self.frame.origin.x*scale, self.frame.origin.y*scale, self.frame.size.width*scale, self.frame.size.height*scale);
    
    NSString *vertFile = [[NSBundle mainBundle] pathForResource:@"shader3dv" ofType:@"glsl"];
    NSString *fragFile = [[NSBundle mainBundle] pathForResource:@"shader3df" ofType:@"glsl"];
    
    if (self.myProgram) {
        glDeleteProgram(self.myProgram);
        self.myProgram = 0;
    }
    
    self.myProgram = [self loadShaders:vertFile fragFile:fragFile];
    
    glLinkProgram(self.myProgram);
    GLint linkSucess;
    glGetProgramiv(self.myProgram, GL_LINK_STATUS, &linkSucess);
    if (GL_FALSE ==  linkSucess) {
        GLchar message[256] = {0};
        glGetProgramInfoLog(self.myProgram, sizeof(message), 0, &message[0]);
        NSString *strLog = [NSString stringWithUTF8String:message];
        NSLog(@"link program err: %@", strLog);
        exit(1);
    }else{
        glUseProgram(self.myProgram);
    }
    
    GLuint indices[] =
    {
        0, 3, 2,
        0, 1, 3,
        0, 2, 4,
        0, 4, 1,
        2, 3, 4,
        1, 4, 3,
    };
    
    GLfloat attrArr[] =
    {
        -0.5f, 0.5f, 0.0f,      1.0f, 0.0f, 1.0f, //左上
        0.5f, 0.5f, 0.0f,       1.0f, 0.0f, 1.0f, //右上
        -0.5f, -0.5f, 0.0f,     1.0f, 1.0f, 1.0f, //左下
        0.5f, -0.5f, 0.0f,      1.0f, 1.0f, 1.0f, //右下
        0.0f, 0.0f, 1.0f,      0.0f, 1.0f, 0.0f, //顶点
    };
    
    if (0 == self.myVertices) {
        glGenBuffers(1, &_myVertices);
    }
    glBindBuffer(GL_ARRAY_BUFFER, _myVertices);
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_DYNAMIC_DRAW);
    
    GLuint vPosition = glGetAttribLocation(self.myProgram, "vPosition");
    glVertexAttribPointer(vPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*6, NULL);
    glEnableVertexAttribArray(vPosition);
    
    GLuint vPositionColor = glGetAttribLocation(self.myProgram, "vPositionColor");
    glVertexAttribPointer(vPositionColor, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*6, (GLfloat *)NULL + 3);
    glEnableVertexAttribArray(vPositionColor);
    
    GLuint projectionMatrixSlot = glGetUniformLocation(self.myProgram, "projectionMatrix");
    GLuint modelViewMatrixSlot = glGetUniformLocation(self.myProgram, "modelViewMatrix");
    
    float width = self.frame.size.width;
    float height = self.frame.size.height;
    float aspectRatio = width/height;    //长宽比
    
    KSMatrix4 _projectionMatrix;
    ksMatrixLoadIdentity(&_projectionMatrix);
    ksPerspective(&_projectionMatrix, 30.0, aspectRatio, 5.0f, 20.0f); //透视变换，视角30°
    
    glUniformMatrix4fv(projectionMatrixSlot, 1, GL_FALSE, (GLfloat*)&_projectionMatrix.m[0][0]);
    glEnable(GL_CULL_FACE);
    
    
    KSMatrix4 _modelViewMatrix;
    ksMatrixLoadIdentity(&_modelViewMatrix);
    ksTranslate(&_modelViewMatrix, 0.0, 0.0, -10.0);    //平移
    
    KSMatrix4 _rotationMatrix;
    ksMatrixLoadIdentity(&_rotationMatrix);
    //旋转
    ksRotate(&_rotationMatrix, self.xDegree, 1.0, 0.0, 0.0); //绕X轴
    ksRotate(&_rotationMatrix, self.yDegree, 0.0, 1.0, 0.0); //绕Y轴
    
    //把变换矩阵相乘，注意先后顺序
    ksMatrixMultiply(&_modelViewMatrix, &_rotationMatrix, &_modelViewMatrix);
    
    glUniformMatrix4fv(modelViewMatrixSlot, 1, GL_FALSE, &_modelViewMatrix.m[0][0]);
    
    glDrawElements(GL_TRIANGLES, sizeof(indices)/sizeof(indices[0]), GL_UNSIGNED_INT, indices);
    
    [self.myContext presentRenderbuffer:GL_RENDERBUFFER];
}

- (GLuint)loadShaders:(NSString *)vertFile fragFile:(NSString *)fragFile
{
    GLuint vertShader, fragShader;
    GLuint program = glCreateProgram();
    
    [self compileSharder:&vertShader type:GL_VERTEX_SHADER file:vertFile];
    [self compileSharder:&fragShader type:GL_FRAGMENT_SHADER file:fragFile];
    
    glAttachShader(program, vertShader);
    glAttachShader(program, fragShader);
    
    glDeleteShader(vertShader);
    glDeleteShader(fragShader);

    return program;
}

- (void)compileSharder:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    NSString *content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    const GLchar *source = (GLchar *)[content UTF8String];
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
}
@end
