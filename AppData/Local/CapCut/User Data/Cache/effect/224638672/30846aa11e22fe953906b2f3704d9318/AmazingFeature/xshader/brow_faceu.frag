precision highp float;
varying vec2 texCoord;
varying vec2 sucaiTexCoord;

uniform sampler2D u_FBOTexture;
uniform sampler2D sucaiImageTexture;
uniform float opacity;
uniform float intensity;

#ifdef BROWTHIN
varying vec2 texCoord1;
uniform float thinOpacity;
uniform float thinIntensity;
uniform sampler2D maskImageTexture;
#endif

#ifdef USE_SEG
varying vec2 segCoord;
uniform sampler2D segMaskTexture;
#endif


#ifdef AMAZING_USE_BLENDMODE_MUTIPLAY
vec3 BlendMultiply(vec3 base, vec3 blend)
{
    return base * blend;
}
vec3 BlendMultiply(vec3 base, vec3 blend, float opacity)
{
    return (BlendMultiply(base, blend) * opacity + base * (1.0 - opacity));
}
#endif

#ifdef AMAZING_USE_BLENDMODE_OVERLAY
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

#ifdef AMAZING_USE_BLENDMODE_ADD
vec3 BlendAdd(vec3 base, vec3 blend)
{
    return min(base + blend,vec3(1.0));
}
vec3 BlendAdd(vec3 base, vec3 blend, float opacity)
{
    return (BlendAdd(base, blend) * opacity + base * (1.0 - opacity));
}
#endif

#ifdef AMAZING_USE_BLENDMODE_SCREEN
vec3 BlendScreen(vec3 base, vec3 blend)
{
    return vec3(1.0) - ((vec3(1.0) - base) * (vec3(1.0) - blend));
}
vec3 BlendScreen(vec3 base, vec3 blend, float opacity)
{
    return (BlendScreen(base, blend) * opacity + base * (1.0 - opacity));
}
#endif

#ifdef AMAZING_USE_BLENDMODE_SOFTLIGHT
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

#ifdef AMAZING_USE_BLENDMODE_AVERAGE
vec3 BlendAverage(vec3 base, vec3 blend)
{
    return (base + blend) / 2.0;
}
vec3 BlendAverage(vec3 base, vec3 blend, float opacity)
{
    return (BlendAverage(base, blend) * opacity + base * (1.0 - opacity));
}
#endif

#ifdef AMAZING_USE_BLENDMODE_COLORBURN
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

#ifdef AMAZING_USE_BLENDMODE_COLORDODGE
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

#ifdef AMAZING_USE_BLENDMODE_DARKEN
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

#ifdef AMAZING_USE_BLENDMODE_DIFFERENCE
vec3 BlendDifference(vec3 base, vec3 blend)
{
    return abs(base - blend);
}
vec3 BlendDifference(vec3 base, vec3 blend, float opacity)
{
    return (BlendDifference(base, blend) * opacity + base * (1.0 - opacity));
}
#endif

#ifdef AMAZING_USE_BLENDMODE_EXCLUSION
vec3 BlendExclusion(vec3 base, vec3 blend)
{
    return base + blend - 2.0 * base * blend;
}
vec3 BlendExclusion(vec3 base, vec3 blend, float opacity)
{
    return (BlendExclusion(base, blend) * opacity + base * (1.0 - opacity));
}
#endif

#ifdef AMAZING_USE_BLENDMODE_LIGHTEN
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

#ifdef AMAZING_USE_BLENDMODE_LINEARDODGE
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

void main(void)
{
#ifdef BROWTHIN
    vec2 offset = texCoord1 - texCoord;
    float weight = texture2D(maskImageTexture, sucaiTexCoord).r;
    offset = offset * weight * thinIntensity * thinOpacity * 1.0;
    vec2 coord = texCoord + offset;
#else
    vec2 coord = texCoord;
#endif

    lowp vec4 src = texture2D(u_FBOTexture, coord);
    vec4 sucai = texture2D(sucaiImageTexture, sucaiTexCoord) * clamp(intensity * opacity, 0.0, 1.0);

    float nonZeroSrcAlpha = step(0.0, -src.a) * 0.000001 + src.a;
    float nonZeroSucaiAlpha = step(0.0, -sucai.a) * 0.000001 + sucai.a;

    vec3 srcColor = clamp(src.rgb / nonZeroSrcAlpha, 0.0, 1.0);
    vec3 blendColor = ApplyBlendMode(srcColor, clamp(sucai.rgb / nonZeroSucaiAlpha, 0.0, 1.0), 1.0);
    blendColor = mix(srcColor, blendColor, sucai.a);

#ifdef USE_SEG
    float seg_opacity = (texture2D(segMaskTexture, segCoord)).x;
    if(clamp(segCoord, 0.0, 1.0) != segCoord) seg_opacity = 1.;
    blendColor = mix(srcColor, blendColor, seg_opacity);
#endif
    gl_FragColor = vec4(blendColor, 1.0) * src.a;
}