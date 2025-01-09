#if defined(AE_FRAMEBUFFER_FETCH)
    #if defined(GL_EXT_shader_framebuffer_fetch)
        #extension GL_EXT_shader_framebuffer_fetch : require
    #elif defined(GL_ARM_shader_framebuffer_fetch)
        #extension GL_ARM_shader_framebuffer_fetch : require
    #endif
#endif
#define ae_insert_flip_uniform

precision highp float;
varying vec2 texCoord;
varying vec2 sucaiTexCoord;

uniform sampler2D u_FBOTexture;
uniform sampler2D sucaiImageTexture;
uniform sampler2D reflectImageTexture;
uniform float opacity;
uniform float intensity;

#ifdef AMAZING_USE_CUSTOM_COLOR
uniform vec3 customColor;
#endif

#ifdef USE_SEG
varying vec2 segCoord;
uniform sampler2D segMaskTexture;
#endif

vec4 textureFromInput()
{
    #if defined(AE_FRAMEBUFFER_FETCH)
        #if defined(GL_EXT_shader_framebuffer_fetch)
            vec4 result = gl_LastFragData[0].rgba;
        #elif defined(GL_ARM_shader_framebuffer_fetch)
            vec4 result = gl_LastFragColorARM;
        #else
            #error AE_FRAMEBUFFER_FETCH but no ext found!
        #endif
    #else
        vec4 result = texture2D(u_FBOTexture, texCoord);
    #endif
    return result;
}

#if defined(AMAZING_USE_BLENDMODE_MUTIPLAY) || defined(AMAZING_USE_BLENDMODE_MUTIPLAY_FORREFLECT)
vec3 BlendMultiply(vec3 base, vec3 blend)
{
    return base * blend;
}
vec3 BlendMultiply(vec3 base, vec3 blend, float opacity)
{
    return (BlendMultiply(base, blend) * opacity + base * (1.0 - opacity));
}
#endif

#if defined(AMAZING_USE_BLENDMODE_OVERLAY) || defined(AMAZING_USE_BLENDMODE_OVERLAY_FORREFLECT)
float BlendOverlay(float base, float blend)
{
    return base < 0.5 ? (2.0 * base * blend) :(1.0 - 2.0 * (1.0 - base) * (1.0 - blend));
}
vec3 BlendOverlay(vec3 base, vec3 blend)
{
    return vec3(BlendOverlay(base.r, blend.r), BlendOverlay(base.g, blend.g), BlendOverlay(base.b, blend.b));
}
vec3 BlendOverlay(vec3 base, vec3 blend, float opacity)
{
    return (BlendOverlay(base, blend) * opacity + base * (1.0 - opacity));
}
#endif

#if defined(AMAZING_USE_BLENDMODE_ADD) || defined(AMAZING_USE_BLENDMODE_ADD_FORREFLECT)
vec3 BlendAdd(vec3 base, vec3 blend)
{
    return min(base + blend,vec3(1.0));
}
vec3 BlendAdd(vec3 base, vec3 blend, float opacity)
{
    return (BlendAdd(base, blend) * opacity + base * (1.0 - opacity));
}
#endif

#if defined(AMAZING_USE_BLENDMODE_SCREEN) || defined(AMAZING_USE_BLENDMODE_SCREEN_FORREFLECT)
vec3 BlendScreen(vec3 base, vec3 blend)
{
    return vec3(1.0) - ((vec3(1.0) - base) * (vec3(1.0) - blend));
}
vec3 BlendScreen(vec3 base, vec3 blend, float opacity)
{
    return (BlendScreen(base, blend) * opacity + base * (1.0 - opacity));
}
#endif

#if defined(AMAZING_USE_BLENDMODE_SOFTLIGHT) || defined(AMAZING_USE_BLENDMODE_SOFTLIGHT_FORREFLECT)
float BlendSoftLight(float base, float blend)
{
    return (blend<0.5)?(2.0*base*blend+base*base*(1.0-2.0*blend)):(sqrt(base)*(2.0*blend-1.0)+2.0*base*(1.0-blend));
}
vec3 BlendSoftLight(vec3 base, vec3 blend)
{
    return vec3(BlendSoftLight(base.r,blend.r),BlendSoftLight(base.g,blend.g),BlendSoftLight(base.b,blend.b));
}
vec3 BlendSoftLight(vec3 base, vec3 blend, float opacity)
{
    return (BlendSoftLight(base, blend) * opacity + base * (1.0 - opacity));
}
#endif

#if defined(AMAZING_USE_BLENDMODE_AVERAGE) || defined(AMAZING_USE_BLENDMODE_AVERAGE_FORREFLECT)
vec3 BlendAverage(vec3 base, vec3 blend)
{
    return (base + blend) / 2.0;
}
vec3 BlendAverage(vec3 base, vec3 blend, float opacity)
{
    return (BlendAverage(base, blend) * opacity + base * (1.0 - opacity));
}
#endif

#if defined(AMAZING_USE_BLENDMODE_COLORBURN) || defined(AMAZING_USE_BLENDMODE_COLORBURN_FORREFLECT)
float BlendColorBurn(float base, float blend)
{
    return (blend == 0.0) ? blend : max((1.0 - ((1.0 - base) / blend)),0.0);
}
vec3 BlendColorBurn(vec3 base, vec3 blend)
{
    return vec3(BlendColorBurn(base.r, blend.r), BlendColorBurn(base.g, blend.g), BlendColorBurn(base.b, blend.b));
}
vec3 BlendColorBurn(vec3 base, vec3 blend, float opacity)
{
    return (BlendColorBurn(base, blend) * opacity + base * (1.0 - opacity));
}
#endif

#if defined(AMAZING_USE_BLENDMODE_COLORDODGE) || defined(AMAZING_USE_BLENDMODE_COLORDODGE_FORREFLECT)
float BlendColorDodge(float base, float blend)
{
    return (blend == 1.0) ? blend : min(base / (1.0 - blend), 1.0);
}
vec3 BlendColorDodge(vec3 base, vec3 blend)
{
    return vec3(BlendColorDodge(base.r, blend.r), BlendColorDodge(base.g, blend.g), BlendColorDodge(base.b, blend.b));
}
vec3 BlendColorDodge(vec3 base, vec3 blend, float opacity)
{
    return (BlendColorDodge(base, blend) * opacity + base * (1.0 - opacity));
}
#endif

#if defined(AMAZING_USE_BLENDMODE_DARKEN) || defined(AMAZING_USE_BLENDMODE_DARKEN_FORREFLECT)
float BlendDarken(float base, float blend)
{
    return min(blend,base);
}
vec3 BlendDarken(vec3 base, vec3 blend)
{
    return vec3(BlendDarken(base.r,blend.r), BlendDarken(base.g,blend.g), BlendDarken(base.b,blend.b));
}
vec3 BlendDarken(vec3 base, vec3 blend, float opacity)
{
    return (BlendDarken(base, blend) * opacity + base * (1.0 - opacity));
}
#endif

#if defined(AMAZING_USE_BLENDMODE_DIFFERENCE) || defined(AMAZING_USE_BLENDMODE_DIFFERENCE_FORREFLECT)
vec3 BlendDifference(vec3 base, vec3 blend)
{
    return abs(base - blend);
}
vec3 BlendDifference(vec3 base, vec3 blend, float opacity)
{
    return (BlendDifference(base, blend) * opacity + base * (1.0 - opacity));
}
#endif

#if defined(AMAZING_USE_BLENDMODE_EXCLUSION) || defined(AMAZING_USE_BLENDMODE_EXCLUSION_FORREFLECT)
vec3 BlendExclusion(vec3 base, vec3 blend)
{
    return base + blend - 2.0 * base * blend;
}
vec3 BlendExclusion(vec3 base, vec3 blend, float opacity)
{
    return (BlendExclusion(base, blend) * opacity + base * (1.0 - opacity));
}
#endif

#if defined(AMAZING_USE_BLENDMODE_LIGHTEN) || defined(AMAZING_USE_BLENDMODE_LIGHTEN_FORREFLECT)
float BlendLighten(float base, float blend)
{
    return max(blend,base);
}
vec3 BlendLighten(vec3 base, vec3 blend)
{
    return vec3(BlendLighten(base.r,blend.r), BlendLighten(base.g,blend.g), BlendLighten(base.b,blend.b));
}
vec3 BlendLighten(vec3 base, vec3 blend, float opacity)
{
    return (BlendLighten(base, blend) * opacity + base * (1.0 - opacity));
}
#endif

#if defined(AMAZING_USE_BLENDMODE_LINEARDODGE) || defined(AMAZING_USE_BLENDMODE_LINEARDODGE_FORREFLECT)
float BlendLinearDodge(float base, float blend)
{
    return min(base + blend, 1.0);
}
vec3 BlendLinearDodge(vec3 base, vec3 blend)
{
    return min(base + blend,vec3(1.0));
}
vec3 BlendLinearDodge(vec3 base, vec3 blend, float opacity)
{
    return (BlendLinearDodge(base, blend) * opacity + base * (1.0 - opacity));
}
#endif

vec3 ApplyBlendMode(vec3 base, vec3 blend, float opacity)
{
    vec3 ret = blend;
#ifdef AMAZING_USE_BLENDMODE_MUTIPLAY
    ret = BlendMultiply(base, blend, opacity);
#endif

#ifdef AMAZING_USE_BLENDMODE_OVERLAY
    ret = BlendOverlay(base, blend, opacity);
#endif

#ifdef AMAZING_USE_BLENDMODE_ADD
    ret = BlendAdd(base, blend, opacity);
#endif

#ifdef AMAZING_USE_BLENDMODE_SCREEN
    ret = BlendScreen(base, blend, opacity);
#endif

#ifdef AMAZING_USE_BLENDMODE_SOFTLIGHT
    ret = BlendSoftLight(base, blend, opacity);
#endif

#ifdef AMAZING_USE_BLENDMODE_AVERAGE
    ret = BlendAverage(base, blend, opacity);
#endif

#ifdef AMAZING_USE_BLENDMODE_COLORBURN
    ret = BlendColorBurn(base, blend, opacity);
#endif

#ifdef AMAZING_USE_BLENDMODE_COLORDODGE
    ret = BlendColorDodge(base, blend, opacity);
#endif

#ifdef AMAZING_USE_BLENDMODE_DARKEN
    ret = BlendDarken(base, blend, opacity);
#endif

#ifdef AMAZING_USE_BLENDMODE_DIFFERENCE
    ret = BlendDifference(base, blend, opacity);
#endif

#ifdef AMAZING_USE_BLENDMODE_EXCLUSION
    ret = BlendExclusion(base, blend, opacity);
#endif

#ifdef AMAZING_USE_BLENDMODE_LIGHTEN
    ret = BlendLighten(base, blend, opacity);
#endif

#ifdef AMAZING_USE_BLENDMODE_LINEARDODGE
    ret = BlendLinearDodge(base, blend, opacity);
#endif
    return ret;
}

vec3 ApplyReflectBlendMode(vec3 base, vec3 blend, float opacity)
{
    vec3 ret = blend;
#ifdef AMAZING_USE_BLENDMODE_MUTIPLAY_FORREFLECT
    ret = BlendMultiply(base, blend, opacity);
#endif

#ifdef AMAZING_USE_BLENDMODE_OVERLAY_FORREFLECT
    ret = BlendOverlay(base, blend, opacity);
#endif

#ifdef AMAZING_USE_BLENDMODE_ADD_FORREFLECT
    ret = BlendAdd(base, blend, opacity);
#endif

#ifdef AMAZING_USE_BLENDMODE_SCREEN_FORREFLECT
    ret = BlendScreen(base, blend, opacity);
#endif

#ifdef AMAZING_USE_BLENDMODE_SOFTLIGHT_FORREFLECT
    ret = BlendSoftLight(base, blend, opacity);
#endif

#ifdef AMAZING_USE_BLENDMODE_AVERAGE_FORREFLECT
    ret = BlendAverage(base, blend, opacity);
#endif

#ifdef AMAZING_USE_BLENDMODE_COLORBURN_FORREFLECT
    ret = BlendColorBurn(base, blend, opacity);
#endif

#ifdef AMAZING_USE_BLENDMODE_COLORDODGE_FORREFLECT
    ret = BlendColorDodge(base, blend, opacity);
#endif

#ifdef AMAZING_USE_BLENDMODE_DARKEN_FORREFLECT
    ret = BlendDarken(base, blend, opacity);
#endif

#ifdef AMAZING_USE_BLENDMODE_DIFFERENCE_FORREFLECT
    ret = BlendDifference(base, blend, opacity);
#endif

#ifdef AMAZING_USE_BLENDMODE_EXCLUSION_FORREFLECT
    ret = BlendExclusion(base, blend, opacity);
#endif

#ifdef AMAZING_USE_BLENDMODE_LIGHTEN_FORREFLECT
    ret = BlendLighten(base, blend, opacity);
#endif

#ifdef AMAZING_USE_BLENDMODE_LINEARDODGE_FORREFLECT
    ret = BlendLinearDodge(base, blend, opacity);
#endif
    return ret;
}

void main(void)
{
    lowp vec4 src = textureFromInput();
    float nonZeroSrcAlpha = step(0.0, -src.a) * 0.000001 + src.a;
    vec3 srcColor = clamp(src.rgb / nonZeroSrcAlpha, 0.0, 1.0);
    vec3 blendColor = srcColor;
    float blendAlpha = src.a;

#ifdef AMAZING_USE_SUCAI
    vec4 sucai = texture2D(sucaiImageTexture, sucaiTexCoord) * clamp(intensity * opacity, 0.0, 1.0);
#ifdef AMAZING_USE_CUSTOM_COLOR
    sucai.rgb = customColor * sucai.a;
#endif
    float nonZeroSucaiAlpha = step(0.0, -sucai.a) * 0.000001 + sucai.a;
    sucai.rgb = ApplyBlendMode(blendColor, clamp(sucai.rgb / nonZeroSucaiAlpha, 0.0, 1.0), 1.0);
    blendColor = mix(blendColor, sucai.rgb, sucai.a);
    blendAlpha = mix(sucai.a, 1.0, blendAlpha);
#endif

#ifdef AMAZING_USE_REFLECT
    vec4 reflect = texture2D(reflectImageTexture, sucaiTexCoord) * clamp(intensity * opacity, 0.0, 1.0);
    float nonZeroReflectAlpha = step(0.0, -reflect.a) * 0.000001 + reflect.a;
    reflect.rgb = ApplyReflectBlendMode(blendColor, clamp(reflect.rgb / nonZeroReflectAlpha, 0.0, 1.0), 1.0);
    blendColor = mix(blendColor, reflect.rgb, reflect.a);
    blendAlpha = mix(reflect.a, 1.0, blendAlpha);
#endif

#ifdef USE_SEG
    float seg_opacity = (texture2D(segMaskTexture, segCoord)).x;
    if(clamp(segCoord, 0.0, 1.0) != segCoord) seg_opacity = 1.;
    blendColor = mix(srcColor, blendColor, seg_opacity);
#endif
    gl_FragColor = vec4(blendColor, 1.0) * blendAlpha;
}