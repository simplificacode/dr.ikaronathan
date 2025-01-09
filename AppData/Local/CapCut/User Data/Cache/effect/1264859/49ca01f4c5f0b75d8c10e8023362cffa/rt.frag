precision highp float;
varying highp vec2 uv0;
uniform sampler2D _MainTex;
uniform float u_blurSize;
uniform vec2 ratio;

const vec2 dir = vec2(0., 1.);

float Gaussian (float x)
{
    float sigma = 5.5;
    return exp(-(x*x) / (2.0 * sigma*sigma));
}
vec4 gauss_blur(sampler2D inputTexture, vec2 uv, float blurSize)
{

    vec4 result         = vec4(0.0);
    vec2 unit_uv        = vec2(blurSize) * ratio / vec2(1000.);
    vec4 centerPixel    = texture2D(inputTexture, uv);
    float sum_weight    = 1.;

    vec2 curPositiveCoordinate = uv;
    vec2 curNegativeCoordinate = uv;

    for(int i=1; i<=16; i++)
    {
        curPositiveCoordinate    += dir * unit_uv;
        curNegativeCoordinate    -= dir * unit_uv;
        float fX = Gaussian(float(i));
        centerPixel += texture2D(inputTexture, curPositiveCoordinate) * fX;
        centerPixel += texture2D(inputTexture, curNegativeCoordinate) * fX;
        sum_weight += fX * 2.0;
    }
    result = centerPixel / sum_weight;
    return result;
}

void main(void)
{
    gl_FragColor = gauss_blur(_MainTex, uv0, u_blurSize);
    // gl_FragColor = vec4(uv0,0,1);
}

