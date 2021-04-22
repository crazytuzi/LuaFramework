-- @Author: xurui
-- @Date:   2016-08-29 15:14:05
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-03-19 16:34:15
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetChooseShowHero = class("QUIWidgetChooseShowHero", QUIWidget)

local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetHeroTitleBox = import("..widgets.QUIWidgetHeroTitleBox")

function QUIWidgetChooseShowHero:ctor(options)
	local ccbFile = "ccb/Widget_Rongyao_zhanshi.ccbi"
	local callBacks = {
		--{ccbCallbackName = "onTriggerUse", callback = handler(self, self._onTriggerUse)}
	}
	QUIWidgetChooseShowHero.super.ctor(self, ccbFile, callBacks, options)
	
  	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetChooseShowHero:setHeroInfo(actorId,skinId,isTransform)
	self._actorId = actorId
	local heroInfos = QStaticDatabase:sharedDatabase():getCharacterByID(self._actorId)

	local heros = remote.herosUtil:getHeroByID(self._actorId) or {}

	if self._avatar == nil then
		self._avatar = QUIWidgetHeroInformation.new()
		self._avatar:setPositionY(50)
		self._avatar:setPositionX(0)
		self._ccbOwner.node_hero:addChild(self._avatar)
	end
	self._avatar:setVisible(true)
	-- self._avatar:setAvatarByHeroInfo({skinId = heros.skinId}, self._actorId, 1.1)
	self._avatar:setAvatarByHeroInfo({skinId = skinId}, self._actorId, 1.1)
    self._avatar:setNameVisible(false)
    self._avatar:setStarVisible(false)
    self._avatar:setBackgroundVisible(false)

    --set condition
	self._ccbOwner.tf_condition_content:setString("收集到魂师"..heroInfos.name)

	local nameContentSize = self._ccbOwner.tf_hero_name:getContentSize()
    self._ccbOwner.tf_hero_name:setString(remote.user.nickname or "")
    self._isHave = remote.herosUtil:checkHeroHavePast(self._actorId)
    if self._isHave == false and not isTransform then
    	self._ccbOwner.node_condition:setVisible(true)
	elseif self._actorId == remote.user.defaultActorId then 
    	self._ccbOwner.node_condition:setVisible(false)
    else
    	self._ccbOwner.node_condition:setVisible(false)
    end

    -- set title
    local title = remote.user.title
   	if title ~= nil and title > 0 then
	    if self._title == nil then
			self._title = QUIWidgetHeroTitleBox.new()
		    self._ccbOwner.node_title:addChild(self._title)
		end
	    self._title:setTitleId(title)
	    self._ccbOwner.node_title:setPosition(ccp(-30, 80))
    elseif  self._title ~= nil then
	   	self._title:removeFromParent()
	   	self._title = nil
	end

	-- set bage
	self._ccbOwner.node_bage:removeAllChildren()
    local config = QStaticDatabase:sharedDatabase():getBadgeByCount(remote.user.nightmareDungeonPassCount)
    if config then
    	local badge = CCTextureCache:sharedTextureCache():addImage(config.alphaicon)
        self._ccbOwner.node_bage:addChild(CCSprite:createWithTexture(badge))
       	local offset = nameContentSize.width - self._ccbOwner.tf_hero_name:getContentSize().width
       	self._ccbOwner.node_bage:setPositionX(self._ccbOwner.node_bage:getPositionX() + offset/2)
    end
end 

function QUIWidgetChooseShowHero:getContentSize()
	local size = CCSize(300, 400)
	return size
end

return QUIWidgetChooseShowHero