precision highp float;

uniform sampler2D _MainTex;
uniform vec2 texSize;
uniform float blurStep;

varying vec2 uv0;

uniform float isBlur;
uniform float angle;

uniform float fade;
uniform float colll;
uniform vec2 u_ScreenParams;

uniform float first_frame;

uniform float GlowRange; 
uniform float y_indez;
uniform float mask_width;
uniform float mask_right;

uniform float sdfwidth;
uniform float sdfHeight;
uniform float progress;
uniform float w_stren;
uniform float offset_x;
uniform float texFixScale;

#define num 16

float Gaussian (float x)
{
    float sigma = 5.5;
    return exp(-(x*x) / (2.0 * sigma*sigma));
}


float uvProtect(vec2 samplerTexCoord)
{
    return step(0.,samplerTexCoord.x)*step(0.,samplerTexCoord.y)*step(samplerTexCoord.x,1.0)*step(samplerTexCoord.y,1.0);
}

void main()
{
    vec2 uv = uv0;

    uv.x = uv.x-(-w_stren*(uv.y+0.0001)-.0)*progress*0.5;

    vec4 result = texture2D(_MainTex, uv);
    float sum = 1.0;
    float dx = 2.0 / u_ScreenParams.x ;

    vec2 uv1 = uv;
    uv1 -= 0.5;
    uv1 = uv1*texFixScale;
    uv1 += 0.5;

    float fix_left = mask_right+0.02;
    float visible = smoothstep(fix_left+0.01,fix_left,uv1.x)*smoothstep(fix_left-0.01-mask_width,fix_left-mask_width,uv1.x);

    gl_FragColor = result*visible;
//    gl_FragColor = texture2D(_MainTex, uv0);
}
