-- fca.lua

local app = {}

local parser = require 'lib.fca.parser'

---------------------------------
-- class FcaInfo
-- ------------------------------

local class = { mt = {} }
app.FcaInfo = class
class.mt.__index = class

local proto = nil
local function FcaSetProto(protoImp)
	proto = protoImp
end
local cache = {}
local function FcaInfoGet(name, cat)
	if cache[name] then return cache[name] end
	local fileutil = CCFileUtils:sharedFileUtils()
	local cha_path = fileutil:fullPathForFilename(string.format("%s/fca/%s/%s.cha", cat, name, name))
	local txt_path = fileutil:fullPathForFilename(string.format("%s/fca/%s/%s.txt", cat, name, name))
	local pb = nil
	if fileutil:isFileExist(cha_path) then
		local data = CCFileUtils:sharedFileUtils():getFileData(cha_path)
		pb = proto(data)
	elseif fileutil:isFileExist(txt_path) then
		local data = CCFileUtils:sharedFileUtils():getFileData(txt_path)
		pb = parser.anim_txt_parse(name, data)
	end
	local self = {
		name = pb.name,
		elements = pb.elements,
		actions = {},
	}
	setmetatable(self, class.mt)

	for i, action in ipairs(pb.actions or {}) do
		local a = {
			name = action.name,
			anchor = action.anchor,
			fps = action.fps or 24,
			frames = {},
			duration = nil,
		}
		self.actions[a.name] = a

		for j, frame in ipairs(action.frames or {}) do
			local f = {
				events = {},
				elements = {},
			}
			a.frames[j] = f

			for k, event in ipairs(frame.events or {}) do
				local e = {
					t = event.type,
					a = event.arg,
				}
				f.events[k] = e
			end

			for k, element in ipairs(frame.elements or {}) do
				local m = element.matrix
				local e = {
					n = self.elements[element.element_idx],
					a = element.alpha,
					--t = CCAffineTransformMake(m[1], -m[2], -m[3], m[4], m[5], -m[6]),
					m = m,
					z = k,
				}
				f.elements[element.element_idx] = e
			end
		end

		a.duration = #a.frames / a.fps
	end

	cache[name] = self
	return self
end
class.get = FcaInfoGet
app.FcaInfoGet = FcaInfoGet
app.FcaSetProto = FcaSetProto

------------------------------------------------
-- class FcaActor
-- ---------------------------------------------

local class = { mt = {} }
app.FcaActor = class
class.mt.__index = class

local function FcaActorCreate(name, cat)
	local info = app.FcaInfoGet(name, cat)
	local self = {
		name = name,
		cat  = cat,
		info = info,
		node = CCNode:create(),
		root = CCNode:create(),
		container = nil,
		action_name = nil,
		action = nil,
		action_elapsed = 0,
		action_frame_idx = -1,
		components = {},		-- path -> CCSprite
		-- action_names = {},
		action_queue = {},
		animation_scale = 1.0,
		paused = false,
		nodeFront = CCNode:create(),
		nodeBack = CCNode:create(),
		nodeFrontScaleWithActor = CCNode:create(),
		nodeBackScaleWithActor = CCNode:create(),
		attached_nodes = {},
		frameCache = nil,
	}
	setmetatable(self, class.mt)

	-- texture loading
	local fileutil = CCFileUtils:sharedFileUtils()
	local plistPath = string.format("%s/fca/%s/png/%s.plist", self.cat, self.name, self.name)
	plistPath = fileutil:fullPathForFilename(plistPath)
	if fileutil:isFileExist(plistPath) then
		local frameCache = CCSpriteFrameCache:create()
		frameCache:retain()
		frameCache:addSpriteFramesWithFile(plistPath, string.format("%s/fca/%s/png/%s.png", self.cat, self.name, self.name))
		self.frameCache = frameCache
		-- self.container = CCSpriteBatchNode:create(string.gsub(plistPath, ".plist", ".png"))
		self.container = CCNode:create()
	else
		self.container = CCNode:create()
	end

	for i, v in ipairs(info.elements) do
		self:changeComponent(i, v.file)
	end

	-- for k, _ in pairs(info.actions) do
	-- 	table.insert(self.action_names, k)
	-- 	self.action_names[k] = k
	-- end

	self.node:addChild(self.nodeFront)
	self.node:addChild(self.root)
	self.node:addChild(self.nodeBack)
	self.root:addChild(self.nodeFrontScaleWithActor)
	self.root:addChild(self.container)
	self.root:addChild(self.nodeBackScaleWithActor)
    self.node:setCascadeColorEnabled(true)
    self.node:setCascadeOpacityEnabled(true)
    self.root:setCascadeColorEnabled(true)
    self.root:setCascadeOpacityEnabled(true)
    self.container:setCascadeColorEnabled(true)
    self.container:setCascadeOpacityEnabled(true)
	if cat == "actor" then
		self:setAction(ANIMATION.STAND, true)
	elseif cat == "effect" then
		self:setAction(EFFECT_ANIMATION)
	end
	self:update(1/24.0001)
	return self
end
app.FcaActorCreate = FcaActorCreate
class.create = FcaActorCreate

local function changeComponent(self, i, file)
	if self.components[i] then
		self.container:removeChild(self.components[i], true)
	end
	local sprite
	if not self.frameCache then
		local path = string.format("%s/fca/%s/png/%s/%s.png", self.cat, self.name, self.name, file)
		sprite = CCSprite:create(path)
	else
		local spriteFrame = self.frameCache:spriteFrameByName(file..".png")
		sprite = CCSprite:createWithSpriteFrame(spriteFrame)
	end
	sprite:setAnchorPoint(ccp(0.0, 0.0))
	sprite:setZOrder(self.info.elements[i].zOrder or 0)
	self.container:addChild(sprite)
	self.components[i] = sprite
end
class.changeComponent = changeComponent

-- "Move", "atk3", "Death", "Idle", "atk2", "Cheer", "ult", "atk4", "WeaponShow", "atk", "Damaged",
local action_alias = {
	-- alias should all be commented, its only for ealy development
    -- [ANIMATION.WALK] = "Move",
    -- [ANIMATION.REVERSEWALK] = "Move",
    -- [ANIMATION.STAND] = "Idle",
    -- [ANIMATION.ATTACK] = "atk",
    -- [ANIMATION.HIT] = "Damaged",
    -- [ANIMATION.SELECTED] = "Cheer",
    -- [ANIMATION.DEAD] = "Death",
    -- [ANIMATION.VICTORY] = "Cheer",
    -- [EFFECT_ANIMATION] = "Start",
    -- ["attack01"] = "atk",
    -- ["attack02"] = "atk2",
    -- ["attack11"] = "ult",
    -- ["attack13"] = "atk3",
    -- ["attack14"] = "atk4",
}

local function setCurrentAction(self, action_name, loop)
	if self.action_name == action_name then
		self.action_loop = loop
		return
	end
	action_name = action_alias[action_name] or action_name
	self.action_name = action_name
	self.action = self.info.actions[action_name]
	self.action_elapsed = 0
	self.action_frame_idx = -1
	self.action_loop = loop
	if self._animationEventHandler then
		self._animationEventHandler({t = 5, a = action_name})
	end
end

local function setAction(self, action_name, loop)
	self.action_queue = {}
	setCurrentAction(self, action_name, loop)
end
class.setAction = setAction

local function appendAction(self, action_name, loop)
	table.insert(self.action_queue, {action_name, loop})
end
class.appendAction = appendAction

local function canPlayAction(self, action_name)
	action_name = action_alias[action_name] or action_name
	return not not self.info.actions[action_name]
end
class.canPlayAction = canPlayAction

local function getActionFrameCount(self, action_name)
	action_name = action_alias[action_name] or action_name
	if action_name == nil or self.info.actions[action_name] == nil then
		return 0
	end
	return #self.info.actions[action_name].frames
end
class.getActionFrameCount = getActionFrameCount

local function getAnimationScale(self)
	return self.animation_scale
end
class.getAnimationScale = getAnimationScale

local function setAnimationScale(self, animationScale)
	self.animation_scale = animationScale
end
class.setAnimationScale = setAnimationScale

local function pauseAction(self)
	self.paused = true
end
class.pauseAction = pauseAction

local function resumeAction(self)
	self.paused = false
end
class.resumeAction = resumeAction

local function stopAction(self)
	self.action = nil
end
class.stopAction = stopAction

local function attachNodeToBone(self, boneName, node, isBackSide, isScaleWithActor)
	if node == nil then
		return
	end
	if boneName == nil then
		local attached_nodes = self.attached_nodes
		table.insert(attached_nodes, {node, -1})
		if isBackSide then
			if isScaleWithActor then
				self.nodeBackScaleWithActor:addChild(node)
			else
				self.nodeBack:addChild(node)
			end
		else
			if isScaleWithActor then
				self.nodeFrontScaleWithActor:addChild(node)
			else
				self.nodeFront:addChild(node)
			end
		end
	else
		local info = self.info
		for i, v in ipairs(info.elements) do
			if string.find(v.file, boneName, 1, true) then
				local sprite = self.components[i]
				if sprite then
					node:setPosition(sprite:getPosition())
					local attached_nodes = self.attached_nodes
					table.insert(attached_nodes, {node, i})
					if isBackSide then
						if isScaleWithActor then
							self.nodeBackScaleWithActor:addChild(node)
						else
							self.nodeBack:addChild(node)
						end
					else
						if isScaleWithActor then
							self.nodeFrontScaleWithActor:addChild(node)
						else
							self.nodeFront:addChild(node)
						end
					end
				end
				break
			end
		end
	end
end
class.attachNodeToBone = attachNodeToBone

local function detachNodeToBone(self, node)
	for _, obj in ipairs(self.attached_nodes) do
		if obj[1] == node then
			node:removeFromParent()
			break
		end
	end
end
class.detachNodeToBone = detachNodeToBone

local zp = {x = 0, y = 0}
local function getBonePosition(self, boneName)
	if boneName == nil then
		return zp
	end
	for i, v in ipairs(self.info.elements) do
		if string.find(v.file, boneName, 1, true) then
			local sprite = self.components[i]
			if sprite then
				return {x = sprite:getPositionX(), y = sprite:getPositionY()}
			end
			break
		end
	end
	return zp
end
class.getBonePosition = getBonePosition

local function isBoneExist(self, boneName)
	if boneName == nil then
		return false
	end
	for _, v in ipairs(self.info.elements) do
		if string.find(v.file, boneName, 1, true) then
			return true
		end
	end
	return false
end
class.isBoneExist = isBoneExist

local floor = math.floor
local max = math.max
local min = math.min
local setVisible = CCNode.setVisible
local setTransform = CCNode.setTransform
local setOpacity = CCSprite.setOpacity
local abs = math.abs
local sampler = math.sampler

local function updateAnimation(self, dt)
	local action = self.action
	if action then
		dt = min(dt, 1/action.fps)
		local time = self.action_elapsed + dt * self.animation_scale
		self.action_elapsed = time
		local idx = max(1, floor(time * action.fps))
		local percent = abs(time * action.fps - idx)
		local frame = self.action.frames[idx]
		local nextFrame = self.action.frames[idx+1]
		-- if idx ~= self.action_frame_idx then
			-- self.action_frame_idx = idx
			-- idx = math.fmod(idx - 1, #self.action.frames + 1) + 1

			if frame then
				local list = self.components
				local elem_infos = frame.elements
				for i = 1, #list do
					local elem_info = elem_infos[i]
					local sprite = list[i]
					if elem_info then
						sprite:setVisible(true)
						local h = sprite:getContentSize().height
						local w = sprite:getContentSize().width
						local m = elem_info.m
						local a, b, c, d, x, y = m[1], m[2], m[3], m[4], m[5], m[6]
						if nextFrame and nextFrame.elements and nextFrame.elements[i] then
							local next_m = nextFrame.elements[i].m
							a = sampler(m[1], next_m[1] or m[1], percent)
							b = sampler(m[2], next_m[2] or m[2], percent)
							c = sampler(m[3], next_m[3] or m[3], percent)
							d = sampler(m[4], next_m[4] or m[4], percent)
							x = sampler(m[5], next_m[5] or m[5], percent)
							y = sampler(m[6], next_m[6] or m[6], percent)
						end
						--[[
						http://www.wolframalpha.com/input/?i=%7B%7B1%2C0%2C0%7D%2C%7B0%2C-1%2C0%7D%2C%7B0%2C0%2C1%7D%7D.%7B%7Ba%2Cc%2Cx%7D%2C%7Bb%2Cd%2Cy%7D%2C%7B0%2C0%2C1%7D%7D.%7B%7B1%2C0%2C0%7D%2C%7B0%2C-1%2Ch%7D%2C%7B0%2C0%2C1%7D%7D.
						]]
						-- local t = CCAffineTransformMake(a, -b, -c, d, c*h+x, -d*h-y)
						local t = CCAffineTransformMake(a, -b, -c, d, (c*h - a*w)/2 + x, (-d*h + b*w)/2 - y)
						sprite:setAdditionalTransform(t)
						sprite:setOpacity(elem_info.a)
						sprite:setZOrder(elem_info.z or 0)
					else
						sprite:setVisible(false)
					end
				end
				-- event dispatching
				if self._animationEventHandler then
					for _, event in ipairs(frame.events) do
						self._animationEventHandler(event)
					end
				end
			end
			if idx > #self.action.frames then
				if self.action_loop then
					self.action_elapsed = 0
					self.action_frame_idx = -1
				else
					if self._animationEventHandler then
						self._animationEventHandler({t = 4, a = self.action_name})
					end
					self.action = nil
					self.action_name = nil
					if #self.action_queue > 0 then
						local obj = self.action_queue[1]
						table.remove(self.action_queue, 1)
						self:setCurrentAction(obj[1], obj[2])
					end
				end
			end
			-- test debug auto next action
			-- if idx == #self.action.frames then
			-- 	local action_name = self.action.name
			-- 	action_name = next(self.info.actions, action_name) or next(self.info.actions)
			-- 	self.action_name = action_name
			-- 	self.action = self.info.actions[action_name]
			-- 	self.action_elapsed = 0
			-- 	self.action_frame_idx = -1
			-- end
		-- end
	end

	for _, obj in ipairs(self.attached_nodes) do
		local node = obj[1]
		local sprite = self.components[obj[2]]
		if node and sprite then
			node:setPosition(sprite:getPosition())
		end
	end
end

local function update(self, dt)
	if self.paused then
		return
	end
	updateAnimation(self, dt)
end
class.update = update
class.updateAnimation = updateAnimation


--[[
	enum EventType {
		ATTACK = 0;
		PLAYSOUND = 1;
		PLAYEFFECT = 2;
		REMOVEEFFECT = 3;
		ANIMATION_END = 4;
		ANIMATION_START = 5;
	}
]]
local function setAnimationEvent(self, handler)
	self._animationEventHandler = handler
end
class.setAnimationEvent = setAnimationEvent

return app