precision lowp float;
varying highp vec2 uv0;
uniform sampler2D _MainTex;

void main()
{
    gl_FragColor = texture2D(_MainTex, uv0);
}
