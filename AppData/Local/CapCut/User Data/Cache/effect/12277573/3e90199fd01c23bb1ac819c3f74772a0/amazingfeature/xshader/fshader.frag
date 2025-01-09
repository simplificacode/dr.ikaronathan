precision highp float;

varying highp vec2 textureCoordinate;
uniform sampler2D inputImageTexture;

uniform vec2 resolution;
uniform vec2 resolution_inv;
//BodySlim
uniform vec4 slim_body_rect;
uniform vec2 slim_body_center_point;
uniform float slim_body_scale;

#define slim_body_left slim_body_rect[0]
#define slim_body_right slim_body_rect[1]
#define slim_body_top slim_body_rect[2]
#define slim_body_bottom slim_body_rect[3]

//HeadSmall
uniform vec4 small_head_rect;
uniform vec2 small_head_center_point;
uniform float small_head_scale;

#define small_head_left small_head_rect[0]
#define small_head_right small_head_rect[1]
#define small_head_top small_head_rect[2]
#define small_head_bottom small_head_rect[3]

// LegsStretch
uniform vec3 stretch_legs_bounds;   //include top and bottom; [0 - top] do nothing， [top, bottom] lift waist， [bottom, imgheight] stretch legs
uniform vec2 stretch_legs_scales;

#define stretch_legs_y_1 stretch_legs_bounds[0]
#define stretch_legs_y_2 stretch_legs_bounds[1]
#define stretch_legs_bounds_length stretch_legs_bounds[2]

#define stretch_legs_scale stretch_legs_scales[0]
#define stretch_waist_scale stretch_legs_scales[1]

//WaistSlim
uniform vec4 slim_waist_rect;
uniform vec2 slim_waist_center_point;
uniform float slim_waist_scale;

#define slim_waist_left slim_waist_rect[0]
#define slim_waist_right slim_waist_rect[1]
#define slim_waist_top slim_waist_rect[2]
#define slim_waist_bottom slim_waist_rect[3]

vec2 processing_smallHead(vec2 coor, vec2 center_point,
                float ori_target_x_ratio, float ori_max_x_ratio, 
                float ori_target_y_ratio, float ori_max_y_ratio, 
                float left, float right, float top, float bottom)
{
    float res_step_y = step(center_point.y, coor.y);
    float tmp_height = mix(top, bottom, res_step_y);
    float offset_y = abs(coor.y - center_point.y);
    float offset_y_ratio = mix(1.0, min(1.0, offset_y / tmp_height), step(0.001, tmp_height));
    float offset_y_ratio3 = offset_y_ratio * offset_y_ratio * offset_y_ratio;

    left = mix(left, left * pow(1.0 - offset_y_ratio, 0.3), res_step_y);
    right = mix(right, right * pow(1.0 - offset_y_ratio, 0.3), res_step_y);

    float tmp_width = mix(left, right, step(center_point.x, coor.x));
    float offset_x = abs(coor.x - center_point.x);
    float offset_x_ratio = mix(1.0, min(1.0, offset_x / tmp_width), step(0.001, tmp_width));
    
    vec2 res = center_point;

    float tmp_x_ratio = ori_target_x_ratio + offset_y_ratio3 - ori_target_x_ratio * offset_y_ratio3;
    float x_ratio = tmp_x_ratio + offset_x_ratio - tmp_x_ratio * offset_x_ratio;
    x_ratio = min(x_ratio, ori_max_x_ratio);
    res.x += x_ratio * coor.x - x_ratio * center_point.x;

    float tmp_offset_x_ratio = 0.5 - cos(3.14 * offset_x_ratio) * 0.5;
    float tmp_y_ratio = ori_target_y_ratio + tmp_offset_x_ratio - ori_target_y_ratio * tmp_offset_x_ratio;
    float y_ratio = tmp_y_ratio + offset_y_ratio - tmp_y_ratio * offset_y_ratio ;
    y_ratio = min(y_ratio, ori_max_y_ratio);
    res.y += y_ratio * coor.y - y_ratio * center_point.y;
    
    return res;
}

vec2 processing_slimBody(vec2 coor, vec2 center_point,
                float ori_target_x_ratio, float ori_max_x_ratio, 
                float left, float right, float top, float bottom)
{
    float tmp_height = mix(top, bottom, step(center_point.y, coor.y));
    float offset_y = abs(coor.y - center_point.y);
    float offset_y_ratio = mix(1.0, min(1.0, offset_y / tmp_height), step(0.001, tmp_height));
    float offset_y_ratio2 = offset_y_ratio * offset_y_ratio;

    float tmp_width = mix(left, right, step(center_point.x, coor.x));
    float offset_x = abs(coor.x - center_point.x);
    float offset_x_ratio = mix(1.0, min(1.0, offset_x / tmp_width), step(0.001, tmp_width));
    float offset_x_ratio2 = offset_x_ratio * offset_x_ratio;
    
    vec2 res = coor;

    float tmp_x_ratio = ori_target_x_ratio + offset_y_ratio2 - ori_target_x_ratio * offset_y_ratio2;
    tmp_x_ratio = mix(tmp_x_ratio, ori_target_x_ratio, step(center_point.y, coor.y));
    float tmp_offset_x_ratio = mix(offset_x_ratio2, 1., offset_x_ratio);
    float x_ratio = tmp_x_ratio + tmp_offset_x_ratio - tmp_x_ratio * tmp_offset_x_ratio;
    x_ratio = min(x_ratio, ori_max_x_ratio);
    res.x = center_point.x + x_ratio * coor.x - x_ratio * center_point.x;

    return res;
}


vec2 processing_slimWaist(vec2 coor, vec2 center_point,
                float ori_target_x_ratio, float ori_max_x_ratio, 
                float left, float right, float top, float bottom)
{
    float tmp_height = mix(top, bottom, step(center_point.y, coor.y));
    float offset_y = abs(coor.y - center_point.y);
    float offset_y_ratio = mix(1.0, min(1.0, offset_y / tmp_height), step(0.001, tmp_height));

    float tmp_width = mix(left, right, step(center_point.x, coor.x));
    float offset_x = abs(coor.x - center_point.x);
    float offset_x_ratio = mix(1.0, min(1.0, offset_x / tmp_width), step(0.001, tmp_width));
    float offset_x_ratio2 = offset_x_ratio * offset_x_ratio;

    vec2 res = coor;

    float tmp_offset_y_ratio = 0.5 - cos(3.14 * offset_y_ratio) * 0.5;
    float tmp_x_ratio = ori_target_x_ratio + tmp_offset_y_ratio - ori_target_x_ratio * tmp_offset_y_ratio;
    float x_ratio = tmp_x_ratio + (1.0 - tmp_x_ratio) * mix(offset_x_ratio2, 1., offset_x_ratio); 
    x_ratio = min(x_ratio, ori_max_x_ratio);
    res.x = x_ratio * coor.x - x_ratio * center_point.x + center_point.x;
    
    return res;
}

void main() {
    vec2 coor = textureCoordinate * resolution;
    coor.y = resolution.y - coor.y;
    vec2 vec_record = vec2(0., 0.);

    //small head
    float target_x_ratio = (small_head_scale - 1.0) * 0.8 + 1.0;
    float target_y_ratio = small_head_scale;
    float max_x_ratio = 0.6 + 0.4 * target_x_ratio; //(1.0 - target_x_ratio) * 0.6 + target_x_ratio;
    float max_y_ratio = 0.6 + 0.4 * target_y_ratio;//(1.0 - target_y_ratio) * 0.6 + target_y_ratio;
    
    vec2 coor_res = processing_smallHead(coor, small_head_center_point,
                            target_x_ratio, max_x_ratio, target_y_ratio, max_y_ratio, 
                            small_head_left, small_head_right, small_head_top, small_head_bottom);
    vec_record = mix(vec_record, vec_record + coor_res - coor, step(0.001, abs(1.0 - small_head_scale)));

    //slim body
    target_x_ratio = slim_body_scale;
    max_x_ratio = slim_body_scale * 0.3 + 0.7; //slim_body_scale - (slim_body_scale - 1.0) * 0.7;

    coor_res = processing_slimBody(coor, slim_body_center_point, target_x_ratio, max_x_ratio, slim_body_left, slim_body_right, slim_body_top, slim_body_bottom);
    vec_record = mix(vec_record, vec_record + coor_res - coor, step(0.001, abs(1.0 - slim_body_scale)));

    // StretchLegs = stretchLegs + liftWaist
    coor_res = coor;
    float mark1 = step(stretch_legs_y_1, coor.y);
    float mark2 = step(stretch_legs_y_2, coor.y);
    float tmp_offset_y_ratio = mix(1.0, min(1.0, abs(coor.y - stretch_legs_y_1) / stretch_legs_bounds_length), step(0.0001, stretch_legs_bounds_length));
    float tmp_y_ratio = stretch_waist_scale + (1.0 - stretch_waist_scale) * tmp_offset_y_ratio;

    coor_res.y = mix(coor_res.y, tmp_y_ratio * (coor.y - stretch_legs_y_1) + stretch_legs_y_1, mark1 - mark2);
    coor_res.y = mix(coor_res.y, (coor.y - stretch_legs_y_2) * stretch_legs_scale + stretch_legs_y_2, mark2);
    vec_record = mix(vec_record, vec_record + coor_res - coor, step(0.001, abs(1.0 - stretch_legs_scale)));

    //slim waist
    target_x_ratio = slim_waist_scale;
    max_x_ratio = 0.4 + 0.6 * target_x_ratio;//(1.0 - target_x_ratio) * 0.4 + target_x_ratio;
    coor_res = processing_slimWaist(coor, slim_waist_center_point, target_x_ratio, max_x_ratio, slim_waist_left, slim_waist_right, slim_waist_top, slim_waist_bottom);
    vec_record = mix(vec_record, vec_record + coor_res - coor, step(0.001, abs(1.0 - slim_waist_scale)));

    //execute texture2D
    coor_res = coor + vec_record;
    coor_res = coor_res * resolution_inv;
    coor_res.y = 1.0-coor_res.y;
    gl_FragColor = texture2D(inputImageTexture, coor_res);

//    vec4  resultColor = texture2D(inputImageTexture,textureCoordinate);
//    if(distance(coor_res, keyPoint10) < 0.06) {
//        gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
//    }
//    if(distance(coor, keyPoint11) < 0.04) {
//        gl_FragColor = vec4(0.0, 1.0, 0.0, 1.0);
//    }
//    if(distance(coor_res, keyPoint12) < 0.03) {
//        gl_FragColor = vec4(0.0, 0.0, 1.0, 1.0);
//    }
// 	gl_FragColor = resultColor;
}
