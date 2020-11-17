/* 
  Paint.fsh
  OpenGLDemos

  Created by cqh on 2017/10/27.
  Copyright © 2017年 cqh. All rights reserved.
*/

uniform sampler2D texture;
varying lowp vec4 color;

void main()
{
    gl_FragColor = color * texture2D(texture, gl_PointCoord);
}
