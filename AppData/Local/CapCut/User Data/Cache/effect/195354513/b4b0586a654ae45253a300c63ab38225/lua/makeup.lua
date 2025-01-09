local isEditor = (Amaz.Macros and Amaz.Macros.EditorSDK) and true or false
--
local exports = exports or {}
local makeup = makeup or {}
---
---@class makeup : ScriptComponent [UI(Display="makeup")]
---@field intensity double [UI(Range={0, 1}, Drag)]
---

makeup.__index = makeup

-- output
local FACE_ADJUST = "face_adjust"
local FACE_ID = "id"
local FACE_ADJUST_INTENSITY = "intensity"
local FACE_ADJUST_PREFAB_PATH = "path"
local RESET_PARAMS = "reset_makeup_root"

-- runtime
local EPSC = 0.001
local SEGMENT_ID = "segmentId"
local LOG_TAG = "AE_EFFECT_TAG makeup.lua"

local PredefinedMakeupEntityList = {
    "Brow",
    "Eyeshadow",
    "Eyeline",
    "Eyemazing",
    "Eyelash",
    "Pupil",
    "Stereo",
    "Blusher",
    "Lip",---blendmode multiply
    "Lip_BlendModeColor",
    "Lip_BlendModeScreen"
}

local tagNameList = {
    "face_adjust_brow",
    "face_adjust_eyeshadow",
    "face_adjust_eyeline",
    "face_adjust_eyemazing",
    "face_adjust_eyelash",
    "face_adjust_pupil",
    "face_adjust_stereo",
    "face_adjust_blusher",
    "face_adjust_lip"
}

function makeup.new(construct, ...)
    local self = setmetatable({}, makeup)
    self.entities = {}
    -- param
    self.maxFaceNum = 10
    self.maxDisplayNum = 5
    self.rootDir = ""
    self.prefabMaterialMap = {}

    self.faceAdjustMapsTable = {}  -- save the input adjust event
    self.makeupEvents = {}         -- parser faceAdjustMapsTable, to get which entity should use which material in which tracking id

    self.isUpdated = false
    return self
end

function makeup:isStringInList(str, list)
    for i = 1, #list do
        if str == list[i] then
            return true
        end
    end
    return false
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

    self.rootDir = scene.assetMgr.rootDir

    script:clearAllEventType()
    script:addEventType(Amaz.AppEventType.SetEffectIntensity)

    local entities = scene.entities
    for i = 0, entities:size() - 1 do
        local entity = entities:get(i)

        if self:isStringInList(entity.name, PredefinedMakeupEntityList) then
            self.entities[entity.name] = entity
        end
    end
end

function makeup:onUpdate(comp, deltaTime)
    -- Amaz.LOGI(LOG_TAG, "onUpdate")
    -- get face info by size order
    self:updateFaceInfoBySize()

    --parser faceAdjustMapsTable to get its entity should valid on which tracking id and which material it should use
    self:parserAdjustEvent()

    local tempIntensity = {}
    for i = 0, #PredefinedMakeupEntityList do
        local entityName = PredefinedMakeupEntityList[i]
        local entity = self.entities[entityName]

        if entity then
            if not isEditor then
                entity.visible = false
            end

            tempIntensity[entityName] = {}
            for f_idx = 0, self.maxFaceNum - 1 do
                tempIntensity[entityName][f_idx] = {material = nil, intensity = 0}
                if isEditor then
                    tempIntensity[entityName][f_idx].intensity = self.intensity
                end
            end

            for ind = 1, self.maxDisplayNum do -- maxFaceNum
                local faceInfo = self.faceInfoBySize[ind]
                local tracking_id = faceInfo.id   -- tracking id
                local index = faceInfo.index  -- n-th of the face result
                if self.makeupEvents[entityName] ~= nil and self.makeupEvents[entityName][tracking_id] ~= nil and self.makeupEvents[entityName][tracking_id]['intensity'] > 0 then
                    tempIntensity[entityName][index] = self.makeupEvents[entityName][tracking_id]
                    entity.visible = true
                end
            end
        end
    end

    for i = 0, #PredefinedMakeupEntityList do
        local entityName = PredefinedMakeupEntityList[i]
        local entity = self.entities[entityName]

        if entity ~= nil then
            local makeup = entity:getComponent("EffectFaceMakeup")
            local renderer = entity:getComponent("MeshRenderer")
            local table = entity:getComponent("TableComponent")
            if makeup ~= nil and renderer ~= nil and table ~= nil and entity.visible then
                local materials = Amaz.Vector()
                local defaultMaterial = table.table:get('default')

                if tempIntensity[entityName] then
                    for f_idx = 0, self.maxFaceNum - 1 do
                        local params = tempIntensity[entityName][f_idx]
                        if params then
                            local material = params["material"]
                            if material ~= nil then
                                -- Amaz.LOGI(LOG_TAG, "apply prefab material")
                                materials:pushBack(material:instantiate())
                            else
                                -- Amaz.LOGI(LOG_TAG, "apply default material")
                                materials:pushBack(defaultMaterial)
                            end
                        else
                            materials:pushBack(defaultMaterial)
                        end
                    end
                else
                    materials:pushBack(defaultMaterial)
                end

                renderer.sharedMaterials = materials

                --need to init makeup comp to avoid it is not inited
                makeup:onInit()
                -- we have to update opacite after set sharedMaterials
                if tempIntensity[entityName] then
                    for f_idx = 0, self.maxFaceNum - 1 do
                        local params = tempIntensity[entityName][f_idx]
                        if params then
                            local intensity = params['intensity']
                            if intensity ~= nil then
                                --Amaz.LOGI(LOG_TAG, "entity : "..entityName..", f_id: "..f_idx.." apply opacity intensity:"..intensity)
                                makeup:setFaceUniform("opacity", f_idx, intensity)
                            else
                                makeup:setFaceUniform("opacity", f_idx, 0.0)
                            end
                        end
                    end
                end
            end
        end
    end

    self.isUpdated = true
end

function makeup:onEvent(comp, event)
    if event.type == Amaz.AppEventType.SetEffectIntensity then
        self:handleIntensityEvent(comp, event)
    end
end

function makeup:handleIntensityEvent(comp, event)
    local key = event.args:get(0)
    -- Amaz.LOGI(LOG_TAG, "onEvent: key ="..key)
    if key == RESET_PARAMS then
        self.faceAdjustMapsTable = {}
        return
    end

    for i = 1, #tagNameList do
        if string.sub(key, 1, string.len(tagNameList[i])) == tagNameList[i] then
            self:eventDataToTable(key, event.args:get(1))
        end
    end
end

function makeup:eventDataToTable(key, data)
    if self.isUpdated then 
        self.faceAdjustMapsTable = {}
        self.isUpdated = false
    end 

    for j = 0, data:size() - 1 do
        if data:get(j):has(FACE_ID) and data:get(j):has(FACE_ADJUST_INTENSITY) and data:get(j):has(FACE_ADJUST_PREFAB_PATH) then 
            local id = data:get(j):get(FACE_ID)
            local intensity = data:get(j):get(FACE_ADJUST_INTENSITY)
            local path = data:get(j):get(FACE_ADJUST_PREFAB_PATH)
            if self.faceAdjustMapsTable[key] == nil then 
                self.faceAdjustMapsTable[key] = {}
            end
            self.faceAdjustMapsTable[key][j] = {trackingId = id, intensity = intensity, path = path}
            -- Amaz.LOGI(LOG_TAG, "data to table key: "..key.." intensity: "..intensity.." id: "..id)
        else
            -- Amaz.LOGI(LOG_TAG, "data to table faild, key: "..key)
        end 
    end 
end 

function makeup:parserAdjustEvent()
    self.makeupEvents = {}

    --first， we parser the original adjust event, decompose those event which tracking id is -1 to the display tracking id.
    --we should discard intensity = 0
    local faceAdjustMapsTableTmp = {}
    for key, intensityVec in pairs(self.faceAdjustMapsTable) do
        faceAdjustMapsTableTmp[key] = {}
        local count = 0

        for i = 1, self.maxDisplayNum do -- maxFaceNum
            local faceInfo = self.faceInfoBySize[i]
            local intensity = 0
            local prefab_path = nil

            --this logic is nessarry, because we can encounter this case:
            --[0] : key = "a", trackingid = -1, intensity = 1.0, path = "xxx"
            --[1] : key = "a", trackingid = 3, intensity = 0.0, path = "xxx"
            --we want to exclude the invalid trackingid = 3 event to prevent it affects other key which trackingid = 3 and intensity ~= 0
            for j = 0, #intensityVec do
                local inputMap = intensityVec[j]
                if inputMap and inputMap["trackingId"] then 
                    if faceInfo.id == inputMap["trackingId"] then
                        intensity = inputMap['intensity']
                        prefab_path = inputMap['path']
                    elseif -1 == inputMap["trackingId"] then
                        intensity = inputMap['intensity']
                        prefab_path = inputMap['path']
                    end
                end
            end

            if intensity > 0 and prefab_path ~= nil and faceInfo.id ~= -1 then
                faceAdjustMapsTableTmp[key][count] = {trackingId = faceInfo.id, intensity = intensity, path = prefab_path}
                count = count + 1
            end
        end
    end

    for key, intensityVec in pairs(faceAdjustMapsTableTmp) do
        for i = 0, #intensityVec do
            local inputMap = intensityVec[i]
            if inputMap and inputMap["trackingId"] and inputMap["intensity"] and inputMap["path"] then
                local tracingId = inputMap["trackingId"]
                local intensity = inputMap["intensity"]
                local prefab_path = inputMap["path"]

                --load prefab, and analysis these entities it contains
                -- prefab with same path is same one, so only load the material at the first time
                 if self.prefabMaterialMap[prefab_path] == nil then
                    self.prefabMaterialMap[prefab_path] = {}

                    local prefab = Amaz.PrefabManager.loadPrefab(prefab_path, "makeup.prefab")
                    if prefab then
                        prefab:init()
                        local prefab_entities = prefab.entities

                        --for each entity, we set the corresponding tracing id , material and intensity
                        for i = 0, prefab_entities:size() - 1 do
                            local entity = prefab_entities:get(i)
                            local makeup = entity:getComponent("EffectFaceMakeup")
                            local renderer = entity:getComponent("MeshRenderer")
                            if makeup and renderer then
                                if self.makeupEvents[entity.name] == nil then
                                    self.makeupEvents[entity.name] = {}
                                end
                                self.prefabMaterialMap[prefab_path][entity.name] = renderer.sharedMaterial
                                self.makeupEvents[entity.name][tracingId] = {intensity = intensity, material = renderer.sharedMaterial}
                            else
                                -- Amaz.LOGE(LOG_TAG, "load prefab failded! makeup is null")
                            end
                        end 
                    end

                    --release prefab
                    prefab = nil
                    collectgarbage("collect")
                 else
                    for name, sharedMaterial in pairs(self.prefabMaterialMap[prefab_path]) do
                        if self.makeupEvents[name] == nil then
                            self.makeupEvents[name] = {}
                        end
                        self.makeupEvents[name][tracingId] = {intensity = intensity, material = sharedMaterial}
                    end
                 end
            end
        end
    end
end

function makeup:updateFaceInfoBySize()
    self.faceInfoBySize = {}

    local result = Amaz.Algorithm.getAEAlgorithmResult()
    local faceCount = result:getFaceCount()
    local freidCount = result:getFreidInfoCount()
    --Amaz.LOGI(LOG_TAG, "faceCount:"..faceCount)
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
    end
    table.sort(
        self.faceInfoBySize,
        function(a, b)
            return a.size > b.size
        end
    )
end

exports.makeup = makeup
return exports
