
precision highp float;
varying vec2 texCoord;
varying vec2 maskTexCoord;

uniform sampler2D inputImageTexture;
uniform sampler2D maskImageTexture;

void main(void)
{
    lowp vec4 src = texture2D(inputImageTexture, texCoord);
    float alpha = texture2D(maskImageTexture, maskTexCoord).r;
    src = src * alpha;
    gl_FragColor = src;
}
