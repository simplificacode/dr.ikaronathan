attribute vec2 attPosition;
attribute vec2 attUV;

varying vec2 texCoord;
varying vec2 maskTexCoord;

uniform mat4 uMVPMatrix;
uniform mat4 uSTMatrix;

void main(void){
    gl_Position = uMVPMatrix * vec4(attPosition, 0.0, 1.0);
    texCoord = 0.5 * gl_Position.xy + 0.5;
    vec2 coord = (uSTMatrix * vec4(attUV.xy, 0.0, 1.0)).xy;
    maskTexCoord = vec2(coord.x, 1.0 - coord.y);
}