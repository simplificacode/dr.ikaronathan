precision highp float;
varying highp vec2 uv0;
uniform sampler2D inputTextureX;
uniform vec4 u_ScreenParams;
uniform float u_StrengthX;
uniform float blurscale1;

vec4 gauss_blur(sampler2D inputTexture, vec2 uv, float angle, float blurSize, vec2 uRenderSize)
{
    float half_gaussian_weight[9];

    float radian = 3.1415926 * angle / 180.0;
    vec2 dir = vec2(cos(radian), sin(radian));
    
    half_gaussian_weight[0]= 0.2;   //0.2;//0.137401;
    half_gaussian_weight[1]= 0.19;  //0.2;//0.125794;
    half_gaussian_weight[2]= 0.17;  //0.2;//0.106483;
    half_gaussian_weight[3]= 0.15;  //0.2;//0.080657;
    half_gaussian_weight[4]= 0.13;  //0.2;//0.054670;
    half_gaussian_weight[5]= 0.11;  //0.2;//0.033159;
    half_gaussian_weight[6]= 0.08;  //0.2;//0.017997;
    half_gaussian_weight[7]= 0.05;  //0.2;//0.008741;
    half_gaussian_weight[8]= 0.02;  //0.2;//0.003799;

    vec4 sum            = vec4(0.0);
    vec4 result         = vec4(0.0);
    vec2 unit_uv        = vec2(blurSize / uRenderSize.x, blurSize / uRenderSize.y)*1.25;
    vec4 centerPixel    = texture2D(inputTexture, uv) * half_gaussian_weight[0];
    float sum_weight    = half_gaussian_weight[0];

    vec2 curPositiveCoordinate = uv;
    vec2 curNegativeCoordinate = uv;

    for(int i=1; i<9; i++)
    {
        curPositiveCoordinate    += dir * unit_uv;
        curNegativeCoordinate    -= dir * unit_uv;
        sum += texture2D(inputTexture, curPositiveCoordinate) * half_gaussian_weight[i];
        sum += texture2D(inputTexture, curNegativeCoordinate) * half_gaussian_weight[i];
        sum_weight += half_gaussian_weight[i] * 2.0;
    }
    result = (sum + centerPixel) / sum_weight;
    return result;
}
void main()
{
    vec4 resColor = gauss_blur(inputTextureX, uv0, 0.0, u_StrengthX*blurscale1, u_ScreenParams.xy);
    gl_FragColor = resColor;
}
