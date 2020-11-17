/* 
  shaderv.vsh
  ShaderDemo

  Created by cqh on 2017/9/25.
  Copyright © 2017年 cqh. All rights reserved.
*/

attribute vec4 position;
attribute vec2 textCoordinate;
uniform mat4 rotateMatrix;
varying lowp vec2 varyTextCoord;

void main ()
{
    varyTextCoord = textCoordinate;
    vec4 vPos = position;
    
    vPos = vPos * rotateMatrix;
    gl_Position = vPos;
}
