precision highp float;
varying highp vec2 uv0;
uniform sampler2D _MainTex;
uniform vec2 offset;
uniform float appear;
void main(void)
{
    vec4 mainColor = texture2D(_MainTex,uv0+offset);
    gl_FragColor = mainColor * appear;
}