local AETools = AETools or {}
AETools.__index = AETools

local function deepcopy(orig)
    local copy
    if type(orig) == "table" then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        -- setmetatable(copy, deepcopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

function AETools.new(attrs)
    local self = setmetatable({}, AETools)
    self.attrs = attrs

    self:_init(100000, 0, true)

    return self
end

function AETools:_init(_min_frame, _max_frame, _auto_flag)
    local max_frame = _max_frame
    local min_frame = _min_frame
    for _,v in pairs(self.attrs) do
        for i = 1, #v do
            local content = v[i]
            if _auto_flag then
                local cur_frame_min = content[2][1]
                local cur_frame_max = content[2][2]
                max_frame = math.max(cur_frame_max, max_frame)
                min_frame = math.min(cur_frame_min, min_frame)
            end

            if content[4] ~= nil and content[5] ~= nil and (content[4][1] == 6413 or content[4][1] == 6415) and content[5][1] == 0 then
                local p0 = content[3][1]
                local totalLen = 0
                local lenInfo = {}
                lenInfo[0] = 0
                for test=1,200,1 do
                    local coord = self._cubicBezier3D(content[3][1], content[3][3], content[3][4], content[3][2], test/200)
                    local length = math.sqrt((coord[1]-p0[1])*(coord[1]-p0[1])+(coord[2]-p0[2])*(coord[2]-p0[2]))
                    p0 = coord
                    totalLen = totalLen + length
                    lenInfo[test] = totalLen
                    -- print(test/200 .. " coord: "..coord[1].." - "..coord[2])
                end
                for test=1,200,1 do
                    lenInfo[test] = lenInfo[test]/(lenInfo[200]+0.000001)
                    -- print(test/200 .. "  "..lenInfo[test])
                end
                content['lenInfo'] = lenInfo
            end
        end
    end

    self.all_frame = max_frame - min_frame
    self.min_frame = min_frame
end

function AETools:setAnimFrameRange(_min_frame, _max_frame)
    self:_init(_min_frame, _max_frame)
end

function AETools:getCurrFrameIndex(_p)
    local frame = math.floor(_p*self.all_frame)
    return frame + self.min_frame
end

function AETools:getFrameCount()
    return self.all_frame
end

function AETools._remap01(a,b,x)
    if x < a then return 0 end
    if x > b then return 1 end
    return (x-a)/(b-a)
end

function AETools._cubicBezier(p1, p2, p3, p4, t)
    return {
        p1[1]*(1.-t)*(1.-t)*(1.-t) + 3*p2[1]*(1.-t)*(1.-t)*t + 3*p3[1]*(1.-t)*t*t + p4[1]*t*t*t,
        p1[2]*(1.-t)*(1.-t)*(1.-t) + 3*p2[2]*(1.-t)*(1.-t)*t + 3*p3[2]*(1.-t)*t*t + p4[2]*t*t*t,
    }
end

function AETools._cubicBezier3D(p1, p2, p3, p4, t)
    if #p1 >= 3 then
        return {
            p1[1]*(1.-t)*(1.-t)*(1.-t) + 3*p2[1]*(1.-t)*(1.-t)*t + 3*p3[1]*(1.-t)*t*t + p4[1]*t*t*t,
            p1[2]*(1.-t)*(1.-t)*(1.-t) + 3*p2[2]*(1.-t)*(1.-t)*t + 3*p3[2]*(1.-t)*t*t + p4[2]*t*t*t,
            p1[3]*(1.-t)*(1.-t)*(1.-t) + 3*p2[3]*(1.-t)*(1.-t)*t + 3*p3[3]*(1.-t)*t*t + p4[3]*t*t*t,
        }
    else
        return {
            p1[1]*(1.-t)*(1.-t)*(1.-t) + 3*p2[1]*(1.-t)*(1.-t)*t + 3*p3[1]*(1.-t)*t*t + p4[1]*t*t*t,
            p1[2]*(1.-t)*(1.-t)*(1.-t) + 3*p2[2]*(1.-t)*(1.-t)*t + 3*p3[2]*(1.-t)*t*t + p4[2]*t*t*t,
            0,
        }
    end
end

function AETools:_cubicBezierSpatial(lenInfo, p1, p2, p3, p4, t)
    local p = 0
    if t <= 0 then
        p = 0
    elseif t >= 1 then
        p = 1
    else
        local ts = 0
        local te = 200
        for i=1,200,1 do
            if lenInfo[i] >= t then
                te = i
                ts = i-1
                break
            end
        end
        p = ts/200. + 0.005*(t-lenInfo[ts])/(lenInfo[te]-lenInfo[ts]+0.000001)
    end
    return self._cubicBezier3D(p1, p2, p3, p4, p)
end

function AETools:_cubicBezier01(_bezier_val, p, y_len)
    local x = self:_getBezier01X(_bezier_val, p, y_len)
    return self._cubicBezier(
        {0,0},
        {_bezier_val[1], _bezier_val[2]},
        {_bezier_val[3], _bezier_val[4]},
        {1, y_len},
        x
    )[2]
end

function AETools:_getBezier01X(_bezier_val, x, y_len)
    local ts = 0
    local te = 1
    -- divide and conque
    local times = 1
    repeat
        local tm = (ts+te)*0.5
        local value = self._cubicBezier(
            {0,0},
            {_bezier_val[1], _bezier_val[2]},
            {_bezier_val[3], _bezier_val[4]},
            {1, y_len},
            tm)
        if(value[1]>x) then
            te = tm
        else
            ts = tm
        end
        times = times +1
    until(te-ts < 0.001 and times < 50)

    return (te+ts)*0.5
end

function AETools._mix(a, b, x, type)
    if type == 1 then
        return a * (1-x) + b * x
    else
        return a + x
    end
end

function AETools:GetVal(_name, _progress)
    local content = self.attrs[_name]
    if content == nil then
        return nil
    end

    local cur_frame = _progress * self.all_frame + self.min_frame

    for i = 1, #content do
        local info = content[i]
        local start_frame = info[2][1]
        local end_frame = info[2][2]
        if cur_frame >= start_frame and cur_frame < end_frame then
            local cur_progress = self._remap01(start_frame, end_frame, cur_frame)
            local bezier = info[1]
            local value_range = info[3]
            local y_len = 1
            if (value_range[2][1] == value_range[1][1] and info[5] and info[5][1]==0 and #(value_range[1])==1) then
                y_len = 0
            end

            if #bezier > 4 then
                -- currently scale attrs contains more than 4 bezier values
                local res = {}
                for k = 1, 3 do
                    local cur_bezier = {bezier[k], bezier[k+3], bezier[k+3*2], bezier[k+3*3]}
                    local p = self:_cubicBezier01(cur_bezier, cur_progress, y_len)
                    res[k] = self._mix(value_range[1][k], value_range[2][k], p, y_len)
                end
                return res

            else
                local p = self:_cubicBezier01(bezier, cur_progress, y_len)
                if info[4] ~= nil and info[5] ~= nil and (info[4][1] == 6413 or info[4][1] == 6415) and info[5] and info[5][1] == 0 then
                    local coord = self:_cubicBezierSpatial(info['lenInfo'],
                                                            value_range[1], 
                                                            value_range[3], 
                                                            value_range[4], 
                                                            value_range[2], 
                                                            p)
                    return coord
                end

                if type(value_range[1]) == "table" then
                    local res = {}
                    for j = 1, #value_range[1] do
                        res[j] = self._mix(value_range[1][j], value_range[2][j], p, y_len)
                    end
                    return res
                end
                return self._mix(value_range[1], value_range[2], p, y_len)
            end
        end
    end

    local first_info = content[1]
    local start_frame = first_info[2][1]
    if cur_frame<start_frame then
        return deepcopy(first_info[3][1])
    end

    local last_info = content[#content]
    local end_frame = last_info[2][2]
    if cur_frame>=end_frame then
        return deepcopy(last_info[3][2])
    end

    return nil
end

return AETools