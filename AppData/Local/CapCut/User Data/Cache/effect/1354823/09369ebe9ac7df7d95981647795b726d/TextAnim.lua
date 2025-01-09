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

local function bezier(controls)
    return function (t, b, c, d)
        t = t/d
        local tvalue = getBezierTfromX(controls, t)
        local value =  getBezierValue(controls, tvalue)
        return b + c * value[2]
    end
end

local function remap01(a,b,x)
    if x < a then
        return 0
    end
    if x > b then
        return 1
    end
    return (x-a)/(b-a)
end

local exports = exports or {}
local TextAnim = TextAnim or {}
TextAnim.__index = TextAnim
function TextAnim.new(construct, ...)
    local self = setmetatable({}, TextAnim)
    self.sharedMaterial = nil
	self.materials = nil
    self.renderer = nil
    self.isVertical = 0.0
    self.duration = 0
    self.first = true
    self.lasttime = 0.0
    self.length = 0.45
    if construct and TextAnim.constructor then TextAnim.constructor(self, ...) end
    return self
end

function TextAnim:constructor()

end

function TextAnim:onStart(comp) 
	self.text = comp.entity:getComponent("SDFText")
    if self.text == nil then
        local text = comp.entity:getComponent('Text')
        if text ~= nil then
			self.text = comp.entity:addComponent('SDFText')
            self.text:setTextWrapper(text)
        end
    end
    self.renderer = comp.entity:getComponent("MeshRenderer")
    self.first = true
end

function TextAnim:initAnim()
    self.text.renderToRT = true
    local materials = Amaz.Vector()
    local InsMaterials = self.sharedMaterial:instantiate()
    materials:pushBack(InsMaterials)
    self.materials = materials
    self.renderer.materials = self.materials
end

function TextAnim:seek(time)
    if self.first then
        self:initAnim()
        self.first = false
    end
    
    self.text.renderToRT = true
    local rect = self.text.rect
    local textW = rect.width
    local screenW = Amaz.BuiltinObject:getOutputTextureWidth()
    local screenH = Amaz.BuiltinObject:getOutputTextureHeight()

    local p_scale = self.text.entity:getComponent("Transform").parent.localScale

    -- self.text.targetRTExtraSize = Amaz.Vector2f((screenW*0.5 - rect.width / (screenW/screenH) * 0.5)/(p_scale.x), 0)
    
    local duration = time / self.duration

    if self.text then
        if  time > 0 then
            local value = 1-duration
            if duration < 0.05 then
                value = remap01(0, 0.05, duration)
                local pos = Amaz.Vector3f(((1-value) * -1 - 0.4) * p_scale.x,0,0)
                self.text.entity:getComponent("Transform").localPosition = pos
            else
                value = remap01(0.05, 0.99, duration)
                value = bezier({0.7,0.2,1,0.2})(1-value, 0, 1, 1)
                local pos = Amaz.Vector3f((-0.4 * (value)) * p_scale.x,0,0)
                self.text.entity:getComponent("Transform").localPosition = pos
            end
    
        else
    
        end

        self.renderer.materials:get(0):setFloat("appear", remap01(0.01, 0.15, duration))

        self.renderer.materials = self.materials
    end

end

function TextAnim:resetData()
    if self.text then
        self.text.renderToRT = false
        -- for i = 1, self.text.chars:size() do
        --     local char = self.text.chars:get(i-1)
        --     char.position = char.initialPosition
        -- end
        -- self.renderer.materials:get(0):setFloat("appear", 1)
        self.text.entity:getComponent("Transform").localPosition = Amaz.Vector3f(0, 0, 0)
    end
end

function TextAnim:setDuration(duration)
    self.duration = duration
end

function TextAnim:clear()
    self:resetData()
end


function TextAnim:onEnter()
    self.first = true
end

function TextAnim:onLeave()
    self:resetData()
    self.first = true
end

exports.TextAnim = TextAnim
return exports
