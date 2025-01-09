local graphName = '76D57C3E-2613-4F50-9D36-jbIbldBdCc5mbKbIc5cld3bEcmcznts-noskin'
local exports = exports or {}
local BachAlgorithm = BachAlgorithm or {}
local Amaz = Amaz or {}
BachAlgorithm.__index = BachAlgorithm
local entityName = "BachAlgorithm"

function BachAlgorithm.new(construct, ...)
    local self = setmetatable({}, BachAlgorithm)
    self.comps = {}
    self.compsdirty = true
    self.intensity = 0.0
    return self
end

function BachAlgorithm:constructor()
    
end

function BachAlgorithm:onComponentAdded(sys, comp)
    if comp:isInstanceOf("MeshRenderer") and comp.entity.name == entityName then
        self.MeshRenderer = comp
    end
end

function BachAlgorithm:onComponentRemoved(sys, comp)
    if comp:isInstanceOf("MeshRenderer") and comp.entity.name == entityName then
        self.MeshRenderer = nil
    end
end

function BachAlgorithm:onStart(sys)
    if self.MeshRenderer then
        self.MeshRenderer.mesh.clearAfterUpload = false
    end
end

function BachAlgorithm:onUpdate(sys, deltaTime)
    local material = self.MeshRenderer.material
    local intensity = self.intensity

    -- srcTexture
    local srcTexture = sys.scene:getInputTexture(Amaz.BuiltInTextureType.INPUT0)
    material:setTex("srcTexture", srcTexture)

    -- resultTexture
    local resultTexture = srcTexture
    local result = Amaz.Algorithm.getAEAlgorithmResult()
    local extraInfo = result:getLensGeneralInfo(graphName, 'vhdr_0', 0)
    local errorCode = extraInfo:get("errorCode")
    if errorCode and errorCode == 1 then
        -- 1 means no error 
        local info = result:getAlgorithmInfo(graphName, 'vhdr_0', 'general_lens', 0)
        if info then
            resultTexture = info.texture
        end
    else
        -- error handle
        Amaz.LOGE("VhdrLuaError", "errorCode:"..tostring(errorCode))
        intensity = 0
    end
    material:setTex("resultTexture", resultTexture)

    -- output texture
    material:setFloat("intensity", intensity)

    self.MeshRenderer.enabled = true
end

function BachAlgorithm:onEvent(comp, event)
    if "effects_adjust_intensity" == event.args:get(0) then
        local intensity = event.args:get(1)
        self.intensity = intensity
        -- Amaz.LOGE("wenjie.123", "onEvent"..tostring(self.intensity))
    end
end

exports.BachAlgorithm = BachAlgorithm
return exports
