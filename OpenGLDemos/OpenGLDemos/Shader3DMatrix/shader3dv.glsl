/* 
  shader3dv.glsl
  OpenGLDemos

  Created by cqh on 2017/10/12.
  Copyright © 2017年 cqh. All rights reserved.
*/


attribute vec4 vPosition;
attribute vec4 vPositionColor;
uniform mat4 projectionMatrix;
uniform mat4 modelViewMatrix;

varying lowp vec4 varyColor;

void main ()
{
    varyColor = vPositionColor;
    
    vec4 vPos = projectionMatrix * modelViewMatrix * vPosition;
    gl_Position = vPos;
}
