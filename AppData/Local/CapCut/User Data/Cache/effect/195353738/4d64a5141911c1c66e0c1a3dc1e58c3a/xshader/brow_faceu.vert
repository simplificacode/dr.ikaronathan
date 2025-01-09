attribute vec2 attPosition;
attribute vec2 attPosition1;
attribute vec2 attUV;

varying vec2 texCoord;
#ifdef BROWTHIN
varying vec2 texCoord1;
#endif
varying vec2 sucaiTexCoord;

uniform mat4 uMVPMatrix;
uniform mat4 uSTMatrix;

#ifdef USE_SEG
varying vec2 segCoord;
uniform mat4 uSegMatrix;
#endif

void main(void)
{
    gl_Position = uMVPMatrix * vec4(attPosition, 0.0, 1.0);
    texCoord = 0.5 * gl_Position.xy + 0.5;

#ifdef BROWTHIN
    vec4 coord0 = uMVPMatrix * vec4(attPosition1, 0.0, 1.0);
    texCoord1 = 0.5 * coord0.xy + 0.5;
#endif
    vec4 coord1 = uSTMatrix * vec4(attUV.xy, 0.0, 1.0);
    sucaiTexCoord = vec2(coord1.x, 1.0 - coord1.y);

#ifdef USE_SEG
    segCoord = (uSegMatrix * vec4(attPosition, 0.0, 1.0)).xy;
#endif
}