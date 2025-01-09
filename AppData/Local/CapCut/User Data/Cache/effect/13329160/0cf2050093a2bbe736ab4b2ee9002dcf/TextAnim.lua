local util = nil ---@class Util
local disable_glow_flag_temporary_changed_in_future = true
local AETools = AETools or {}     ---@class AETools
AETools.__index = AETools

function AETools:new(frameRate)
    local self = setmetatable({}, AETools)
    self.key_frame_info = {}
    self.frameRate = frameRate == nil and 16 or frameRate
    return self
end

function AETools:addKeyFrameInfo(in_val, out_val, frame, val)
    local key_frame_count = #self.key_frame_info
    if key_frame_count == 0 and frame > 0 then
        self.key_frame_info[key_frame_count + 1] = {
            ["v_in"] = in_val,
            ["v_out"] = out_val,
            ["cur_frame"] = 0,
            ["value"] = val
        }
    end

    key_frame_count = #self.key_frame_info
    self.key_frame_info[key_frame_count + 1] = {
        ["v_in"] = in_val,
        ["v_out"] = out_val,
        ["cur_frame"] = frame,
        ["value"] = val
    }
    self:_updateKeyFrameInfo()
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

function AETools:_cubicBezier01(_bezier_val, p)
    local x = self:_getBezier01X(_bezier_val, p)
    return self._cubicBezier(
        {0,0},
        {_bezier_val[1], _bezier_val[2]},
        {_bezier_val[3], _bezier_val[4]},
        {1,1},
        x
    )[2]
end

function AETools:_getBezier01X(_bezier_val, x)
    local ts = 0
    local te = 1
    -- divide and conque
    repeat
        local tm = (ts+te)*0.5
        local value = self._cubicBezier(
            {0,0},
            {_bezier_val[1], _bezier_val[2]},
            {_bezier_val[3], _bezier_val[4]},
            {1,1},
            tm)
        if(value[1]>x) then
            te = tm
        else
            ts = tm
        end
    until(te-ts < 0.0001)

    return (te+ts)*0.5
end

function AETools._mix(a, b, x)
    return a * (1-x) + b * x
end

function AETools:_updateKeyFrameInfo()
    if self.key_frame_info and #self.key_frame_info > 0 then
        self.finish_frame_time = self.key_frame_info[#self.key_frame_info]["cur_frame"]
    end
end

function AETools._getDiff(val1, val2)
    local res = nil
    if type(val1) == "table" then
        res = {}
        for i = 1, #val1 do
            res[i] = math.abs(val1-val2)
        end
    else
        res = math.abs(val1-val2)
    end
    return res
end

function AETools:_getSingleCurPartVal(val1, val2, duration, info1, info2, part_progress)
    local diff = val2-val1
    if(math.abs(diff) < 0.001) then return val2 end

    local average = diff/duration + 0.0001

    local x1 = info1[2]/100
    local y1 = x1*info1[1]/average
    local x2 = 1-info2[2]/100
    local y2 = 1-(1-x2)*info2[1]/average

    if val1 > val2 then
        x1 = info1[2]/100
        y1 = -x1*info1[1]/average
        x2 = info2[2]/100
        y2 = 1+x2*info2[1]/average
        x2 = 1-x2
        if(x1 < 0.0002)then y1 = 0 end
        if(y2 < 0.0002)then y2 = 0 end
    end
    local bezier_val = {x1, y1, x2, y2}
    -- Amaz.LOGI("lrc x1", x1)
    -- Amaz.LOGI("lrc y1", y1)
    -- Amaz.LOGI("lrc x2", x2)
    -- Amaz.LOGI("lrc y2", y2)
    local progress = self:_cubicBezier01(bezier_val, part_progress)

    local res = self._mix(val1, val2, progress)
    return res
end


function AETools:getCurPartVal(_progress, hard_cut)
    
    local part_id, part_progress = self:_getCurPart(_progress)

    local frame1 = self.key_frame_info[part_id-1]
    local frame2 = self.key_frame_info[part_id]

    if hard_cut == true then
        return frame1["value"]
    end

    local info1 = frame1["v_out"]
    local info2 = frame2["v_in"]

    info1[2] = info1[2] < 0.011 and 0 or info1[2]
    info2[2] = info2[2] < 0.011 and 0 or info2[2]

    local duration = (frame2["cur_frame"]-frame1["cur_frame"])/self.frameRate

    local res = nil
    if type(frame1["value"]) == "table" then
        res = {}
        for i = 1, #frame1["value"] do
            res[i] = self:_getSingleCurPartVal(frame1["value"][i], frame2["value"][i], duration, info1, info2, part_progress)
        end
    else
        res = self:_getSingleCurPartVal(frame1["value"], frame2["value"], duration, info1, info2, part_progress)
    end

    return res

end

function AETools:_getCurPart(progress)
    if progress > 0.999 then
        return #self.key_frame_info, 1
    end

    for i = 1, #self.key_frame_info do
        local info = self.key_frame_info[i]
        if progress < info["cur_frame"]/self.finish_frame_time then
            return i, self._remap01(
                self.key_frame_info[i-1]["cur_frame"]/self.finish_frame_time,
                self.key_frame_info[i]["cur_frame"]/self.finish_frame_time,
                progress
            )
        end
    end
end

function AETools:clear()
    self.key_frame_info = {}
    self:_updateKeyFrameInfo()
end

function AETools:test()
    Amaz.LOGI("lrc "..tostring(self.key_frame_info), tostring(#self.key_frame_info))
end

local exports = exports or {}
local TextAnim = TextAnim or {}
TextAnim.__index = TextAnim
---@class TextAnim : ScriptComponent
---@field autoplay boolean
---@field duration number
---@field curTime number
---@field progress number [UI(Range={0, 1}, Slider)]
---@field last_live_time number

local isEditor = (Amaz.Macros and Amaz.Macros.EditorSDK) and true or false
local util = {}     ---@class Util
local json = cjson.new()
local rootDir = nil
local record_t = {}

local function getBezierValue(controls, t)
    local ret = {}
    local xc1 = controls[1]
    local yc1 = controls[2]
    local xc2 = controls[3]
    local yc2 = controls[4]
    ret[1] = 3*xc1*(1-t)*(1-t)*t+3*xc2*(1-t)*t*t+t*t*t
    ret[2] = 3*yc1*(1-t)*(1-t)*t+3*yc2*(1-t)*t*t+t*t*t
    return ret
end

local function getBezierDerivative(controls, t)
    local ret = {}
    local xc1 = controls[1]
    local yc1 = controls[2]
    local xc2 = controls[3]
    local yc2 = controls[4]
    ret[1] = 3*xc1*(1-t)*(1-3*t)+3*xc2*(2-3*t)*t+3*t*t
    ret[2] = 3*yc1*(1-t)*(1-3*t)+3*yc2*(2-3*t)*t+3*t*t
    return ret
end

local function getBezierTfromX(controls, x)
    local ts = 0
    local te = 1
    -- divide and conque
    repeat
        local tm = (ts+te)/2
        local value = getBezierValue(controls, tm)
        if(value[1]>x) then
            te = tm
        else
            ts = tm
        end
    until(te-ts < 0.0001)

    return (te+ts)/2
end

local function changeVec2ToTable(val)
    return {val.x, val.y}
end

local function changeVec3ToTable(val)
    return {val.x, val.y, val.z}
end

local function changeVec4ToTable(val)
    return {val.x, val.y, val.z, val.w}
end

local function changeCol3ToTable(val)
    return {val.r, val.g, val.b}
end

local function changeCol4ToTable(val)
    return {val.r, val.g, val.b, val.a}
end

local function changeTable2Vec4(t)
    return Amaz.Vector4f(t[1], t[2], t[3], t[4])
end

local function changeTable2Vec3(t)
    return Amaz.Vector3f(t[1], t[2], t[3])
end

local function changeTable2Vec2(t)
    return Amaz.Vector2f(t[1], t[2])
end

local function changeTable2Col3(t)
    return Amaz.Color(t[1], t[2], t[3])
end

local function changeTable2Col4(t)
    return Amaz.Color(t[1], t[2], t[3], t[4])
end

local _typeSwitch = {
    ["vec4"] = function(v)
        return changeVec4ToTable(v)
    end,
    ["vec3"] = function(v)
        return changeVec3ToTable(v)
    end,
    ["vec2"] = function(v)
        return changeVec2ToTable(v)
    end,
    ["float"] = function(v)
        return tonumber(v)
    end,
    ["string"] = function(v)
        return tostring(v)
    end,
    ["col3"] = function(v)
        return changeCol3ToTable(v)
    end,
    ["col4"] = function(v)
        return changeCol4ToTable(v)
    end,

    -- change table to userdata
    ["_vec4"] = function(v)
        return changeTable2Vec4(v)
    end,
    ["_vec3"] = function(v)
        return changeTable2Vec3(v)
    end,
    ["_vec2"] = function(v)
        return changeTable2Vec2(v)
    end,
    ["_float"] = function(v)
        return tonumber(v)
    end,
    ["_string"] = function(v)
        return tostring(v)
    end,
    ["_col3"] = function(v)
        return changeTable2Col3(v)
    end,
    ["_col4"] = function(v)
        return changeTable2Col4(v)
    end,
}

local function typeSwitch()
    return _typeSwitch
end

local function createTableContent()
    local t = {}
    for k,v in pairs(record_t) do
        t[k] = {}
        t[k]["type"] = v["type"]
        t[k]["val"] = v["func"](v["val"])
    end
    return t
end

function util.registerParams(_name, _data, _type)
    record_t[_name] = {
        ["type"] = _type,
        ["val"] = _data,
        ["func"] = _typeSwitch[_type]
    }
end

function util.getRegistedParams()
    return record_t
end

function util.setRegistedVal(_name, _data)
    record_t[_name]["val"] = _data
end

function util.getRootDir()
    if rootDir == nil then
        local str = debug.getinfo(2, "S").source
        rootDir = str:match("@?(.*/)")
    end
    -- Amaz.LOGI("lrc getRootDir 123", tostring(rootDir))
    return rootDir
end

function util.registerRootDir(path)
    rootDir = path
end

function util.bezier(controls)
    local control = controls
    if type(control) ~= "table" then
        control = changeVec4ToTable(controls)
    end
    return function (t, b, c, d)
        t = t/d
        local tvalue = getBezierTfromX(control, t)
        local value =  getBezierValue(control, tvalue)
        return b + c * value[2]
    end
end

function util.remap01(a,b,x)
    if x < a then return 0 end
    if x > b then return 1 end
    return (x-a)/(b-a)
end

function util.remap(smin, smax, dmin, dmax, value)
	return (value - smin) / (smax - smin) * (dmax - dmin) + dmin
end
function util.mix(a, b, x)
    return a * (1-x) + b * x
end

function util.CreateJsonFile(file_path)
    local t = createTableContent()
    local content = json.encode(t)
    local file = io.open(util.getRootDir()..file_path, "w+b")
    if file then
      file:write(tostring(content))
      io.close(file)
    end
end

function util.ReadFromJson(file_path)
    local file = io.input(util.getRootDir()..file_path)
    local json_data = json.decode(io.read("*a"))
    local res = {}
    for k, v in pairs(json_data) do
        local func = _typeSwitch["_"..tostring(v["type"])]
        res[k] = func(v["val"])
    end
    return res
end

function util.bezierWithParams(input_val_4, min_val, max_val, in_val, reverse)
    if type(input_val_4) == "tabke" then
        if reverse == nil then
            return util.bezier(input_val_4)(util.remap01(min_val, max_val, in_val), 0, 1, 1)
        else
            return util.bezier(input_val_4)(1-util.remap01(min_val, max_val, in_val), 0, 1, 1)
        end
    else
        if reverse == nil then
            return util.bezier(util.changeVec4ToTable(input_val_4))(util.remap01(min_val, max_val, in_val), 0, 1, 1)
        else
            return util.bezier(util.changeVec4ToTable(input_val_4))(1-util.remap01(min_val, max_val, in_val), 0, 1, 1)
        end
    end
end


function util.clamp(min, max, value)
	return math.min(math.max(value, min), max)
end

local function getRootDir()
    local rootDir = nil
    if rootDir == nil then
        local str = debug.getinfo(2, "S").source
        rootDir = str:match("@?(.*/)")
    end
    return rootDir
end

local function createRT(px, py, shared)
    local rt = Amaz.ScreenRenderTexture()
    rt.pecentX = px
    rt.pecentY = py
    rt:setShared(shared)
    return rt
end

local ae_attribute = {
	["ADBE_Rotate_X_0_0"]={
		[1]={{0, 33.333333, }, {0.27235057181202, 40.7443589967191, }, 0, 82, }, 
		[2]={{0.53059278448652, 50.6257367490572, }, {0.52503961578972, 33.333333, }, 8, -50, }, 
		[3]={{0.19933072803811, 50.5064742410736, }, {0.20306297576912, 33.333333, }, 15, 10, }, 
		[4]={{0, 36.9405160350954, }, {0, 16.666666667, }, 24, 0, }, 
	}, 
	["ADBE_Opacity_0_1"]={
		[1]={{0, 0.01, }, {500, 0.01, }, 0, 0, }, 
		[2]={{500, 0.01, }, {0, 0.01, }, 5, 100, }, 
		[3]={{500, 0.01, }, {0, 0.01, }, 24, 100, }, 
	}, 
}

function TextAnim.new(construct, ...)
    local self = setmetatable({}, TextAnim)

    -- online attr
    self.duration = 0
    self.curTime = 0

    self.sharedMaterial = nil
	self.materials = nil
    self.renderer = nil
    self.isVertical = 0.0
    self.first = true

    -- Editor about ---
    self.autoplay = false
    self.duration = 2

    -- Runtime ---
    self.progress = 0

    -- Init Attr ----
    self.last_live_time = 1

    -- self:registerParams("move_bezier", "vec4")
    -- self:registerParams("rotate_bezier", "vec4")
    -- self:registerParams("turbulent_offset", "vec2")
    -- self:registerParams("last_live_time", "float")
    -- self:registerParams("radial_blur_number", "float")
    -- self:registerParams("turbulent_number", "float")

    if construct and TextAnim.constructor then TextAnim.constructor(self, ...) end
    return self
end

local function FindParent(trans)
    if trans.parent == nil then
        return trans
    else
        return FindParent(trans.parent)
    end
end

function TextAnim:getParent()
    if self.parent == nil then
        self.parent = FindParent(self.trans)
    end
    return self.parent
end

function TextAnim:initKeyFrame() 
    for _name, info_list in pairs(ae_attribute) do
        local tool = AETools:new(25)
        for i = 1, #info_list do
            tool:addKeyFrameInfo(info_list[i][1], info_list[i][2], info_list[i][3], info_list[i][4])
        end
        self[_name] = tool
    end
end

function TextAnim:registerParams(_name, _type)
    local _data = self[_name]
    if util == nil then
        util = includeRelativePath("Util")
        util.registerRootDir(getRootDir())
    end
    util.registerParams(_name, _data, _type)
end

function TextAnim:constructor()

end

function TextAnim:transInitial(trans)
    if trans then
        trans.localPosition = Amaz.Vector3f(0,0,0)
        trans.localScale = Amaz.Vector3f(1,1,1)
        trans.localEulerAngle = Amaz.Vector3f(0,0,0)
    end
end

function TextAnim:onStart(comp, sys) 
    -- if util == nil then
    --     util = includeRelativePath("Util")
    --     util.registerRootDir(getRootDir())
    -- end
    self.entity = comp.entity
	self.text = comp.entity:getComponent("SDFText")
    if self.text == nil then
        local text = comp.entity:getComponent('Text')
        if text ~= nil then
			self.text = comp.entity:addComponent('SDFText')
            self.text:setTextWrapper(text)
        end
    end
    self.cam = comp.entity.scene:findEntityBy("InfoSticker_camera_entity"):getComponent("Camera")
    self.camTrans = comp.entity.scene:findEntityBy("InfoSticker_camera_entity"):getComponent("Transform")
    self.cameraRenderOrder = self.cam.renderOrder
    self.trans = comp.entity:getComponent("Transform")
	self.transParent = self:getParent()

    self.renderer = nil
	if self.text ~= nil then
		self.renderer = comp.entity:getComponent("MeshRenderer")
	else
		self.renderer = comp.entity:getComponent("Sprite2DRenderer")
	end

    self.first = true
    self.rootDir = getRootDir()
    self.layer = 0

    self.last_rotate_blur = 0
    self.richText = comp.entity:getComponent("Text")
end

function TextAnim:_LoadAssets()
    -- prefabs 
    self.helper_prefab = Amaz.PrefabManager.loadPrefab(self.rootDir, self.rootDir .. "prefabs/helper.prefab")
    
    -- assets
    self.white_quad_mat = self.entity.scene.assetMgr:SyncLoad("effects/white_quad/white_quad.material")
    self.white_quad_mat2 = self.entity.scene.assetMgr:SyncLoad("effects/white_quad/white_quad2.material")
    self.blur1_mat = self.entity.scene.assetMgr:SyncLoad("effects/blur/blur1.material")
    self.normal_mat = self.entity.scene.assetMgr:SyncLoad("effects/normal/normal.material")
    -- self.flip_mat = self.entity.scene.assetMgr:SyncLoad("effects/flip/flip.material")
    -- self.fullscreen_mat = self.entity.scene.assetMgr:SyncLoad("effects/fullscreen/fullscreen.material")
    -- self.normal_mat = self.entity.scene.assetMgr:SyncLoad("effects/normal/normal.material")
end

function TextAnim:initAnim()

    self.text.renderToRT = true
    if self.helper == nil then
        Amaz.LOGI("lrc helper is nil", "test")
        self:loadPrefab()
    end
    self.scene_entities_count = self.entity.scene.entities:size()
    self:_updatePrefabLayer()

    if Amaz.Macros and Amaz.Macros.EditorSDK then
    else
        self:ReadFromJson()
    end

    self:initKeyFrame()

end


function TextAnim:onUpdate(comp, time)
    if Amaz.Macros and Amaz.Macros.EditorSDK then
        self.curTime = self.curTime + time
        self:seek(self.curTime)
    end
end

---@function [UI(Button="generate json file")]
function TextAnim:CreateJsonFile()
    -- Amaz.LOGI("lrc", "CreateJsonFile")
    for k,v in pairs(util.getRegistedParams()) do
        if self[k] == nil then
            Amaz.LOGE("lrc ERROR!!!", "no registed value called : "..tostring(k))
        else
            util.setRegistedVal(k, self[k])
        end
    end
    util.CreateJsonFile("data_val.json")
end

---@function [UI(Button="read from json file")]
function TextAnim:ReadFromJson()
    -- Amaz.LOGI("lrc readfrom json", "read from json")
    local t = util.ReadFromJson("data_val.json")
    for k,v in pairs(t) do 
        self[k] = v
    end
end

function TextAnim:getLayer()
    self.layer = 0
    for i = 0, self.entity.scene.entities:size() - 1 do
        local e = self.entity.scene.entities:get(i)
        local trans = self.trans
        local entityname = ""
        while trans ~= nil  do
            if trans.entity.name ~= "" then
                entityname = trans.entity.name
                break
            end
            trans = trans.parent
        end
        if entityname == e.name then
            self.layer = i
            break
        end
    end
end

function TextAnim:_rotateByAEAxis(_trans, _euler_angle)
    local up = Amaz.Vector3f(0.0, 1.0, 0.0)
    local left = Amaz.Vector3f(1.0, 0.0, 0.0)
    local forward = Amaz.Vector3f(0.0, 0.0, 1.0)

    local y_angle = math.pi * _euler_angle.y/180
    local x_angle = math.pi * _euler_angle.x/180
    local z_angle = math.pi * _euler_angle.z/180

    _trans.localOrientation = 
                            Amaz.Quaternionf.axisAngleToQuaternion(forward, z_angle) *
                            Amaz.Quaternionf.axisAngleToQuaternion(up, y_angle) * 
                            Amaz.Quaternionf.axisAngleToQuaternion(left, x_angle)
end

function TextAnim:seek(time)
    Amaz.LOGE("lrc ", tostring(time))
    if self.first then
        self:initAnim()
        self.first = false
        self.frame = 1

        if self.richText.bloomEnable and disable_glow_flag_temporary_changed_in_future then
            self.oriBloomEnabled = self.richText.bloomEnable
            self.richText.bloomEnable = false
        end
    end

    if Amaz.Macros and Amaz.Macros.EditorSDK then
        if self.autoplay then
            self.progress = time % self.duration / self.duration
        end
    else
        self.progress = time % (self.duration+0.00001) / (self.duration+0.000001)
    end

    local w = Amaz.BuiltinObject:getOutputTextureWidth()
    local h = Amaz.BuiltinObject:getOutputTextureHeight()

    if self.text and self.text.chars:size() > 0 then
        self.text.targetRTExtraSize = Amaz.Vector2f(0,0)
        local parent = self:getParent()
        
        local expandSize = self.text:getRectExpanded()

        if self.helper then
            self.helper.visible = true
        end

        local rect = self.text.rect
        local p = util.bezier({.56,0,.3,1.13})(self.progress,0,1,1)

        local main_rect = Amaz.Vector2f(expandSize.width, expandSize.height)
        local radius = 0
        local length1 = math.abs(main_rect.y*math.cos(radius))
        local length2 = math.abs(main_rect.x*math.cos(radius))
        local meshScale = math.max((w/h)*(length1/w), 1*(length2/h))
        meshScale = meshScale * math.max(main_rect.x, main_rect.y)/math.max(length1, length2)
        meshScale = meshScale * parent.localScale.x
        local extra_scale = Amaz.Vector2f(main_rect.x/main_rect.y, main_rect.y/main_rect.x)
        extra_scale = Amaz.Vector2f(
            extra_scale.x > 1 and 1 or extra_scale.x,
            extra_scale.y > 1 and 1 or extra_scale.y
        )

        self.pass_trans1.localScale = Amaz.Vector3f(meshScale * extra_scale.x, meshScale * extra_scale.y,meshScale * extra_scale.y*0.5)
        
        local sqrt3 = 1.732
        sqrt3 = 2.74747
        self.pass_trans1.localPosition = Amaz.Vector3f(0,0,10-sqrt3-self.pass_trans1.localScale.z)

        local cur_rotate_value = self.ADBE_Rotate_X_0_0:getCurPartVal(self.progress)

        -- if cur_rotate_value < 180 then
        --     cur_rotate_value = -cur_rotate_value
        -- else
        --     cur_rotate_value = 360 - cur_rotate_value
        -- end

        Amaz.LOGI("lrc "..self.progress*24, cur_rotate_value)

        -- Amaz.LOGI("lrc rotate", cur_rotate_value)
        self:_rotateByAEAxis(self.pass_trans1, Amaz.Vector3f(
            cur_rotate_value, 0, parent.localEulerAngle.z
        ))

        self.pass_mat1:setVec2("textSize", main_rect)

        -- self.pass_mat1:setFloat("blurSize", util.mix(0.002, 0, p))
        local pp = self.progress
        if pp < 0.2 then
            pp = util.remap01(0, 0.2, pp)
            pp = util.bezier({.65,0,.87,.42})(pp, 0, 1, 1)
            pp = util.mix(0, 1, pp)
        else
            pp = util.remap01(0.2, 1, pp)
            pp = util.bezier({.86,.21,.35,.93})(pp, 0, 1, 1)
            pp = util.mix(1, 0, pp)
        end
        self.pass_mat2:setFloat("blurSize", pp*0.000)
        self.last_rotate_blur = cur_rotate_value
        self.pass_mat2:setFloat("angle", parent.localEulerAngle.z+90)

        local alpha = self.ADBE_Opacity_0_1:getCurPartVal(self.progress)*0.01
        -- Amaz.LOGI("lrc alpha", alpha)
        self.pass_mat2:setFloat("alpha", alpha)

        self.pass_mat1:setMat4("myModel", self.pass_trans1.localMatrix)

        self.cam1trans:setWorldPosition(self.camTrans:getWorldPosition())
        self.cam1trans:setWorldScale(self.camTrans:getWorldScale())
        self.cam1trans:setWorldOrientation(self.camTrans:getWorldOrientation())

    end

    self.frame = self.frame + 1

    if self.entity.scene.entities:size() ~= self.scene_entities_count then
        self:_updatePrefabLayer()
        self.scene_entities_count = self.entity.scene.entities:size()
    end

end

function TextAnim:_updateByPersCam()
    local pos = self.trans.parent.localPosition
    self.mesh0trans.localPosition = Amaz.Vector3f(pos.x, pos.y, -1/math.tan(50/180*math.pi*0.5))
    -- Amaz.LOGI("lrc", -1/math.tan(50/180*math.pi*0.5)*0.5)

end

function TextAnim:loadPrefab()
    if isEditor then
        self:_LoadAssets()
    end
    self.helper = self.helper_prefab:instantiateToEntity(self.entity.scene, self.trans.parent.entity)
    self.helper.visible = true

    for i = 0, 1 do
        self["cam"..i] = self.helper:searchEntity("cam"..i):getComponent("Camera")
        self["cam"..i.."trans"] = self.helper:searchEntity("cam"..i):getComponent("Transform")
        self["cam"..i].renderTexture = createRT(1,1,false)
        self["rt"..i] = self["cam"..i].renderTexture
    end

    if self.renderer then
        self.renderer.sharedMaterial = self.normal_mat:instantiate()
    end

    for i = 1, 2 do
        self["pass"..i] = self.helper:searchEntity("pass"..i)
        self["pass_trans"..i] = self["pass"..i]:getComponent("Transform")
        self["pass_mesh"..i] = self["pass"..i]:getComponent("MeshRenderer")
    end
    self["pass_mesh"..1].material = self.white_quad_mat2:instantiate()
    self["pass_mat"..1] = self["pass_mesh"..1].material
    self["pass_mat"..1]:setTex("mainTex", self.rt0)

    self["pass_mesh"..2].material = self.blur1_mat:instantiate()
    self["pass_mat"..2] = self["pass_mesh"..2].material
    self["pass_mat"..2]:setTex("inputTexture", self.rt1)

    if self.cam then
        self.cam.renderOrder = 100000
    end

end

function TextAnim:_setDynamicBitSet(layer, cam)
    if  cam then
        local x = layer
        x = math.floor(x / 64) * 64 + 64
        local bitset = Amaz.DynamicBitset.new(x,"0x0")
        cam.layerVisibleMask = bitset:set(layer, true)
    end
end

function TextAnim:_updatePrefabLayer()
    if self.helper then
        self:getLayer()
        local parent_idx = self.layer * 10
        self.entity.layer = parent_idx

        self["pass"..1].layer = parent_idx + 1
        self["pass"..2].layer = 0
        
        self.cam0.renderOrder = parent_idx + 1
        self.cam1.renderOrder = parent_idx + 2
    
        self:_setDynamicBitSet(self.entity.layer, self.cam0)
        self:_setDynamicBitSet(parent_idx + 1, self.cam1)
    end
end

function TextAnim:resetData()
    if self.text and self.text.chars:size() > 0 then
        self:transInitial(self.trans)
        self.text.renderToRT = false
    end

    if self.helper ~= nil then
        self.text.entity.scene:removeEntity(self.helper)
        self.trans.children:erase(self.helper)
        self.helper = nil
    end
    if self.cam then
        self.cam.renderOrder = self.cameraRenderOrder
    end
    self.text.entity.layer = 0

    if self.oriBloomEnabled then
        self.richText.bloomEnable = self.oriBloomEnabled
    end

    collectgarbage("collect")
end


function TextAnim:setDuration(duration)
    self.duration = duration
end

function TextAnim:clear()
    Amaz.LOGI("lrc", "clear")
    self:resetData()
end


function TextAnim:onEnter()
    Amaz.LOGI("lrc", "onEnter")
    -- self:resetData()
    self.first = true
end

function TextAnim:onLeave()
    Amaz.LOGI("lrc", "onLeave")
    self:resetData()
    self.first = true
end

exports.TextAnim = TextAnim
return exports
