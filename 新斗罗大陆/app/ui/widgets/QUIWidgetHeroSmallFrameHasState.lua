--
-- Author: wkwang
-- Date: 2015-01-31 10:42:19
--
local QUIWidgetHeroSmallFrame = import("..widgets.QUIWidgetHeroSmallFrame")
local QUIWidgetHeroSmallFrameHasState = class("QUIWidgetHeroSmallFrameHasState", QUIWidgetHeroSmallFrame)

function QUIWidgetHeroSmallFrameHasState:ctor(options)
	QUIWidgetHeroSmallFrameHasState.super.ctor(self, options)
	self._ccbOwner.node_dead:setVisible(false)
	self._ccbOwner.node_junheng_force:setVisible(false)
end





function QUIWidgetHeroSmallFrameHasState:setHero(actorId, selectTable)
	QUIWidgetHeroSmallFrameHasState.super.setHero(self, actorId, selectTable)

	-- self._ccbOwner.node_mp:setPositionY(-90)	
	self:setHeroStateInfo(actorId)
end

function QUIWidgetHeroSmallFrameHasState:setSoulSpirit(actorId, selectTable)
	QUIWidgetHeroSmallFrameHasState.super.setSoulSpirit(self, actorId, selectTable)

	self._ccbOwner.node_hp:setVisible(false)
	self._ccbOwner.node_mp:setVisible(true)	
	-- self._ccbOwner.node_mp:setPositionY(-50)	
	self:setHeroStateInfo(actorId)
end


function QUIWidgetHeroSmallFrameHasState:setHeroByInfoForFormation(info)
	QUIWidgetHeroSmallFrameHasState.super.setHeroByInfoForFormation(self,info)

	self:setHeroStateInfo(info.id)
end


function QUIWidgetHeroSmallFrameHasState:setSoulSpiritByInfoForFormation(info)
	QUIWidgetHeroSmallFrameHasState.super.setSoulSpiritByInfoForFormation(self,info)

	self._ccbOwner.node_hp:setVisible(false)
	self._ccbOwner.node_mp:setVisible(true)	
	-- self._ccbOwner.node_mp:setPositionY(-50)	
	self:setHeroStateInfo(info.id)


end


function QUIWidgetHeroSmallFrameHasState:setHeroStateInfo(actorId)
	local hp = 0
	local mp = 0
	local maxHp = 0
	local maxMp = 1000
	local heroInfo = nil

	if self._heroModel then
		maxHp = self._heroModel:getMaxHp()
		maxMp = self._heroModel:getRageTotal()
	end
	if self._info ~= nil then
		maxHp = self._info.arrangement:getMaxHp(maxHp)
		heroInfo = self._info.arrangement:getHeroInfoById(actorId)
	end

	self._maxHp = maxHp
	if heroInfo == nil then
		hp = self._maxHp
		-- 太阳井魂师入场时有初始怒气值
		local rage_config = db:getCharacterRageByCharacterID(actorId)
		if rage_config and rage_config.enter_rage then
			local dungeon_rage_config = db:getDungeonRageOffenceByDungeonID("sunwell")
			local enter_coefficient = (dungeon_rage_config and dungeon_rage_config.enter_coefficient) and dungeon_rage_config.enter_coefficient or 1
			mp = rage_config.enter_rage * enter_coefficient
		else
			mp = 0
		end
		-- 盗贼初始连击点数满
		local character_config = db:getCharacterByID(actorId)
		if character_config.combo_points_auto then
			mp = 1000
		end
	else
		hp = heroInfo.hp or heroInfo.currHp
		if heroInfo.mp or heroInfo.currMp then
			mp = heroInfo.mp or heroInfo.currMp
		else
			-- 太阳井魂师入场时有初始怒气值
			local rage_config = db:getCharacterRageByCharacterID(actorId)
			if rage_config and rage_config.enter_rage then
				local dungeon_rage_config = db:getDungeonRageOffenceByDungeonID("sunwell")
				local enter_coefficient = (dungeon_rage_config and dungeon_rage_config.enter_coefficient) and dungeon_rage_config.enter_coefficient or 1
				mp = rage_config.enter_rage * enter_coefficient
			else
				mp = 0
			end
			-- 盗贼初始连击点数满
			local character_config = db:getCharacterByID(actorId)
			if character_config.combo_points_auto then
				mp = 1000
			end
		end
	end

	if hp == nil or hp > self._maxHp then
		hp = self._maxHp
	end

	if self._heroModel then
		self:showDead(hp)
	end

	self._ccbOwner.sp_hp:setScaleX(hp/self._maxHp)
	self._ccbOwner.sp_mp:setScaleX(mp/maxMp) 
end

function QUIWidgetHeroSmallFrameHasState:showDead(hp)
	if hp <= 0 then
		self._ccbOwner.node_dead:setVisible(true)
		self._ccbOwner.node_hp:setVisible(false)
		self._ccbOwner.node_mp:setVisible(false)		
		makeNodeFromNormalToGray(self:getHead())
	else
		self._ccbOwner.node_dead:setVisible(false)
		self._ccbOwner.node_hp:setVisible(true)
		self._ccbOwner.node_mp:setVisible(true)	
		makeNodeFromGrayToNormal(self:getHead())
	end
end

--event callback area--
function QUIWidgetHeroSmallFrameHasState:_onTriggerHeroOverview(tag, menuItem)
	if self._soulSpirit or self._godarmInfo then
		QUIWidgetHeroSmallFrameHasState.super._onTriggerHeroOverview(self, tag, menuItem)
		return
	end
	local heroInfo = nil
	if self._info ~= nil and self._info.arrangement ~= nil and self._actorId ~= nil then
		heroInfo = self._info.arrangement:getHeroInfoById(self._actorId)
	end
	local hp = 0
	if heroInfo == nil then
		hp = self._maxHp
	else
		-- SunWar里面的特别约定，没有hp就是满血。
		hp = heroInfo.hp or heroInfo.currHp or self._maxHp
	end
	if hp > 0 then
		QUIWidgetHeroSmallFrameHasState.super._onTriggerHeroOverview(self, tag, menuItem)
	end
end

return QUIWidgetHeroSmallFrameHasState