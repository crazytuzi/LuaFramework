--
-- Author: xurui
-- Date: 2016-03-21 14:40:21
--
local QUIWidgetHeroFrame = import("..widgets.QUIWidgetHeroFrame")
local QUIWidgetExchangeHeroFrame = class("QUIWidgetExchangeHeroFrame", QUIWidgetHeroFrame)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetItemsBox = import(".QUIWidgetItemsBox")

function QUIWidgetExchangeHeroFrame:ctor(options)
	QUIWidgetExchangeHeroFrame.super.ctor(self, options)
	self._ccbOwner.node_mount_box:setVisible(false)
	self._ccbOwner.node_artifact_box:setVisible(false)
end

function QUIWidgetExchangeHeroFrame:setHero(actorId)
	self._actorId = actorId
	self._hero = remote.herosUtil:getHeroByID(self._actorId)

	-- 设置头像显示
	self._heroHead:setHero(actorId, level)
	self._heroHead:setStarVisible(true)
	self._heroHead:setStar(self._hero.grade)
	self._heroHead:showSabcWithoutStar()

	local level = 0
	local characher = QStaticDatabase:sharedDatabase():getCharacterByID(self._actorId)
		-- invisible tip icon
	self._ccbOwner.node_tips_hero:setVisible(false)
	-- display fragment
	self:showBattleForce()
	local grade_info = QStaticDatabase:sharedDatabase():getGradeByHeroActorLevel(self._actorId, self._hero.grade + 1)
	local soulGemId = grade_info.soul_gem
	local needGemCount = grade_info.soul_gem_count
	local currentGemCount = remote.items:getItemsNumByID(soulGemId)
	-- can summon the hero
	if currentGemCount >= needGemCount then
		self._ccbOwner.sprite_bar:setScaleX(self._forceBarScaleX)
	else
		self._ccbOwner.sprite_bar:setScaleX(self._forceBarScaleX * (currentGemCount / needGemCount))
	end
	self._ccbOwner.node_hero_force_full:setVisible(false)
	self._ccbOwner.node_hero_force:setVisible(true)
	self._ccbOwner.node_hero_force:setString(tostring(currentGemCount) .. "/" .. tostring(needGemCount))
	self._ccbOwner.node_recruitAnimation:setVisible(false)

    local itemBox = QUIWidgetItemsBox.new()
    itemBox:setGoodsInfo(soulGemId, ITEM_TYPE.ITEM, 0)
    itemBox:hideSabc()
    itemBox:hideTalentIcon()
    itemBox:setScale(0.5)
    itemBox:setPosition(ccp(self._ccbOwner.soul_icon:getPosition()))
    self._ccbOwner.soul_icon:getParent():addChild(itemBox)
    self._ccbOwner.soul_icon:setVisible(false)

	self._heroHead:showSabcWithoutStar()
	self._heroHead:setLevelVisible(false)

	-- Show profession
	local profession = characher.func or "t"
	self:setProfession(profession)

	-- 设置魂师名称
	local name = characher.name
	local nameColor = BREAKTHROUGH_COLOR_LIGHT["white"]

	local breakthroughLevel,color = remote.herosUtil:getBreakThrough(self._hero.breakthrough)
	level = self._hero.level
	--设置进阶
	if color ~= nil then
		nameColor = BREAKTHROUGH_COLOR_LIGHT[color]
	end
	if breakthroughLevel > 0 then
		name = name.." +"..breakthroughLevel
	end
	self._ccbOwner.node_hero_name:setString(name)
	self._ccbOwner.node_hero_name:setColor(nameColor)
end

return QUIWidgetExchangeHeroFrame