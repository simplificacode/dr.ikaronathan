precision highp float;
attribute vec3 position;
attribute vec2 texcoord0;
varying vec2 uv;
varying vec4 uv1;
uniform mat4 mvpMat;

void main()
{ 
  vec4 pos = vec4(position.xy, 0.0, 1.0);
  gl_Position = mvpMat * pos;
  // gl_Position = pos;
  uv1 = mvpMat * pos;
  uv = texcoord0;
}