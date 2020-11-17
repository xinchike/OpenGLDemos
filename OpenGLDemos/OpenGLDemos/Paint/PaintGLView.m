//
//  PaintGLView.m
//  OpenGLDemos
//
//  Created by cqh on 2017/10/25.
//  Copyright © 2017年 cqh. All rights reserved.
//

#import "PaintGLView.h"
#import <OpenGLES/ES2/gl.h>
#import <GLKit/GLKit.h>

#import "LYPoint.h"

#import "shaderUtil.h"
#import "fileUtil.h"
#import "debug.h"


//CONSTANTS:

#define kBrushOpacity		(1.0 / 3.0)
#define kBrushPixelStep		3
#define kBrushScale			2

//Shaders
enum{
    PROGRAM_POINT,
    NUM_PROGRAMS
};

enum{
    UNIFORM_MVP,
    UNIFORM_POINT_SIZE,
    UNIFORM_VERTEX_COLOR,
    UNIFORM_TEXTURE,
    NUM_UNIFORMS
};

enum{
    ATTRIB_VERTEX,
    NUM_ATTRIBS
};

typedef struct
{
    char *vert;
    char *frag;
    GLint uniform[NUM_UNIFORMS];
    GLuint id;
}programInfo_t;

programInfo_t myProgram[NUM_PROGRAMS] = {
    {"paint.vsh", "paint.fsh"},
};

//Texture
typedef struct{
    GLuint id;
    GLsizei width;
    GLsizei height;
}textureInfo_t;


@interface PaintGLView()
{
    GLint backingWidth;
    GLint backingHeight;
    
    EAGLContext *myContext;
    
    GLuint viewRenderBuffer, viewFrameBuffer;
    
    textureInfo_t brushTexture;
    GLfloat brushColor[4];
    
    BOOL firstTouch;
    BOOL needErase;
    
    //Shader objects
    GLuint vertexShader;
    GLuint fragmentShader;
    GLuint shaderProgram;
    
    //Buffer objects
    GLuint vboId;
    
    BOOL initialized;
    
    NSMutableArray *lyArr;
}
@end


@implementation PaintGLView

@synthesize  location;
@synthesize  previousLocation;


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

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self setupLayer];
        
        myContext = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
        if (!myContext || ![EAGLContext setCurrentContext:myContext]) {
            return nil;
        }
        
        self.contentScaleFactor = [UIScreen mainScreen].scale;
        
        needErase = YES;
    }
    return self;
}

- (void)layoutSubviews
{
    [EAGLContext setCurrentContext:myContext];
    
    if (!initialized) {
        initialized = [self initGL];
    }else{
        [self resizeFromLayer:(CAEAGLLayer *)self.layer];
    }
    
    if (needErase) {
        [self erase];
        needErase = NO;
    }
}

- (void)setupLayer
{
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    eaglLayer.opaque = YES;
    eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
}

- (BOOL)initGL
{
    glGenFramebuffers(1, &viewFrameBuffer);
    glGenRenderbuffers(1, &viewRenderBuffer);
    
    glBindFramebuffer(GL_FRAMEBUFFER, viewFrameBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, viewRenderBuffer);
    
    [myContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:(id<EAGLDrawable>)self.layer];
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, viewRenderBuffer);
    
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
    
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        return NO;
    }
    
    glViewport(0, 0, backingWidth, backingHeight);
    
    glGenBuffers(1, &vboId);
    
    brushTexture = [self textureFromName:@"Particle.png"];
    
    [self setupShaders];
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    
    return YES;
}

//- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer
//{
//    return YES;
//}

- (void)erase
{
    [EAGLContext setCurrentContext:myContext];
    
    glBindFramebuffer(GL_FRAMEBUFFER, viewFrameBuffer);
    glClearColor(0.0, 0.0, 0.0, 0.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glBindRenderbuffer(GL_RENDERBUFFER, viewRenderBuffer);
    [myContext presentRenderbuffer:GL_RENDERBUFFER];
}

- (textureInfo_t)textureFromName:(NSString *)name
{
    textureInfo_t textureInfo = {};
    
    CGImageRef brushImg;
    CGContextRef brushContext;
    GLubyte *brushData;
    size_t width, height;
    GLuint texId;
    
    UIImage *img = [UIImage imageNamed:name];
    if (img) {
        brushImg = img.CGImage;
        width = CGImageGetWidth(brushImg);
        height = CGImageGetHeight(brushImg);
        
        brushData = (GLubyte *)calloc(width * height * 4, sizeof(GLubyte));
        
        brushContext = CGBitmapContextCreate(brushData, width, height, 8, width * 4, CGImageGetColorSpace(brushImg), kCGImageAlphaPremultipliedLast);
        
        CGContextDrawImage(brushContext, CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height), brushImg);
        CGContextRelease(brushContext);
        
        glGenTextures(1, &texId);
        glBindTexture(GL_TEXTURE_2D, texId);
        
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei)width, (GLsizei)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, brushData);
        
        free(brushData);
        
        textureInfo.id = texId;
        textureInfo.width = (GLsizei)width;
        textureInfo.height = (GLsizei)height;
    }
    
    return textureInfo;
}

- (void)setupShaders
{
    for (int i = 0; i < NUM_PROGRAMS; i++) {
        char *vSrc = readFile(pathForResource(myProgram[i].vert));
        char *fSrc = readFile(pathForResource(myProgram[i].frag));
        GLsizei attribCount = 0;
        GLchar *attribUsed[NUM_ATTRIBS] = {0};
        GLint attrib[NUM_ATTRIBS] = {0};
        GLchar *attribName[NUM_ATTRIBS] = {"inVertex",};
        
        const GLchar *uniformName[NUM_UNIFORMS] = {
            "MVP", "pointSize", "vertexColor", "texture",
        };
        
        // auto-assign known attribs
        for (int j = 0; j < NUM_ATTRIBS; j++)
        {
            if (strstr(vSrc, attribName[j])) {
                attrib[attribCount] = j;
                attribUsed[attribCount++] = attribName[j];
            }
        }
        
        glueCreateProgram(vSrc, fSrc, attribCount, (const GLchar **)&attribUsed[0], attrib, NUM_UNIFORMS, &uniformName[0], myProgram[i].uniform, &myProgram[i].id);
        
        free(vSrc);
        free(fSrc);
        
        if (i == PROGRAM_POINT) {
            glUseProgram(myProgram[PROGRAM_POINT].id);
            
            glUniform1i(myProgram[PROGRAM_POINT].uniform[UNIFORM_TEXTURE], 0);
            
            GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0, backingWidth, 0, backingHeight, -1, 1);
            GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
            
            GLKMatrix4 MVPMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
            glUniformMatrix4fv(myProgram[PROGRAM_POINT].uniform[UNIFORM_MVP], 1, GL_FALSE, MVPMatrix.m);
            
            // point size
            glUniform1f(myProgram[PROGRAM_POINT].uniform[UNIFORM_POINT_SIZE], brushTexture.width / kBrushScale);
            
            // initialize brush color
            glUniform4fv(myProgram[PROGRAM_POINT].uniform[UNIFORM_VERTEX_COLOR], 1, brushColor);
        }
    }
    
    glError();
}

- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer
{
    // Allocate color buffer backing based on the current layer size
    glBindRenderbuffer(GL_RENDERBUFFER, viewRenderBuffer);
    [myContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
    
    // For this sample, we do not need a depth buffer. If you do, this is how you can allocate depth buffer backing:
    //    glBindRenderbuffer(GL_RENDERBUFFER, depthRenderbuffer);
    //    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, backingWidth, backingHeight);
    //    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderbuffer);
    
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
    {
        NSLog(@"Failed to make complete framebuffer objectz %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        return NO;
    }
    
    // Update projection matrix
    GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0, backingWidth, 0, backingHeight, -1, 1);
    GLKMatrix4 modelViewMatrix = GLKMatrix4Identity; // this sample uses a constant identity modelView matrix
    GLKMatrix4 MVPMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
    
    glUseProgram(myProgram[PROGRAM_POINT].id);
    glUniformMatrix4fv(myProgram[PROGRAM_POINT].uniform[UNIFORM_MVP], 1, GL_FALSE, MVPMatrix.m);
    
    // Update viewport
    glViewport(0, 0, backingWidth, backingHeight);
    
    return YES;
}

// Releases resources when they are not longer needed.
- (void)dealloc
{
    // Destroy framebuffers and renderbuffers
    if (viewFrameBuffer) {
        glDeleteFramebuffers(1, &viewFrameBuffer);
        viewFrameBuffer = 0;
    }
    if (viewRenderBuffer) {
        glDeleteRenderbuffers(1, &viewRenderBuffer);
        viewRenderBuffer = 0;
    }

    // texture
    if (brushTexture.id) {
        glDeleteTextures(1, &brushTexture.id);
        brushTexture.id = 0;
    }
    // vbo
    if (vboId) {
        glDeleteBuffers(1, &vboId);
        vboId = 0;
    }
    
    // tear down context
    if ([EAGLContext currentContext] == myContext)
        [EAGLContext setCurrentContext:nil];
}

// Drawings a line onscreen based on where the user touches
- (void)renderLineFromPoint:(CGPoint)start toPoint:(CGPoint)end
{
    static GLfloat*		vertexBuffer = NULL;
    static NSUInteger	vertexMax = 64;
    NSUInteger			vertexCount = 0,
    count,
    i;
    
    //	[EAGLContext setCurrentContext:context];
    glBindFramebuffer(GL_FRAMEBUFFER, viewFrameBuffer);
    
    // Convert locations from Points to Pixels
    CGFloat scale = self.contentScaleFactor;
    start.x *= scale;
    start.y *= scale;
    end.x *= scale;
    end.y *= scale;
    
    // Allocate vertex array buffer
    if(vertexBuffer == NULL)
        vertexBuffer = malloc(vertexMax * 2 * sizeof(GLfloat));
    
    // Add points to the buffer so there are drawing points every X pixels
    count = MAX(ceilf(sqrtf((end.x - start.x) * (end.x - start.x) + (end.y - start.y) * (end.y - start.y)) / kBrushPixelStep), 1);
    for(i = 0; i < count; ++i) {
        if(vertexCount == vertexMax) {
            vertexMax = 2 * vertexMax;
            vertexBuffer = realloc(vertexBuffer, vertexMax * 2 * sizeof(GLfloat));
        }
        
        vertexBuffer[2 * vertexCount + 0] = start.x + (end.x - start.x) * ((GLfloat)i / (GLfloat)count);
        vertexBuffer[2 * vertexCount + 1] = start.y + (end.y - start.y) * ((GLfloat)i / (GLfloat)count);
        vertexCount += 1;
    }
    
    // Load data to the Vertex Buffer Object
    glBindBuffer(GL_ARRAY_BUFFER, vboId);
    glBufferData(GL_ARRAY_BUFFER, vertexCount*2*sizeof(GLfloat), vertexBuffer, GL_DYNAMIC_DRAW);
    
    glEnableVertexAttribArray(ATTRIB_VERTEX);
    glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, GL_FALSE, 0, 0);
    
    // Draw
    glUseProgram(myProgram[PROGRAM_POINT].id);
    glDrawArrays(GL_POINTS, 0, (int)vertexCount);
    
    // Display the buffer
    glBindRenderbuffer(GL_RENDERBUFFER, viewRenderBuffer);
    [myContext presentRenderbuffer:GL_RENDERBUFFER];
}

//- (void)paint
//{
//    
//    //    NSMutableArray* mutableArr = [NSMutableArray array];
//    //    for (LYPoint* point in lyArr) {
//    //        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
//    //        [dict setObject:point.mX forKey:@"mX"];
//    //        [dict setObject:point.mY forKey:@"mY"];
//    //        [mutableArr addObject:dict];
//    //    }
//    for (int i = 0; i + 1 < lyArr.count; i += 2) {
//        LYPoint* lyPoint1 = lyArr[i];
//        LYPoint* lyPoint2 = lyArr[i + 1];
//        CGPoint point1, point2;
//        point1.x = lyPoint1.mX.floatValue;
//        point1.y = lyPoint1.mY.floatValue;
//        point2.x = lyPoint2.mX.floatValue;
//        point2.y = lyPoint2.mY.floatValue;
//        [self renderLineFromPoint:point1 toPoint:point2];
//    }
//}

// Handles the start of a touch
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGRect				bounds = [self bounds];
    UITouch*            touch = [[event touchesForView:self] anyObject];
    firstTouch = YES;
    // Convert touch point from UIView referential to OpenGL one (upside-down flip)
    location = [touch locationInView:self];
    location.y = bounds.size.height - location.y;
}

// Handles the continuation of a touch.
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGRect				bounds = [self bounds];
    UITouch*			touch = [[event touchesForView:self] anyObject];
    
    // Convert touch point from UIView referential to OpenGL one (upside-down flip)
    if (firstTouch) {
        firstTouch = NO;
        previousLocation = [touch previousLocationInView:self];
        previousLocation.y = bounds.size.height - previousLocation.y;
    } else {
        location = [touch locationInView:self];
        location.y = bounds.size.height - location.y;
        previousLocation = [touch previousLocationInView:self];
        previousLocation.y = bounds.size.height - previousLocation.y;
    }
    
    // Render the stroke
    [self renderLineFromPoint:previousLocation toPoint:location];
}

// Handles the end of a touch event when the touch is a tap.
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGRect				bounds = [self bounds];
    UITouch*            touch = [[event touchesForView:self] anyObject];
    if (firstTouch) {
        firstTouch = NO;
        previousLocation = [touch previousLocationInView:self];
        previousLocation.y = bounds.size.height - previousLocation.y;
        [self renderLineFromPoint:previousLocation toPoint:location];
    }
}

// Handles the end of a touch event.
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    // If appropriate, add code necessary to save the state of the application.
    // This application is not saving state.
    NSLog(@"cancell");
}

- (void)setBrushColorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue
{
    // Update the brush color
    brushColor[0] = red * kBrushOpacity;
    brushColor[1] = green * kBrushOpacity;
    brushColor[2] = blue * kBrushOpacity;
    brushColor[3] = kBrushOpacity;
    
    if (initialized) {
        glUseProgram(myProgram[PROGRAM_POINT].id);
        glUniform4fv(myProgram[PROGRAM_POINT].uniform[UNIFORM_VERTEX_COLOR], 1, brushColor);
    }
}


- (BOOL)canBecomeFirstResponder {
    return YES;
}

@end
