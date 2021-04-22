-- @Author: xurui
-- @Date:   2019-12-25 17:54:47
-- @Last Modified by:   xurui
-- @Last Modified time: 2020-01-16 14:59:07
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetTotemChallengeClient = class("QUIWidgetTotemChallengeClient", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")

QUIWidgetTotemChallengeClient.EVENT_CLICK_CHALLENGE = "EVENT_CLICK_CHALLENGE"
QUIWidgetTotemChallengeClient.EVENT_CLICK_VISIT = "EVENT_CLICK_VISIT"

function QUIWidgetTotemChallengeClient:ctor(options)
	local ccbFile = "ccb/Widget_totemChallenge_client.ccbi"
    local callBacks = {
    }
    QUIWidgetTotemChallengeClient.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

end

function QUIWidgetTotemChallengeClient:onEnter()
end

function QUIWidgetTotemChallengeClient:onExit()
end

function QUIWidgetTotemChallengeClient:setInfo(info, index)
	self._info = info
	self._index = index
	self._userInfoDict = remote.totemChallenge:getTotemUserDungeonInfo()

	local scaleY = 1
	self._ccbOwner.node_client:setPositionY(-230)
	self._ccbOwner.sp_right:setScaleY(-scaleY)
	self._ccbOwner.sp_right:setPositionY(-220.8)
	self._ccbOwner.sp_left:setScaleY(scaleY)
	self._ccbOwner.sp_left:setPositionY(-220.8)
	if self._index%2 ~= 0 then
		self._ccbOwner.node_client:setPositionY(-260)
		self._ccbOwner.sp_right:setScaleY(scaleY)
		self._ccbOwner.sp_right:setPositionY(-232)
		self._ccbOwner.sp_left:setScaleY(-scaleY)
		self._ccbOwner.sp_left:setPositionY(-232)
	end

	self._ccbOwner.sp_left:setVisible(self._index ~= 1)
	local rewardConfig = remote.totemChallenge:getDungeonRewardConfigById(self._info.rivalPos)
	if rewardConfig and rewardConfig.chapter_reward then
		self._ccbOwner.sp_right:setVisible(false)
	else
		self._ccbOwner.sp_right:setVisible(true)
	end

	if self._userInfoDict and self._userInfoDict.intoLayer == remote.totemChallenge.HARD_TYPE then
		self._ccbOwner.node_normal_model:setVisible(false)
		self._ccbOwner.node_hard_model:setVisible(true)
	else
		self._ccbOwner.node_normal_model:setVisible(true)
		self._ccbOwner.node_hard_model:setVisible(false)
	end

	self:setFighterInfo()

	self:setDungeonState(self._userInfoDict.totalNum == self._info.rivalPos)
end

function QUIWidgetTotemChallengeClient:setFighterInfo()
	self._ccbOwner.tf_name:setString(self._info.nickname or "")
    local num,unit = q.convertLargerNumber(self._info.force or 0)
	self._ccbOwner.tf_force:setString(num..unit)
	self._ccbOwner.tf_dungeon:setString(string.format("%s-%s", (self._userInfoDict.currentFloor or 1), self._index))

	local actorId = 1001
	if self._info.defaultActorId and self._info.defaultActorId ~= 0 then
		actorId = self._info.defaultActorId
	end
	local heroConfig = db:getCharacterByID(actorId)
	local iconPath = heroConfig.visitingCard
	if self._info.defaultSkinId and self._info.defaultSkinId ~= 0 then
		local skinConfig = db:getHeroSkinConfigByID(self._info.defaultSkinId)
		if skinConfig and skinConfig.skins_visitingCard then
			iconPath = skinConfig.skins_visitingCard
		end
	end
	if iconPath and iconPath ~= self._iconPath then
		self._ccbOwner.node_icon:removeAllChildren()

		self._iconPath = iconPath
		self._heroCard = CCSprite:create(iconPath)
		self._heroCard:setPositionY(-50)
		local vertices = {{-88, -167}, {0, -186}, {88, -167}, {88, 167}, {0, 186}, {-88, 167}, {-88, -167}}
	    local drawNode = CCDrawNode:create()
	    drawNode:drawPolygon(vertices, {})
	    local ccclippingNode = CCClippingNode:create()
	    ccclippingNode:setAlphaThreshold(1)
	    ccclippingNode:setStencil(drawNode)
	    ccclippingNode:addChild(self._heroCard)
	    self._ccbOwner.node_icon:addChild(ccclippingNode)

	    self._lyMask = CCLayerColor:create(ccc4(0, 0, 0, 80), 178, 374)
	    self._lyMask:setPosition(ccp(-89, -137))
	    ccclippingNode:addChild(self._lyMask)
	end
end

function QUIWidgetTotemChallengeClient:setDungeonState(state)
	if state == nil then return end

	self._ccbOwner.node_btn_challenge:setVisible(false)
	self._ccbOwner.sp_done:setVisible(false)
	self._ccbOwner.node_effect_normal:setVisible(false)
	self._ccbOwner.node_effect_hard:setVisible(false)
	self._ccbOwner.btn_click:setVisible(false)
	self._ccbOwner.btn_visit:setVisible(false)
	self._ccbOwner.tf_name:setPositionX(0)
	if self._lyMask then
		self._lyMask:setVisible(true)
	end
	self._isSowInfo = false
	self._canFight = state

	if self._info.isPass then   --已通关
		self._ccbOwner.sp_done:setVisible(true)
	else
		if state then   --当前关卡
			self._isSowInfo = true
			if self._lyMask then
				self._lyMask:setVisible(false)
			end
			self._ccbOwner.node_btn_challenge:setVisible(true)
			self._ccbOwner.node_effect_normal:setVisible(true)
			self._ccbOwner.node_effect_hard:setVisible(true)
			self._ccbOwner.btn_click:setVisible(true)
			self._ccbOwner.btn_visit:setVisible(true)
			self._ccbOwner.tf_name:setPositionX(-13)
		end
	end
end

function QUIWidgetTotemChallengeClient:showPassEffect(callback)
	self._ccbOwner.sp_done:setVisible(false)
	local ccArray = CCArray:create()
	ccArray:addObject(CCDelayTime:create(0.1))
	ccArray:addObject(CCCallFunc:create(function()
		self._ccbOwner.sp_done:setVisible(true)
		self._ccbOwner.sp_done:setScale(2)
	end))
	ccArray:addObject(CCScaleTo:create(0.2, 0.8))
	ccArray:addObject(CCScaleTo:create(0.1, 1))
	ccArray:addObject(CCCallFunc:create(function()
		self:setDungeonState(false)
		if callback then
			callback()
		end
	end))
	self._ccbOwner.sp_done:runAction(CCSequence:create(ccArray))
end

function QUIWidgetTotemChallengeClient:getContentSize()
	return self._ccbOwner.ly_size:getContentSize()
end

function QUIWidgetTotemChallengeClient:getEffectNode()
	return self._ccbOwner.node_effect_normal
end

function QUIWidgetTotemChallengeClient:_onTriggerChallenge(event)
	local callback
	if type(event) == "table" then
		callback = event.callback
	end

	self:dispatchEvent({name = QUIWidgetTotemChallengeClient.EVENT_CLICK_CHALLENGE, info = self._info, index = self._index, callback = callback})
end

function QUIWidgetTotemChallengeClient:_onTriggerVisit()
	if self._isSowInfo then
		self:dispatchEvent({name = QUIWidgetTotemChallengeClient.EVENT_CLICK_VISIT, info = self._info})
	end
end

return QUIWidgetTotemChallengeClient
