local util = nil ---@class Util

local exports = exports or {}
local TextAnim = TextAnim or {}
TextAnim.__index = TextAnim
---@class TextAnim : ScriptComponent
---@field autoplay boolean
---@field y_indez number
---@field mask_width number
---@field w_stren number
---@field offset_x number
---@field mask_right number
---@field GlowRange number
---@field duration number
---@field curTime number
---@field progress number [UI(Range={0, 1}, Slider)]
---@field blurStep number
---@field rotation Vector3f
---@field movement Vector3f
---@field movementInfo Vector4f
---@field blurInfo Vector4f
---@field blurProgressBezier Vector4f

local function print(f,b)
    --Amaz.LOGI("lrc "..tostring(f), tostring(b))
end

local function getRootDir()
    local rootDir = nil
    if rootDir == nil then
        local str = debug.getinfo(2, "S").source
        rootDir = str:match("@?(.*/)")
    end
    return rootDir
end

local ae_attribute = {
	["motion_blur"]={
		[1]={{0, 16.666666667, }, {-357.142857142857, 16.666666667, }, 14, 100, }, 
		[2]={{-357.142857142857, 16.666666667, }, {0, 16.666666667, }, 24, 0, }, 
	}, 
	["wrpmesh"]={
		[1]={{0, 33.333333, }, {1.4990891017419e-7, 47.2555437827663, }, 0, 14, }, 
		[2]={{6.90442831796645e-8, 50.9632879639225, }, {0, 16.666666667, }, 21, 0, }, 
		[3]={{6.90442831796645e-8, 50.9632879639225, }, {0, 16.666666667, }, 24, 0, }, 
	}
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
    self.isBlur = true
    self.duration = 2

    -- Runtime ---
    self.progress = 0

    -- Init Attr ----
    self.blurStep = 3
    self.angle = 3
    self.rotation = Amaz.Vector3f(0,0,0)
    self.movement = Amaz.Vector3f(0,0,0)
    self.movementInfo = Amaz.Vector4f(0,0.5,4,1)
    self.blurInfo = Amaz.Vector4f(0,0.2,4,1)
    self.blurProgressBezier = Amaz.Vector4f(.22, .12, .88, .08)

    -- self:registerParams("blurInfo", "vec4")
    -- self:registerParams("angle", "float")
    -- self:registerParams("blurProgressBezier", "vec4")
    self:registerParams("mask_width", "float")
    self:registerParams("GlowRange", "float")
    self:registerParams("y_indez", "float")
    self:registerParams("w_stren", "float")
    self:registerParams("offset_x", "float")
    if construct and TextAnim.constructor then TextAnim.constructor(self, ...) end
    return self
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


function TextAnim:initKeyFrame() 
    for _name, info_list in pairs(ae_attribute) do
        local tool = includeRelativePath("AETools"):new(util)
        for i = 1, #info_list do
            tool:addKeyFrameInfo(info_list[i][1], info_list[i][2], info_list[i][3], info_list[i][4])
        end
        self[_name] = tool
    end
end


function TextAnim:transInitial(trans)
    if trans then
        trans.localPosition = Amaz.Vector3f(0,0,0)
        trans.localScale = Amaz.Vector3f(1,1,1)
        trans.localEulerAngle = Amaz.Vector3f(0,0,0)
    end
end

function TextAnim:onStart(comp) 
    if util == nil then
        util = includeRelativePath("Util")
        util.registerRootDir(getRootDir())
    end

    self.entity = comp.entity
	self.text = comp.entity:getComponent("SDFText")
    if self.text == nil then
        local text = comp.entity:getComponent('Text')
        if text ~= nil then
			self.text = comp.entity:addComponent('SDFText')
            self.text:setTextWrapper(text)
        end
    end
    self.trans = comp.entity:getComponent("Transform")
	self.transParent = self.trans.parent

    self.renderer = nil
	if self.text ~= nil then
		self.renderer = comp.entity:getComponent("MeshRenderer")
	else
		self.renderer = comp.entity:getComponent("Sprite2DRenderer")
	end

    self:transInitial(self.trans)
    self:initKeyFrame()
    self.first = true

end

function TextAnim:initAnim()
    self.text.renderToRT = true
    local materials = Amaz.Vector()
    local InsMaterials = nil
    if self.sharedMaterial then
        InsMaterials = self.sharedMaterial:instantiate()
    else
        InsMaterials = self.renderer.material
    end
    materials:pushBack(InsMaterials)
    self.materials = materials
    self.renderer.materials = self.materials

    if Amaz.Macros and Amaz.Macros.EditorSDK then
    else
        self:ReadFromJson()
    end
    self.text.renderToRT = true
    local h = Amaz.BuiltinObject:getOutputTextureHeight()
    local w = Amaz.BuiltinObject:getOutputTextureWidth()

    self.text.targetRTExtraSize = Amaz.Vector2f(w, h)

    -- local tex = materials:getTex('_MainTex')
    -- if tex then
    --     Amaz.LOGI("==========>>mainTex","")
    --     -- mat:setVec4('texSize', Amaz.Vector4f(tex.width, tex.height, 0, 0))
    --     self.text.targetRTExtraSize = Amaz.Vector2f(tex.width, tex.height)
    -- end
end

local function randVal(val, perc)
    return math.random() * val * perc + val * (1-perc)
end

function TextAnim:onUpdate(comp, time)
    -- Amaz.LOGI("lrc", "onUpdate time: "..time)
    if Amaz.Macros and Amaz.Macros.EditorSDK then
        self.curTime = self.curTime + time
        self:seek(self.curTime)
    end
end

---@function [UI(Button="generate json file")]
function TextAnim:CreateJsonFile()

    for k,v in pairs(util.getRegistedParams()) do
        if self[k] == nil then
            --Amaz.LOGE("lrc ERROR!!!", "no registed value called : "..tostring(k))
        else
            util.setRegistedVal(k, self[k])
        end
    end
    util.CreateJsonFile("data_val.json")
end

---@function [UI(Button="read from json file")]
function TextAnim:ReadFromJson()
    local t = util.ReadFromJson("data_val.json")
    for k,v in pairs(t) do 
        self[k] = v
    end
end

local function movement_curve(val)
    local x = val
    local sin = math.sin((x+0.5)*math.pi)
    local exp = math.exp(-x)
    return sin * exp
end


function TextAnim:seek(time)
    if self.first then
        self:initAnim()
        self.first = false
        self.materials:get(0):setFloat("first_frame", 1.)
    else
        self.materials:get(0):setFloat("first_frame", 0.)
    end

    --Amaz.LOGI("==========>>mainTex",tostring(self.materials:get(0)))
    local mat = self.materials:get(0)
    local tex = mat:getTex('_MainTex')
    local width = 0
    if tex then
        width = tex.width
    else
        width = self.text.rect.width*self.trans.localScale.x
    end

    local w = Amaz.BuiltinObject:getOutputTextureWidth()
    mat:setFloat("texFixScale",w/self.text.rect.width*self.trans.localScale.x + 1.0)
    
    if Amaz.Macros and Amaz.Macros.EditorSDK then
        if self.autoplay then
            self.progress = time % self.duration / self.duration
        end
    else
        self.progress = time % (self.duration+0.001) / self.duration
    end

    if self.text and self.text.chars:size() > 0 then

        local pt2 = 1.1*self.progress
        pt2 = pt2 > 1.0 and 1.0 or pt2
        local progress = util.bezier({0.95,0.0,0.32,1})(pt2, 0, 1, 1)


        local motion_blur = self.motion_blur:getCurPartVal(self.progress)/100.0
        -- self.bottom_mat:setFloat("turbulent_number", turbulent_number)


        -- local progress = util.bezier({0.43,0.94,0.71,0.78})(self.progress, 0, 1, 1)

        local fix_blur = 0.5 + 0.5*util.remap01(0.0,0.2,self.progress)
        self.materials:get(0):setFloat("y_indez",self.y_indez*motion_blur*fix_blur)

        self.materials:get(0):setFloat("GlowRange", self.GlowRange*motion_blur*fix_blur)

        local rect = self.text.rect
        -- Amaz.LOGE("wjs",rect.width .. " " .. rect.height)
        self.materials:get(0):setFloat("sdfwidth", rect.width)
        self.materials:get(0):setFloat("sdfHeight", rect.height)
        local progress2 = util.remap01(0.01,0.2,self.progress)
        self.materials:get(0):setFloat("mask_width", self.mask_width*0.3+self.mask_width*0.7*progress2)
        --local pt1 = (1.0 - progress*1.25)
        local pt1 = (0.0 + progress*1.25)
        self.materials:get(0):setFloat("mask_right", pt1)
        local width = self.mask_width*progress2
        local wrep = self.wrpmesh:getCurPartVal(self.progress)/14
        self.materials:get(0):setFloat("progress", wrep)
        self.materials:get(0):setFloat("w_stren", self.w_stren)
        self.materials:get(0):setFloat("offset_x", self.offset_x)
        self.materials:get(0):setFloat("w_stren", 0.2)
        self.materials:get(0):setFloat("offset_x", 0)
    end

end

function TextAnim:resetData()
    if self.text and self.text.chars:size() > 0 then
        self.text.renderToRT = false
        self:transInitial(self.trans)
        self.text.targetRTExtraSize = Amaz.Vector2f(0,0)
    end
end


function TextAnim:setDuration(duration)
    self.duration = duration
end

function TextAnim:clear()
    self:resetData()
end


function TextAnim:onEnter()
    self:resetData()
    self.first = true
end

function TextAnim:onLeave()
    self:resetData()
    self.first = true
end

exports.TextAnim = TextAnim
return exports
