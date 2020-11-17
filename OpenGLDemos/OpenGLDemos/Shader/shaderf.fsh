/* 
  shaderf.fsh
  ShaderDemo

  Created by cqh on 2017/9/25.
  Copyright © 2017年 cqh. All rights reserved.
*/


varying lowp vec2 varyTextCoord;
uniform sampler2D colorMap;

void main ()
{
    gl_FragColor = texture2D(colorMap, varyTextCoord);
}
