local Main = require("Main")

local TextAnim = {}
TextAnim.__index = TextAnim

function TextAnim.new()
    local self = setmetatable({}, TextAnim)
    self.curTime = 0.0
    self.duration = 5.0
    self.w = 0
    self.h = 0
    self._visible = false
    self._dirty = false
    self._main = Main.new()
    return self
end

function TextAnim:onStart (comp)
    self.scene = comp.entity.scene
    local cameraEntity = self.scene:findEntityBy("InfoSticker_camera_entity")
    if cameraEntity then
        self.camera = cameraEntity:getComponent("Camera")
    end
    self.rootPath = debug.getinfo(1, "S").source:match("@?(.*/)")
    self.rootNode = comp.entity:getComponent("Transform")
    self.rootText = comp.entity:getComponent("Text")
    self.rootTextOld = comp.entity:getComponent("SDFText")
    if not self.rootTextOld then
        if self.rootText then
            self.rootTextOld = comp.entity:addComponent("SDFText")
            self.rootTextOld:setTextWrapper(self.rootText)
        end
    end
    self._main:onCreate(self)
end

function TextAnim:onEnter ()
    if not self.visible then
        self._main:onShow(self)
        self._visible = true
    end
    self._dirty = true
end

function TextAnim:onLeave ()
    if self._visible then
        self._main:onHide(self)
        self._visible = false
    end
end

function TextAnim:clear ()
    self:onLeave()
end

function TextAnim:onSetProperty (key, value)
    if key ~= "common_parameters_adjustment" or value == "" then
        return
    end
    local data = cjson.decode(value)
    for k, v in pairs(data) do
        if k == "animation_adjust_direction" then
            if v == "left" then
                self.dir = self.dirL
                self._dirty = true
            elseif v == "right" then
                self.dir = self.dirR
                self._dirty = true
            elseif v == "down" then
                self.dir = self.dirD
                self._dirty = true
            elseif v == "up" then
                self.dir = self.dirU
                self._dirty = true
            end
        elseif k == "animation_adjust_content_mode" then
            if v == "char" then
                self.split = self.splitByChar
                self._dirty = true
            elseif v == "word" then
                self.split = self.splitByWord
                self._dirty = true
            elseif v == "line" then
                self.split = self.splitByLine
                self._dirty = true
            elseif v == "all" then
                self.split = self.splitByNone
                self._dirty = true
            end
        elseif k == "animation_adjust_color" then
            self.color = v
            self._dirty = true
        end
    end
end

function TextAnim:setDuration (duration)
    self.duration = duration
end

function TextAnim:seek (time)
    if not self._visible then
        return
    end
    local w = Amaz.BuiltinObject:getOutputTextureWidth()
    local h = Amaz.BuiltinObject:getOutputTextureHeight()
    if self.w ~= w or self.h ~= h then
        self.w = w
        self.h = h
        self._dirty = true
    end
    self._main:onUpdate(self, self._dirty, time)
    self._dirty = false
end


---#ifdef DEV
--//function TextAnim:onUpdate (comp, dt)
--//    self:seek(math.min(self.curTime, self.duration))
--//    self.curTime = self.curTime + dt
--//end
--//function TextAnim:onEvent (comp, event)
--//    if event.type ~= Amaz.EventType.TOUCH then
--//        return
--//    end
--//    local pointer = event.args:get(0)
--//    if pointer.type == Amaz.TouchType.TOUCH_BEGAN then
--//        self.curTime = 0
--//        self:onEnter()
--//    elseif pointer.type == Amaz.TouchType.TOUCH_ENDED or pointer.type == Amaz.TouchType.TOUCH_CANCELLED then
--//        self:onLeave()
--//    end
--//end
---#endif


local exports = exports or {}
exports.TextAnim = TextAnim
return exports