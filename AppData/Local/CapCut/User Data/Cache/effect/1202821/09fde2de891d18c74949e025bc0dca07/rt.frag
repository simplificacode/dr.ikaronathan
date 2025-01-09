precision highp float;
varying highp vec2 uv0;
varying highp float heightN;
uniform sampler2D _MainTex;
uniform sampler2D noiseTexture;

uniform float _time;
uniform float _upper;
uniform float _lowwer;
uniform highp vec4 texSize;
float n11(float p){
    return fract(sin(p*101.)*2727.)*0.45+0.22*(sin(p*20. - 1.35)+1.0)/2.;
}
void main(void)
{
    vec2 uv = uv0;
    vec2 newuv = uv;
    float myW = 2.4;
    float textX = floor(uv.x*texSize.x/myW)*myW/texSize.x;
    float mytime = _time;
    float offset = mytime+n11(textX);
    newuv.y = clamp(heightN*uv.y-(heightN-1.)*mix(1.0,0.0,smoothstep(0.0,1.0,offset)),0.0,1.0);
    vec4 mainColor = texture2D(_MainTex,newuv);
    mainColor*=smoothstep(0.65,0.25,uv.y)*smoothstep(0.05,0.6,mytime);
    gl_FragColor = mainColor;
}