attribute vec4 position;
attribute vec2 texcoord0;
varying vec2 uv0;
varying vec3 uv1;
uniform mat4 u_MVP;

uniform float i_scale;
uniform vec2 u_ScreenParams;

const float PI = 3.1415926;
mat4 Projection_Matrix(){
    float fovy = 40.;
    float cot = 1./tan(fovy*0.5/180.*PI);
    float near = 0.1;
    float far = 1000.;
    float aspect = float(u_ScreenParams.x)/float(u_ScreenParams.y);
    return mat4(
        cot/(aspect+0.000001),   0.0,   0.0,                     0.0,
        0.0,                     cot,   0,                       0.0,
        0.0,                     0.0,   -(far+near)/(far-near),  -1.0,
        0.0,                     0.0,   -2.*near*far/(far-near), 0.0
    );

}

uniform mat4 u_View;
uniform mat4 u_Model;
uniform mat4 u_Projection;

uniform float roty;

mat4 Rotation(vec3 rotation)
{
    float radX = radians(rotation.x);
    float radY = radians(rotation.y);
    float radZ = radians(rotation.z);
    float sinX = sin(radX);
    float cosX = cos(radX);
    float sinY = sin(radY);
    float cosY = cos(radY);
    float sinZ = sin(radZ);
    float cosZ = cos(radZ);

    return mat4(
        cosY*cosZ, cosX*sinZ+sinX * sinY*cosZ, sinX*sinZ - cosX * sinY*cosZ,0.0,
        -cosY*sinZ, cosX*cosZ - sinX * sinY*sinZ, sinX*cosZ + cosX * sinY*sinZ,0.0,
        sinY, -sinX * cosY, cosX*cosY,0.0,
        0.0, 0.0, 0.0,1.0
    );
}

uniform mat4 myModel;

void main()
{
    uv1 = vec3(texcoord0, 1.);
    // vec3 local_pos = position.xyz;
    // vec2 dlv = (u_DownLeftVertex) * left_down_corner;
    // vec2 drv = (u_DownRightVertex) * vec2(right_up_corner.x, left_down_corner.y);
    // vec2 urv = (u_UpRightVertex) * right_up_corner;
    // vec2 ulv = (u_UpLeftVertex) * vec2(left_down_corner.x, right_up_corner.y);

    // CornerPositioning(
    //     texcoord0,
    //     dlv, drv, urv, ulv,
    //     position.xyz,
    //     uv1,
    //     local_pos
    // );

    // vec4 newPos = position;
    // gl_Position = u_MVP * vec4(local_pos.xyz, 1.);
        vec4 newPos = position;
    mat4 m_Model = myModel;
    m_Model[3][0] = 0.;
    m_Model[3][1] = 0.;
    // m_Model[3][2] = 10.-1.732050807569;

    // m_Model[0][0] = 2.;
    // m_Model[1][1] = 2.;
    // m_Model[2][2] = 2.;

    vec4 persp_glpos = Projection_Matrix() * u_View * m_Model * vec4(position.xyz, 1.);
    vec4 ortho_glpos = u_Projection * u_View * vec4(u_Model[3][0], u_Model[3][1], 0., 0.);
    gl_Position = persp_glpos + ortho_glpos * persp_glpos.w;
    // gl_Position = u_MVP * vec4(position.xyz, 1.);
    uv0 = texcoord0;
    // uv0.y = 1.0 - uv0.y;
}
