attribute vec4 position;
attribute vec2 texcoord0;
varying vec2 uv0;
uniform mat4 u_MVP;

uniform float mainTex_equal_null;

void main()
{
    vec4 newPos = position;
    gl_Position = vec4(position.xyz, 1.);
    uv0 = texcoord0;
    // uv0.y = 1.0 - uv0.y;
}
