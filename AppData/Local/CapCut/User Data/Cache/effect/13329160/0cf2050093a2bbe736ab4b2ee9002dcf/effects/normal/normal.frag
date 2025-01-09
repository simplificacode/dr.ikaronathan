precision highp float;

varying vec2 uv0;

uniform sampler2D _MainTex;
uniform vec2 u_ScreenParams;

void main()
{
    vec2 uv1 = uv0;
    uv1 = 1.-uv1;
    vec4 res = texture2D(_MainTex, uv1);
    // res = vec4(uv0,0,1);
    gl_FragColor = res;
}
