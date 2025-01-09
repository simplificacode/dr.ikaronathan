local Utils = require("common/Utils")
local Helper = require("info_sticker/Helper")

local ALPHA_ANIM = {0, 0.4, 0, 1, {0.35, 0.35, 0.65, 0.65}}
local SCALE_ANIM = {0, 1.0, 10, 1, {0.43, 0.09, 0.44, 0.96}}

local function interpolate (anim, x)
    x = Utils.step(anim[1], anim[2], x)
    local p = anim[5]
    local y = Utils.bezier4x2y(0, p[1], p[3], 1, 0, p[2], p[3], 1, x)
    return Utils.mix(anim[3], anim[4], y)
end


local Main = {}
Main.__index = Main
function Main.new ()
    return setmetatable({}, Main)
end



function Main:onCreate (env)
    env.splitByChar = Helper.splitByChar
    env.splitByWord = Helper.splitByWord
    env.splitByLine = Helper.splitByLine
    env.splitByNone = Helper.splitByNone
    env.split = env.splitByChar

    ---#ifdef DEV
--//    env.rootTextOld.str = "First Line Line Line Line\nSecond Line"
--//    env.duration = 10
--//    env.split = env.splitByWord
    ---#endif
end

function Main:onShow (env)
    self.frags = nil
end

function Main:onUpdate (env, dirty, curTime)
    local text = env.rootTextOld
    if dirty then
        text:forceTypeSetting()
        self.frags = env.split(text.chars)
        for _, frag in ipairs(self.frags) do
            local X0 = 999999
            local X1 = -999999
            local Y0 = 999999
            local Y1 = -999999
            for _, char in ipairs(frag) do
                local x = char.initialPosition.x
                local y = char.initialPosition.y
                local hw = char.width * 0.5
                local hh = char.height * 0.5
                X0 = math.min(X0, x - hw)
                X1 = math.max(X1, x + hw)
                Y0 = math.min(Y0, y - hh)
                Y1 = math.max(Y1, y + hh)
            end
            frag.cx = (X0 + X1) * 0.5
            frag.cy = (Y0 + Y1) * 0.5
        end
    end

    if not self.frags then
        return
    end

    local fragCount = #self.frags
    local durationPerFrag = env.duration / fragCount
    local currentFragIndexF = curTime / durationPerFrag
    local currentFragIndexI = math.floor(currentFragIndexF)
    local currentFragProgress = currentFragIndexF - currentFragIndexI
    if currentFragIndexI < 0 then
        currentFragIndexI = 0
        currentFragProgress = 0
    elseif currentFragIndexI >= fragCount then
        currentFragIndexI = fragCount - 1
        currentFragProgress = 1
    end
    Utils.log("progress: [%d] - %.3f > [%d]", currentFragIndexI, currentFragProgress, currentFragIndexI + 1)

    for i = 0, #self.frags - 1 do
        local frag = self.frags[i + 1]
        if i < currentFragIndexI then
            for _, char in ipairs(frag) do
                char.position = char.initialPosition:copy()
                char.scale = Amaz.Vector3f(1, 1, 1)
                char.color = Amaz.Vector4f(1, 1, 1, 1)
            end
        elseif i > currentFragIndexI then
            for _, char in ipairs(frag) do
                char.color = Amaz.Vector4f(1, 1, 1, 0)
                char.scale = Amaz.Vector3f(0, 0, 0)
            end
        else
            local scale = interpolate(SCALE_ANIM, currentFragProgress)
            local alpha = interpolate(ALPHA_ANIM, currentFragProgress)
            Utils.log("scale = %.3f, alpha = %.3f", scale, alpha)
            Utils.log("cx = %.3f, cy = %.3f", frag.cx, frag.cy)
            for _, char in ipairs(frag) do
                local x = char.initialPosition.x
                local y = char.initialPosition.y
                local dx = x - frag.cx
                local dy = y - frag.cy
                x = frag.cx + dx * scale
                y = frag.cy + dy * scale
                --char.position = char.initialPosition:copy()
                char.position = Amaz.Vector3f(x, y, char.initialPosition.z)
                char.scale = Amaz.Vector3f(scale, scale, 1)
                char.color = Amaz.Vector4f(1, 1, 1, alpha)
            end
        end
    end
end

function Main:onHide (env)
    local sdf = env.rootTextOld
    local chars = sdf.chars
    for i = 0, chars:size() - 1 do
        local char = chars:get(i)
        char.position = char.initialPosition
        char.scale = Amaz.Vector3f(1, 1, 1)
        char.color = Amaz.Vector4f(1, 1, 1, 1)
    end
    self.frags = nil
end


return Main