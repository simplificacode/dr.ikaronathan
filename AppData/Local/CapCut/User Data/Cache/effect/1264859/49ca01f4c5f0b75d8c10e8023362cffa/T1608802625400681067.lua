
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

local exports = exports or {}
local T1608802625400681067 = T1608802625400681067 or {}
T1608802625400681067.__index = T1608802625400681067
function T1608802625400681067.new(construct, ...)
    local self = setmetatable({}, T1608802625400681067)
    self.duration = 1.0
    self.count = 0
    if construct and T1608802625400681067.constructor then T1608802625400681067.constructor(self, ...) end
    return self
end

function T1608802625400681067:constructor()

end

function T1608802625400681067:remap01(a,b,x)
    if x < a then
        return 0
    end
    if x > b then
        return 1
    end
    return (x-a)/(b-a)
end

function T1608802625400681067:onStart(comp) 
    self.text = comp.entity:getComponent("SDFText")
    
    if self.text == nil then
        local text = comp.entity:getComponent('Text')
        if text ~= nil then
			self.text = comp.entity:addComponent('SDFText')
            self.text:setTextWrapper(text)
        end
    end 
    
	self.trans = comp.entity:getComponent("Transform")
	-- self.text.str = 'Transform'

	self.first = true
	self.renderer = nil
	if self.text ~= nil then
		self.renderer = comp.entity:getComponent("MeshRenderer")
	else
		self.renderer = comp.entity:getComponent("Sprite2DRenderer")
	end
end


function T1608802625400681067:seek(time)
	if self.first then
		local materials = Amaz.Vector()
		local InsMaterials = self.sharedMaterial:instantiate()
		materials:pushBack(InsMaterials)
		self.materials = materials
		self.renderer.materials = self.materials
		if self.text ~= nil then
			self.text.renderToRT = true
		else
		end
        self.first = false
        if self.text ~= nil then
            local rect = self.text.rect
            self.text.targetRTExtraSize = Amaz.Vector2f(rect.width * 1.2, rect.height * 0.2)
        end
	end

	-- time = time % self.duration

	-- text animation
	if self.text ~= nil then
        local rect = self.text.rect
        local ratio = Amaz.Vector2f(1, rect.width/rect.height)
        self.charScale = {}
        local maxScale = 1.2
        local minScale = 0.2
        for i = 1, self.text.chars:size() do
            self.charScale[i] = (maxScale - minScale) * math.pow(i/self.text.chars:size(), 1/4) + minScale
        end

        self.materials:get(0):setFloat("u_blurSize", 1)
        self.materials:get(0):setVec2("ratio", ratio)


        local progress = time / self.duration
        if progress < 0.999999 then
            self.materials:get(0):setFloat("appear", self:remap01(0, 0.7, progress))
            -- progress = self:remap01(0, 0.9, progress)
            local p_1_0 = 1-progress
            self.materials:get(0):setFloat("u_blurSize", 
                                        1.1 * bezier({0.24, 0.53, 0.42, 0.97})(p_1_0, 0, 1, 1))

            local chars = self.text.chars
            local size = chars:size()
            --Amaz.LOGI("lrc", tostring(size))

            local charDuration = self.duration / size
            for i = 1, size do
                local char = chars:get(i-1)
                local value = 0
                if time > charDuration * (i-1) - charDuration*0.7 then
                    local scale = self.charScale[i]
                    local time_remap = self:remap01(charDuration * (i-1)  - charDuration*0.7, self.duration, time)

                    local percent = (i-1)/(size-1 + 0.0001)
                    value = bezier({0.5-0.15*percent, 0.35+0.15*percent, 0.41+0.57*percent, 0.98-0.57*percent})(1-time_remap, 0, 1, 1) * scale + 1
                else
                    value = 0
                end

                char.scale = Amaz.Vector3f(value, value, value)
                --Amaz.LOGI("lrc char "..char.utf8code, tostring(char.scale))
            end

        else
            self.materials:get(0):setFloat("appear", 1)
            self.materials:get(0):setFloat("u_blurSize", 0)
        end

	end
end

function T1608802625400681067:setDuration(duration)
   self.duration = duration
end

function T1608802625400681067:resetData()
	if self.text ~= nil then
		local chars = self.text.chars 
		for i = 1, chars:size() do
			local char = chars:get(i - 1)
			if char.rowth ~= -1 then
				char.position = char.initialPosition
				char.rotate = Amaz.Vector3f(0, 0, 0)
				char.scale = Amaz.Vector3f(1, 1, 1)
				char.color = Amaz.Vector4f(1, 1, 1, 1)
			end
		end
        self.text.chars = chars
        self.text.targetRTExtraSize = Amaz.Vector2f(0.0,0.0)
	end

	self.trans.localPosition = Amaz.Vector3f(0, 0, 0)
	self.trans.localEulerAngle = Amaz.Vector3f(0, 0, 0)
	self.trans.localScale = Amaz.Vector3f(1, 1, 1)
end

function T1608802625400681067:clear()
	self:resetData()
    if self.text ~= nil then
		self.text.renderToRT = false
		self.sharedMaterial:enableMacro('ANIMSEQ', 0)
		-- self.renderer.sharedMaterials = Amaz.Vector()
	end
end

function T1608802625400681067:onEnter()
	self.first = true
end


function T1608802625400681067:onLeave()
	self:resetData()
	if self.text ~= nil then
		self.text.renderToRT = false
	end
	self.first = true
end


exports.T1608802625400681067 = T1608802625400681067
return exports
