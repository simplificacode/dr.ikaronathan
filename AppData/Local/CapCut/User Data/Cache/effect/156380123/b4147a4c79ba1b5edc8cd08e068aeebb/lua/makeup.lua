local isEditor = (Amaz.Macros and Amaz.Macros.EditorSDK) and true or false
local exports = exports or {}
local makeup = makeup or {}
---
---@class makeup : ScriptComponent [UI(Display="makeup")]
----@field intensity double [UI(Range={0,1}, Slider)]
---
makeup.__index = makeup

-- output
local FACE_ADJUST = "face_adjust"
local FACE_ID = "id"
local FACE_ADJUST_INTENSITY = "intensity"
local RESET_PARAMS = "reset_params"

-- runtime
local EPSC = 0.001
local SEGMENT_ID = "segmentId"
local LOG_TAG = "AE_EFFECT_TAG makeup.lua"

local nameMap = {
    face_adjust_brow = "Brow",
    face_adjust_eyeshadow = "Eyeshadow",
    face_adjust_eyeline = "Eyeline",
    face_adjust_eyemazing = "Eyemazing",
    face_adjust_eyelash = "Eyelash",
    face_adjust_pupil = "Pupil",
    face_adjust_stereo = "Stereo",
    face_adjust_blusher = "Blusher",
    face_adjust_lip = "Lip",
}

local function splitKey(key)
    local res = {}
    local idx = -1
    for i = 1, string.len(key) do
        if string.sub(key, i, i) == '_' then
            idx = i
        end
    end
    if idx > 0 then
        res[1] = string.sub(key, 1, idx - 1)
        res[2] = string.sub(key, idx + 1)
    end
    return res
end

function makeup.new(construct, ...)
    local self = setmetatable({}, makeup)
    self.entities = {}
    -- param
    self.maxFaceNum = 10
    self.maxDisplayNum = 5
    self.faceAdjustMaps = {}
    self.lastTempIntensity = {}
    for tagName, entityName in pairs(nameMap) do
        self.lastTempIntensity[entityName] = {}
        for i = 0, self.maxFaceNum - 1 do
            self.lastTempIntensity[entityName][i] = { material = nil, intensity = 0 }
        end
    end
    return self
end

function makeup:onStart(comp, script)
    local scene = comp.entity.scene
    self.scriptProps = comp.properties
    local segmentId = self.scriptProps:get(SEGMENT_ID)
    if segmentId ~= nil then
        self.logTag = string.format('%s %s', LOG_TAG, segmentId)
    else
        self.logTag = LOG_TAG
    end

    script:clearAllEventType()
    script:addEventType(Amaz.AppEventType.SetEffectIntensity)

    local entities = scene.entities
    for i = 0, entities:size() - 1 do
        local entity = entities:get(i)
        for tagName, entityName in pairs(nameMap) do
            if entityName == entity.name then
                local makeup = entity:getComponent("EffectFaceMakeup")
                local renderer = entity:getComponent("MeshRenderer")
                local table = entity:getComponent("TableComponent")
                self.entities[entityName] = {
                    makeup = makeup,
                    renderer = renderer,
                    table = table,
                }
            end
        end
    end
end

function makeup:onUpdate(comp, deltaTime)
    -- get face info by size order
    self:updateFaceInfoBySize()

    -- init tempIntensity
    local tempIntensity = {}
    for tagName, entityName in pairs(nameMap) do
        tempIntensity[entityName] = {}
        for i = 0, self.maxFaceNum - 1 do
            tempIntensity[entityName][i] = { material = nil, intensity = 0 }
        end
    end

    -- set tempIntensity by faceAdjustMaps
    for key, intensityVec in pairs(self.faceAdjustMaps) do
        local split = splitKey(key)
        local tag = split[1]
        local mat = split[2]
        -- Amaz.LOGW(self.logTag, "onUpdate tag " .. tag .. " mat " .. mat)
        if tag ~= nil then
            local entityName = nameMap[tag]
            if entityName ~= nil then
                for i = 1, self.maxDisplayNum do -- maxFaceNum
                    local faceInfo = self.faceInfoBySize[i]
                    local id = faceInfo.id
                    local index = faceInfo.index
                    local intensity = 0
                    for j = 0, intensityVec:size() - 1 do
                        local inputMap = intensityVec:get(j)
                        if id == inputMap:get(FACE_ID) and inputMap:has(FACE_ADJUST_INTENSITY) then
                            intensity = inputMap:get(FACE_ADJUST_INTENSITY)
                        elseif -1 == inputMap:get(FACE_ID) and inputMap:has(FACE_ADJUST_INTENSITY) then
                            intensity = inputMap:get(FACE_ADJUST_INTENSITY)
                        end
                    end
                    -- Amaz.LOGW(self.logTag, "onUpdate id " .. id .. " index " .. index .. " intensity " .. intensity)
                    if intensity ~= 0 then
                        tempIntensity[entityName][index] = { material = mat, intensity = intensity }
                    end
                end
            end
        end
    end

    -- set material, intensity
    for tagName, entityName in pairs(nameMap) do
        local entity = self.entities[entityName]
        if entity ~= nil then
            local makeup = entity['makeup']
            local renderer = entity['renderer']
            if makeup ~= nil and renderer ~= nil then
                for i = 0, self.maxFaceNum - 1 do
                    local params = tempIntensity[entityName][i]
                    local intensity = params['intensity']
                    if isEditor then 
                        intensity = self.intensity
                    end 
                    -- Amaz.LOGW(self.logTag, "onUpdate entityName " .. entityName .. " i " .. i .. " intensity " .. intensity)
                    makeup:setFaceUniform("opacity", i, intensity)
                end
            end
        end
    end

    self.lastTempIntensity = tempIntensity
end

function makeup:onEvent(comp, event)
    if event.type == Amaz.AppEventType.SetEffectIntensity then
        self:handleIntensityEvent(comp, event)
    end
end

function makeup:handleIntensityEvent(comp, event)
    local key = event.args:get(0)
    if key == RESET_PARAMS then
        self.faceAdjustMaps = {}
        return
    end
    for tagName, entityName in pairs(nameMap) do
        if string.sub(key, 1, string.len(tagName)) == tagName then
            self.faceAdjustMaps[key] = event.args:get(1)
        end
    end
end

function makeup:updateFaceInfoBySize()
    self.faceInfoBySize = {}

    local result = Amaz.Algorithm.getAEAlgorithmResult()
    local faceCount = result:getFaceCount()
    local freidCount = result:getFreidInfoCount()
    -- Amaz.LOGW(self.logTag, "updateFaceInfoBySize faceCount " .. faceCount .. " freidCount " .. freidCount)
    for i = 0, self.maxFaceNum - 1 do
        local trackId = -1
        local faceSize = 0
        if i < faceCount then
            local baseInfo = result:getFaceBaseInfo(i)
            local faceId = baseInfo.ID
            local faceRect = baseInfo.rect
            for j = 0, freidCount - 1 do
                local freidInfo = result:getFreidInfo(j)
                if faceId == freidInfo.faceid then
                    trackId = freidInfo.trackid
                end
            end
            faceSize = faceRect.width * faceRect.height
        end
        table.insert(self.faceInfoBySize, {
            index = i,
            id = trackId,
            size = faceSize
        })
        -- Amaz.LOGW(self.logTag, "updateFaceInfoBySize add face info index " .. i .. " id " .. trackId .. " size " .. faceSize)
    end
    table.sort(self.faceInfoBySize, function(a, b)
        return a.size > b.size
    end)
end

exports.makeup = makeup
return exports