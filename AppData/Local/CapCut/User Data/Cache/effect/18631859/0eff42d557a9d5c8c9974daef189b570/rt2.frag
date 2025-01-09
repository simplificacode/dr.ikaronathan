precision highp float;

uniform sampler2D _MainTex;
uniform sampler2D u_LastTex;
uniform vec2 texSize;
uniform float blurStep;

varying vec2 uv0;

uniform float isBlur;
uniform float angle;

uniform float fade;
uniform float colll;
uniform vec2 u_ScreenParams;

uniform float first_frame;
uniform float sdfwidth;
uniform float sdfHeight;

uniform float GlowRange; 
uniform float y_indez;
uniform float mask_width;
uniform float mask_right;
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

    uv.x = uv.x-(-w_stren*(uv.y*8.0-2.80))*progress;
    vec4 inputColor = texture2D(u_LastTex, uv);
    vec4 result = inputColor;
    float sum = 1.0;
    float dx = 2.0/u_ScreenParams.x;
    for(float j=1.0 ; j < 25. ; j+= 1.0)
    {
        // left
        vec2 samplerTexCoord = vec2(uv.x + j*dx*y_indez, uv.y);
        float uvPro = uvProtect(samplerTexCoord);
        vec4 tc = texture2D(u_LastTex, samplerTexCoord);
        result += tc*uvPro;
        sum += 1.0*uvPro;

        vec2 samplerTexCoord1 = vec2(uv.x - j*dx*y_indez, uv.y );
        uvPro = uvProtect(samplerTexCoord1);
        vec4 tc1 = texture2D(u_LastTex,samplerTexCoord1);
        result += tc1*uvPro;
        sum += 1.0*uvPro;

        if(j>GlowRange)
        break;
    }
    result/=(sum);

    vec4 oriCol=texture2D(_MainTex, uv);

    vec2 uv1 = uv;
    uv1 -= 0.5;
    uv1 = uv1*texFixScale;
    uv1 += 0.5;

//    vec4 org = oriCol*smoothstep(1.0,0.95,progress)*smoothstep(mask_right+mask_width/4.0-0.001,mask_right+mask_width*0.8,uv1.x);
//    result =result*smoothstep(-0.0001,0.0001,progress)*smoothstep(1.0,0.999,progress);
//    gl_FragColor = mix(result,org/(org.a+0.0001),org.a);

    vec4 org = oriCol*smoothstep(1.0,0.95,progress)*smoothstep(mask_right-mask_width/4.0+0.001,mask_right-mask_width*0.8,uv1.x);
    result =result*smoothstep(-0.0001,0.0001,progress)*smoothstep(1.0,0.999,progress);
    gl_FragColor = mix(result,org/(org.a+0.0001),org.a);
}
