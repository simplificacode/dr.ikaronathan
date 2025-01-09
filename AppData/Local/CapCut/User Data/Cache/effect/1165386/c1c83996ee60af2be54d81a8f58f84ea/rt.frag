precision mediump float;
varying highp vec2 uv0;

uniform sampler2D _MainTex;
uniform float deg;
uniform highp vec4 texSize;


void main()
{
    lowp vec4 curColor = texture2D(_MainTex,uv0);
    float progress = deg;
    float cur_progress = progress*0.5;
    lowp vec4 resultColor = curColor;
    if(uv0.x<0.5-cur_progress)
    {
        lowp vec4 edgeColor = texture2D(_MainTex,vec2(0.5-cur_progress,uv0.y));
        resultColor = edgeColor;
    }
    else if(uv0.x>0.5+cur_progress)
    {
        lowp vec4 edgeColor = texture2D(_MainTex,vec2(0.5+cur_progress,uv0.y));
        resultColor = edgeColor;
    }
    gl_FragColor = resultColor;
}