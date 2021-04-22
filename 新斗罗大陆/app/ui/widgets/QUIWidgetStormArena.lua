--
-- Author: Your Name
-- Date: 2015-01-15 16:43:00
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetStormArena = class("QUIWidgetStormArena", QUIWidget)

local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")
local QActorProp = import("...models.QActorProp")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIWidgetHeroTitleBox = import(".QUIWidgetHeroTitleBox")
local QUIViewController = import("..QUIViewController")
local QNavigationController = import("...controllers.QNavigationController")
local QChatDialog = import("...utils.QChatDialog")
local QUIWidgetActorDisplay = import(".actorDisplay.QUIWidgetActorDisplay")

QUIWidgetStormArena.EVENT_USER_HEAD_CLICK = "EVENT_USER_HEAD_CLICK"
QUIWidgetStormArena.EVENT_BATTLE = "EVENT_BATTLE"
QUIWidgetStormArena.EVENT_QUICK_BATTLE = "EVENT_QUICK_BATTLE"
QUIWidgetStormArena.EVENT_FAST_BATTLE = "EVENT_FAST_BATTLE"
QUIWidgetStormArena.EVENT_WORSHIP = "EVENT_WORSHIP"
QUIWidgetStormArena.EVENT_VISIT = "EVENT_VISIT"
QUIWidgetStormArena.EVENT_ANIMATION = "EVENT_ANIMATION"

function QUIWidgetStormArena:ctor(options)
	local ccbFile = "ccb/Widget_StormArena.ccbi"
  	local callBacks = {
      {ccbCallbackName = "onPress", callback = handler(self, self._onPress)},
      {ccbCallbackName = "onTriggerFans", callback = handler(self, self._onTriggerFans)},
      {ccbCallbackName = "onTriggerVisit", callback = handler(self, self._onTriggerVisit)},
      {ccbCallbackName = "onTriggerFastFighter", callback = handler(self, self._onTriggerFastFighter)},
  }
	QUIWidgetStormArena.super.ctor(self,ccbFile,callBacks,options)
  	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._normalPos = self._ccbOwner.node_head1:getPositionY()
	self._worshipPos = self._normalPos + 20
	self._positionY = self._ccbOwner.chenghao:getPositionY()

	self._ccbOwner.tf_user_name:setString("")
	self._ccbOwner.tf_rank:setString(0)
	self._ccbOwner.tf_battleforce:setString(0)
	self._ccbOwner.node_fans:setVisible(false)

	self._words = QStaticDatabase:sharedDatabase():getArenaLangaue()
    self._animationManager = tolua.cast(self._ccbView:getUserObject(), "CCBAnimationManager")
end

function QUIWidgetStormArena:onEnter()
	QUIWidgetStormArena.super.onEnter(self)
end

function QUIWidgetStormArena:onExit()
	QUIWidgetStormArena.super.onExit(self)
	if self.schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self.schedulerHandler)
		self.schedulerHandler = nil
	end
    if self._animationManager ~= nil then
        self._animationManager:disconnectScriptHandler()
    end

    if self._avatar1 ~= nil then
    	self._avatar1:removeFromParent()
    	self._avatar1 = nil
    end
    if self._avatar2 ~= nil then
    	self._avatar2:removeFromParent()
    	self._avatar2 = nil
    end
end

--[[
	info 对手信息
	isWorship 是不是前十名
	index 序号第几个
	isFans 是不是膜拜过
	isManualRefresh 是不是手动刷新
]]
function QUIWidgetStormArena:setInfo(info, index, isManualRefresh)
	self.index = index
	self.info = info
	self.isFans = info.isFans or false
	self.isWorship = info.isWorship or false
	self.isManualRefresh = isManualRefresh

	local myStormInfo = remote.stormArena:getStormArenaInfo()
	if self.rivalId ~= nil and fighterResult ~= nil then
		self._topRank = fighterResult.stormResponse.mySelf.lastRank
	else
		self._topRank = myStormInfo.rank or 10001
	end
	self:refreshInfo()
end

function QUIWidgetStormArena:refreshInfo()
	self._animationManager:stopAnimation()
	self._animationManager:runAnimationsForSequenceNamed("normal")

	self._ccbOwner.node_chair:setVisible(false)
	self._ccbOwner.btn_fastFighter:setVisible(false)
	self._ccbOwner.node_high:setVisible(false)
	self._ccbOwner.node_self:setVisible(false)
	self._ccbOwner.effect_1:setVisible(false)
	self._ccbOwner.effect_2:setVisible(false)
	self._ccbOwner.effect_3:setVisible(false)
	
	if self.isManualRefresh == true and self.isWorship == false then
		self._effect = QUIWidgetAnimationPlayer.new()
		self._effect:playAnimation("effects/douhuncang_guang.ccbi", nil,function()
			self._effect = nil
		end)
		self._effect:setPosition(160, -270)
		self:getView():addChild(self._effect)
		self._effect:setScale(1.3)
	else
		if self._effect ~= nil then
			self._effect:disappear()
			self._effect = nil
		end
	end

	self._ccbOwner.tf_user_name:setString(self.info.name or "")
	self._ccbOwner.tf_rank:setString(self.info.rank or 999999)

	local force = self.info.force or 0
	local force,unit = q.convertLargerNumber(force)
	self._ccbOwner.tf_battleforce:setString(force..(unit or ""))
	self._ccbOwner.node_fans:setVisible(self.isWorship)
	self._ccbOwner.tf_fans_count:setString(self.info.worshipCount or 0)
	self._ccbOwner.tf_fans_count:setScale(1)
	self._ccbOwner.tf_server_name:setString(self.info.game_area_name or "")
	
	local size = self._ccbOwner.tf_fans_count:getContentSize()
	if size.width > 60 then
		self._ccbOwner.tf_fans_count:setScale(60/size.width)
	end

	if remote.user.userId == self.info.userId and not self.isWorship then
		self._ccbOwner.node_self:setVisible(true)
		self._ccbOwner.node_tf_force:setPosition(22, 14)
		self._ccbOwner.tf_server_name:setVisible(false)
		self._ccbOwner.name_battleforce:setString("防守战力：")
		self._ccbOwner.name_rank:setString("跨服排名：")
		self._ccbOwner.node_tf_force:setScale(0.95)
	else
		self._ccbOwner.name_battleforce:setString("战力：")
		self._ccbOwner.name_rank:setString("排名：")
		self._ccbOwner.tf_server_name:setVisible(true)
		self._ccbOwner.node_high:setVisible(true)
		self._ccbOwner.node_tf_force:setPosition(9, 4)
		self._ccbOwner.node_tf_force:setScale(1)
	end

	if self.isWorship == true then
		self._ccbOwner.node_fans_ready:setVisible(self.isFans ~= true)
		self._ccbOwner.sp_fans_end:setVisible(self.isFans == true)
		self._ccbOwner.node_head1:setPositionY(self._worshipPos)
		self._ccbOwner.node_head2:setPositionY(self._worshipPos)
		self:showRank(self.info.rank or 999999)
	else
		self._ccbOwner.node_head1:setPositionY(self._normalPos)
		self._ccbOwner.node_head2:setPositionY(self._normalPos)
		print("rank = ", self._topRank, self.info.rank)
		if self._topRank < self.info.rank then
			self._isSkipFight = true
			self._isFastFight = false
			self._ccbOwner.tf_fastFight:setString("扫荡")
			self._ccbOwner.btn_fastFighter:setVisible(true)
		elseif self._topRank > self.info.rank and app.unlock:getUnlockStormArenaFastFight() then
			self._isSkipFight = false
			self._isFastFight = true
			self._ccbOwner.tf_fastFight:setString("自动战斗")
			self._ccbOwner.btn_fastFighter:setVisible(true)
		else
			self._isSkipFight = false
			self._isFastFight = false
			self._ccbOwner.btn_fastFighter:setVisible(false)
		end
	end

	self:setHeroAvatar()

	self:showTitle(self.info.title, self.info.soulTrial)
end

function QUIWidgetStormArena:setHeroAvatar() 
	local heroInfo1 = remote.herosUtil:getMaxForceByHeros(self.info)
	if heroInfo1 and (self._avatar1 == nil or self._avatar1:getActorId() ~= heroInfo1.actorId) then
		self._ccbOwner.node_head1:removeAllChildren()
		self._avatar1 = nil
		self._avatar1 = QUIWidgetActorDisplay.new(heroInfo1.actorId, {heroInfo = heroInfo1})
		self._ccbOwner.node_head1:addChild(self._avatar1)
		self._avatar1:setAutoStand(true)
	end
	
	local heroInfo2 = remote.herosUtil:getMaxForceBySecondTeamHeros(self.info)
	if heroInfo2 and (self._avatar2 == nil or self._avatar2:getActorId() ~= heroInfo2.actorId) then
		self._ccbOwner.node_head2:removeAllChildren()
		self._avatar2 = nil
		self._avatar2 = QUIWidgetActorDisplay.new(heroInfo2.actorId, {heroInfo = heroInfo2})
		self._ccbOwner.node_head2:addChild(self._avatar2)
		self._avatar2:setAutoStand(true)
	end

	local scaleX = 1
	if remote.user.userId == self.info.userId and not self.isWorship then
		scaleX = -1
	end
	if self._avatar1 then
		self._avatar1:setScaleX(scaleX)
		self._avatar1:setVisible(true)
	end
	if self._avatar2 then
		self._avatar2:setScaleX(scaleX)
		self._avatar2:setVisible(true)
	end
end

function QUIWidgetStormArena:showRank(rank)
	self._ccbOwner.node_chair:setVisible(true)
	self._ccbOwner.node_chair1:setVisible(false)
	self._ccbOwner.node_chair2:setVisible(false)
	self._ccbOwner.node_chair3:setVisible(false)
	self._ccbOwner.node_chair4:setVisible(false)
end

function QUIWidgetStormArena:showTitle(title, soulTrial)
	local titleBox = QUIWidgetHeroTitleBox.new()
	titleBox:setTitleId(title, soulTrial)
	self._ccbOwner.chenghao:removeAllChildren()
	self._ccbOwner.chenghao:addChild(titleBox)

	local positionY = self._positionY
    if self.isWorship == true then
    	positionY = positionY+30
    end
    self._ccbOwner.chenghao:setPositionY(positionY)
end

function QUIWidgetStormArena:removeWord()
	if self._wordWidget ~= nil then
		self._wordWidget:removeFromParent()
		self._wordWidget = nil
	end
end

--设置是否禁言
function QUIWidgetStormArena:setGag(b)
	self._isGag = b
end

function QUIWidgetStormArena:showWord(str)
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

function QUIWidgetStormArena:showFans()
	self._effectPlayer = QUIWidgetAnimationPlayer.new()
	self._ccbOwner.node_effect:addChild(self._effectPlayer)
	self._effectPlayer:playAnimation("ccb/effects/mobai.ccbi", nil, function ()
		self._ccbOwner.node_effect:removeChild(self._effectPlayer)
		self.info.worshipCount = self.info.worshipCount or 0
		self.info.worshipCount = self.info.worshipCount + 1
		self._ccbOwner.tf_fans_count:setString(self.info.worshipCount or 0)
		self._ccbOwner.tf_fans_count:setScale(1)
		local size = self._ccbOwner.tf_fans_count:getContentSize()
		if size.width > 60 then
			self._ccbOwner.tf_fans_count:setScale(60/size.width)
		end
		self._effectPlayer = nil
		self.isFans = true
		self._ccbOwner.node_fans_ready:setVisible(self.isFans ~= true)
		self._ccbOwner.sp_fans_end:setVisible(self.isFans == true)
	end)
end

function QUIWidgetStormArena:hideBaseInfo(b, callback)
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
    else
    	self._animationManager:runAnimationsForSequenceNamed("appear")
    end
end

function QUIWidgetStormArena:changeBaseInfo(info)
	self._ccbOwner.tf_user_name:setString(info.name)
	local force,unit = q.convertLargerNumber(info.force or 0)
	self._ccbOwner.tf_battleforce:setString(force..(unit or ""))
	self:showTitle(info.title, info.soulTrial)

	if remote.user.userId == info.userId and not self.isWorship then
		self._ccbOwner.node_high:setVisible(false)
		self._ccbOwner.node_self:setVisible(true)
		-- self._ccbOwner.node_tf_force:setPositionY(10)
		self._ccbOwner.name_battleforce:setString("防守战力：")
		self._ccbOwner.name_rank:setString("跨服排名：")
	end
end

function QUIWidgetStormArena:showDeadEffect( callback )
	local endIndex = 0
	if self._avatar1 then
		self._avatar1:displayWithBehavior(ANIMATION_EFFECT.DEAD)
		self._avatar1:setDisplayBehaviorCallback(function ()
					endIndex = endIndex + 1

					self._avatar1:setVisible(false)
					if endIndex == 2 then
						if callback then
							callback()
						end
					end
				end)
	else
		endIndex = endIndex + 1
	end
	if self._avatar2 then
		self._avatar2:displayWithBehavior(ANIMATION_EFFECT.DEAD)
		self._avatar2:setDisplayBehaviorCallback(function ()
					endIndex = endIndex + 1

					self._avatar2:setVisible(false)
					if endIndex == 2 then
						if callback then
							callback()
						end
					end
				end)
	else
		endIndex = endIndex + 1
	end
end

function QUIWidgetStormArena:getTouchNodeByName(name)
	if name == nil then return end
	return self._ccbOwner[name]
end

function QUIWidgetStormArena:getContentSize( ... )
	return CCSize(330, 500)
end

function QUIWidgetStormArena:_onTriggerFans()
	self:dispatchEvent({name = QUIWidgetStormArena.EVENT_WORSHIP, info = self.info, widget = self, index = self.index, isWorship = self.isWorship})
end

function QUIWidgetStormArena:_onTriggerVisit()
	self:dispatchEvent({name = QUIWidgetStormArena.EVENT_VISIT, info = self.info, index = self.index, isWorship = self.isWorship})
end

function QUIWidgetStormArena:_onTriggerFastFighter()
	print("QUIWidgetStormArena:_onTriggerFastFighter()   ", self._isSkipFight, self._isFastFight)
	if self._isSkipFight then
		self:dispatchEvent({name = QUIWidgetStormArena.EVENT_QUICK_BATTLE, info = self.info, isWorship = self.isWorship, widget = self, index = self.index})
	elseif self._isFastFight then
		self:dispatchEvent({name = QUIWidgetStormArena.EVENT_FAST_BATTLE, info = self.info, isWorship = self.isWorship, widget = self, index = self.index})
	end
end

function QUIWidgetStormArena:_onPress()
	self:dispatchEvent({name = QUIWidgetStormArena.EVENT_BATTLE, info = self.info, isWorship = self.isWorship, widget = self, index = self.index})
end

return QUIWidgetStormArena