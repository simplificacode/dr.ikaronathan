precision highp float;

// attribute vec3 attPosition;
// attribute vec2 attUV;

// varying vec2 uv;
// varying vec2 uRenderSize;

// uniform int baseTexWidth;
// uniform int baseTexHeight;

// void main() {
//     gl_Position = vec4(attPosition,1.0);
//     uv = attUV;
//     uRenderSize = vec2(baseTexWidth, baseTexHeight);
// }

attribute vec3 attPosition;
attribute vec2 attUV;
varying vec2 textureCoordinate;
void main()
{
    gl_Position = vec4(attPosition, 1.);
    textureCoordinate = attUV;
}
