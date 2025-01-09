precision highp float;

uniform sampler2D u_LastTex1;
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

    vec4 result = texture2D(u_LastTex1, uv);
    float sum = 1.0;
    float dx = 2.0/u_ScreenParams.x;

    for(float j=1.0 ; j < 25. ; j+= 1.0)
    {
        vec2 samplerTexCoord = vec2(uv.x + j*dx*y_indez, uv.y);
        float uvPro = uvProtect(samplerTexCoord);
        vec4 tc = texture2D(u_LastTex1, samplerTexCoord);
        result += tc*uvPro;
        sum += 1.0*uvPro;

        vec2 samplerTexCoord1 = vec2(uv.x - j*dx*y_indez, uv.y );
        uvPro = uvProtect(samplerTexCoord1);
        vec4 tc1 = texture2D(u_LastTex1,samplerTexCoord1);
        result += tc1*uvPro;
        sum += 1.0*uvPro;

        if(j>GlowRange)
        break;
    }
    result/=(sum);

    gl_FragColor = result;

}
