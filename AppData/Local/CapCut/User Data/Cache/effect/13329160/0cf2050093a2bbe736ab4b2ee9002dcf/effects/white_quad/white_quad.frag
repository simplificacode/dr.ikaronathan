precision highp float;

varying vec2 uv0;
varying vec3 uv1;

uniform sampler2D mainTex;
uniform vec2 textSize;

uniform float extra_scale;

uniform float alpha;
void CornerPositioning(vec3 i_uv, out vec2 o_uv){
    o_uv = i_uv.xy/i_uv.z;
}


float cut(vec2 _u){ return step(0., _u.x) * step(_u.x, 1.) * step(0., _u.y) * step(_u.y, 1.); }

void main()
{
    vec2 used_uv1=vec2(0); CornerPositioning(uv1, used_uv1);
    vec2 uv1 = uv0;
    uv1 -= 0.5;
    // if(textSize.x > textSize.y){
    //     uv1.y *= textSize.x/textSize.y;
    // }else{
    //     uv1.x *= textSize.y/textSize.x;
    // }
    uv1 += 0.5;
    // uv1.y = 1.-uv1.y;
    // uv1 -= 0.5;
    // // uv1 *= extra_scale;
    // uv1 += 0.5;
    // vec4 res = texture2D(mainTex, used_uv1);
    vec4 res = texture2D(mainTex, uv1);
    // res *= cut(used_uv1);
    // res = mix(vec4(uv0,0,1), res, res.a);
    // res.a *= alpha;
    // res = vec4(1,0,0,1);
    gl_FragColor = res;
}
