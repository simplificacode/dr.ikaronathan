--@input float duration = 1.5{"widget":"slider","min":0.1,"max":3.0}

local editor = {
	enable = false,
	time = 0,
}

local exports = exports or {}
local TextAnim = TextAnim or {}
TextAnim.__index = TextAnim
function TextAnim.new(construct, ...)
    local self = setmetatable({}, TextAnim)

    self.sharedMaterial = nil
    self.tween = nil
	self.materials = nil
    self.renderer = nil
    self.duration = 0

    if construct and TextAnim.constructor then TextAnim.constructor(self, ...) end
    return self
end

function TextAnim:constructor()

end

function TextAnim:onStart(comp) 
    -- Amaz.LOGI('AE_LUA_TAG', 'TextAnim:onStart')

	self.text = comp.entity:getComponent('SDFText')
    if self.text == nil then
        local text = comp.entity:getComponent('Text')
        if text ~= nil then
			self.text = comp.entity:addComponent('SDFText')
            self.text:setTextWrapper(text)
        end
    end
    self.renderer = comp.entity:getComponent("MeshRenderer")

    if editor.enable then
        self.sharedMaterial = comp.entity:getComponent('Transform').parent.entity:getComponent('MeshRenderer').materials:get(0)
    end
end

-- used for editor simulate
function TextAnim:onUpdate(comp, deltaTime)
	if editor.enable then
		local properties = comp.properties
		if properties:has('duration') then
			local duration = properties:get('duration')
			self:setDuration(duration)
		end

        self:seek(editor.time)
        editor.time = editor.time + deltaTime
	end
end

local function updateTween(self)
    --Amaz.LOGI("wdg==","updateTween1")
    if self.tweenDirty == false then
		return
	end
    --Amaz.LOGI("wdg==","updateTween2")
    self.text.renderToRT = true
    local materials = Amaz.Vector()
    local InsMaterials = self.sharedMaterial:instantiate()
    materials:pushBack(InsMaterials)
    self.materials = materials
    self.renderer.materials = self.materials

    local mat = self.materials:get(0)
    self.tween = self.text.entity.scene.tween:fromTo(mat, {['deg'] = 0}, {['deg'] = 1}, self.duration, Amaz.Ease.linear, nil, 0.0, nil, false)
    mat:setVec4('texSize', Amaz.Vector4f(1, 1, 0, 0))
    self.tweenDirty = false
end

function TextAnim:seek(time)
    updateTween(self)

    self.text.renderToRT = true
    self.renderer.materials = self.materials

    self.tween:set(time)
    --Amaz.LOGI("wdg==","seek"..time)
    local mat = self.materials:get(0)
    local tex = mat:getTex('_MainTex')
    if tex then
        mat:setVec4('texSize', Amaz.Vector4f(tex.width, tex.height, 0, 0))
    end

    -- alpha gradual change
    local alpha_gradual_change_duration = 5/30
    if time<=alpha_gradual_change_duration then
        self.text.alpha = time/alpha_gradual_change_duration
    else 
        self.text.alpha = 1.0
    end

end

function TextAnim:setDuration(duration)
    if math.abs(duration - self.duration) > 0.01 then
		self.duration = duration
        self.tweenDirty = true
	end
end

function TextAnim:clear()
    --Amaz.LOGI("wdg==","clear")
	if self.tween then
        self.tween:clear()
        self.tween = nil
        self.text.renderToRT = false
        self.text.alpha = 1.0
    end
end

function TextAnim:onEnter()
    --Amaz.LOGI("wdg==","onEnter")
	self.tweenDirty = true
end

function TextAnim:onLeave()
    --Amaz.LOGI("wdg==","onLeave")
    self:clear()
    self.tweenDirty = true
end


exports.TextAnim = TextAnim
return exports
