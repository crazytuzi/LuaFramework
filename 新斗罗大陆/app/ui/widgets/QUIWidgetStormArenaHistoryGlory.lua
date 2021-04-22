
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetStormArenaHistoryGlory = class("QUIWidgetStormArenaHistoryGlory", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")
local QUIWidgetHeroTitleBox = import(".QUIWidgetHeroTitleBox")

local QStaticDatabase = import("...controllers.QStaticDatabase")

function QUIWidgetStormArenaHistoryGlory:ctor(options)
	local ccbFile = "ccb/Widget_StormArena_ryq.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerVisit", callback = handler(self, self._onTriggerVisit)},
    }
	QUIWidgetStormArenaHistoryGlory.super.ctor(self, ccbFile, callBacks, options)

  	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()

end

function QUIWidgetStormArenaHistoryGlory:onEnter()

end

function QUIWidgetStormArenaHistoryGlory:onExit()

end

function QUIWidgetStormArenaHistoryGlory:resetAll()
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

function QUIWidgetStormArenaHistoryGlory:setFighterInfo(fighter, index)
  	self:resetAll()
  	self._isAllServersHistory = remote.stormArena.isAllServersHistory
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
	
	local force = self._fighter.teamForce or 0
    local num, unit = q.convertLargerNumber(force)
    self._ccbOwner.tf_battleforce:setString(num..(unit or ""))
	self._ccbOwner.tf_name_score:setString("排名：")
	self._ccbOwner.tf_score:setString(self._fighter.rank or 1)
	self._ccbOwner.tf_score:setPositionX(self._ccbOwner.tf_name_score:getPositionX() + self._ccbOwner.tf_name_score:getContentSize().width - 4)
	
	self._ccbOwner.tf_server_name:setString(self._fighter.env or "")
	self._ccbOwner.btn_visit:setVisible(true)
	self._ccbOwner.btn_visit_2:setVisible(true)

	if self._avatar1 == nil then
		self._avatar1 = QUIWidgetHeroInformation.new()
    	self._ccbOwner.avatar:addChild(self._avatar1)
	    self._avatar1:setPosition(-50, -15)
	    self._avatar1:setBackgroundVisible(false)
		self._avatar1:setNameVisible(false)
	end

	if self._avatar2 == nil then
		self._avatar2 = QUIWidgetHeroInformation.new()
    	self._ccbOwner.avatar:addChild(self._avatar2)
	    self._avatar2:setPosition(50, -15)
	    self._avatar2:setBackgroundVisible(false)
		self._avatar2:setNameVisible(false)
	end

	local heroInfos = nil
	local subheros = nil
	local sub2heros = nil
	if self._fighter.heros ~= nil and #self._fighter.heros > 0 then
		local heroInfo1 = remote.herosUtil:getMaxForceByHeros(self._fighter)
		local heroInfo2 = remote.herosUtil:getMaxForceBySecondTeamHeros(self._fighter)
		if heroInfo1 then
			self._avatar1:setAvatarByHeroInfo(heroInfo1, heroInfo1.actorId, 1)
			self._avatar1:setStarVisible(false)
		end
		if heroInfo2 then
			self._avatar2:setAvatarByHeroInfo(heroInfo2, heroInfo2.actorId, 1)
			self._avatar2:setStarVisible(false)
		end
	else
		if fighter.defaultActorId and fighter.defaultActorId ~= 0 then
			self._avatar1:setAvatarByHeroInfo({skinId = fighter.defaultSkinId}, fighter.defaultActorId, 1)
			self._avatar1:setStarVisible(false)
			self._avatar2:setAvatarByHeroInfo({skinId = fighter.defaultSkinId}, fighter.defaultActorId, 1)
			self._avatar2:setStarVisible(false)
		end
	end

	self:setUnionName()

    self:showTitle(self._fighter.title, self._fighter.soulTrial)
end 

function QUIWidgetStormArenaHistoryGlory:setUnionName() 
	if self._fighter == nil then return end
	
	local unionName = self._fighter.consortiaName or ""
	self._ccbOwner.tf_union_name:setString("【"..unionName.."】" or "")
	if unionName == nil or unionName == "" then
		self._ccbOwner.tf_union_name:setString("无宗门")
	end
end

function QUIWidgetStormArenaHistoryGlory:showTitle(title, soulTrial)
	local titleBox = QUIWidgetHeroTitleBox.new()
	titleBox:setTitleId(title, soulTrial)
	self._ccbOwner.chenghao:removeAllChildren()
	self._ccbOwner.chenghao:addChild(titleBox)
end

function QUIWidgetStormArenaHistoryGlory:_onTriggerVisit()
    app.sound:playSound("common_small")

	remote.stormArena:stormArenaQueryDefenseHerosRequest(self._fighter.userId, function(data)
		local fighterInfo = (data.towerFightersDetail or {})[1] or {}

		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogStromArenaPlayerInfo",
    		options = {fighterInfo = fighterInfo, isPVP = true}}, {isPopCurrentDialog = false})
	end)
end

return QUIWidgetStormArenaHistoryGlory