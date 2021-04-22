--
-- Author: Your Name
-- Date: 2015-01-15 16:43:00
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetGloryArena = class("QUIWidgetGloryArena", QUIWidget)

local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")
local QActorProp = import("...models.QActorProp")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIWidgetHeroTitleBox = import(".QUIWidgetHeroTitleBox")
local QChatDialog = import("...utils.QChatDialog")

QUIWidgetGloryArena.EVENT_USER_HEAD_CLICK = "EVENT_USER_HEAD_CLICK"
QUIWidgetGloryArena.EVENT_BATTLE = "EVENT_BATTLE"
QUIWidgetGloryArena.EVENT_QUICK_BATTLE = "EVENT_QUICK_BATTLE"
QUIWidgetGloryArena.EVENT_WORSHIP = "EVENT_WORSHIP"
QUIWidgetGloryArena.EVENT_VISIT = "EVENT_VISIT"
QUIWidgetGloryArena.EVENT_ANIMATION = "EVENT_ANIMATION"

function QUIWidgetGloryArena:ctor(options)
	local ccbFile = "ccb/Widget_GloryArena.ccbi"
  	local callBacks = {
      {ccbCallbackName = "onPress", callback = handler(self, QUIWidgetGloryArena._onPress)},
      {ccbCallbackName = "onTriggerFans", callback = handler(self, QUIWidgetGloryArena._onTriggerFans)},
      {ccbCallbackName = "onTriggerVisit", callback = handler(self, QUIWidgetGloryArena._onTriggerVisit)},
      {ccbCallbackName = "onTriggerFastFighter", callback = handler(self, QUIWidgetGloryArena._onTriggerFastFighter)},
  }
	QUIWidgetGloryArena.super.ctor(self,ccbFile,callBacks,options)
  	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._avatar = QUIWidgetHeroInformation.new()
	self._avatar:setBackgroundVisible(false)
	self._avatar:setNameVisible(false)
	self._ccbOwner.node_head:addChild(self._avatar)
	self._normalPos = self._ccbOwner.node_head:getPositionY()
	self._worshipPos = self._ccbOwner.node_worship_head:getPositionY()
	self._positionY = self._ccbOwner.chenghao:getPositionY()

	self._ccbOwner.tf_user_name:setString("")
	self._ccbOwner.tf_rank:setString(0)
	self._ccbOwner.tf_battleforce:setString(0)
	self._ccbOwner.node_fans:setVisible(false)

	self._words = QStaticDatabase:sharedDatabase():getArenaLangaue()
    self._animationManager = tolua.cast(self._ccbView:getUserObject(), "CCBAnimationManager")
end

function QUIWidgetGloryArena:onEnter()
	QUIWidgetGloryArena.super.onEnter(self)
end

function QUIWidgetGloryArena:onExit()
	QUIWidgetGloryArena.super.onExit(self)
	if self.schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self.schedulerHandler)
		self.schedulerHandler = nil
	end
    if self._animationManager ~= nil then
        self._animationManager:disconnectScriptHandler()
    end
end

--[[
	info 对手信息
	isWorship 是不是前十名
	index 序号第几个
	isFans 是不是膜拜过
	isManualRefresh 是不是手动刷新
	rivalId 上次挑战对手的id
	fighterResult 上次挑战的结果
	rivalInfo 上次挑战对手的信息
]]
function QUIWidgetGloryArena:setInfo(info, isWorship, index, isFans, isManualRefresh, rivalId, fighterResult, rivalInfo)
	self.index = index
	self.info = info
	self.isFans = isFans
	self.isWorship = isWorship
	self.isManualRefresh = isManualRefresh
	self.rivalId = rivalId
	self._avatar:setAutoStand(true)
	self._avatar:setAvatarVisible(true)
	if self.rivalId ~= nil and fighterResult ~= nil then
		self._topRank = fighterResult.gloryCompetitionResponse.mySelf.lastRank
	else
		self._topRank = remote.tower.gloryArenaMyInfo.rank
	end
	self:refreshInfo()
	if self.rivalId ~= nil then
		if self.rivalId == self.info.userId and self.isWorship == false then
		
			if self._topRank < self.info.rank then --播放死亡动画 当自己的排名比对手靠前
			
				self._avatar:avatarPlayAnimation(ANIMATION_EFFECT.DEAD)
				self._avatar:setAutoStand(false)
				self._isGag = true
				self:removeWord()
				self.schedulerHandler = scheduler.scheduleGlobal(function ()
					if self._avatar then
						if not self._avatar:isAvatarPlayingAnimation() then
							scheduler.unscheduleGlobal(self.schedulerHandler)
							self.schedulerHandler = nil
							self:dispatchEvent({name = QUIWidgetGloryArena.EVENT_ANIMATION})
							-- self._avatar:pauseAnimation()
						end
					else
						scheduler.unscheduleGlobal(self.schedulerHandler)
						self.schedulerHandler = nil
						self:dispatchEvent({name = QUIWidgetGloryArena.EVENT_ANIMATION})
					end
					
				end, 0)
			else
				self._avatar:setAvatarVisible(false) --播放踢人动画 隐藏对手
			end
		elseif remote.user.userId == self.info.userId and self.isWorship == false and rivalInfo ~= nil and rivalInfo.rank < self._topRank then
			self._avatar:setAvatarVisible(false) --播放踢人动画 隐藏自己
		end
	else
		self._isGag = false
	end
	
	self:setUnionName()
end

function QUIWidgetGloryArena:setFightLable(lable)
	-- body
	if lable then
		self._ccbOwner.fight_lable:setString(lable)
	end
end

function QUIWidgetGloryArena:setUnionName() 
	if self.info == nil then return end
	local unionName = self.info.consortiaName or ""

	self._ccbOwner.tf_union_name:setString("【"..unionName.."】" or "")
	if unionName == nil or unionName == "" then
		self._ccbOwner.tf_union_name:setString("无宗门")
	end
end

function QUIWidgetGloryArena:showRank(rank)
	self._ccbOwner.node_chair:setVisible(true)
	self._ccbOwner.node_chair1:setVisible(false)
	self._ccbOwner.node_chair2:setVisible(false)
	self._ccbOwner.node_chair3:setVisible(false)
	self._ccbOwner.node_chair4:setVisible(false)

	if rank == 1 then
		self._ccbOwner.node_chair1:setVisible(true)
		self._ccbOwner.effect_1:setVisible(true)
	elseif rank > 1 and rank < 4 then
		self._ccbOwner["node_chair"..rank]:setVisible(true)
		self._ccbOwner["effect_"..rank]:setVisible(true)
	elseif rank < 11 then
		self._ccbOwner.node_chair4:setVisible(true)
	end
end

function QUIWidgetGloryArena:refreshInfo()
	self._animationManager:stopAnimation()
	self._animationManager:runAnimationsForSequenceNamed("normal")

	self._ccbOwner.node_chair:setVisible(false)
	self._ccbOwner.btn_fastFighter:setVisible(false)
	self._ccbOwner.node_high:setVisible(false)
	self._ccbOwner.node_low:setVisible(false)
	self._ccbOwner.node_self:setVisible(false)
	self._ccbOwner.effect_1:setVisible(false)
	self._ccbOwner.effect_2:setVisible(false)
	self._ccbOwner.effect_3:setVisible(false)
	self._ccbOwner.effect_4:setVisible(false)
	
	if self.isManualRefresh == true and self.isWorship == false then
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
	if self.info.heros ~= nil then 
		maxHero = remote.herosUtil:getMaxForceByHeros(self.info)

		local actorId =  maxHero.actorId
		local heroInfo = maxHero
		if self.info.defaultActorId and self.info.defaultActorId ~= 0 then
			actorId = self.info.defaultActorId
			heroInfo = remote.herosUtil:getSpecifiedHeroById(self.info, actorId)
		end
		if actorId ~= nil then
			if q.isEmpty(heroInfo) then
				heroInfo = {skinId = self.info.defaultSkinId or 0}
			end
			self._avatar:setAvatarByHeroInfo({skinId = self.info.defaultSkinId}, actorId, 1.3)
			-- self._avatar:setAvatarByHeroInfo(showHeroInfo, actorId, 1.3)
			self._avatar:setStarVisible(false)
		end
	end
	self._ccbOwner.tf_user_name:setString(self.info.name)
	self._ccbOwner.tf_rank:setString(self.info.rank or 999999)

	local force = self.info.force or 0
	local num,unit = q.convertLargerNumber(force)
	self._ccbOwner.tf_battleforce:setString(num..(unit or ""))
	self._ccbOwner.node_fans:setVisible(self.isWorship)
	self._ccbOwner.tf_fans_count:setString(self.info.worshipCount or 0)
	self._ccbOwner.tf_fans_count:setScale(1)
	self._ccbOwner.serverName:setString(self.info.game_area_name or "")
	
	local size = self._ccbOwner.tf_fans_count:getContentSize()
	if size.width > 60 then
		self._ccbOwner.tf_fans_count:setScale(60/size.width)
	end
	if self.isWorship == true then
		self._ccbOwner.node_high:setVisible(true)
	else
		if remote.user.userId == self.info.userId then
			self._ccbOwner.node_self:setVisible(true)
			self._ccbOwner.effect_4:setVisible(true)
		else
			self._ccbOwner.node_low:setVisible(true)
		end
	end
	if self.isWorship == true then
		self._ccbOwner.btn_fans:setVisible(self.isFans ~= true)
		self._ccbOwner.sp_fans_end:setVisible(self.isFans == true)
		self._ccbOwner.node_head:setPositionY(self._worshipPos)
		self:showRank(self.info.rank or 999999)
	else
		self._ccbOwner.node_head:setPositionY(self._normalPos)
		if self._topRank > self.info.rank then
			if app.unlock:getUnlockGloryArena() then
				self._ccbOwner.btn_fastFighter:setVisible(remote.tower.canJoinGloryArena)
				self:setFightLable("自动战斗")
			else
				self._ccbOwner.btn_fastFighter:setVisible(false)
			end
			
		else
			self._ccbOwner.btn_fastFighter:setVisible(self._topRank < self.info.rank and remote.tower.canJoinGloryArena)
			self:setFightLable("扫荡")
		end
		self:showRank(self.info.rank or 999999)
		self._ccbOwner.node_chair:setVisible(false)
	end
	self:showTitle(self.info.title, self.info.soulTrial)
end

function QUIWidgetGloryArena:showTitle(title, soulTrial)
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

function QUIWidgetGloryArena:removeWord()
	if self._wordWidget ~= nil then
		self._wordWidget:removeFromParent()
		self._wordWidget = nil
	end
end

--设置是否禁言
function QUIWidgetGloryArena:setGag(b)
	self._isGag = b
end

function QUIWidgetGloryArena:showWord(str)
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

function QUIWidgetGloryArena:showFans()
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
		self._ccbOwner.btn_fans:setVisible(self.isFans ~= true)
		self._ccbOwner.sp_fans_end:setVisible(self.isFans == true)
	end)
end

function QUIWidgetGloryArena:hideBaseInfo(b, callback)
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

function QUIWidgetGloryArena:changeBaseInfo(info)
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

function QUIWidgetGloryArena:_onTriggerFans()
	self:dispatchEvent({name = QUIWidgetGloryArena.EVENT_WORSHIP, info = self.info, widget = self, index = self.index})
end

function QUIWidgetGloryArena:_onTriggerVisit()
	self:dispatchEvent({name = QUIWidgetGloryArena.EVENT_VISIT, info = self.info, index = self.index})
end

function QUIWidgetGloryArena:_onTriggerFastFighter()
	self:dispatchEvent({name = QUIWidgetGloryArena.EVENT_QUICK_BATTLE, info = self.info, isWorship = self.isWorship, widget = self, index = self.index})
end

function QUIWidgetGloryArena:_onPress()
	self:dispatchEvent({name = QUIWidgetGloryArena.EVENT_BATTLE, info = self.info, isWorship = self.isWorship, widget = self, index = self.index})
end

return QUIWidgetGloryArena