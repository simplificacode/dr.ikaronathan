precision lowp float;
varying highp vec2 uv;
varying highp vec4 uv1;
uniform sampler2D ganTexture;

uniform float u_h;
uniform float u_s_factor;

// varying vec2 faceUV;
uniform mat4 uFaceSegMVP;
uniform float uFaceSegDetected;
uniform sampler2D uFaceSeg;
uniform vec4 u_ScreenParams; // built-in uniform
uniform vec4 u_nowColor; // built-in uniform

void main()
{
    // vec2 screenPosition = uv1.xy / uv1.w * 0.5 + 0.5;
    // screenPosition.y = 1.-screenPosition.y;
    // screenPosition = screenPosition * u_ScreenParams.xy;
    // vec2 faceUV = (uFaceSegMVP * vec4(screenPosition.xy, 0.0, 1.0)).xy;
    // float weight = 1.0;
    // vec4 maskFace = texture2D(uFaceSeg, faceUV);
    // float weightFace = maskFace.r;
    // // 0.1, to avoid some basecase at the edge
    // float uvFlagFace = 1.0 - step(0.1, faceUV.y);
    // weightFace = max(uvFlagFace, weightFace);
    // uvFlagFace = step(0.0, faceUV.x);
    // float uvFlagFace2 = 1.0 - step(1.0, faceUV.x);
    // weightFace = weightFace * uvFlagFace * uvFlagFace2;
    // weightFace = max(weightFace, 1.0 - uFaceSegDetected);
    // weight = min(weight, weightFace);
    vec4 resultColor = texture2D(ganTexture, uv);
    resultColor.a *= u_h;

    // blend in texture
    gl_FragColor = resultColor ;
    // gl_FragColor = u_nowColor;
    // gl_FragColor.a = 0.5;
    // gl_FragColor = vec4(uv1.z / uv1.w * 0.5 + 0.5,0,0,1);
    // gl_FragColor = maskFace;
    // gl_FragColor.a = 1.;
    // gl_FragColor = vec4(,0,1);

}
