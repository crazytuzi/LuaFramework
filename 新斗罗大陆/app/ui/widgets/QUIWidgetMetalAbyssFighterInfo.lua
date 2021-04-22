

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetMetalAbyssFighterInfo = class("QUIWidgetMetalAbyssFighterInfo", QUIWidget)
local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")
local QActorProp = import("...models.QActorProp")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIWidgetHeroTitleBox = import("..widgets.QUIWidgetHeroTitleBox")
local QChatDialog = import("...utils.QChatDialog")

QUIWidgetMetalAbyssFighterInfo.EVENT_BATTLE = "EVENT_METAL_ABYSS_BATTLE"
QUIWidgetMetalAbyssFighterInfo.EVENT_VISIT = "EVENT_METAL_ABYSS_VISIT"

function QUIWidgetMetalAbyssFighterInfo:ctor(options)
	local ccbFile = "ccb/Widget_MetalAbyss_FighterInfo.ccbi"
  	local callBacks = {
      {ccbCallbackName = "onPress", callback = handler(self, self._onPress)},
      {ccbCallbackName = "onTriggerVisit", callback = handler(self, self._onTriggerVisit)},
  }
	QUIWidgetMetalAbyssFighterInfo.super.ctor(self,ccbFile,callBacks,options)
  	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	self._avatar = QUIWidgetHeroInformation.new()
	self._avatar:setBackgroundVisible(false)
	self._avatar:setNameVisible(false)

	self._ccbOwner.node_head:addChild(self._avatar)
	self._normalPos = self._ccbOwner.node_head:getPositionY()
	self._positionY = self._ccbOwner.chenghao:getPositionY()
    q.setButtonEnableShadow(self._ccbOwner.btn_visit)

	self._ccbOwner.tf_user_name:setString("")
	self._ccbOwner.tf_battleforce:setString(0)

	self._words = db:getArenaLangaue()
    self._animationManager = tolua.cast(self._ccbView:getUserObject(), "CCBAnimationManager")
end

function QUIWidgetMetalAbyssFighterInfo:onEnter()
	QUIWidgetMetalAbyssFighterInfo.super.onEnter(self)
end

function QUIWidgetMetalAbyssFighterInfo:onExit()
	QUIWidgetMetalAbyssFighterInfo.super.onExit(self)
	if self.schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self.schedulerHandler)
		self.schedulerHandler = nil
	end
    if self._animationManager ~= nil then
        self._animationManager:disconnectScriptHandler()
    end
end

function QUIWidgetMetalAbyssFighterInfo:setInfo(info,  index,  isManualRefresh)
	self.index = index
	self.info = info
	self.isManualRefresh = isManualRefresh
	self._avatar:setAutoStand(true)
	self._avatar:setAvatarVisible(true)
	self:refreshInfo()
	self:setServerName()
	self:setStar(index)


end

function QUIWidgetMetalAbyssFighterInfo:refreshInfo()
	self._animationManager:stopAnimation()
	self._animationManager:runAnimationsForSequenceNamed("normal")
	self._ccbOwner.node_chair:setVisible(false)
	self._ccbOwner.node_high:setVisible(false)
	self._ccbOwner.node_low:setVisible(false)
	self._ccbOwner.node_self:setVisible(false)
	self._ccbOwner.effect_1:setVisible(false)
	self._ccbOwner.effect_2:setVisible(false)
	self._ccbOwner.effect_3:setVisible(false)
	self._ccbOwner.effect_4:setVisible(false)

	self._ccbOwner.node_client:setVisible(true)

	if self.isManualRefresh == true then
		self._effect = QUIWidgetAnimationPlayer.new()
		self._effect:playAnimation("effects/ChooseHero.ccbi",nil,function ()
			self._effect = nil
		end)
		self._effect:setPositionY(-90)
		self:addChild(self._effect)
	else
		if self._effect ~= nil then
			self._effect:disappear()
			self._effect = nil
		end
	end
	local maxHero = nil
	local maxForce = 0
	local actorId =  self.info.defaultActorId
	if actorId ~= nil then
		self._avatar:setAvatarByHeroInfo({skinId = self.info.defaultSkinId}, actorId, 1.3)
		self._avatar:setStarVisible(false)
	end
	self._ccbOwner.tf_user_name:setString(self.info.name)

	local force = self.info.force or 0
	local num,unit = q.convertLargerNumber(force or 0)
	self._ccbOwner.tf_battleforce:setString(num..(unit or ""))

	if remote.user.userId == self.info.userId then
		self._ccbOwner.node_self:setVisible(true)
		self._ccbOwner.effect_4:setVisible(true)
	else
		self._ccbOwner.node_low:setVisible(true)
	end

	self._ccbOwner.node_head:setPositionY(self._normalPos)
	self:showTitle(self.info.title, self.info.soulTrial)

end


function QUIWidgetMetalAbyssFighterInfo:setServerName() 
	if self.info == nil then return end
	
	local name = self.info.game_area_name or ""
	self._ccbOwner.tf_union_name:setString("【"..name.."】" or "")
	if name == nil or name == "" then
		self._ccbOwner.tf_union_name:setString("无区服信息")
	end
end

function QUIWidgetMetalAbyssFighterInfo:showTitle(title, soulTrial)
	local titleBox = QUIWidgetHeroTitleBox.new()
	titleBox:setTitleId(title, soulTrial)
	self._ccbOwner.chenghao:setVisible(true)

	self._ccbOwner.chenghao:removeAllChildren()
	self._ccbOwner.chenghao:addChild(titleBox)

	local positionY = self._positionY
    if self.isWorship == true then
    	positionY = positionY+30
    end
    self._ccbOwner.chenghao:setPositionY(positionY)
end

function QUIWidgetMetalAbyssFighterInfo:hideBaseInfo(b, callback)
	self._animationManager:connectScriptHandler(function(name)
	    if self._animationManager ~= nil then
	        self._animationManager:disconnectScriptHandler()
	    end
	    if callback ~= nil then
			callback()
		end
    end)
	if b == false then
    	self._animationManager:runAnimationsForSequenceNamed("diappear")
    	self._ccbOwner.effect_4:setScale(1)
    	self._ccbOwner.effect_4:runAction(CCScaleTo:create(0.3, 0, 0))
    else
    	self._animationManager:runAnimationsForSequenceNamed("appear")
    	self._ccbOwner.effect_4:setScale(0)
    	self._ccbOwner.effect_4:runAction(CCScaleTo:create(0.3, 1, 1))
    end
end

function QUIWidgetMetalAbyssFighterInfo:changeBaseInfo(info)
	self._ccbOwner.tf_user_name:setString(info.name)
	local force,unit = q.convertLargerNumber(info.force or 0)
	self._ccbOwner.tf_battleforce:setString(force..(unit or ""))
	self:showTitle(info.title, info.soulTrial)

	local unionName = info.consortiaName or ""
	self._ccbOwner.tf_union_name:setString("【"..unionName.."】" or "")
	if unionName == nil or unionName == "" then
		self._ccbOwner.tf_union_name:setString("无宗门")
	end

	if remote.user.userId == info.userId then
		self._ccbOwner.node_high:setVisible(false)
		self._ccbOwner.node_low:setVisible(false)
		self._ccbOwner.node_self:setVisible(true)
		self._ccbOwner.effect_4:setVisible(true)
	end
end

function QUIWidgetMetalAbyssFighterInfo:removeWord()
	if self._wordWidget ~= nil then
		self._wordWidget:removeFromParent()
		self._wordWidget = nil
	end
end

--设置是否禁言
function QUIWidgetMetalAbyssFighterInfo:setGag(b)
	self._isGag = b
end

function QUIWidgetMetalAbyssFighterInfo:showWord(str)
	if self._isGag == true then return end --禁言状态不准说话
	self:removeWord()
	if self.info == nil then return end
	local word = "啦啦啦！啦啦啦！我是卖报的小行家！"
	if str ~= nil then
		word = str
	elseif self.info.declaration ~= nil and self.info.declaration ~= "" then
		word = self.info.declaration
	elseif self._words ~= nil then
		local maxCount = table.nums(self._words)
		local count = math.random(1, maxCount)
		for _,value in pairs(self._words) do
			if value.id == count then
				word = value.langaue
				break
			end
		end
	end

	if self._wordWidget == nil then
		self._wordWidget = QChatDialog.new()
		self:addChild(self._wordWidget)
	end

	self._wordWidget:setPositionY(70)
	self._wordWidget:setPositionX(20)
	self._wordWidget:setString(word)
	local size = self._wordWidget:getContentSize()
	local pos = self._wordWidget:convertToWorldSpace(ccp(0,0))
	if (pos.x + size.width) > display.width then
		self._wordWidget:setScaleX(-1)
		self._wordWidget:setPositionX(-20)
	else
		self._wordWidget:setScaleX(1)
	end
end


function QUIWidgetMetalAbyssFighterInfo:setStar(num)
	local dis = 30
	local start = -30 + (3 - num) * 15

	for i=1,3 do
		self._ccbOwner["node_star_"..i]:setVisible(i <= num)
		self._ccbOwner["node_star_"..i]:setPositionX(start + (i - 1) *dis)
		self._ccbOwner["star"..i]:setRotation(0)
	end
end

function QUIWidgetMetalAbyssFighterInfo:playFightAction(difficult,worldPos)
	local actionTime = 0.5
	local delay = 0.2
	local scale = 0.2

	self._ccbOwner.chenghao:setVisible(false)
	self._ccbOwner.node_client:setVisible(false)
	self._ccbOwner.node_high:setVisible(false)
	self._ccbOwner.node_low:setVisible(false)

	local endPos = self._ccbOwner.node_star:convertToNodeSpace(worldPos)

	for i=1,difficult do
		local node  = self._ccbOwner["node_star_"..i]
		local spStar  = self._ccbOwner["star"..i]
		local arr2 = CCArray:create()
		arr2:addObject(CCMoveTo:create(actionTime,  endPos))
		arr2:addObject(CCScaleTo:create(actionTime,1))	
		local array = CCArray:create()
		array:addObject(CCScaleTo:create(scale,2))	
		array:addObject(CCDelayTime:create(delay * (i - 1)))
		array:addObject(CCSpawn:create(arr2))
		array:addObject(CCCallFunc:create(function()
			node:setVisible(false)
			spStar:stopAllActions()
			spStar:setRotation(0)
			node:setPosition(ccp(0,0))
	    end))
		node:runAction(CCSequence:create(array))

		local arr = CCArray:create()
		arr:addObject(CCRotateBy:create(0.5, 360))
		spStar:runAction(CCRepeatForever:create(CCSequence:create(arr)))

	end

	if self._avatar then
		self._avatar:getAvatar():getActor():playAnimation(ANIMATION.DEAD, false)
	end

	actionTime = actionTime + scale +(difficult - 1)*delay

	return actionTime
end




function QUIWidgetMetalAbyssFighterInfo:_onTriggerVisit(event)
	self:dispatchEvent({name = QUIWidgetMetalAbyssFighterInfo.EVENT_VISIT, info = self.info, index = self.index})
end

function QUIWidgetMetalAbyssFighterInfo:_onPress()
	self:dispatchEvent({name = QUIWidgetMetalAbyssFighterInfo.EVENT_BATTLE, info = self.info,  widget = self, index = self.index})
end

return QUIWidgetMetalAbyssFighterInfo