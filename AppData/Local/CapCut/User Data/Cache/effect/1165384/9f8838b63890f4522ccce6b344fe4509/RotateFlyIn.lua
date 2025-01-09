local exports = exports or {}
local RotateFlyIn = RotateFlyIn or {}

RotateFlyIn.__index = RotateFlyIn
function RotateFlyIn.new(construct, ...)
    local self = setmetatable({}, RotateFlyIn)
    self.duration = 3.0
    self.count = 0
    self.tweens = {}   -- scale
	self.tweens1 = {}  -- position
	self.tweens2 = {}  -- rotate
	self.st = {}
	self.comp = nil
    -- print("New")
    if construct and RotateFlyIn.constructor then RotateFlyIn.constructor(self, ...) end
    return self
end

function RotateFlyIn:constructor()

end

local function shuffle(list) 
	local rdseed = math.randomseed(tostring(os.time()):reverse():sub(1, 6));
	local t = 0;
	for i = 2, #list do
		local j = math.random(i);
		t = list[j];
		list[j] = list[i];
		list[i] = t;
	end
end

local function createList(num, minn, maxx)
	local list = {};
	local base = 1 / (num - 1);
	for i = 1, num do
		table.insert(list, (i-1)*(maxx-minn)*base + minn);
	end
	shuffle(list);
	return list;
end

local function getRowOfText(text)
	if (text == nil) then 
		return 1;
	end

	local ed = text.chars:size() - 1;
	while (ed >= 0 and text.chars:get(ed).rowth == -1) do
		ed = ed - 1;
	end

	if (ed < 0) then 
		return text.chars:size();
	else
		return text.chars:size() - ed + text.chars:get(ed).rowth;
	end
end 

local function checkDirty(self)
	if self.text == nil or self.text.chars:size() == 0 then return end

	if self.tweenDirty then
	
		local screenH = Amaz.BuiltinObject:getOutputTextureHeight();

		local animTrans = self.comp.entity:getComponent("Transform")
		local parentTrans = animTrans.parent
		
		local userS = parentTrans.localScale
		local userR = parentTrans.localOrientation
		local userT = parentTrans.localPosition
	
		local animS = animTrans.localScale
		local animR = animTrans.localOrientation
		local animT = animTrans.localPosition


		self.count = self.text.chars:size()
		self.tweens = {}
		self.tweens1 = {}
		self.tweens2 = {}
		self.st = createList(self.count, 0, 0.6 * self.duration);

		-- for i = 1, #self.st do
		-- 	print("i = "..i.." ,st[i] = "..self.st[i]);
		-- end

		-- local charHeight = self.text.rect.height / (self.text.chars:get(self.count - 1).rowth + 1);
		local charHeight = self.text.rect.height / getRowOfText(self.text);

		for i = 1, self.count do
			local char = self.text.chars:get(i - 1)
			-- local duration = Amaz.Ease.linear(1, 0 , self.duration * 0.33, 1)
			-- print("i="..i.." ,duration="..duration)

			-- local duration = Amaz.Ease.linear(1, 0 , self.duration * 0.33, 1)
			local t = math.random(500, 1000) * 0.001;
			local duration = (self.duration - self.st[i]) * t;
			--print("t = "..t.." ,duration = "..duration);

			local curPos = char.initialPosition
			table.insert(self.tweens, i, self.text.entity.scene.tween:fromTo(char, 
													{["scale"] = Amaz.Vector3f(0, 0, 0)},
													{["scale"] = Amaz.Vector3f(1, 1, 0)},
													duration / 2,
													Amaz.Ease.CubicOut,
													nil,
													0.0,
													nil,
													false
													))

			table.insert(
				self.tweens2, i, 
				self.text.entity.scene.tween:fromTo(
					char, 
					{["rotate"] = Amaz.Vector3f(0, 0, -720)},
					{["rotate"] = Amaz.Vector3f(0, 0, 0)},
					duration,
					Amaz.Ease.CubicOut,
					nil,
					0.0,
					nil,
					false
				)
			)

			--  zhelibuzhijiechar.heightshiyinweiyouxiehuazideheightkenengbingburukanshangqunameai
			--local charHeight = char.height;
			--local charHeight = self.text.rect.height / (self.text.chars:get(self.count - 1).rowth + 1);
			--local charHeight = (self.text.rect.height * screenH) / (2 * self.text.chars:get(self.count - 1).rowth);
			
			local p0 = curPos - Amaz.Vector3f(0, (math.random() + 1.5) * charHeight, 0);

			-- print("Char: "..char.height.." "..charHeight.." "..screenH.." "..self.text.rect.height.." "..self.text.chars:get(self.count - 1).rowth)
			table.insert(
				self.tweens1, i, 
				self.text.entity.scene.tween:fromTo(
					char, 
					{["position"] = p0},
					{["position"] = curPos},
					duration,
					Amaz.Ease.CubicOut,
					nil,
					0.0,
					nil,
					false
				)
			)

			-- local T = (1 + userT.y) / userS.y;
			-- local D = char.height * 0.5;
			-- table.insert(
			-- 	self.tweens1, i, 
			-- 	self.text.entity.scene.tween:fromTo(
			-- 		char, 
			-- 		{["position"] = Amaz.Vector3f(curPos.x, - 0.5 * screenH * T - D, 0)},
			-- 		{["position"] = curPos},
			-- 		duration,
			-- 		Amaz.Ease.CubicInOut,
			-- 		nil,
			-- 		0.0,
			-- 		nil,
			-- 		false
			-- 	)
			-- )
			
			self.tweenDirty = false
		end
	end
end

function RotateFlyIn:onStart(comp) 
	self.comp = comp
	self.text = comp.entity:getComponent('SDFText')
    if self.text == nil then
        local text = comp.entity:getComponent('Text')
        if text ~= nil then
			self.text = comp.entity:addComponent('SDFText')
            self.text:setTextWrapper(text)
        end
    end
	self.count = self.text.chars:size()
	self.tweenDirty = true
	checkDirty(self)
	--Amaz.LOGI("wangyu000.onStart", self.text.str)
end

function RotateFlyIn:onEnter()
	--Amaz.LOGI("wangyu000.onEnter", self.text.str)
	self.count = self.text.chars:size()
	self.tweenDirty = true
	checkDirty(self)
end

function RotateFlyIn:seek(time)
	--Amaz.LOGI("wangyu000.seek %i", self.text.str, self.tweenDirty)
    checkDirty(self)
    for i = 1, self.count do
		-- local start = Amaz.Ease.linear(i / self.count, 0, self.duration * 0.67, 1)
		-- local t = time - start;
		local t = time - self.st[i];
    	self.tweens[i]:set(t);
		self.tweens1[i]:set(t);
		self.tweens2[i]:set(t);
		--Amaz.LOGI("wangyu001.seek, i %d, t %f", i, t)
    end
    local chars = self.text.chars 
    self.text.chars = chars
end

function RotateFlyIn:setDuration(duration)
   self.tweenDirty = true
   self.duration = duration
end

function RotateFlyIn:clear()
	self.tweenDirty = true
    if self.text ~= nil then
		--Amaz.LOGI("wangyu000.clear", self.text.str)
    	local chars = self.text.chars 
        for i = 1, self.count do
            local char = chars:get(i-1)
            char.position = char.initialPosition
			char.color.w = 1.0
			char.rotate = Amaz.Vector3f(0,0,0);
			char.scale = Amaz.Vector3f(1,1,0)
        end
		for key, value in pairs(self.tweens) do
			value:clear()
		end 
		for key, value in pairs(self.tweens1) do
			value:clear()
		end 
		for key, value in pairs(self.tweens2) do
			value:clear()
		end
    	self.text.chars = chars
        self.tweens = {}
		self.tweens1 = {}
		self.tweens2 = {}
		self.st = {}
    end
end

function RotateFlyIn:onLeave()
	self.tweenDirty = true
    if self.text ~= nil then
		--Amaz.LOGI("wangyu000.onLeave", self.text.str)
    	local chars = self.text.chars 
        for i = 1, self.count do
            local char = chars:get(i-1)
            char.position = char.initialPosition
			char.color.w = 1.0
			char.rotate = Amaz.Vector3f(0,0,0);
			char.scale = Amaz.Vector3f(1,1,0)
        end
		for key, value in pairs(self.tweens) do
			value:clear()
		end 
		for key, value in pairs(self.tweens1) do
			value:clear()
		end 
		for key, value in pairs(self.tweens2) do
			value:clear()
		end
    	self.text.chars = chars
        self.tweens = {}
		self.tweens1 = {}
		self.tweens2 = {}
		self.st = {}
    end
end

exports.RotateFlyIn = RotateFlyIn
return exports
