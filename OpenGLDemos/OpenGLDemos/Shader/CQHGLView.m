//
//  CQHGLView.m
//  ShaderDemo
//
//  Created by cqh on 2017/9/23.
//  Copyright © 2017年 cqh. All rights reserved.
//

#import "CQHGLView.h"
#import <OpenGLES/ES2/gl.h>


@interface CQHGLView()

@property (nonatomic, strong)EAGLContext *myContext;
@property (nonatomic, strong)CAEAGLLayer *myLayer;

@property (nonatomic, assign)GLuint myProgram;

@property (nonatomic, assign)GLuint myColorRenderBuffer;
@property (nonatomic, assign)GLuint myColorFrameBuffer;

@end

@implementation CQHGLView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (void)layoutSubviews
{
//    [super layoutSubviews];
    [self setupLayer];
    [self setupContext];
    [self destoryRenderAndFrameBuffer];
    
    [self setupRenderBuffer];
    [self setupFrameBuffer];
    
    [self render];
}

- (void)setupLayer
{
    self.myLayer = (CAEAGLLayer *)self.layer;
    
    //设置放大位数
    [self setContentScaleFactor:[UIScreen mainScreen].scale];
    self.myLayer.opaque = YES;
    
    self.myLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
}

- (void)setupContext
{
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!context) {
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }
    
    if (![EAGLContext setCurrentContext:context]) {
        
        NSLog(@"Failed to set current OpenGL context");
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
    
    [self.myContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.myLayer];
}

- (void)setupFrameBuffer
{
    GLuint buffer;
    glGenFramebuffers(1, &buffer);
    self.myColorFrameBuffer = buffer;
    glBindFramebuffer(GL_FRAMEBUFFER, self.myColorFrameBuffer);
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.myColorRenderBuffer);
}

- (void)render
{
    glClearColor(0.0, 1.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    GLfloat scale = [UIScreen mainScreen].scale;    //获取视图放大位数
    glViewport(self.frame.origin.x * scale, self.frame.origin.y * scale, self.frame.size.width * scale, self.frame.size.height * scale);    //设置视口大小
    
    //读取文件路径
    NSString *vertFilePath = [[NSBundle mainBundle] pathForResource:@"shaderv" ofType:@"vsh"];
    NSString *fragFilePath = [[NSBundle mainBundle] pathForResource:@"shaderf" ofType:@"fsh"];
    
    //加载shader、编译
    self.myProgram = [self loadShader:vertFilePath frag:fragFilePath];
    
    //链接
    glLinkProgram(self.myProgram);
    GLint linkSataus;
    glGetProgramiv(self.myProgram, GL_LINK_STATUS, &linkSataus);
    if (GL_FALSE == linkSataus) {
        GLchar errMsg[256];
        glGetProgramInfoLog(self.myProgram, sizeof(errMsg), 0, &errMsg[0]);
        NSString *msgString = [NSString stringWithUTF8String:errMsg];
        NSLog(@"%@", msgString);
        return;
    }else{
        NSLog(@"shader link sucess");
        glUseProgram(self.myProgram);
    }
    
    GLfloat attrArr[] =
    {
        0.5f, -0.5f, -0.0f,     0.0f, 1.0f,
        -0.5f, 0.5f, -0.0f,     1.0f, 0.0f,
        -0.5f, -0.5f, -0.0f,    1.0f, 1.0f,
        
        0.5f, 0.5f, -0.0f,      0.0f, 0.0f,
        -0.5f, 0.5f, -0.0f,     1.0f, 0.0f,
        0.5f, -0.5f, -0.0f,     0.0f, 1.0f,
    };

    
//    GLfloat attrArr[] =
//    {
//        0.5f, -0.5f, -0.0f,     1.0f, 0.0f,
//        -0.5f, 0.5f, -0.0f,     0.0f, 1.0f,
//        -0.5f, -0.5f, -0.0f,    0.0f, 0.0f,
//        
//        0.5f, 0.5f, -0.0f,      1.0f, 1.0f,
//        -0.5f, 0.5f, -0.0f,     0.0f, 1.0f,
//        0.5f, -0.5f, -0.0f,     1.0f, 0.0f,
//    };
    
//    GLfloat attrArr[] =
//    {
//        0.5f, -0.5f, -1.0f,     1.0f, 0.0f,
//        -0.5f, 0.5f, -1.0f,     0.0f, 1.0f,
//        -0.5f, -0.5f, -1.0f,    0.0f, 0.0f,
//        0.5f, 0.5f, -1.0f,      1.0f, 1.0f,
//        -0.5f, 0.5f, -1.0f,     0.0f, 1.0f,
//        0.5f, -0.5f, -1.0f,     1.0f, 0.0f,
//    };
    
    GLuint attrBuffer;
    glGenBuffers(1, &attrBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, attrBuffer);
//    glBindRenderbuffer(GL_ARRAY_BUFFER, attrBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_DYNAMIC_DRAW);
//
//    GLuint position = glGetAttribLocation(self.myProgram, "position");
//    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (float *)NULL+0);
//    glEnableVertexAttribArray(position);
//    
//    GLuint textCoor = glGetAttribLocation(self.myProgram, "textCoordinate");
//    glVertexAttribPointer(textCoor, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (float *)NULL + 3);
//    glEnableVertexAttribArray(textCoor);
    
//    GLuint attrBuffer;
//    glGenBuffers(1, &attrBuffer);
//    glBindBuffer(GL_ARRAY_BUFFER, attrBuffer);
//    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_DYNAMIC_DRAW);
    
    GLuint position = glGetAttribLocation(self.myProgram, "position");
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, NULL);
    glEnableVertexAttribArray(position);
    
    GLuint textCoor = glGetAttribLocation(self.myProgram, "textCoordinate");
    glVertexAttribPointer(textCoor, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (float *)NULL + 3);
    glEnableVertexAttribArray(textCoor);
    
    [self setupTexture];

    //获取shader里面的变量，这里记得要在glLinkProgram后面，后面，后面！
    GLuint rorate = glGetUniformLocation(self.myProgram, "rotateMatrix");
    float radians = 10 * 3.14159f/180.0f;
    float c = cosf(radians);
    float s = sinf(radians);
    
    GLfloat zRotation[16] =
    {
        c, -s, 0, 0.0,
        s, c, 0,  0,
        0, 0, 1.0, 0,//
        0.0, 0, 0, 1.0//
    };
    
//    glUniformMatrix4fv(rorate, 1, GL_FALSE, (GLfloat *)&zRotation[0]);
//    
//    glDrawArrays(GL_TRIANGLES, 0, 6);
//    [self.myContext presentRenderbuffer:GL_RENDERBUFFER];
    
    
    //设置旋转矩阵
    glUniformMatrix4fv(rorate, 1, GL_FALSE, (GLfloat *)&zRotation[0]);
    
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
    [self.myContext presentRenderbuffer:GL_RENDERBUFFER];
}

/**
 *  c语言编译流程：预编译、编译、汇编、链接
 *  glsl的编译过程主要有glCompileShader、glAttachShader、glLinkProgram三步；
 *  @param vert 顶点着色器
 *  @param frag 片元着色器
 *
 *  @return 编译成功的shaders
 */
- (GLint)loadShader:(NSString *)vert frag:(NSString *)frag
{
    GLuint vertSharder, fragShader;
    GLuint program = glCreateProgram();
    
    //编译
    [self compileShader:&vertSharder type:GL_VERTEX_SHADER filePath:vert];
    [self compileShader:&fragShader type:GL_FRAGMENT_SHADER filePath:frag];
    
    glAttachShader(program, vertSharder);
    glAttachShader(program, fragShader);
    
    //释放不需要的shader
    glDeleteShader(vertSharder);
    glDeleteShader(fragShader);
    
    return program;
}

- (void)compileShader:(GLuint *)shader type:(GLenum)type filePath:(NSString *)filePath
{
    NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    const GLchar *souce = (GLchar *)[content UTF8String];
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &souce, NULL);
    glCompileShader(*shader);
}

- (void)setupTexture
{
    // 1获取图片的CGImageRef
    CGImageRef img = [UIImage imageNamed:@"for_test"].CGImage;
    if (!img) {
        NSLog(@"Failed to load image: for_test");
        exit(1);
    }
    
    // 2 读取图片的大小
    size_t imgWith = CGImageGetWidth(img);
    size_t imgHeight = CGImageGetHeight(img);
    
    GLubyte *imgData = (GLubyte *)calloc((imgWith * imgHeight)*4, sizeof(GLubyte));
    CGContextRef imgContext = CGBitmapContextCreate(imgData, imgWith, imgHeight, 8, imgWith * 4, CGImageGetColorSpace(img), kCGImageAlphaPremultipliedLast);
    
    //3在CGContextRef上绘图
    CGContextDrawImage(imgContext, CGRectMake(0, 0, imgWith, imgHeight), img);
    CGContextRelease(imgContext);
    
    //4绑定纹理到默认的纹理ID（这里只有一张图片，故而相当于默认于片元着色器里面的colorMap，如果有多张图不可以这么做）
    glBindTexture(GL_TEXTURE_2D, 0);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    float fw = imgWith, fh = imgHeight;
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fw, fh, 0, GL_RGBA, GL_UNSIGNED_BYTE, imgData);
//    glBindTexture(GL_TEXTURE_2D, 0);
    free(imgData);
    
}

@end
