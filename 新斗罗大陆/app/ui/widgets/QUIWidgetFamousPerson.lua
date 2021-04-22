-- @Author: xurui
-- @Date:   2016-08-19 10:01:08
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-12-24 14:45:58
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetFamousPerson = class("QUIWidgetFamousPerson", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")
local QUIWidgetHeroTitleBox = import(".QUIWidgetHeroTitleBox")

function QUIWidgetFamousPerson:ctor(options)
	local ccbFile = "ccb/Widget_Rank_mingrentang.ccbi"
	local callBacks = {
        -- {ccbCallbackName = "onTriggerAvatar", callback = handler(self, self._onTriggerAvatar)},
        {ccbCallbackName = "onTriggerVisit", callback = handler(self, self._onTriggerVisit)},
    }
	QUIWidgetFamousPerson.super.ctor(self, ccbFile, callBacks, options)

  	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()

  	self._index = options.index
end

function QUIWidgetFamousPerson:onEnter()
end

function QUIWidgetFamousPerson:onExit()
end

function QUIWidgetFamousPerson:resetAll()
  	for i = 1, 3 do
  		self._ccbOwner["no_effect_"..i]:setVisible(false)
  		self._ccbOwner["effect_"..i]:setVisible(false)
  		self._ccbOwner["node_chair_"..i]:setVisible(false)
  	end
  	self._ccbOwner["no_effect_"..self._index]:setVisible(true)
  	self._ccbOwner["node_chair_"..self._index]:setVisible(true)

  	if self._avatar ~= nil then
  		self._avatar:removeFromParent()
  		self._avatar = nil
  	end
  	self._ccbOwner.node_avatar:removeAllChildren()
  	self._ccbOwner.btn_avatar:setVisible(false)

  	self._ccbOwner.node_info:setVisible(false)
  	self._ccbOwner.btn_visit:setVisible(false)
	self._ccbOwner.btn_visit_big:setVisible(false)
end

function QUIWidgetFamousPerson:setFighterInfo(fighter, index,isCollegeTrain,areaType)
	if type(fighter) ~= "table" then
		if index then
			self._ccbOwner["no_effect_"..index]:setVisible(true)
		end
		self._ccbOwner.node_info:setVisible(false)
		return
	end
	if isCollegeTrain then
		self._ccbOwner.tf_famousPerson_name:setString("竞速积分：")
	end
	self._ccbOwner["effect_"..self._index]:setVisible(true)
	self._ccbOwner.node_info:setVisible(true)
	self._fighter = fighter

	self._ccbOwner.tf_user_name:setString(self._fighter.name or "")
    -- local num,unit = q.convertLargerNumber(self._fighter.force or 0)
    -- self._ccbOwner.tf_battleforce:setString(num..(unit or ""))
    self._ccbOwner.tf_famousPerson_value:setString(self._fighter.celebrityHallInteral or "")
	-- self._ccbOwner.tf_server_name:setString("【"..self._fighter.game_area_name.."】")
	if isCollegeTrain then
		self._ccbOwner.btn_visit:setVisible(false)
		self._ccbOwner.btn_visit_big:setVisible(false)		
		self._ccbOwner.tf_user_name:setPositionX(self._ccbOwner.tf_user_name:getPositionX() - 15)
	else
		self._ccbOwner.btn_visit:setVisible(true)
		self._ccbOwner.btn_visit_big:setVisible(true)
	end
	self._ccbOwner["no_effect_"..self._index]:setVisible(false)

	if self._avatar == nil then
		self._avatar = QUIWidgetHeroInformation.new()
    	self._ccbOwner.node_avatar:addChild(self._avatar)
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
		end
	end

    self:setUnionName(isCollegeTrain,areaType)

    self:showTitle(fighter.title, fighter.soulTrial)
end 

function QUIWidgetFamousPerson:setUnionName(isCollegeTrain,areaType) 
	if self._fighter == nil then return end
	
	local unionName = self._fighter.consortiaName or ""
	if isCollegeTrain then 
		if areaType == 1 then
			unionName = self._fighter.game_area_name or ""
		else
			unionName = self._fighter.consortiaName or ""
		end
	end
	self._ccbOwner.tf_union_name:setString("【"..unionName.."】" or "")
	if unionName == nil or unionName == "" then
		self._ccbOwner.tf_union_name:setString("无宗门")
	end
end

function QUIWidgetFamousPerson:showTitle(title, soulTrial)
	local titleBox = QUIWidgetHeroTitleBox.new()
	titleBox:setTitleId(title, soulTrial)
	self._ccbOwner.chenghao:removeAllChildren()
	self._ccbOwner.chenghao:addChild(titleBox)
end


function QUIWidgetFamousPerson:_onTriggerVisit()
    app.sound:playSound("common_small")
    app:getClient():topRankUserRequest(self._fighter.userId, function(data)
    	local fighter = data.rankingFighter
    	-- QPrintTable(self._fighter)
    	self._fighter.fighter = fighter
 		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogPlayerInfo",
    		options = self._fighter}, {isPopCurrentDialog = false})
	end)
end

function QUIWidgetFamousPerson:_onTriggerAvatar() 
end

return QUIWidgetFamousPerson