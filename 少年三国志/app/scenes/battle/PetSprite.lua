require("app.cfg.pet_info")
local PetShadowEntry = require("app.scenes.battle.entry.PetShadowEntry")
local PetRealEntry   = require("app.scenes.battle.entry.PetRealEntry")
local BattleFieldConst = require "app.scenes.battle.BattleFieldConst"

local PetSprite = class("PetSprite", function(...)
	return display.newNode()
end)

function PetSprite:ctor(petBaseId, isHeroPet, battleField)
	self._petBaseId = petBaseId
	self._isHeroPet = isHeroPet
	self._battleField = battleField

	self._canPlayAttack = false
	self._attackFinish  = false
	self._nextAttackType= 0

	-- resources
	local petInfo = pet_info.get(self._petBaseId)
	local petName = petInfo.ready_id
	self._shadowSp = "sp_zc_" .. petName .. "_light"
	self._attackSp = "sp_zhanchong_" .. petName .. "_attack"
	self._contSp   = "sp_zhanchong_" .. petName .. "_cont"

	self._petShadowEntry = PetShadowEntry.new({spId = self._shadowSp}, nil, battleField)
	self._petShadowEntry:retainEntry()
	self._petShadowEntry:setEventHandler(handler(self, self.eventHandler))
	self:addChild(self._petShadowEntry:getObject())

	-- 实体的sp需要根据需要动态创建
	self._petRealEntry = nil

	-- stop update initially
	self:stop()
end

function PetSprite:getBaseID()
	return self._petBaseId
end

function PetSprite:update()
	if not self._stop then
		self._petShadowEntry:updateEntry()
		if self._petRealEntry then
			self._petRealEntry:updateEntry()
		end
	end
end

function PetSprite:start()
	self._stop = false
end

function PetSprite:stop()
	self._stop = true
end

function PetSprite:eventHandler(event, ...)
	if event == "appear_stop" then
		-- 战宠出现动画结束之后，循环播放待机动画
		self:playReady()
	elseif event == "attack_play" then
		-- 普通攻击是在虚影移出的某个时间点播放
		if self._nextAttackType == BattleFieldConst.SKILL_PET_NORMAL then
			self._canPlayAttack = true
			self._nextAttackType = 0
		end
	elseif event == "out_stop" then
		-- 虚影移出动画结束，暂停
		self._petShadowEntry:pause()

		-- 大招是在虚影完全移出之后播放
		if self._nextAttackType == BattleFieldConst.SKILL_PET_ACTIVE then
			self._canPlayAttack = true
			self._nextAttackType = 0
		end
	elseif event == "finish" then
		-- 实体攻击结束
		self._attackFinish = true
		self:removeRealEntry()
	end

	if self._externalHandler then
		self._externalHandler(event, ...)
	end
end

function PetSprite:playAppear(eventHandler)
	self:start()
	self._petShadowEntry:resume()
	self._petShadowEntry:getObject():setVisible(true)
	self._externalHandler = eventHandler
	return self._petShadowEntry:jumpToAppear(false)
end

function PetSprite:playReady(eventHandler)
	self._petShadowEntry:getObject():setVisible(true)
	self._externalHandler = eventHandler
	return self._petShadowEntry:jumpToReady(true)
end

-- @param nextAttackType: 移出之后的攻击类型（普通还是大招）
function PetSprite:playOut(eventHandler, nextAttackType)
	self._nextAttackType = nextAttackType
	self._canPlayAttack = false
	self._externalHandler = eventHandler
	self._petShadowEntry:jumpToOut(false)
	return function() return self._canPlayAttack end
end

function PetSprite:playAttack(eventHandler)
	self._externalHandler = eventHandler
	return self:createRealEntry(self._attackSp)
end

function PetSprite:playCont(eventHandler)
	self._externalHandler = eventHandler

	-- 大招需要以屏幕中间为基准，所以要偏移
	local offsetX = display.cx - self:getPositionX()
	local offsetY = display.cy - self:getPositionY()

	return self:createRealEntry(self._contSp, ccp(offsetX, offsetY))
end

-- 强制停止攻击
function PetSprite:stopAttack()
	self:removeRealEntry()
end

function PetSprite:createRealEntry(_spId, pos)
	self:removeRealEntry()
	self._attackFinish = false

	-- enemy's pet plays the reverse animation
	if not self._isHeroPet then
		local reverse = "battle/pet/" .. _spId .. "_r/" .. _spId .. "_r.json"
		local fullPath = CCFileUtils:sharedFileUtils():fullPathForFilename(reverse)
		if CCFileUtils:sharedFileUtils():isFileExist(fullPath) then
			_spId = _spId .. "_r"
		end
	end

	self._petRealEntry = PetRealEntry.new({spId = _spId}, nil, self._battleField)
	self._petRealEntry:setEventHandler(handler(self, self.eventHandler))
	self._petRealEntry:getObject():setPosition(pos or ccp(0, 0))
	self:addChild(self._petRealEntry:getObject())

	return function() return self._attackFinish end
end

function PetSprite:removeRealEntry()
	if self._petRealEntry then
		self._petRealEntry:getObject():removeFromParent()
		self._petRealEntry:releaseEntry()
		self._petRealEntry = nil
	end
end

function PetSprite:moveToLayer(newLayer)
	self:retain()
	self:removeFromParent()
	newLayer:addChild(self)
	self:release()
end

function PetSprite:destroy()
	self._petShadowEntry:releaseEntry()
end

return PetSprite