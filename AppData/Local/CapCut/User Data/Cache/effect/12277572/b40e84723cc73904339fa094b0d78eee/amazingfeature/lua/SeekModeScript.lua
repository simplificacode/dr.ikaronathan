--@input float stretch_leg_intensity = 0.50 {"widget":"slider","min":0.0,"max":1.0}
--@input float slim_body_intensity = 0.50 {"widget":"slider","min":0.0,"max":1.0}
--@input float slim_waist_intensity = 0.50 {"widget":"slider","min":0.0,"max":1.0}
--@input float small_head_intensity = 0.50 {"widget":"slider","min":0.0,"max":1.0}
--@input float all_slim_body_intensity = 0.50 {"widget":"slider","min":0.0,"max":1.0}


local req = nil

local faceCount = 0
local faceKeyPoints = {}
local faceRect = {left = 0.0, right = 0.0, top = 0.0, bottom = 0.0}

local bodyCount = 0
local bodyKeyPoints = {}

local initFlag = 0
local img_width = 1.0
local img_height = 1.0
local cameraPosition = nil

local bodyWaistPoint = Amaz.Vector2f(-1.0, -1.0) --EffectSdk.Vec2(-1.0, -1.0)

local globalfaceLength = -1.0

local bodySynPointMap = {}
bodySynPointMap[0] = 0
bodySynPointMap[1] = 1
bodySynPointMap[2] = 5
bodySynPointMap[3] = 6
bodySynPointMap[4] = 7
bodySynPointMap[5] = 2
bodySynPointMap[6] = 3
bodySynPointMap[7] = 5
bodySynPointMap[8] = 11
bodySynPointMap[9] = 12
bodySynPointMap[10] = 13
bodySynPointMap[11] = 8
bodySynPointMap[12] = 9
bodySynPointMap[13] = 10
bodySynPointMap[14] = 15
bodySynPointMap[15] = 14
bodySynPointMap[16] = 17
bodySynPointMap[17] = 16

local sho_and_hip_distance = -1.0

local small_head_weight = 0.0
local pre_head_center = Amaz.Vector2f(-1.0, -1.0) --EffectSdk.Vec2(-1.0, -1.0)
local pre_body_center = Amaz.Vector2f(-1.0, -1.0) --EffectSdk.Vec2(-1.0, -1.0)
local head_jitter_status = 0
local body_jitter_status = 0

local globalpercentage = {
    all_slim_body_value = 0.0,
    small_head_value = 0.0,
    stretch_leg_value = 0.0,
    slim_body_value = 0.0,
    slim_waist_value = 0.0
}

local globalstride = {
    slim_body_stride = 0.995,
    small_head_stride = 0.995,
    stretch_leg_stride = 0.995,
    slim_waist_stride = 0.995,
}

local detect_status = {
    head_detect_status = 0,
    leg_detect_status = 0,
    body_detect_status = 0,
    waist_detect_status = 0
}

local slimALL = {}

-- whether a point is within the range of the image
local function isPointValid(point)
    if point.x >= 0.0 and point.y >= 0.0 and point.x < img_width and point.y < img_height then
        return true
    end

    return false
end

-- The coordinate range of the minimum enclosing rectangle
local function get_box_params(points)
    local min_x = -1.0
    local max_x = -1.0
    local min_y = -1.0
    local max_y = -1.0

    for k,v in pairs(points) do
        if isPointValid(v) then
            if min_x == -1.0 or v.x < min_x then
                min_x = v.x
            end

            if max_x == -1.0 or v.x > max_x then
                max_x = v.x
            end

            if min_y == -1.0 or v.y < min_y then
                min_y = v.y
            end

            if max_y == -1.0 or v.y > max_y then
                max_y  = v.y
            end
        end
    end

    return min_x, max_x, min_y, max_y
end

-- compute distance between the points
local function compute_distance(p1, p2)
    if isPointValid(p1) and isPointValid(p2) then
        return math.sqrt( (p1.x - p2.x) * (p1.x - p2.x) + (p1.y - p2.y) * (p1.y - p2.y) )
    else
        return -1.0
    end
end

-- Calculate mean point
local function get_mean_point(points)
    local meanPoint = Amaz.Vector2f(0.0, 0.0) --EffectSdk.Vec2(0.0, 0.0)
    local count = 0

    for k,v in pairs(points) do
        if isPointValid(v) then
            meanPoint.x = meanPoint.x + v.x
            meanPoint.y = meanPoint.y + v.y
            count = count + 1
        end
    end

    if count > 0 then
        meanPoint.x = meanPoint.x / count
        meanPoint.y = meanPoint.y / count
    else
        meanPoint.x = -1.0
        meanPoint.y = -1.0
    end

    return meanPoint
end

-- Calculate the x-mean coordinates
local function get_mean_x_with_weight(points, pointsNum)
    if pointsNum == 0 then
        return -1.0
    elseif pointsNum == 1 then
        return points[1].x
    end

    local mean_x = 0.0
    local min_x, max_x, min_y, max_y = get_box_params(points)
    if min_x == max_x then
        return min_x
    end

    local mid_x = math.abs(min_x + max_x) * 0.5

    local leftSum = 0.0
    local rightSum = 0.0
    local count = 0

    local distanceSave = {}
    for i = 1, pointsNum do
        if isPointValid(points[i]) then
            local tmp_dis = points[i].x - mid_x
            distanceSave[i] = tmp_dis
            leftSum = leftSum - math.min(0.0, tmp_dis)
            rightSum = rightSum + math.max(0.0, tmp_dis)
            count = count + 1
        else
            distanceSave[i] = 0.0
        end
    end

    if count == 0 then
        mean_x = -1.0
    else
        for i = 1, pointsNum do
            local weight = 0.0
            if distanceSave[i] < 0.0 then
                weight = math.abs(distanceSave[i]) / leftSum * rightSum  -- lef_dis/lefSum 
            elseif distanceSave[i] > 0.0 then
                weight = math.abs(distanceSave[i]) / rightSum * leftSum
            end

            mean_x = mean_x + points[i].x * weight
        end
        mean_x = mean_x / (leftSum + rightSum)  -- leftSum + rightSum 
    end

    return mean_x
end

-- calculate the params of line
local function get_line_param(p1, p2)
    local A = p1.y - p2.y
    local B = p2.x - p1.x
    local C = p1.x * p2.y - p2.x * p1.y

    return A, B, C
end

local function get_vertical_cross_point_param(center, vec)
    local x = -1.0
    local y = -1.0
    local z = -1.0
    local w = -1.0

    local p1 = center
    local p2 = Amaz.Vector2f(center.x + vec.x, center.y + vec.y) --EffectSdk.Vec2(center.x + vec.x, center.y + vec.y)

    if isPointValid(p1) and isPointValid(p2) then
        local A, B, C = get_line_param(p1, p2)
        local A2 = A * A
        local B2 = B * B
        local A2plusB2 = A2 + B2

        if A2plusB2 ~= 0.0 then
            local AB = A * B
            local AC = A * C
            local BC = B * C
            local A2plusB2_inv = 1.0 / A2plusB2

            x = A2 * A2plusB2_inv
            y = AB * A2plusB2_inv
            z = AC * A2plusB2_inv
            w = BC * A2plusB2_inv
        end
    end

    return x,y,z,w
end

local function get_body_points(ids, num, removeSynPoint)
    local res = {}
    local count = 0

    for i = 1,num do
        local id = ids[i]
        if removeSynPoint == 0 then
            if bodyKeyPoints[id].is_detect and isPointValid(bodyKeyPoints[id]) then
                count = count + 1
                res[count] = bodyKeyPoints[id]
            end
        else
            local syn_id = bodySynPointMap[id]
            if bodyKeyPoints[id].is_detect and isPointValid(bodyKeyPoints[id]) and bodyKeyPoints[syn_id].is_detect and isPointValid(bodyKeyPoints[syn_id]) then
                count = count + 1
                res[count] = bodyKeyPoints[id]
            end
        end
    end

    return res, count
end

local function smooth_fun(cur_var, tmp_var, lambda_value)
    local res
    if cur_var == -1.0 then
        res = tmp_var
    elseif tmp_var == -1.0 then
        res = cur_var
    else
        res = lambda_value * cur_var + (1.0 - lambda_value) * tmp_var
    end

    return res
end

local function update_scale(is_detect, cur_scale, min_scale, max_scale, cur_stride, default_stride)

    local res = 1.0
    local stride = cur_stride
    if is_detect == 0 then
        stride = default_stride
    end

    if is_detect == 1 then
        if max_scale > 1.0 then
            res = cur_scale / stride
        elseif min_scale < 1.0 then
            res = cur_scale * stride
        end
        cur_stride = 0.97
    else
        if cur_scale > 1.0 then
            res = cur_scale * stride
        elseif cur_scale < 1.0 then
            res = cur_scale / stride
        end
    end

    res = math.max(math.min(max_scale ,res), min_scale)

    return res, cur_stride
end

local function resetDetectStatus()
    detect_status.head_detect_status = 0
    detect_status.leg_detect_status = 0
    detect_status.body_detect_status = 0
    detect_status.waist_detect_status = 0
end

local function resetSlimALL()
    slimALL = {} 
    slimALL.whole_body_slim = {}
    slimALL.whole_body_slim.center = Amaz.Vector2f(-1.0, -1.0) --EffectSdk.Vec2(-1.0, -1.0)
    slimALL.whole_body_slim.left = -1.0
    slimALL.whole_body_slim.right = -1.0
    slimALL.whole_body_slim.top = -1.0
    slimALL.whole_body_slim.bottom = -1.0
    slimALL.whole_body_slim.x_min = -1.0
    slimALL.whole_body_slim.x_max = -1.0
    slimALL.whole_body_slim.y_min = -1.0
    slimALL.whole_body_slim.y_max = -1.0
    slimALL.whole_body_slim.scale = 1.0

    slimALL.head_small = {}
    slimALL.head_small.center = Amaz.Vector2f(-1.0, -1.0) --EffectSdk.Vec2(-1.0, -1.0)
    slimALL.head_small.left = -1.0
    slimALL.head_small.right = -1.0
    slimALL.head_small.top = -1.0
    slimALL.head_small.bottom = -1.0
    slimALL.head_small.x_min = -1.0
    slimALL.head_small.x_max = -1.0
    slimALL.head_small.y_min = -1.0
    slimALL.head_small.y_max = -1.0
    slimALL.head_small.scale = 1.0

    slimALL.leg_stretch = {}
    slimALL.leg_stretch.y_1 = -1.0
    slimALL.leg_stretch.y_2 = -1.0
    slimALL.leg_stretch.scale = 1.0

    slimALL.waist_slim = {}
    slimALL.waist_slim.center = Amaz.Vector2f(-1.0, -1.0) --EffectSdk.Vec2(-1.0, -1.0)
    slimALL.waist_slim.left = -1.0
    slimALL.waist_slim.right = -1.0
    slimALL.waist_slim.top = -1.0
    slimALL.waist_slim.bottom = -1.0
    slimALL.waist_slim.x_min = -1.0
    slimALL.waist_slim.x_max = -1.0
    slimALL.waist_slim.y_min = -1.0
    slimALL.waist_slim.y_max = -1.0
    slimALL.waist_slim.scale = 1.0
end

local function judgePointAbnormalJitter(pre_point, cur_point, next_point, jitter_status)
    if isPointValid(pre_point) and isPointValid(cur_point) then
        local dis1 = compute_distance(next_point, cur_point)
        local dis2 = compute_distance(pre_point, cur_point)

        if dis1 > 10.0 * dis2 then
            jitter_status = (jitter_status + 1) % 2
        else
            jitter_status = 0
        end
    else
        jitter_status = 0
    end

    return jitter_status
end

local function updateSmallHeadParams(face_is_detected, face_center, face_length, head_center, head_length)
    if head_jitter_status == 0 then
        local tmp_left, tmp_right, tmp_top, tmp_bottom, tmp_face_length
        pre_head_center = slimALL.head_small.center

        if face_is_detected == 1 then
            
            slimALL.head_small.center.x = smooth_fun(slimALL.head_small.center.x, face_center.x, 0.2);
            slimALL.head_small.center.y = smooth_fun(slimALL.head_small.center.y, face_center.y, 0.2);
            tmp_left = face_length * 1.1
            tmp_right = face_length * 1.1
            tmp_top = face_length * 1.4
            tmp_bottom = face_length * 1.3
            tmp_face_length = face_length
        else
           
            slimALL.head_small.center.x = smooth_fun(slimALL.head_small.center.x, head_center.x, 0.2);
            slimALL.head_small.center.y = smooth_fun(slimALL.head_small.center.y, head_center.y, 0.2);
            tmp_left = head_length * 1.1
            tmp_right = head_length * 1.1
            tmp_top = head_length * 1.4
            tmp_bottom = head_length * 1.3
            tmp_face_length = head_length
        end

        if slimALL.head_small.center.x + tmp_face_length * 1.0 < slimALL.head_small.x_max and slimALL.head_small.center.x - tmp_face_length * 1.0 > slimALL.head_small.x_min and slimALL.head_small.center.y + tmp_face_length * 0.8 < slimALL.head_small.y_max and slimALL.head_small.center.y - tmp_face_length * 1.0 > slimALL.head_small.y_min then
                tmp_left = math.min(tmp_left, slimALL.head_small.center.x)
                tmp_right = math.min(tmp_right, img_width - 1.0 - slimALL.head_small.center.x)
                tmp_top = math.min(tmp_top,slimALL.head_small.center.y)
                tmp_bottom = math.min(tmp_bottom, img_height - 1.0 - slimALL.head_small.center.y)

                slimALL.head_small.x_min = smooth_fun(slimALL.head_small.x_min, slimALL.head_small.center.x - tmp_left, 0.9)
                slimALL.head_small.x_max = smooth_fun(slimALL.head_small.x_max, slimALL.head_small.center.x + tmp_right, 0.9)
                slimALL.head_small.y_min = smooth_fun(slimALL.head_small.y_min, slimALL.head_small.center.y - tmp_top, 0.9)
                slimALL.head_small.y_max = smooth_fun(slimALL.head_small.y_max, slimALL.head_small.center.y + tmp_bottom, 0.9)

                slimALL.head_small.left = slimALL.head_small.center.x - slimALL.head_small.x_min
                slimALL.head_small.right = slimALL.head_small.x_max - slimALL.head_small.center.x
                slimALL.head_small.top = slimALL.head_small.center.y - slimALL.head_small.y_min
                slimALL.head_small.bottom = slimALL.head_small.y_max - slimALL.head_small.center.y
        elseif slimALL.head_small.center.x + tmp_face_length * 0.7 < slimALL.head_small.x_max and slimALL.head_small.center.x - tmp_face_length * 0.7 > slimALL.head_small.x_min and slimALL.head_small.center.y + tmp_face_length * 0.3 < slimALL.head_small.y_max and slimALL.head_small.center.y - tmp_face_length * 0.5 > slimALL.head_small.y_min then
            slimALL.head_small.left = math.min(smooth_fun(slimALL.head_small.left, tmp_left, 0.2), slimALL.head_small.center.x)
            slimALL.head_small.right = math.min(smooth_fun(slimALL.head_small.right, tmp_right, 0.2), img_width - 1.0 - slimALL.head_small.center.x)
            slimALL.head_small.top = math.min(smooth_fun(slimALL.head_small.top, tmp_top, 0.2), slimALL.head_small.center.y)
            slimALL.head_small.bottom = math.min(smooth_fun(slimALL.head_small.bottom, tmp_bottom, 0.2), img_height - 1.0 - slimALL.head_small.center.y)

            slimALL.head_small.x_min = smooth_fun(slimALL.head_small.x_min, slimALL.head_small.center.x - slimALL.head_small.left, 0.7)
            slimALL.head_small.x_max = smooth_fun(slimALL.head_small.x_max, slimALL.head_small.center.x + slimALL.head_small.right, 0.7)
            slimALL.head_small.y_min = smooth_fun(slimALL.head_small.y_min, slimALL.head_small.center.y - slimALL.head_small.top, 0.7)
            slimALL.head_small.y_max = smooth_fun(slimALL.head_small.y_max, slimALL.head_small.center.y + slimALL.head_small.bottom, 0.7)
        else
            slimALL.head_small.left = math.min(tmp_left, slimALL.head_small.center.x)
            slimALL.head_small.right = math.min(tmp_right, img_width - 1.0 - slimALL.head_small.center.x)
            slimALL.head_small.top = math.min(tmp_top, slimALL.head_small.center.y)
            slimALL.head_small.bottom = math.min(tmp_bottom, img_height - 1.0 - slimALL.head_small.center.y)

            slimALL.head_small.x_min = slimALL.head_small.center.x - slimALL.head_small.left
            slimALL.head_small.x_max = slimALL.head_small.center.x + slimALL.head_small.right
            slimALL.head_small.y_min = slimALL.head_small.center.y - slimALL.head_small.top
            slimALL.head_small.y_max = slimALL.head_small.center.y + slimALL.head_small.bottom
        end

        
        local minDistance = math.min(math.min(slimALL.head_small.center.x - slimALL.head_small.x_min, slimALL.head_small.x_max - slimALL.head_small.center.x), math.min(slimALL.head_small.center.y - slimALL.head_small.y_min, slimALL.head_small.y_max - slimALL.head_small.center.y))
        small_head_weight = math.max(math.min(1.0, minDistance / tmp_face_length), 0.0) 
    end
end

local function updateSlimBodyParams(waist_center, dis_between_sho_and_hip)
    if body_jitter_status == 0 then
        pre_body_center = slimALL.whole_body_slim.center
        local tmp_left, tmp_right, tmp_top, tmp_bottom

        slimALL.whole_body_slim.center.x = smooth_fun(slimALL.whole_body_slim.center.x, waist_center.x, 0.5);
        slimALL.whole_body_slim.center.y = smooth_fun(slimALL.whole_body_slim.center.y, waist_center.y, 0.2);
        tmp_left = dis_between_sho_and_hip * 0.8
        tmp_right = dis_between_sho_and_hip * 0.8
        tmp_top = dis_between_sho_and_hip * 0.8
        tmp_bottom = img_height

        slimALL.whole_body_slim.left = math.min(smooth_fun(slimALL.whole_body_slim.left, tmp_left, 0.5), slimALL.whole_body_slim.center.x)
        slimALL.whole_body_slim.right = math.min(smooth_fun(slimALL.whole_body_slim.right, tmp_right, 0.5), img_width - 1.0 - slimALL.whole_body_slim.center.x)
        slimALL.whole_body_slim.top = math.min(smooth_fun(slimALL.whole_body_slim.top, tmp_top, 0.5), slimALL.whole_body_slim.center.y)
        slimALL.whole_body_slim.bottom = math.min(smooth_fun(slimALL.whole_body_slim.bottom, tmp_bottom, 0.5), img_height - 1.0 - slimALL.whole_body_slim.center.y)

        slimALL.whole_body_slim.x_min = slimALL.whole_body_slim.center.x - slimALL.whole_body_slim.left
        slimALL.whole_body_slim.x_max = slimALL.whole_body_slim.center.x + slimALL.whole_body_slim.right
        slimALL.whole_body_slim.y_min = slimALL.whole_body_slim.center.y - slimALL.whole_body_slim.top
        slimALL.whole_body_slim.y_max = slimALL.whole_body_slim.center.y + slimALL.whole_body_slim.bottom
    end
end

local function updateSlimWaistParams(waist_center, dis_between_sho_and_hip)
    if body_jitter_status == 0 then
        local tmp_left, tmp_right, tmp_top, tmp_bottom
        slimALL.waist_slim.center.x = smooth_fun(slimALL.waist_slim.center.x, waist_center.x, 0.2);
        slimALL.waist_slim.center.y = smooth_fun(slimALL.waist_slim.center.y, waist_center.y, 0.2);

        tmp_left = dis_between_sho_and_hip * 0.6
        tmp_right = dis_between_sho_and_hip * 0.6
        tmp_top = dis_between_sho_and_hip * 0.4
        tmp_bottom = dis_between_sho_and_hip * 0.4

        slimALL.waist_slim.left = math.min(smooth_fun(slimALL.waist_slim.left, tmp_left, 0.3), slimALL.waist_slim.center.x)
        slimALL.waist_slim.right = math.min(smooth_fun(slimALL.waist_slim.right, tmp_right, 0.3), img_width - 1.0 - slimALL.waist_slim.center.x)
        slimALL.waist_slim.top = math.min(smooth_fun(slimALL.waist_slim.top, tmp_top, 0.3), slimALL.waist_slim.center.y)
        slimALL.waist_slim.bottom = math.min(smooth_fun(slimALL.waist_slim.bottom, tmp_bottom, 0.3), img_height - 1.0 - slimALL.waist_slim.center.y)

        slimALL.waist_slim.x_min = slimALL.waist_slim.center.x - slimALL.waist_slim.left
        slimALL.waist_slim.x_max = slimALL.waist_slim.center.x + slimALL.waist_slim.right
        slimALL.waist_slim.y_min = slimALL.waist_slim.center.y - slimALL.waist_slim.top
        slimALL.waist_slim.y_max = slimALL.waist_slim.center.y + slimALL.waist_slim.bottom
    end
end

local function updateStretchLegParams(legs_center, dis_between_sho_and_hip)
    if isPointValid(bodyWaistPoint) and bodyWaistPoint.y + dis_between_sho_and_hip * 0.2 < slimALL.leg_stretch.y_2 and bodyWaistPoint.y > slimALL.leg_stretch.y_1 and slimALL.leg_stretch.y_2 - slimALL.leg_stretch.y_1 <  0.85 * dis_between_sho_and_hip then
        return true
    else
        local tmp_y_1 = -1.0
        local tmp_y_2 = -1.0

        local ratio1 = 0.7
        local ratio2 = 0.63

        if dis_between_sho_and_hip ~= -1.0 then
            tmp_y_1 = legs_center.y - dis_between_sho_and_hip * (ratio1 + ratio2)
            tmp_y_2 = legs_center.y - dis_between_sho_and_hip * ratio1
        end

        slimALL.leg_stretch.y_1 = smooth_fun(slimALL.leg_stretch.y_1, tmp_y_1, 0.5)
        slimALL.leg_stretch.y_1 = math.max( math.min(slimALL.leg_stretch.y_1, img_height), 0.0)

        slimALL.leg_stretch.y_2 = smooth_fun(slimALL.leg_stretch.y_2, tmp_y_2, 0.95)
        slimALL.leg_stretch.y_2 = math.max( math.min(slimALL.leg_stretch.y_2, img_height), slimALL.leg_stretch.y_1)
    end
end

local function updateAllScale()
    local slim_body_min = 1.0
    local slim_body_max = 1.0 + globalpercentage.slim_body_value * 0.3
    slimALL.whole_body_slim.scale, globalstride.slim_body_stride = update_scale(detect_status.body_detect_status, slimALL.whole_body_slim.scale, slim_body_min, slim_body_max, globalstride.slim_body_stride, 0.9975)

    local small_head_min = 1.0
    local small_head_max = 1.0 + math.min(0.35, globalpercentage.small_head_value * 0.22 + globalpercentage.all_slim_body_value * 0.13)
    slimALL.head_small.scale, globalstride.small_head_stride = update_scale(detect_status.head_detect_status, slimALL.head_small.scale, small_head_min, small_head_max, globalstride.small_head_stride, 0.9975)

    local stretch_leg_min = 1.0
    local stretch_leg_max = 1.0 + math.min(0.4, globalpercentage.stretch_leg_value * 0.27 + globalpercentage.all_slim_body_value * 0.15)
    slimALL.leg_stretch.scale,  globalstride.stretch_leg_stride = update_scale(detect_status.leg_detect_status, slimALL.leg_stretch.scale, stretch_leg_min, stretch_leg_max, globalstride.stretch_leg_stride, 0.9975)
    -- Amaz.LOGI("++++leg_stretch:",detect_status.leg_detect_status..","..slimALL.leg_stretch.scale..",,"..globalstride.stretch_leg_stride)

    local slim_waist_min = 1.0
    local slim_waist_max = 1.0 + math.min(0.45, globalpercentage.slim_waist_value * 0.25 + globalpercentage.all_slim_body_value * 0.23)
    slimALL.waist_slim.scale, globalstride.slim_waist_stride = update_scale(detect_status.waist_detect_status, slimALL.waist_slim.scale, slim_waist_min, slim_waist_max, globalstride.slim_waist_stride, 0.9975)

end


local exports = exports or {}
local SeekModeScript = SeekModeScript or {}
SeekModeScript.__index = SeekModeScript

function SeekModeScript.new(construct, ...)
    local self = setmetatable({}, SeekModeScript)
    if construct and SeekModeScript.constructor then SeekModeScript.constructor(self, ...) end
    self.startTime = 0.0
    self.endTime = 3.0
    self.curTime = 0.0
    self.width = 0
    self.height = 0
    -- self.material = nil
    globalpercentage.slim_body_value = 0.0
    self.bodyIntensity = 0.0
    return self
end

function SeekModeScript:constructor()

end

function SeekModeScript:onUpdate(comp, detalTime)
    --ccc
    -- local props = comp.entity:getComponent("ScriptComponent").properties
    -- if props:has("stretch_leg_intensity") then
    --     -- self:seekToTime(comp, props:get("curTime"))
    --     globalpercentage.stretch_leg_value = props:get("stretch_leg_intensity")
        
    -- end

    -- if props:has("slim_body_intensity") then
    --     globalpercentage.slim_body_value = props:get("slim_body_intensity")
    -- end

    -- if props:has("slim_waist_intensity") then
    --     globalpercentage.slim_waist_value = props:get("slim_waist_intensity")
    -- end

    -- if props:has("small_head_intensity") then
    --     globalpercentage.small_head_value = props:get("small_head_intensity")
    -- end

    -- if props:has("all_slim_body_intensity") then
    --     globalpercentage.all_slim_body_value = props:get("all_slim_body_intensity")
    -- end

    --ccc
    self:seekToTime(comp, self.curTime - self.startTime)
    -- globalpercentage.stretch_leg_value = self.curTime - self.startTime
    -- print("skeleton intensity update:", globalpercentage.stretch_leg_value)
    
end

function SeekModeScript:onEvent(sys, event)
    if event.type == Amaz.AppEventType.SetEffectIntensity then
        if event.args:get(0) == "intensity" then
            globalpercentage.slim_body_value = event.args:get(1)
            self.bodyIntensity = globalpercentage.slim_body_value
        end
    end
end

function SeekModeScript:start(comp)
    self.material = comp.entity:getComponent("MeshRenderer").material
    --init
    resetSlimALL()

    globalstride.slim_waist_stride = 0.001
    globalstride.stretch_leg_stride = 0.001
    globalstride.small_head_stride = 0.001
    globalstride.slim_body_stride = 0.001

    globalpercentage.all_slim_body_value = 0.0
    globalpercentage.slim_body_value = 0.0
    globalpercentage.slim_waist_value = 0.0
    globalpercentage.small_head_value = 0.0

    initFlag = 1
end

function SeekModeScript:seekToTime(comp, time)

    local w = Amaz.BuiltinObject:getInputTextureWidth()
    local h = Amaz.BuiltinObject:getInputTextureHeight()
    if w ~= self.width or h ~= self.height then
        self.width = w
        self.height = h
        -- self.material:setInt("baseTexWidth", self.width)
        -- self.material:setInt("baseTexHeight", self.height)
        img_width = w
        img_height = h
    end

    if self.first == nil then
        self.first = true
        self:start(comp)
    end
    self.material:setFloat("timer", time)
    -- print("seekToTime:", time)
    self:updateFaceInfo()
    self:updateSkeletonInfo()

    -- globalpercentage.stretch_leg_value = time
    -- globalpercentage.stretch_leg_value = 1.0
    -- globalpercentage.slim_body_value = 1.0

    resetDetectStatus()

    if bodyCount == 0.0 then
        if faceCount == 1 then
            local face_center = Amaz.Vector2f(-1.0, -1.0) --EffectSdk.Vec2(-1.0, -1.0)
            face_center.x = get_mean_x_with_weight(faceKeyPoints, 5)
            face_center.y = get_mean_point(faceKeyPoints).y

            local face_length = math.max(math.abs(faceRect.left - faceRect.right), math.abs(faceRect.top - faceRect.bottom)) * 1.5
            globalfaceLength = smooth_fun(globalfaceLength, face_length, 0.8)

            detect_status.head_detect_status = 1
            head_jitter_status = judgePointAbnormalJitter(pre_head_center, slimALL.head_small.center, face_center, head_jitter_status)
            updateSmallHeadParams(1, face_center, globalfaceLength, nil, nil)
        end
    else
        local headPointsIds = {0, 1, 14, 15, 16, 17}
        local shoulderPointsIds = {2, 5}
        local hipPointsIds = {8, 11}

        local headPointsVec, headPointsSize = get_body_points(headPointsIds, 6, 0)
        local shoulderPointsVec, shoulderPointsSize = get_body_points(shoulderPointsIds, 2, 0)
        local hipPointsVec, hipPointsSize = get_body_points(hipPointsIds, 2, 0)

        local shoulder_center = get_mean_point(shoulderPointsVec)
        local hip_center = get_mean_point(hipPointsVec)
        local head_center = Amaz.Vector2f(-1.0, -1.0) --EffectSdk.Vec2(-1.0, -1.0)
        head_center.x = get_mean_x_with_weight(headPointsVec, headPointsSize)
        head_center.y = get_mean_point(headPointsVec).y
        -- local body_center = EffectSdk.Vec2(shoulder_center.x * 0.5 + hip_center.x * 0.5, shoulder_center.y * 0.5 + hip_center.y * 0.5)
        local body_center = Amaz.Vector2f(shoulder_center.x * 0.5 + hip_center.x * 0.5, shoulder_center.y * 0.5 + hip_center.y * 0.5)

        sho_and_hip_distance = smooth_fun(sho_and_hip_distance, compute_distance(shoulder_center, hip_center), 0.8)
        
        local legs_center = Amaz.Vector2f(-1.0, -1.0) --EffectSdk.Vec2(-1.0, -1.0)
        if isPointValid(hip_center) and isPointValid(body_center) then
            legs_center.x = 0.7 * hip_center.x + 0.3 * body_center.x
            legs_center.y = hip_center.y
        elseif isPointValid(hip_center) then
            legs_center.x = hip_center.x
            legs_center.y = hip_center.y
        end

        if sho_and_hip_distance > 0.0 and isPointValid(legs_center) then
            legs_center.y = math.min(legs_center.y + sho_and_hip_distance * 0.9, img_height - 1.0)
        end
       

        local waist_center = Amaz.Vector2f(-1.0, -1.0) --EffectSdk.Vec2(-1.0, -1.0)
        if isPointValid(shoulder_center) and isPointValid(hip_center) then
            waist_center.x = 0.3 * shoulder_center.x + 0.7 * hip_center.x
            waist_center.y = 0.3 * shoulder_center.y + 0.7 * hip_center.y
            head_center.x = smooth_fun(head_center.x, waist_center.x, 0.7)
        elseif isPointValid(shoulder_center)  and sho_and_hip_distance ~= -1.0 then
            waist_center.x = shoulder_center.x
            waist_center.y = math.min(shoulder_center.y + sho_and_hip_distance * 0.7, img_height - 1.0)
            head_center.x = smooth_fun(head_center.x, waist_center.x, 0.7)
        end

        bodyWaistPoint.x = smooth_fun(bodyWaistPoint.x, waist_center.x, 0.6)
        bodyWaistPoint.y = smooth_fun(bodyWaistPoint.y, waist_center.y, 0.6)

        local head_length = -1.0
        if isPointValid(head_center) then
            local tmp_x_min, tmp_x_max, tmp_y_min, tmp_y_max = get_box_params(headPointsVec)
            head_length = math.max(math.abs(tmp_x_max - tmp_x_min), math.abs(tmp_y_min - tmp_y_max))
            head_length = math.max(head_length, sho_and_hip_distance * 0.3)
        end
        globalfaceLength = smooth_fun(globalfaceLength, head_length, 0.8)

        if hipPointsSize < 1 and faceCount == 1 then
            local face_center = Amaz.Vector2f(-1.0, -1.0) --EffectSdk.Vec2(-1.0, -1.0)
            face_center.x = get_mean_x_with_weight(faceKeyPoints, 5)
            face_center.y = get_mean_point(faceKeyPoints).y

            local face_length = math.max(math.abs(faceRect.left - faceRect.right), math.abs(faceRect.top - faceRect.bottom)) * 1.5
            globalfaceLength = smooth_fun(globalfaceLength, face_length, 0.8)

            detect_status.head_detect_status = 1
            head_jitter_status = judgePointAbnormalJitter(pre_head_center, slimALL.head_small.center, face_center, head_jitter_status)
           
            updateSmallHeadParams(1, face_center, globalfaceLength, nil, nil)
        elseif isPointValid(head_center) then
          
            if isPointValid(head_center) and head_length > 0.0 then
                detect_status.head_detect_status = 1
                head_jitter_status = judgePointAbnormalJitter(pre_head_center, slimALL.head_small.center, head_center, head_jitter_status)
               
                updateSmallHeadParams(0, nil, nil, head_center, globalfaceLength)
            end
        end

        if isPointValid(waist_center) then
            detect_status.waist_detect_status = 1
            detect_status.body_detect_status = 1

            body_jitter_status = judgePointAbnormalJitter(pre_body_center, slimALL.whole_body_slim.center, waist_center, body_jitter_status)
            updateSlimBodyParams(waist_center, sho_and_hip_distance)
            updateSlimWaistParams(waist_center, sho_and_hip_distance)
        end

        -- Amaz.LOGI("+++++++++++++rcl++++++:",legs_center.x)
        -- Amaz.LOGI("+++++++++++++rcl++++++:",legs_center.y)
        if isPointValid(legs_center) then
            detect_status.leg_detect_status = 1
            updateStretchLegParams(legs_center, sho_and_hip_distance)
        end
    end
    globalpercentage.slim_body_value = self.bodyIntensity
    updateAllScale()
    self:updateAllBodyShapingParams()
end

function SeekModeScript:updateAllBodyShapingParams()
    self.material:setVec2("resolution", Amaz.Vector2f(img_width, img_height))
    self.material:setVec2("resolution_inv", Amaz.Vector2f(1.0/img_width, 1.0/img_height))

    self.material:setVec4("slim_body_rect", Amaz.Vector4f(slimALL.whole_body_slim.left, slimALL.whole_body_slim.right, slimALL.whole_body_slim.top, slimALL.whole_body_slim.bottom))
    self.material:setVec2("slim_body_center_point", Amaz.Vector2f(slimALL.whole_body_slim.center.x, slimALL.whole_body_slim.center.y))
    self.material:setFloat("slim_body_scale", slimALL.whole_body_slim.scale)
    
    self.material:setVec4("small_head_rect", Amaz.Vector4f(slimALL.head_small.left, slimALL.head_small.right, slimALL.head_small.top, slimALL.head_small.bottom))
    self.material:setVec2("small_head_center_point", Amaz.Vector2f(slimALL.head_small.center.x, slimALL.head_small.center.y))
    self.material:setFloat("small_head_scale", (slimALL.head_small.scale - 1.0) * small_head_weight + 1.0)
    
    self.material:setVec3("stretch_legs_bounds", Amaz.Vector3f(slimALL.leg_stretch.y_1, slimALL.leg_stretch.y_2, slimALL.leg_stretch.y_2 - slimALL.leg_stretch.y_1))
    self.material:setVec2("stretch_legs_scales", Amaz.Vector2f(1.0 / slimALL.leg_stretch.scale, (1.0 - slimALL.leg_stretch.scale) * 0.7 + slimALL.leg_stretch.scale))

    self.material:setVec4("slim_waist_rect", Amaz.Vector4f(slimALL.waist_slim.left, slimALL.waist_slim.right, slimALL.waist_slim.top, slimALL.waist_slim.bottom))
    self.material:setVec2("slim_waist_center_point", Amaz.Vector2f(slimALL.waist_slim.center.x, slimALL.waist_slim.center.y))
    self.material:setFloat("slim_waist_scale", slimALL.waist_slim.scale)

    -- Amaz.LOGI("+++++resolution:",img_height)
end

function SeekModeScript:updateFaceInfo()
    faceCount = 0
    faceRect.left = -1.0
    faceRect.right = -1.0
    faceRect.top = -1.0
    faceRect.bottom = -1.0

    local result = Amaz.Algorithm.getAEAlgorithmResult()
    faceCount = result:getFaceCount()
    -- Amaz.LOGI("++++++faceCount:",faceCount)
    if faceCount > 0 then
        local faceInfo = result:getFaceBaseInfo(0)
        faceKeyPoints[1] = faceInfo.points_array:get(74)
        faceKeyPoints[2] = faceInfo.points_array:get(77)
        faceKeyPoints[3] = faceInfo.points_array:get(2)
        faceKeyPoints[4] = faceInfo.points_array:get(30)
        faceKeyPoints[5] = faceInfo.points_array:get(46)

        for j = 1, 5 do
            faceKeyPoints[j].x = faceKeyPoints[j].x*img_width
            faceKeyPoints[j].y = faceKeyPoints[j].y*img_height
        end

        faceRect.left   = faceInfo.rect.x*img_width
        faceRect.right  = (faceInfo.rect.x+faceInfo.rect.width)*img_width
        faceRect.top    = (faceInfo.rect.y+faceInfo.rect.height)*img_height
        faceRect.bottom = faceInfo.rect.y*img_height

        -- Amaz.LOGI("++++++faceRect.left:",faceRect.left..","..faceInfo.rect.width)
        -- Amaz.LOGI("++++++faceRect.top:",faceRect.bottom)
        -- Amaz.LOGI("+++++++++++++rcl:",faceKeyPoints[1].x)
    end
end

function SeekModeScript:updateSkeletonInfo()
    local result = Amaz.Algorithm.getAEAlgorithmResult()
    local skeletonInfo = result:getSkeletonInfo(0)
    --local keyPointSize = skeletonInfo.key_points_xy:size()
    local skeletonCount = result:getSkeletonCount()
    Amaz.LOGI("++++++skeletonCount:", skeletonCount)
    local keyPoint10 = Amaz.Vector2f(0.0, 0.0)
    local keyPoint11 = Amaz.Vector2f(0.0, 0.0)
    local keyPoint12 = Amaz.Vector2f(0.0, 0.0)
    bodyCount = skeletonCount
    if skeletonCount > 0 then
        for i = 0, 17 do
            local tmpPoint = {x = 0.0, y = 0.0, is_detect = false}
            tmpPoint.x = skeletonInfo.key_points_xy:get(i).x*img_width
            tmpPoint.y = img_height-(skeletonInfo.key_points_xy:get(i).y)*img_height
            tmpPoint.is_detect = skeletonInfo.key_points_detected:get(i)
            bodyKeyPoints[i] = tmpPoint
        end
    end
    -- Amaz.LOGI("+++++++++++++rcl:",bodyKeyPoints[1].x)
    -- Amaz.LOGE("+++++++++++++rcl:",bodyKeyPoints[1].y)
end

exports.SeekModeScript = SeekModeScript
return exports
