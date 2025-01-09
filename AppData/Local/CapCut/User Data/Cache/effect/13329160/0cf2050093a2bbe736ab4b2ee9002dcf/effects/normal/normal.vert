attribute vec4 position;
attribute vec2 texcoord0;
varying vec2 uv0;
uniform mat4 u_MVP;

uniform float mainTex_equal_null;

void main()
{
    vec4 newPos = position;
    if(mainTex_equal_null > 0.5){
        gl_Position = u_MVP * newPos;
    }else{
        gl_Position = vec4(sign(newPos.xyz), newPos.w);
    }
    uv0 = texcoord0;
    uv0.y = 1.0 - uv0.y;
}
