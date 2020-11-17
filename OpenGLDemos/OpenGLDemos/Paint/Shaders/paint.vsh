/* 
  paint.vsh
  OpenGLDemos

  Created by cqh on 2017/10/27.
  Copyright © 2017年 cqh. All rights reserved.
*/


attribute vec4 inVertex;
uniform mat4 MVP;
uniform float pointSize;
uniform lowp vec4 vertexColor;

varying lowp vec4 color;

void main()
{
    gl_Position = MVP * inVertex;
    gl_PointSize = pointSize;
    
    color = vertexColor;
}
