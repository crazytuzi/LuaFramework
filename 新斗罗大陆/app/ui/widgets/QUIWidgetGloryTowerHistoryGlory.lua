-- @Author: xurui
-- @Date:   2016-08-19 10:01:08
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-11-13 17:02:36
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetGloryTowerHistoryGlory = class("QUIWidgetGloryTowerHistoryGlory", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")
local QUIWidgetHeroTitleBox = import(".QUIWidgetHeroTitleBox")
local QUIWidgetFloorIcon = import("..widgets.QUIWidgetFloorIcon")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QUIWidgetGloryTowerHistoryGlory:ctor(options)
	local ccbFile = "ccb/Widget_GloryTower_ryq.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerVisit", callback = handler(self, self._onTriggerVisit)},
    }
	QUIWidgetGloryTowerHistoryGlory.super.ctor(self, ccbFile, callBacks, options)

  	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetGloryTowerHistoryGlory:onEnter()

end

function QUIWidgetGloryTowerHistoryGlory:onExit()

end

function QUIWidgetGloryTowerHistoryGlory:resetAll()
  	for i = 1, 3 do
  		self._ccbOwner["no_effect_"..i]:setVisible(false)
  		self._ccbOwner["effect_"..i]:setVisible(false)
  	end
  	if self._avatar ~= nil then
  		self._avatar:removeFromParent()
  		self._avatar = nil
  	end
  	self._ccbOwner.icon_node:removeAllChildren()
end

function QUIWidgetGloryTowerHistoryGlory:setFighterInfo(fighter, index, historyType)
  	self:resetAll()
  	self._historyType = historyType
	self._ccbOwner["node_chair"..index]:setVisible(true)
	if type(fighter) ~= "table" then
		self._ccbOwner["no_effect_"..index]:setVisible(true)
		self._ccbOwner.node_info:setVisible(false)
		self._ccbOwner.icon_node:setVisible(false)
		return
	end
	self._ccbOwner["effect_"..index]:setVisible(true)
	self._ccbOwner.icon_node:setVisible(true)
	self._ccbOwner.node_info:setVisible(true)
	self._fighter = fighter

	self._ccbOwner.tf_user_name:setString(self._fighter.name or "")
	
	local force = self._fighter.force or 0
    local num,unit = q.convertLargerNumber(force)
    self._ccbOwner.tf_battleforce:setString(num..(unit or ""))
    if historyType == 2 then
		self._ccbOwner.name_rank:setString("排名：")
		self._ccbOwner.tf_rank_value:setString(self._fighter.rank or 1)
	else
		self._ccbOwner.name_rank:setString("获得积分：")
		self._ccbOwner.tf_rank_value:setString(tostring(self._fighter.towerScore))
	end
	self._ccbOwner.tf_rank_value:setPositionX(self._ccbOwner.name_rank:getPositionX() + self._ccbOwner.name_rank:getContentSize().width - 4)
	
	self._ccbOwner.server_name:setString(self._fighter.game_area_name or "")
	self._ccbOwner.btn_visit:setVisible(true)
	self._ccbOwner.btn_visit_2:setVisible(true)

	if self._avatar == nil then
		self._avatar = QUIWidgetHeroInformation.new()
    	self._ccbOwner.avatar:addChild(self._avatar)
	    self._avatar:setBackgroundVisible(false)
		self._avatar:setNameVisible(false)
	end

	local heroInfos = nil
	local subheros = nil
	local sub2heros = nil
	local sub3heros = nil
	if self._fighter.heros ~= nil and #self._fighter.heros > 0 then
		heroInfos = self._fighter.heros
		subheros = self._fighter.subheros
		sub2heros = self._fighter.sub2heros
		sub3heros = self._fighter.sub3heros

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
		        heroInfo = {skinId = fighter.defaultSkinId}
			end
			if actorId ~= nil then
				self._avatar:setAvatarByHeroInfo(heroInfo, actorId, 1.2)
				self._avatar:setStarVisible(false)
			end
		end
	else
		if fighter.defaultActorId and fighter.defaultActorId ~= 0 then
			self._avatar:setAvatarByHeroInfo({skinId = fighter.defaultSkinId}, fighter.defaultActorId, 1.2)
			self._avatar:setStarVisible(false)
			-- self._ccbOwner.btn_visit:setVisible(false)
			-- self._ccbOwner.btn_visit_2:setVisible(false)
		end
	end


	-- set floor icon
	if historyType == 2 then
		self._fighter.title = self._fighter.rank + 600
	end

    local floorNode = QUIWidgetFloorIcon.new({floor = self._fighter.towerFloor or 1, iconType = "tower", isLarge = true})
    self._ccbOwner.icon_node:addChild(floorNode)
    self._ccbOwner.icon_node:setScale(0.6)
    floorNode:setShowName(false)

    self:setUnionName()

    self:showTitle(self._fighter.title, self._fighter.soulTrial)
end 

function QUIWidgetGloryTowerHistoryGlory:setUnionName() 
	if self._fighter == nil then return end
	
	local unionName = self._fighter.consortiaName or ""
	self._ccbOwner.tf_union_name:setString("【"..unionName.."】" or "")
	if unionName == nil or unionName == "" then
		self._ccbOwner.tf_union_name:setString("无宗门")
	end
end

function QUIWidgetGloryTowerHistoryGlory:showTitle(title, soulTrial)
	local titleBox = QUIWidgetHeroTitleBox.new()
	titleBox:setTitleId(title, soulTrial)
	self._ccbOwner.chenghao:removeAllChildren()
	self._ccbOwner.chenghao:addChild(titleBox)
end

function QUIWidgetGloryTowerHistoryGlory:_onTriggerVisit()
    app.sound:playSound("common_small")

    if self._historyType == 2 then
    	app:getClient():topGloryArenaRankUserRequest(self._fighter.userId, function(data)
			local fighter = (data.towerFightersDetail or {})[1] or {}
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogPlayerInfo",
                options = {fighter = fighter, specialTitle1 = "胜利场数：", specialValue1 = fighter.victory, forceTitle = "防守战力：", isPVP = true}}, {isPopCurrentDialog = false})
		end)
    else
    	remote.tower:towerQueryFightRequest(self._fighter.userId, self._fighter.env, nil, function(data)
			local fighter = data.towerFightersDetail[1]
			local towerScore = fighter.towerScore
			local force = 0
			if fighter.heros ~= nil then
				for _, hero in pairs(fighter.heros) do
					force = force + hero.force
				end
			end
			if fighter.subheros ~= nil then
				for _,hero in pairs(fighter.subheros) do
					force = force + hero.force
				end
			end
			if fighter.sub2heros ~= nil then
				for _,hero in pairs(fighter.sub2heros) do
					force = force + hero.force
				end
			end

	  		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogPlayerInfo",
                options = {fighter = fighter, specialTitle1 = "荣誉积分：", specialValue1 = towerScore, forceTitle = "防守战力：", isPVP = true}}, {isPopCurrentDialog = false})
		end)
    end
end

return QUIWidgetGloryTowerHistoryGlory