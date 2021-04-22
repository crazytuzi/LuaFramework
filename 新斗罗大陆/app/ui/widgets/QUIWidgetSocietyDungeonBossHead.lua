--
-- Author: Kumo.Wang
-- Date: Tue May 31 14:50:53 2016
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSocietyDungeonBossHead = class("QUIWidgetSocietyDungeonBossHead", QUIWidget)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

QUIWidgetSocietyDungeonBossHead.EVENT_CLICK = "QUIWIDGETSOCIETYDUNGEONBOSSHEAD_EVENT_CLICK"

function QUIWidgetSocietyDungeonBossHead:ctor(options)
	local ccbFile = "ccb/Widget_Society_BossHead.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClick", callback = handler(self, QUIWidgetSocietyDungeonBossHead._onTriggerClick)},
	}
	QUIWidgetSocietyDungeonBossHead.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._curHp = options.bossHp
	self._chapter = options.chapter
	self._wave = options.wave

	local scoietyWaveConfig = QStaticDatabase.sharedDatabase():getScoietyWave(self._wave, self._chapter)
	self._bossId = scoietyWaveConfig.boss
	self._bossLevel = scoietyWaveConfig.levels
	if scoietyWaveConfig.is_final_boss then
		self._isBoss = true
	end
	self._initTotalHpScaleX = self._ccbOwner.sp_hp:getScaleX()

	-- self._ccbOwner.tf_name = setShadow5(self._ccbOwner.tf_name)
	self._ccbOwner.node_item:removeAllChildren()
	self:_init()
end

function QUIWidgetSocietyDungeonBossHead:onEnter()

end

function QUIWidgetSocietyDungeonBossHead:onExit()

end

function QUIWidgetSocietyDungeonBossHead:getHeight()
	return self._ccbOwner.node_size:getContentSize().height * self._ccbOwner.node_size:getScaleY()
end

function QUIWidgetSocietyDungeonBossHead:getWidth()
	return self._ccbOwner.node_size:getContentSize().width * self._ccbOwner.node_size:getScaleX()
end

function QUIWidgetSocietyDungeonBossHead:getWave()
	return self._wave
end

function QUIWidgetSocietyDungeonBossHead:updateHp( curHp )
	if curHp then self._curHp = curHp end

	if self._curHp == 0 then
		self:_updateHeadState()
	else
		self._ccbOwner.node_boss:setVisible(true)
		self._ccbOwner.node_chest:setVisible(false)

		local totalHp = self:getTotalHp( self._bossId, self._bossLevel )
		local sx = self._curHp / totalHp * self._initTotalHpScaleX
		-- print("[Kumo] 血条 ", self._curHp, totalHp, sx, self._initTotalHpScaleX)
		self._ccbOwner.sp_hp:setScaleX( sx )
	end
end

function QUIWidgetSocietyDungeonBossHead:_updateHeadState()
	self._ccbOwner.node_boss:setVisible(false)
	self._ccbOwner.node_chest:setVisible(true)
	self._openNode:setVisible(false)
	self._closeNode:setVisible(false)
	self._ccbOwner.normal_tips:setVisible(false)
	if remote.union:isReceived( self._wave,  self._chapter) then
		self._openNode:setVisible(true)
		self._ccbOwner.normal_tips:setVisible(false)
		self:_showMyReceived()
	else
		self._closeNode:setVisible(true)
		self._ccbOwner.normal_tips:setVisible(true)
	end
end

function QUIWidgetSocietyDungeonBossHead:getTotalHp( bossId, bossLevel )
	if not self._bossId or not self._bossLevel then return 0 end

	if not bossId then bossId = self._bossId end
	if not bossLevel then bossLevel = self._bossLevel end

	local characterData = QStaticDatabase.sharedDatabase():getCharacterDataByID( bossId, bossLevel )
	local totalHp = characterData.hp_value + characterData.hp_grow * characterData.npc_level

	return totalHp
end

function QUIWidgetSocietyDungeonBossHead:_onTriggerClick()
	-- print("QUIWidgetSocietyDungeonBossHead:_onTriggerClick()")
	self:dispatchEvent({name = QUIWidgetSocietyDungeonBossHead.EVENT_CLICK, wave = self._wave})
end

function QUIWidgetSocietyDungeonBossHead:update( wave )
	print("QUIWidgetSocietyDungeonBossHead:update()", wave, self._wave)
	if wave == self._wave then
		self._ccbOwner.sp_liang:setVisible(true)
		self._ccbOwner.sp_an:setVisible(false)

	else
		self._ccbOwner.sp_liang:setVisible(false)
		self._ccbOwner.sp_an:setVisible(true)
	end
end

function QUIWidgetSocietyDungeonBossHead:_init()
	if self._isBoss then
		self._ccbOwner.node_1:setVisible(false)
		self._ccbOwner.node_2:setVisible(true)
		self._openNode = self._ccbOwner.sp_opened2
		self._closeNode = self._ccbOwner.sp_normal2
	else
		self._ccbOwner.node_1:setVisible(true)
		self._ccbOwner.node_2:setVisible(false)
		self._openNode = self._ccbOwner.sp_opened1
		self._closeNode = self._ccbOwner.sp_normal1
	end
	
	local character = QStaticDatabase.sharedDatabase():getCharacterByID(self._bossId)
	self._ccbOwner.tf_name:setString(character.name)

	self._ccbOwner.node_boss:setVisible(true)
	self._ccbOwner.node_chest:setVisible(false)
	self._ccbOwner.sp_liang:setVisible(false)
	self._ccbOwner.sp_an:setVisible(true)
		
 	local heroHead = QUIWidgetHeroHead.new()
	self._ccbOwner.node_head:addChild(heroHead)
	heroHead:setHero(self._bossId)
	heroHead:setLevel(0)
	-- heroHead:setLevel(self._bossLevel)

	local breakthrough = character.breakthrough_level or 7
	heroHead:setBreakthrough(breakthrough)

	self:updateHp()
end

function QUIWidgetSocietyDungeonBossHead:_showMyReceived()
	local userConsortia = remote.user:getPropForKey("userConsortia")
	local tbl = userConsortia.consortia_boss_reward
	if not tbl or table.nums(tbl) == 0 then return end

	for _, value in pairs(tbl) do
		if value.wave == self._wave and value.chapter == self._chapter then
			self:_showAward(value.reward)
		end
	end
end

function QUIWidgetSocietyDungeonBossHead:_showAward( str )
	if not str or str == "" then return end
	
	self._ccbOwner.node_item:removeAllChildren()

	local s, e = string.find(str, ";")
	local newStr = ""
	if s then
		newStr = string.sub(str, 1, s - 1)
	else
		newStr = str
	end

	s, e = string.find(newStr, "%^")
	if s then
		local item = QUIWidgetItemsBox.new()
    	item:setPromptIsOpen(true)
    	item:setNeedshadow( false )
		self._ccbOwner.node_item:addChild(item)

		local a = string.sub(newStr, 1, s - 1)
		local b = string.sub(newStr, e + 1)
		-- print("[Kumo] QUIWidgetSocietyDungeonBossHead:_showAward() ", a, b)
		local n = tonumber(a)
		if n then
			-- 数字， item
			item:setGoodsInfo(a, ITEM_TYPE.ITEM, tonumber(b))
		else
			-- 字母，resource
			item:setGoodsInfo(nil, a, tonumber(b))
		end

		local index = 0
		local awardList = remote.union:analyseAwards(self._wave, self._chapter)
		-- QPrintTable(awardList)
		for _, value in pairs(awardList) do
			index = index + 1
			-- print(value.itemCount, tonumber(b), index)
			if tonumber(value.itemCount) == tonumber(b) then
				break
			end
		end

		if index < 3 then
			local ccbFile = "ccb/effects/heji_kuang_2.ccbi"
		    local aniPlayer = QUIWidgetAnimationPlayer.new()
		    self._ccbOwner.node_item:addChild(aniPlayer)
		    aniPlayer:playAnimation(ccbFile, nil, nil, false)
		end
	end
end

return QUIWidgetSocietyDungeonBossHead