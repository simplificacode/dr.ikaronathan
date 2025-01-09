attribute vec4 position;
attribute vec2 texcoord0;
varying vec2 uv0;
uniform mat4 u_MVP;

uniform mat4 local_model;
uniform mat4 u_VP;
uniform mat4 father_model;
uniform vec2 u_ScreenParams;

void main()
{
    vec4 newPos = position;
    gl_Position = vec4(texcoord0 * 2.0 - 1.0, 0.0, 1.0);
    uv0 = texcoord0;
}
