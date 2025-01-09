local exports = exports or {}
local makeup = makeup or {}
makeup.__index = makeup

-- output
local FACE_ADJUST = "face_adjust_whole"
local FACE_ID = "id"
local FACE_ADJUST_INTENSITY = "intensity"
local FACE_ADJUST_DISABLE_PART = "disable_part"
local RESET_PARAMS = "reset_params"

-- runtime
local EPSC = 0.001
local SEGMENT_ID = "segmentId"
local LOG_TAG = "AE_EFFECT_TAG makeup.lua"

local makeup2dMap = {
    Brow = { "face_adjust_brow" },
    Eyeshadow = { "face_adjust_eyeshadow" },
    Eyeline = { "face_adjust_eyeline" },
    Eyemazing = { "face_adjust_eyemazing" },
    Eyelash = { "face_adjust_eyelash" },
    Pupil = {
        "face_adjust_pupil",
        "face_adjust_eyelight"
    },
    Stereo = { "face_adjust_stereo" },
    Blusher = { "face_adjust_blusher" },
    Lip = { "face_adjust_lip" },
}

local opacity2dDefault = "opacity"
local opacity2dMap = {
    -- face_adjust_brow = "opacity",
    -- face_adjust_eyeshadow = "opacity",
    -- face_adjust_eyeline = "opacity",
    -- face_adjust_eyemazing = "opacity",
    -- face_adjust_eyelash = "opacity",
    -- face_adjust_stereo = "opacity",
    -- face_adjust_blusher = "opacity",
    -- face_adjust_lip = "opacity",
    face_adjust_pupil = "sucaiOpacity",
    face_adjust_eyelight = "reflectOpacity",
}

local makeup3dMap = {
    -- Eyelash3D = { "face_adjust_eyelash" },
    Face3D = {
        "face_adjust_mask",
        "face_adjust_highlight",
        "face_adjust_lip",
        "face_adjust_eyeshadow" 
    },
}

local opacity3dDefault = "uOpacity"
local opacity3dMap = {
    face_adjust_mask = "uMaskOpacity",
    face_adjust_highlight = "uHighlightOpacity",
    face_adjust_lip = "uLipOpacity",
    face_adjust_eyeshadow = "uSequinOpacity"
}

function makeup.new(construct, ...)
    local self = setmetatable({}, makeup)

    -- param
    self.maxFaceNum = 10
    self.maxDisplayNum = 5
    self.faceAdjustMaps = {}
    -- self.faceAdjustMaps[-1] = {
    --     face_adjust_brow = 1,
    --     face_adjust_eyeshadow = 1,
    --     face_adjust_eyeline = 1,
    --     face_adjust_eyemazing = 1,
    --     face_adjust_eyelash = 1,
    --     face_adjust_pupil = 1,
    --     face_adjust_eyelight = 1,
    --     face_adjust_stereo = 1,
    --     face_adjust_blusher = 1,
    --     face_adjust_lip = 1,
    --     face_adjust_mask = 1,
    --     face_adjust_highlight = 1,
    -- }

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

    self.makeup2dCamera = scene:findEntityBy("Makeup2DCamera")
    if self.makeup2dCamera ~= nil then
        self.makeup2dObjs = {}
        for name, _ in pairs(makeup2dMap) do
            local entity = scene:findEntityBy(name)
            self.makeup2dObjs[name] = {
                entity = entity,
                makeup = entity:getComponent("EffectFaceMakeup"),
            }
        end
        -- Amaz.LOGS(self.logTag, "onStart add makeup 2d objects")
    end
    self.makeup3dCamera = scene:findEntityBy("Makeup3DCamera")
    if self.makeup3dCamera ~= nil then
        self.makeup3dObjs = {}
        for name, _ in pairs(makeup3dMap) do
            self.makeup3dObjs[name] = {}
            for i = 0, self.maxDisplayNum - 1 do
                local entity = scene:findEntityBy(name .. i)
                self.makeup3dObjs[name][i] = {
                    entity = entity,
                    renderer = entity:getComponent("MeshRenderer"),
                }
            end
        end
        -- Amaz.LOGS(self.logTag, "onStart add makeup 3d objects")
    end
end

function makeup:onUpdate(comp, deltaTime)
    -- get face info by size order
    self:updateFaceInfoBySize()

    -- update makeup with valid track id
    for i = 1, self.maxFaceNum do
        local faceInfo = self.faceInfoBySize[i]
        local id = faceInfo.id
        local index = faceInfo.index
        local mesh = faceInfo.mesh
        local adjustMap = nil
        if id ~= -1 and i <= self.maxDisplayNum then
            adjustMap = self.faceAdjustMaps[id]
            if adjustMap == nil then
                adjustMap = self.faceAdjustMaps[-1]
            end
        end
        if adjustMap ~= nil then
            -- Amaz.LOGS(self.logTag, "onUpdate has valid adjustMap in id " .. id .. " index " .. index)
        else
            -- Amaz.LOGS(self.logTag, "onUpdate no valid adjustMap in id " .. id .. " index " .. index)
        end
        self:updateMakeup2D(adjustMap, index)
        self:updateMakeup3D(adjustMap, i - 1, mesh)
    end
end

function makeup:updateMakeup2D(adjustMap, faceIndex)
    for name, adjustKeys in pairs(makeup2dMap) do
        local makeup2dObj = self.makeup2dObjs[name]
        if makeup2dObj.entity.visible == true then
            local makeup2dComp = makeup2dObj.makeup
            local makeup2dOpacity = 0
            if adjustMap ~= nil then
                for _, key in pairs(adjustKeys) do
                    local opacityName = opacity2dMap[key]
                    local opacityValue = adjustMap[key]
                    if opacityName == nil then
                        makeup2dOpacity = opacityValue
                    else
                        makeup2dComp:setFaceUniform(opacityName, faceIndex, opacityValue)
                        if opacityValue > EPSC then
                            makeup2dOpacity = 1
                        end
                    end
                end
            end
            makeup2dComp:setFaceUniform(opacity2dDefault, faceIndex, makeup2dOpacity)
        end
    end
end

function makeup:updateMakeup3D(adjustMap, faceIndex, meshInfo)
    if faceIndex >= self.maxDisplayNum then
        return
    end
    local meshUpdate = false
    for name, adjustKeys in pairs(makeup3dMap) do
        local makeup3dObj = self.makeup3dObjs[name][faceIndex]
        if makeup3dObj.entity.visible == true then
            local makeup3dRenderer = makeup3dObj.renderer
            local makeup3dOpacity = 0
            if adjustMap ~= nil and meshInfo ~= nil then
                for _, key in pairs(adjustKeys) do
                    local opacityName = opacity3dMap[key]
                    local opacityValue = adjustMap[key]
                    if opacityName == nil then
                        makeup3dOpacity = opacityValue
                    else
                        makeup3dRenderer.props:setFloat(opacityName, opacityValue)
                        if opacityValue > EPSC then
                            makeup3dOpacity = 1
                        end
                    end
                end
            end
            makeup3dRenderer.enabled = makeup3dOpacity > EPSC
            if makeup3dRenderer.enabled then
                meshUpdate = true
            end
            if name == "Face3D" and meshUpdate == true then
                local faceMVP = meshInfo.mvp
                local faceModel = meshInfo.modelMatrix
                local facePos = meshInfo.vertexes
                local faceNormals = meshInfo.normals
                if facePos:size() >= 1200 then
                    makeup3dRenderer.mesh:setVertexArray(facePos)
                    makeup3dRenderer.mesh:setNormalArray(faceNormals)
                    makeup3dRenderer.props:setMatrix("uModel", faceModel)
                    makeup3dRenderer.props:setMatrix("uMVP", faceMVP)
                end
            end
        end
    end
end

function makeup:onEvent(comp, event)
    if event.type == Amaz.AppEventType.SetEffectIntensity then
        self:handleIntensityEvent(comp, event.args)
    end
end

function makeup:handleIntensityEvent(comp, args)
    local inputKey = args:get(0)
    local inputValue = args:get(1)
    -- Amaz.LOGS(self.logTag, "handleIntensityEvent set " .. inputKey)

    if inputKey == RESET_PARAMS then
        self.faceAdjustMaps = {}
    elseif inputKey == FACE_ADJUST then
        self.faceAdjustMaps = {}
        local inputSize = inputValue:size()
        for i = 0, inputSize - 1 do
            local inputMap = inputValue:get(i)
            local inputId = inputMap:get(FACE_ID)
            local inputIntensity = inputMap:get(FACE_ADJUST_INTENSITY)
            -- Amaz.LOGS(self.logTag, "handleIntensityEvent set intensity to " .. inputIntensity .. " in id " .. inputId)
            local adjustMap = {
                face_adjust_brow = inputIntensity,
                face_adjust_eyeshadow = inputIntensity,
                face_adjust_eyeline = inputIntensity,
                face_adjust_eyemazing = inputIntensity,
                face_adjust_eyelash = inputIntensity,
                face_adjust_pupil = inputIntensity,
                face_adjust_eyelight = inputIntensity,
                face_adjust_stereo = inputIntensity,
                face_adjust_blusher = inputIntensity,
                face_adjust_lip = inputIntensity,
                face_adjust_mask = inputIntensity,
                face_adjust_highlight = inputIntensity,
            }
            local disableParts = inputMap:get(FACE_ADJUST_DISABLE_PART)
            for j = 0, disableParts:size() - 1 do
                local disablePart = disableParts:get(j)
                adjustMap[disablePart] = 0
                -- Amaz.LOGS(self.logTag, "handleIntensityEvent disable " .. disablePart .. " in id " .. inputId)
            end
            self.faceAdjustMaps[inputId] = adjustMap
        end
    end
end

function makeup:updateFaceInfoBySize()
    self.faceInfoBySize = {}

    local result = Amaz.Algorithm.getAEAlgorithmResult()
    local faceCount = result:getFaceCount()
    local freidCount = result:getFreidInfoCount()
    local face3dCount = result:getFaceFittingCount1256()
    -- Amaz.LOGS(self.logTag, "updateFaceInfoBySize faceCount " .. faceCount .. " freidCount " .. freidCount)
    for i = 0, self.maxFaceNum - 1 do
        local trackId = -1
        local meshInfo = nil
        local faceSize = 0
        if i < faceCount then
            local baseInfo = result:getFaceBaseInfo(i)
            local faceId = baseInfo.ID
            local faceRect = baseInfo.rect
            for j = 0, face3dCount - 1 do
                local face3dInfo = result:getFaceMeshInfo1256(j)
                if faceId == face3dInfo.ID then
                    meshInfo = face3dInfo
                end
            end
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
            mesh = meshInfo,
            size = faceSize
        })
        -- Amaz.LOGS(self.logTag, "updateFaceInfoBySize add face info index " .. i .. " id " .. trackId .. " size " .. faceSize)
    end
    table.sort(self.faceInfoBySize, function(a, b)
        return a.size > b.size or (a.size == b.size and a.index < b.index)
    end)
end

exports.makeup = makeup
return exports