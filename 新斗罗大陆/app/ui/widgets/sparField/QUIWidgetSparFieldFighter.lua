local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetSparFieldFighter = class("QUIWidgetSparFieldFighter", QUIWidget)
local QUIWidgetActorDisplay = import("...widgets.actorDisplay.QUIWidgetActorDisplay")
local QUIWidgetAnimationPlayer = import("...widgets.QUIWidgetAnimationPlayer")
local QUIViewController = import("....ui.QUIViewController")
local QStaticDatabase = import("....controllers.QStaticDatabase")
local QChatDialog = import("....utils.QChatDialog")

QUIWidgetSparFieldFighter.EVENT_CLICK = "EVENT_CLICK"

function QUIWidgetSparFieldFighter:ctor(options)
	local ccbFile = "ccb/Widget_sparfield_hero.ccbi"
  	local callBacks = {
      	{ccbCallbackName = "onPress", callback = handler(self, QUIWidgetSparFieldFighter._onPress)},
      	{ccbCallbackName = "onTriggerVisit", callback = handler(self, QUIWidgetSparFieldFighter._onTriggerVisit)},
  	}
	QUIWidgetSparFieldFighter.super.ctor(self,ccbFile,callBacks,options)
  	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self._animationManager = tolua.cast(self._ccbView:getUserObject(), "CCBAnimationManager")
    self._ccbOwner.node_info:setVisible(false)
end

function QUIWidgetSparFieldFighter:onExit()
	QUIWidgetSparFieldFighter.super.onExit(self)
	if self._handler ~= nil then 
		scheduler.unscheduleGlobal(self._handler)
		self._handler = nil
	end
    if self._animationManager ~= nil then
        self._animationManager:disconnectScriptHandler()
    end
end

function QUIWidgetSparFieldFighter:setFightInfo(fightInfo, isAnimation, index)
	self._fightInfo = fightInfo
	self._difficulty = index
	self._ccbOwner.tf_user_name:setString(fightInfo.name or "")
	if fightInfo.consortiaName == nil or fightInfo.consortiaName == "" then
		self._ccbOwner.tf_union_name:setString("无宗门")
	else
		self._ccbOwner.tf_union_name:setString(fightInfo.consortiaName)
	end
	self._ccbOwner.tf_area_name:setString(fightInfo.game_area_name or "")
	local num,unit = q.convertLargerNumber(fightInfo.topnForce)
	self._ccbOwner.tf_battleforce:setString(num..(unit or ""))
	for i=1,3 do
		self._ccbOwner["sp_star"..i]:setVisible(i<=index)
	end
	
	if self._avatar ~= nil then
		self._avatar:removeFromParent()
		self._avatar = nil
	end
	self._avatar = QUIWidgetActorDisplay.new(fightInfo.defaultActorId, {heroInfo = {skinId = fightInfo.defaultSkinId}})
	self._avatar:setScaleX(-1.2)
	self._avatar:setScaleY(1.2)
	self._ccbOwner.node_avatar:addChild(self._avatar)
	if isAnimation then
		self._avatar:setVisible(false)
		self._handler = scheduler.performWithDelayGlobal(function ()
			self:playThunderEffect()
			self._avatar:setVisible(true)
			self._animationManager:runAnimationsForSequenceNamed("appear")
	    	self._ccbOwner.node_info:setVisible(true)
		end, 0.5)
		self:playAppearEffect()
	else
    	self._ccbOwner.node_info:setVisible(true)
	end
end

function QUIWidgetSparFieldFighter:showWord(str)
	if self._isGag == true then return end --禁言状态不准说话
	self:removeWord()
	if self._fightInfo == nil then return end
	local word = "啦啦啦！啦啦啦！我是卖报的小行家！"
	if str ~= nil then
		word = str
	end
	if self._wordWidget == nil then
		self._wordWidget = QChatDialog.new()
		self:addChild(self._wordWidget)
	end
	self._wordWidget:setPositionY(50)
	self._wordWidget:setString(word)
	local size = self._wordWidget:getContentSize()
	local pos = self._wordWidget:convertToWorldSpace(ccp(0,0))
	if (pos.x + size.width) > display.width then
		self._wordWidget:setScaleX(-1)
	else
		self._wordWidget:setScaleX(1)
	end
end

function QUIWidgetSparFieldFighter:removeWord()
	if self._wordWidget ~= nil then
		self._wordWidget:removeFromParent()
		self._wordWidget = nil
	end
end

--播放一道闪电劈下的效果
function QUIWidgetSparFieldFighter:playThunderEffect()
    local thunderPlayer = QUIWidgetAnimationPlayer.new()
    thunderPlayer:playAnimation("ccb/effects/Widget_Black_mounatin_shandian.ccbi")
    thunderPlayer:setScale(1.5)
    thunderPlayer:setPositionY(215)
    self._ccbOwner.node_avatar:addChild(thunderPlayer)
end

function QUIWidgetSparFieldFighter:playAppearEffect()
	local selfAnimationPlayer = QUIWidgetAnimationPlayer.new()
	selfAnimationPlayer:playAnimation("ccb/effects/nightmare_emeng_yidong_fx.ccbi", nil,nil,true)
	self._ccbOwner.node_avatar:addChild(selfAnimationPlayer)
end

--播放消失动画
function QUIWidgetSparFieldFighter:playDisappearEffect()
	if self._avatar ~= nil then
		self._handler = scheduler.performWithDelayGlobal(function ()
			self._avatar:setVisible(false)
		end, 0.1)
	    local firePlayer = QUIWidgetAnimationPlayer.new()
	    firePlayer:playAnimation("ccb/effects/siwang_hy.ccbi")
    	firePlayer:setScale(2)
    	self._ccbOwner.node_avatar:addChild(firePlayer)
    	if self._animationManager ~= nil then
			self._animationManager:runAnimationsForSequenceNamed("disappear")
		end
	end
end

function QUIWidgetSparFieldFighter:_onPress()
	self:dispatchEvent({name = QUIWidgetSparFieldFighter.EVENT_CLICK, fightInfo = self._fightInfo, difficulty = self._difficulty})
end

function QUIWidgetSparFieldFighter:_onTriggerVisit()
	local wave = remote.sparField:getWave()
	local config = QStaticDatabase:sharedDatabase():getSparFieldReward(wave, remote.user.dailyTeamLevel)
	local starConfig = QStaticDatabase:sharedDatabase():getSparFieldLevelById(remote.sparField:getSparFieldLevel())

	local awards = QStaticDatabase:sharedDatabase():getluckyDrawById(config["reward_"..self._difficulty])
	for _,award in ipairs(awards) do
		award.count = math.floor(award.count * (starConfig.reward_coefficient + 1))
	end
	self._fightInfo.force = self._fightInfo.topnForce
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogPlayerInfo",
		options = {fighter = self._fightInfo, awardTitle1 = "胜利奖励：", awardValue1 = awards, forceTitle = "战力：", isPVP = true}}, {isPopCurrentDialog = false})
end

return QUIWidgetSparFieldFighter