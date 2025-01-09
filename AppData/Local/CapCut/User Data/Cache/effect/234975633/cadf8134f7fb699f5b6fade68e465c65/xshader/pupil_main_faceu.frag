
precision highp float;
varying vec2 texCoord;
varying vec2 sucaiTexCoord;
varying float weight;

uniform sampler2D inputImageTexture;
uniform sampler2D blendmodeNormalTexture;
uniform sampler2D blendmodeScreenTexture;
uniform sampler2D reflectImageTexture;

uniform float intensity;
uniform float opacity;

#ifdef USE_SEG
varying vec2 segCoord;
uniform sampler2D segMaskTexture;
#endif

const float EPSC = 0.001;

#if defined(AMAZING_USE_BLENDMODE_MULTIPLY) || defined(AMAZING_USE_BLENDMODE_MULTIPLY_FORREFLECT)
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

vec3 ApplyBlendModeNormal(vec3 base, vec3 blend, float opacity)
{
    vec3 ret = blend;
    return ret;
}

vec3 ApplyBlendModeScreen(vec3 base, vec3 blend, float opacity)
{
    vec3 ret = blend;
#ifdef AMAZING_USE_BLENDMODE_SCREEN
    ret = BlendScreen(base, blend, opacity);
#endif
    return ret;
}

void main(void)
{
    lowp vec4 src = texture2D(inputImageTexture, texCoord);
    float nonZeroSrcAlpha = max(0.0001, src.a);
    vec3 srcColor = clamp(src.rgb / nonZeroSrcAlpha, 0.0, 1.0);
    vec3 blendColor = srcColor;

#ifdef AMAZING_USE_BLENDMODE_NORMAL_TEXTURE
    vec4 normal_sucai = texture2D(blendmodeNormalTexture, sucaiTexCoord);
    normal_sucai *= clamp(opacity, 0.0, 1.0);
    float nonZeroNormalSucaiAlpha = max(0.0001, normal_sucai.a);
    normal_sucai.rgb = ApplyBlendModeNormal(blendColor, clamp(normal_sucai.rgb / nonZeroNormalSucaiAlpha, 0.0, 1.0), 1.0);
    blendColor = mix(blendColor, normal_sucai.rgb, normal_sucai.a);
#endif

#ifdef AMAZING_USE_BLENDMODE_SCREEN_TEXTURE
    vec4 screen_sucai = texture2D(blendmodeScreenTexture, sucaiTexCoord);
    screen_sucai *= clamp(opacity, 0.0, 1.0);
    float nonZeroScreenSucaiAlpha = max(0.0001, screen_sucai.a);
    screen_sucai.rgb = ApplyBlendModeScreen(blendColor, clamp(screen_sucai.rgb / nonZeroScreenSucaiAlpha, 0.0, 1.0), 1.0);
    blendColor = mix(blendColor, screen_sucai.rgb, screen_sucai.a);
#endif

#ifdef USE_SEG
    float seg_opacity = texture2D(segMaskTexture, segCoord).x;
    if (clamp(segCoord, 0.0, 1.0) != segCoord) seg_opacity = 1.;
    blendColor = mix(srcColor, blendColor, seg_opacity);
#endif

    float opacity_ = opacity > EPSC ? 1.0 : opacity;
    gl_FragColor = vec4(mix(srcColor, blendColor, weight * intensity * opacity_), 1.0) * src.a;
}
