local exports = exports or {}
local global = global or {}
global.__index = global

local ganTextureUniform = "ganTexture"
local inferenceNodeName = "Inference"
local resNodeName = "StyleTransferPostProcess"
local tfmNodeName = "FaceAlign"
-- local faceSelectNodeName = "face_select_0"
local maxFaceNum = 10
local maxDisplayNum = 5

-- face select params
local FACE_INFO = "face_info"
local FACE_COUNT_EXCEED_MAX = "face_count_exceed_max"
local FACE_ADJUST = "face_adjust"
local FACE_ID = "id"
local FACE_INDEX = "index"
local FACE_BBOX = "bbox"
local FACE_DIRECT = "direct"
local FACE_ADJUST_INTENSITY = "intensity"
local EPSC = 0.001

local printd = function(...)
    local arg = {...}
    local msg = "effect_lua:"
    for k, v in pairs(arg) do
        msg = msg .. tostring(v) .. " "
    end
    -- Amaz.LOGD("algolua", msg)
end

local printi = function(...)
    local arg = {...}
    local msg = "effect_lua:"
    for k, v in pairs(arg) do
        msg = msg .. tostring(v) .. " "
    end
    -- Amaz.LOGI("algolua", msg)
end

local printe = function(...)
    local arg = {...}
    local msg = "effect_lua:"
    for k, v in pairs(arg) do
        msg = msg .. tostring(v) .. " "
    end
    -- Amaz.LOGE("algolua", msg)
end

function global.new(construct, ...)
    local self = setmetatable({}, global)
    self.comps = {}
    self.compsdirty = true
    return self
end

function global:constructor()
end

function global:onComponentAdded(sys, comp)
    -- printe('running: global:onComponentAdded '..tostring(comp.name))
end

function global:onComponentRemoved(sys, comp)
    -- printe('running: global:onComponentRemoved'..tostring(comp.name))
end

function global:onStart(sys)
    -- self:init_func__main(sys)

    -- self.slider_init_lim = 10
    -- self.slider_init_cter = 0
    -- self.slider_h.e.visible = false
    -- self.slider_s_factor.e.visible = false

    -- self.h_default_value = 1.0
    -- self.s_factor_default_value = 0.5

    -- self.str_h_tp = "[blend1 controller]: %.4f"
    -- self.str_s_factor_tp = "[saturation controller]: %.4f"

    -- printe("running: gan:onStart")
    -- self.faceMaskMVPUniform = "uFaceSegMVP"
    -- self.faceMaskDetectedUniform = "uFaceSegDetected"
    -- self.faceMaskTextureUniform = "uFaceSeg"
    self.initState = true
    self.MeshRenders = {}
    local entities = sys.scene.entities
    local baseEntity = nil
    local baseMeshRenderLayer = 0
    for i = 0, entities:size() - 1 do
        local entity = entities:get(i)
        local renderer = entity:getComponent("MeshRenderer")
        if renderer then
            local tex = Amaz.Texture2D()
            renderer.material:setTex(ganTextureUniform, tex)
            baseEntity = entity
            self.MeshRenders[0] = renderer
            baseMeshRenderLayer = entity.layer
        else
            printe("gan", "MeshRenderer is nil")
        end

        if entity.name == "SeekModeScript" then
            local scriptComp = entity:getComponent("ScriptComponent")
            -- self.scriptProps = scriptComp.properties
        end
    end

    -- Add other face renderers
    for i = 1, maxFaceNum - 1 do
        local entity = sys.scene:cloneEntityFrom(baseEntity)
        -- entity.layer = baseMeshRenderLayer+i
        self.MeshRenders[i] = entity:getComponent("MeshRenderer")
        if not entity:getComponent("MeshRenderer") then
            printe("gan==", "MeshRenderer is nil")
        end
        local tex = Amaz.Texture2D()
        self.MeshRenders[i].material:setTex(ganTextureUniform, tex)
        -- sys.scene.entities:pushBack(entity)
    end

    -- Face adjust and selection
    self.faceAdjustMaps = {}
    local defaultMap = Amaz.Map()
    defaultMap:set(FACE_ID, -1)
    defaultMap:set(FACE_ADJUST_INTENSITY, 0)
    self.faceAdjustMaps[-1] = defaultMap
end

-- local AlgoType = {"Inference"}
-- local faceId2RenderId = {0}

-- function global:FaceSegMaterialUpdate(faceSeg, mvpName, texName, faceSegMaterial)
--     local warpMat = faceSeg.warp_mat
--     local w = math.max(0.001, faceSeg.face_mask_size)
--     local h = math.max(0.001, faceSeg.face_mask_size)
--     local segMVP = Amaz.Matrix4x4f()
--     segMVP:SetRow(0, Amaz.Vector4f(warpMat:get(0) / w, warpMat:get(1) / w, 0.0, warpMat:get(2) / w))
--     segMVP:SetRow(1, Amaz.Vector4f(warpMat:get(3) / h, warpMat:get(4) / h, 0.0, warpMat:get(5) / h))
--     segMVP:SetRow(2, Amaz.Vector4f(0.0, 0.0, 1.0, 0.0))
--     segMVP:SetRow(3, Amaz.Vector4f(0.0, 0.0, 0.0, 1.0))
    
--     faceSegMaterial:setMat4(mvpName, segMVP)
--     local tex = faceSegMaterial:getTex(texName)
--     if tex then
--         tex:storage(faceSeg.image)
--     end
-- end

-- function global:FaceSegCompUpdate(idx, result)
--     local faceSeg = result:getFaceFaceMask(idx)
--     local faceSegMaterial = self.MeshRenders[idx].material
--     -- Amaz.LOGI('yyb1',idx)

--     if faceSeg then
--         -- Amaz.LOGI('yyb123',idx)
--         self:FaceSegMaterialUpdate(faceSeg, self.faceMaskMVPUniform, self.faceMaskTextureUniform, faceSegMaterial)
--         faceSegMaterial:setFloat(self.faceMaskDetectedUniform, 1)
--     else
--         faceSegMaterial:setFloat(self.faceMaskDetectedUniform, 0)
--     end

-- end
function global:onUpdate(sys, deltaTime)

    local total_mesh = 0
    for i = 0, maxFaceNum - 1 do
        local meshRender = self.MeshRenders[i]
        if meshRender then
            total_mesh = total_mesh + 1
            meshRender.enabled = false
        else
            printe("MeshRender is nil", i)
        end
    end

    -- printe("=====totalMesh", total_mesh)

    -- if self.initState then
    --     for i = 0, #self.MeshRenders do
    --         local faceSegMaterial = self.MeshRenders[i].material
    --         local tex = faceSegMaterial:getTex(self.faceMaskTextureUniform)
    --         if tex == nil then
    --             tex = Amaz.Texture2D()
    --             tex.filterMin = Amaz.FilterMode.LINEAR
    --             tex.filterMag = Amaz.FilterMode.LINEAR
    --             faceSegMaterial:setTex(self.faceMaskTextureUniform, tex)
    --     -- Amaz.LOGI('yyb123',tostring(i))

    --         end
    --     end
    --     self.initState = false
    -- end

    -- self:updateFaceInfoBySize()

    local result = Amaz.Algorithm.getAEAlgorithmResult()
    local faceCount = result:getFaceCount()
    local freidCount = result:getFreidInfoCount()
    local nhIndex = 0
    for i = 0, faceCount - 1 do
        -- 1. convert faceid to freid and get intensity
        local faceInfo = result:getFaceBaseInfo(i)
        local faceId = faceInfo.ID
        local trackId = -1
        for j = 0, freidCount - 1 do
            local freidInfo = result:getFreidInfo(j)
            if faceId == freidInfo.faceid then
                trackId = freidInfo.trackid
                break
            end
        end
        local intensity = 0
        local adjustMap = self.faceAdjustMaps[trackId]
        if adjustMap == nil then
            adjustMap = self.faceAdjustMaps[-1]
        end
        if adjustMap ~= nil then
            intensity = adjustMap:get(FACE_ADJUST_INTENSITY)
        end
        
        if intensity > EPSC then
            local nodeInfo = result:getNHImageInfo(sys.scene.name, resNodeName, nhIndex)
            local tfmInfo = result:getNHImageTfmInfo(sys.scene.name, tfmNodeName, nhIndex)
            nhIndex = nhIndex + 1
            
            if nodeInfo then
                local meshRender = self.MeshRenders[i]
                meshRender.enabled = true
                local material = meshRender.material
                material:setMat4("mvpMat", tfmInfo.mvp)
                material:getTex(ganTextureUniform):storage(nodeInfo.image)
                -- showMatrix("mvp"..i..":", tfmInfo.mvp)
                material:setFloat("u_h", intensity)
                -- self:FaceSegCompUpdate(i, result)
            end
        end
    end
end

-- function global:onLateUpdate(sys, deltaTime)
--     -- update face algo params
--     local result = Amaz.Algorithm.getAEAlgorithmResult()
--     local faceAlgoParams = Amaz.Vector()
--     for i = 1, maxDisplayNum do
--         local faceInfo = self.faceInfoBySize[i]
--         local id = faceInfo.id
--         local index = faceInfo.index
--         if id ~= -1 then
--             local baseInfo = result:getFaceBaseInfo(index)
--             local algoMap = Amaz.Map()
--             algoMap:set(FACE_ID, id)
--             algoMap:set(FACE_INDEX, index)
--             algoMap:set(FACE_DIRECT, self:getFaceAngle(baseInfo))
--             -- algoMap:set(FACE_BBOX, self:getFaceBBox(baseInfo.rect, self.makeupRenderer.mesh, index * 248)) -- TODO: makeupRenderer not configured in smooth_skin
--             algoMap:set(FACE_BBOX, self:rectToFloatVector(baseInfo.rect))
--             faceAlgoParams:pushBack(algoMap)
--         end
--     end
--     self.scriptProps:set(FACE_INFO, faceAlgoParams)
--     self.scriptProps:set(FACE_COUNT_EXCEED_MAX, self.faceCountExceedMax)
-- end

function global:onEvent(sys, event)
    if event.type == Amaz.AppEventType.SetEffectIntensity then
        self:handleIntensityEvent(event)
    end
end

function global:handleIntensityEvent(event)
    if event.args:get(0) == FACE_ADJUST then
        self.faceAdjustMaps = {}
        local inputVector = event.args:get(1)
        local inputSize = inputVector:size()
        for i = 0, inputSize - 1 do
            local inputMap = inputVector:get(i)
            local inputId = inputMap:get(FACE_ID)
            self.faceAdjustMaps[inputId] = inputMap
        end
    end
end

-- function global:rectToFloatVector(rect)
--     local vector = Amaz.FloatVector()
--     vector:pushBack(rect.x * 2 - 1) -- left
--     vector:pushBack((rect.y + rect.height) * 2 - 1) -- top
--     vector:pushBack((rect.x + rect.width) * 2 - 1) -- right
--     vector:pushBack(rect.y * 2 - 1) -- bottom
--     return vector
-- end

-- function global:updateFaceInfoBySize()
--     self.faceInfoBySize = {}
--     self.faceCountExceedMax = false

--     local result = Amaz.Algorithm.getAEAlgorithmResult()
--     local faceCount = result:getFaceCount()
--     local freidCount = result:getFreidInfoCount()
--     if freidCount > maxDisplayNum then
--         self.faceCountExceedMax = true
--     end
--     for i = 0, maxFaceNum - 1 do
--         local trackId = -1
--         local faceId = -1
--         local faceSize = 0
--         if i < faceCount then
--             local baseInfo = result:getFaceBaseInfo(i)
--             faceId = baseInfo.ID
--             local faceRect = baseInfo.rect
--             for j = 0, freidCount - 1 do
--                 local freidInfo = result:getFreidInfo(j)
--                 if faceId == freidInfo.faceid then
--                     trackId = freidInfo.trackid
--                 end
--             end
--             faceSize = faceRect.width * faceRect.height
--         end
--         table.insert(self.faceInfoBySize, {
--             index = i,
--             id = trackId,
--             faceid = faceId,
--             size = faceSize
--         })
--     end
--     table.sort(self.faceInfoBySize, function(a, b)
--         return a.size > b.size
--     end)
-- end

-- function global:getFaceAngle(info)
--     local vector = Amaz.FloatVector()
--     vector:pushBack(info.yaw)
--     vector:pushBack(info.pitch)
--     vector:pushBack(info.roll)
--     return vector
-- end

------------------------------------------------------------------------------------------------
-- bm functions --
------------------------------------------------------------------------------------------------

-- function global:init_func__main(sys)
--     if (not self:init_func__variables(sys)) then
--         return false
--     end
--     local l = { -- init logging use print()
--     {self.init_func__register_lua_path, {}}, {self.init_func__ie_console, {}}, -- init alias
--     {self.init_func__alias, {}}, -- entities
--     {self.init_func__entities, {
--         -- dynamic
--         slider_h = "slider_h",
--         slider_s_factor = "slider_s_factor",
--         et = "Entity",
--         sdf_h = "sdf_h",
--         sdf_s_factor = "sdf_s_factor"
--     }}, -- components
--     {self.init_func__components, {
--         slider_h = {"IFUISlider"},
--         slider_s_factor = {"IFUISlider"},
--         et = {"MeshRenderer"},
--         sdf_h = {"SDFText"},
--         sdf_s_factor = {"SDFText"}
--     }}}
--     for i = 1, #l do
--         if (not l[i][1](self, l[i][2])) then
--             return false
--         end
--     end
--     return true
-- end

-- function global:init_func__entities(itable)
--     for k, v in pairs(itable) do
--         self[k] = {}
--         self[k][self.bm_alias["Entity"]] = self.sys.scene:findEntityBy(v)
--         if (self[k][self.bm_alias["Entity"]] == nil) then
--             self:print('[%s] error: entity "%s" init failed', "init_func__entities", v)
--             return false
--         end
--     end
--     return true
-- end

-- function global:init_func__components(itable)
--     for k, v in pairs(itable) do
--         if (self[k] == nil) then
--             self:print("[%s] error: self.%s's %s init failed", "init_func__components", k, v)
--             return false
--         end
--         for i = 1, #v do
--             if (self.bm_alias[v[i]] == nil) then
--                 self.bm_alias[v[i]] = v[i]
--             end
--             self[k][self.bm_alias[v[i]]] = self[k][self.bm_alias["Entity"]]:getComponent(v[i])
--             if (self[k][self.bm_alias[v[i]]] == nil) then
--                 self:print("[%s] error: self.%s's %s init failed", "init_func__components", k, v[i])
--                 return false
--             end
--         end
--     end
--     return true
-- end

-- function global:init_func__alias()
--     self.bm_alias = {
--         Entity = "e",
--         MeshRenderer = "mr",
--         Camera = "cam",
--         Transform = "trans",
--         TableComponent = "tcomp",
--         SDFText = "sdf",
--         IFUISlider = "ifslider"
--     }
--     return true
-- end

-- function global:init_func__variables(sys)
--     self.sys = sys
--     return true
-- end

-- function global:init_func__register_lua_path()
--     local tp = self.sys.scene.assetMgr.rootDir .. "lua/?.lua"
--     if not string.find(package.path, tp) then
--         package.path = package.path .. ";" .. tp
--     end
--     return true
-- end

-- function global:init_func__ie_console()
--     self.bm_logger = require("ie_console")
--     return true
-- end

-- function global:print(log_text, ...)
--     self.bm_logger.log(log_text, ...)
-- end

exports.global = global
return exports
