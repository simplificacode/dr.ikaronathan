precision highp float;

varying vec2 fTexCoord;
uniform sampler2D _MainTex;
uniform float alpha;
uniform float curalpha;

void main()
{
    vec4 c = vec4(0.0, 0.0, 0.0, 0.0);
    c = texture2D(_MainTex, fTexCoord);
    c *= alpha;
    float mixalpha = smoothstep(0.0,0.02,fTexCoord.x)*(1.0-smoothstep(0.980,1.0,fTexCoord.x))*smoothstep(0.0,0.02,fTexCoord.y)*(1.0-smoothstep(0.980,1.0,fTexCoord.y));
    gl_FragColor = c*curalpha;
}
