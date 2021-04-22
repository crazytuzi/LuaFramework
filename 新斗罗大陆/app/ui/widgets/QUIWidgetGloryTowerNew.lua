--
-- Author: Your Name
-- Date: 2015-12-30 12:08:37
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetGloryTowerNew = class("QUIWidgetGloryTowerNew", QUIWidget)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")
local QUIViewController = import("..QUIViewController")
local QActorProp = import("...models.QActorProp")
local QUIWidgetHeroTitleBox = import("..widgets.QUIWidgetHeroTitleBox")
local QUIWidgetFloorIcon = import("..widgets.QUIWidgetFloorIcon")

QUIWidgetGloryTowerNew.GLORY_TOWER_EVENT_CLICK = "GLORY_TOWER_EVENT_CLICK"

function QUIWidgetGloryTowerNew:ctor(options)
	local ccbFile = "ccb/Widget_GloryTower_New.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerVisit", callback = handler(self, self._onTriggerVisit)},
        {ccbCallbackName = "onTriggerFighter", callback = handler(self, self._onTriggerFighter)},
        {ccbCallbackName = "onTriggerFastFighter", callback = handler(self, self._onTriggerFastFighter)},
    }
	QUIWidgetGloryTowerNew.super.ctor(self, ccbFile, callBacks, options)

  	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._avatar = QUIWidgetHeroInformation.new()
    self._ccbOwner.avatar:addChild(self._avatar)
	self._avatar:setStarVisible(false)
    self._avatar:setBackgroundVisible(false)
	self._avatar:setNameVisible(false)

	self:_init()
end

function QUIWidgetGloryTowerNew:_init()
	if app.unlock:getUnlockGloryTowerQuickFight() then
		self._ccbOwner.btn_fastFighter:setVisible(true)
	else
		self._ccbOwner.btn_fastFighter:setVisible(false)
	end
end

function QUIWidgetGloryTowerNew:setFighters(fighter, index, selfLevel)
	self._fighter = fighter
	self._towerLevel = selfLevel

	self._ccbOwner.tf_user_name:setString(self._fighter.name or "")
	local force = self._fighter.force or 0
    local num,unit = q.convertLargerNumber(force or 0)
    self._ccbOwner.tf_battleforce:setString(num..(unit or ""))
    local config = QStaticDatabase:sharedDatabase():getGloryTower(self._towerLevel or 0)
	self._ccbOwner.name_rank:setString("获得积分：")
	local offsetScore = math.floor((self._fighter.topnForce or 0)/100000)
	offsetScore = offsetScore > 100 and 100 or offsetScore
	self._ccbOwner.tf_rank:setString(config["win_score_factor_"..index] + offsetScore or 0)
	self._ccbOwner.server_name:setString(self._fighter.game_area_name or "")

	self._ccbOwner.icon_node:removeAllChildren()
	self._ccbOwner.icon_node:setScale(0.6)
	local floorNode = QUIWidgetFloorIcon.new({floor = self._fighter.towerFloor or 1, iconType = "tower", isLarge = true})
    self._ccbOwner.icon_node:addChild(floorNode)
    floorNode:setShowName(false)

	local heroInfos = nil
	local subheros = nil
	local sub2heros = nil
	local sub3heros = nil
	if fighter.heros ~= nil and #fighter.heros > 0 then
		heroInfos = fighter.heros
		subheros = fighter.subheros
		sub2heros = fighter.sub2heros
		sub3heros = fighter.sub3heros

		local maxForce = 0
		local maxHero = nil

		local findMaxHero = function(heroInfo)
			for _,value in ipairs(heroInfo) do
				local force = value.force or 0
				if force > maxForce then
					maxForce = force
					maxHero = value
				end
			end
		end

		if heroInfos ~= nil then 
			findMaxHero(heroInfos)
			if subheros ~= nil then
				findMaxHero(subheros)
			end
			if sub2heros ~= nil then
				findMaxHero(sub2heros)
			end
			if sub3heros ~= nil then
				findMaxHero(sub3heros)
			end
			local actorId =  maxHero.actorId
			local heroInfo = maxHero
			if fighter.defaultActorId and fighter.defaultActorId ~= 0 then
				actorId = fighter.defaultActorId
				heroInfo = remote.herosUtil:getSpecifiedHeroById(fighter, actorId)
			end
			if q.isEmpty(heroInfo) then
				heroInfo = {skinId = fighter.defaultSkinId or 0}
			end
			local showHeroInfo = clone(heroInfo)
			showHeroInfo.skinId = fighter.defaultSkinId or 0
			
			if actorId ~= nil then
				self._avatar:setAvatarByHeroInfo(showHeroInfo, actorId, 1.2)
				self._avatar:setStarVisible(false)
			end
		end
	end

	self:setUnionName()

    self:showTitle(fighter.title, fighter.soulTrial)
	
	--xurui:检查扫荡功能解锁提示
	self._ccbOwner.node_reduce_effect:setVisible(app.tip:checkReduceUnlokState("towerAutoBattle"))
end

function QUIWidgetGloryTowerNew:setUnionName() 
	if self._fighter == nil then return end
	local unionName = self._fighter.consortiaName or ""

	self._ccbOwner.tf_union_name:setString("【"..unionName.."】" or "")
	if unionName == nil or unionName == "" then
		self._ccbOwner.tf_union_name:setString("无宗门")
	end
end

function QUIWidgetGloryTowerNew:showTitle(title, soulTrial)
	local titleBox = QUIWidgetHeroTitleBox.new()
	titleBox:setTitleId(title, soulTrial)
	self._ccbOwner.chenghao:removeAllChildren()
	self._ccbOwner.chenghao:addChild(titleBox)
end

function QUIWidgetGloryTowerNew:_onTriggerVisit()
    app.sound:playSound("common_small")
	-- self._fighter.text = "胜利场数："
	-- app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogGloryFigterInfo",
	-- 	options = {info = self._fighter, selfLevel = self._towerLevel, isLong = true}}, {isPopCurrentDialog = false})

	local baseNum = QStaticDatabase:sharedDatabase():getTeamConfigByTeamLevel(remote.user.level).tower_money or 1
    local dropNum = QStaticDatabase:sharedDatabase():getGloryTower(self._towerLevel or 1).tower_money_factor or 0
    local count = baseNum * dropNum
    local typeName = "towerMoney"
    local award = { { typeName = typeName, count = count } }
    -- QPrintTable(self._fighter)
	-- app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogPlayerInfo",
 --        options = {fighter = self._fighter, specialTitle1 = "胜利场数：", specialValue1 = self._fighter.victory, awardTitle2 = "胜利奖励：", awardValue2 = award, forceTitle = "防守战力：", isPVP = true}}, {isPopCurrentDialog = false})

	remote.tower:towerQueryFightRequest(self._fighter.userId, self._fighter.env, self._fighter.actorIds, function(data)
		local fighter = data.towerFightersDetail[1] or {}
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogPlayerInfo",
            options = {fighter = fighter, specialTitle1 = "胜利场数：", specialValue1 = fighter.victory, awardTitle2 = "胜利奖励：", awardValue2 = award, forceTitle = "防守战力：", isPVP = true}}, {isPopCurrentDialog = false})
	end)	
end

function QUIWidgetGloryTowerNew:_onTriggerFighter()
	self:dispatchEvent({name = QUIWidgetGloryTowerNew.GLORY_TOWER_EVENT_CLICK, fighter = self._fighter, isQuickFight = false})
end

function QUIWidgetGloryTowerNew:_onTriggerFastFighter()
	--xurui:设置扫荡功能解锁提示
	if app.tip:checkReduceUnlokState("towerAutoBattle") then
		app.tip:setReduceUnlockState("towerAutoBattle", 2)
		self._ccbOwner.node_reduce_effect:setVisible(false)
	end

	self:dispatchEvent({name = QUIWidgetGloryTowerNew.GLORY_TOWER_EVENT_CLICK, fighter = self._fighter, isQuickFight = true})
end

return QUIWidgetGloryTowerNew