local exports = exports or {}
local face_info = face_info or {}
face_info.__index = face_info

-- output
local FACE_INFO = "face_info"
local FACE_MESH = "face_mesh"
local FACE_COUNT_EXCEED_MAX = "face_count_exceed_max"
local FACE_ID = "id"
local FACE_INDEX = "index"
local FACE_BBOX = "bbox"
local FACE_DIRECT = "direct"

-- runtime
local MIN = math.min
local MAX = math.max
local SEGMENT_ID = "segmentId"
local LOG_TAG = "AE_EFFECT_TAG face_info.lua"

function face_info.new(construct, ...)
    local self = setmetatable({}, face_info)

    -- param
    self.maxFaceNum = 10
    self.maxDisplayNum = 5

    return self
end

function face_info:onStart(comp, script)
    local scene = comp.entity.scene
    local scriptSystem = scene:getSystem("ScriptSystem")
    scriptSystem:clearAllEventType()

    self.scriptProps = comp.properties
    local segmentId = self.scriptProps:get(SEGMENT_ID)
    if segmentId ~= nil then
        self.logTag = string.format('%s %s', LOG_TAG, segmentId)
    else
        self.logTag = LOG_TAG
    end

    self.meshTemplate = self.scriptProps:get(FACE_MESH)
    if self.meshTemplate ~= nil then
        self.meshType = Amaz.AMGBeautyMeshType.FACE145
        self.meshTool = Amaz.AMGFaceMeshUtils()
        self.meshTool:setMesh(self.meshTemplate, self.meshType)
    else
        Amaz.LOGE(self.logTag, "self.meshTemplate == nil")
    end
end

function face_info:onUpdate(comp, deltaTime)
    self.inputWidth = Amaz.BuiltinObject:getInputTextureWidth()
    self.inputHeight = Amaz.BuiltinObject:getInputTextureHeight()
    self:updateFaceInfoBySize()
    self:updateFaceAlgoParams()
end

function face_info:onEvent(comp, event)
    if event.type == Amaz.AppEventType.SetEffectIntensity then
        self:handleIntensityEvent(comp, event)
    end
end

function face_info:handleIntensityEvent(comp, event)
end

function face_info:updateFaceInfoBySize()
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

function face_info:updateFaceAlgoParams()
    local faceAlgoParams = Amaz.Vector()
    local faceCountExceedMax = false

    local result = Amaz.Algorithm.getAEAlgorithmResult()
    for i = 1, self.maxDisplayNum do
        local faceInfo = self.faceInfoBySize[i]
        local id = faceInfo.id
        local index = faceInfo.index
        if id ~= -1 then
            local baseInfo = result:getFaceBaseInfo(index)
            local algoMap = Amaz.Map()
            algoMap:set(FACE_ID, id)
            algoMap:set(FACE_INDEX, index)
            algoMap:set(FACE_BBOX, self:getFaceBBox(baseInfo))
            algoMap:set(FACE_DIRECT, self:getFaceAngle(baseInfo))
            faceAlgoParams:pushBack(algoMap)
        end
    end
    local freidCount = result:getFreidInfoCount()
    if freidCount > self.maxDisplayNum then
        faceCountExceedMax = true
    end
    self.scriptProps:set(FACE_INFO, faceAlgoParams)
    self.scriptProps:set(FACE_COUNT_EXCEED_MAX, faceCountExceedMax)
    -- Amaz.LOGW(self.logTag, "updateFaceAlgoParams face algo params size " .. faceAlgoParams:size())
end

function face_info:getFaceAngle(info)
    local angle = Amaz.FloatVector()
    angle:pushBack(info.yaw)
    angle:pushBack(info.pitch)
    angle:pushBack(info.roll)
    return angle
end

function face_info:getFaceBBox(info)
    local points_array = info.points_array
    local rect = info.rect

    local min_x = rect.x * 2 - 1 -- left
    local min_y = rect.y * 2 - 1 -- bottom
    local max_x = (rect.x + rect.width) * 2 - 1 -- right
    local max_y = (rect.y + rect.height) * 2 - 1 -- top
    if points_array:size() > 0 then
        self.meshTool:updateMeshWithFaceData106(self.meshType, points_array, 0)
        local indexs = {117, 120, 123, 127, 130, 133, 136, 139, 142}
        local point, x, y
        for i = 1, 9 do
            point = self.meshTemplate:getVertex(indexs[i])
            x = point.x * 2 / self.inputWidth - 1
            y = 1 - point.y * 2 / self.inputHeight
            min_x = MIN(min_x, x)
            min_y = MIN(min_y, y)
            max_x = MAX(max_x, x)
            max_y = MAX(max_y, y)
        end
    end

    local bbox = Amaz.FloatVector()
    bbox:pushBack(MAX(min_x, -1)) -- left
    bbox:pushBack(MIN(max_y, 1)) -- top
    bbox:pushBack(MIN(max_x, 1)) -- right
    bbox:pushBack(MAX(min_y, -1)) -- bottom
    return bbox
end

exports.face_info = face_info
return exports