local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetNightmareInstanceLayer = class("QUIWidgetNightmareInstanceLayer", QUIWidget)
local QUIWidgetActorDisplay = import("..widgets.actorDisplay.QUIWidgetActorDisplay")
local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

QUIWidgetNightmareInstanceLayer.EVENT_CLICK_CHEST = "EVENT_CLICK_CHEST"
QUIWidgetNightmareInstanceLayer.EVENT_CLICK_FIGHT = "EVENT_CLICK_FIGHT"
QUIWidgetNightmareInstanceLayer.EVENT_CLICK_RECORD = "EVENT_CLICK_RECORD"

function QUIWidgetNightmareInstanceLayer:ctor(options)
	local ccbFile = "ccb/Widget_nightmare_floor3.ccbi"
	local callbacks = {
			{ccbCallbackName = "onTriggerFighter", callback = handler(self, QUIWidgetNightmareInstanceLayer._onTriggerFighter)},
			{ccbCallbackName = "onTriggerHonor", callback = handler(self, QUIWidgetNightmareInstanceLayer._onTriggerHonor)},
		}
	QUIWidgetNightmareInstanceLayer.super.ctor(self, ccbFile, callbacks, options)

  	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()

  	-- self._ccbOwner.sp_rope1
  	-- self._ccbOwner.sp_rope2
  	-- self._ccbOwner.sp_borad
  	-- self._ccbOwner.tf_battleforce
  	self._heroScale = 1.1
  	self._scale = 1.5

  	setShadow5(self._ccbOwner.tf_layer, ccc3(60,28,0))

	self._chest = self._ccbOwner.sp_chest
	self._chest:setTouchEnabled(true)
	self._chest:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
	self._chest:setTouchSwallowEnabled(true)
	self._chest:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QUIWidgetNightmareInstanceLayer._onTriggerTouch))
end

function QUIWidgetNightmareInstanceLayer:onExit()
	QUIWidgetNightmareInstanceLayer.super.onExit(self)
	if self._schedulerHander ~= nil then
		scheduler.unscheduleGlobal(self._schedulerHander)
	end
end

function QUIWidgetNightmareInstanceLayer:setInfo(layerInfo, progress)
	self._progress = progress
	self._layerInfo = layerInfo

	self._ccbOwner.tf_layer:setString("第"..self._layerInfo.layer.."层")
	if self._layerInfo.layer == progress then
		self:showSelfAvatar()
	end
	if self._layerInfo.layer >= progress then
		self:showAvatar()
		self:showChest(false)
	else
		self:showChest(true)
	end
	local desc = "暂无"
	local bestForce = remote.nightmare:getBestPass(self._layerInfo.int_dungeon_id)
	if bestForce ~= nil then
    	local num,unit = q.convertLargerNumber(bestForce)
    	desc = num..(unit or "")
	end
	self._ccbOwner.tf_battleforce:setString(desc)
end

function QUIWidgetNightmareInstanceLayer:resetAll()
	self._ccbOwner.node_boss1:setVisible(false)
	self._ccbOwner.node_boss2:setVisible(false)
	self._chest:setVisible(false)
end

--显示怪物的Avatar
function QUIWidgetNightmareInstanceLayer:showAvatar()
	if self._layerInfo.monster_id ~= nil then
		if self._monster ~= nil then
			self._monster:removeFromParent()
			self._monster = nil
		end
		self._monster = QUIWidgetActorDisplay.new(self._layerInfo.monster_id)
		self._ccbOwner.node_boss2:addChild(self._monster)
		self._ccbOwner.node_boss2:setVisible(true)
		if self._layerInfo.boss_size ~= nil then
			self._monster:setScaleX(self._layerInfo.boss_size)
			self._monster:setScaleY(self._layerInfo.boss_size)
		end
	end
end

--显示自己的Avatar
function QUIWidgetNightmareInstanceLayer:showSelfAvatar()
	self:_checkSelfAvatar()
	self._ccbOwner.node_boss1:setVisible(true)
	if self._forceHideSelf ~= true then
		self._avatar:setVisible(true)
	end
	self._heroInfo = nil
	if remote.user.defaultActorId ~= nil then
		self._heroInfo = remote.herosUtil:getHeroByID(remote.user.defaultActorId)
	end
	if self._heroInfo == nil then
		self._heroInfo = remote.herosUtil:getMaxForceBySelfHeros()
	end
	if self._heroInfo ~= nil then
		self._avatar:setAvatarByHeroInfo(self._heroInfo, self._heroInfo.actorId, self._heroScale)
		self._avatar:setStarVisible(false)
	end
end

--播放自己出现的动画
function QUIWidgetNightmareInstanceLayer:avatarAnimationForSelf()
	if self._layerInfo.layer == self._progress then
		local selfAnimationPlayer = QUIWidgetAnimationPlayer.new()
		selfAnimationPlayer:setPositionY(40)
		selfAnimationPlayer:setPositionX(-20)
    	selfAnimationPlayer:playAnimation("ccb/effects/Arena_sg.ccbi", nil,nil,true)
    	self._ccbOwner.node_boss1:addChild(selfAnimationPlayer)
    	self._forceHideSelf = true
		self._avatar:setVisible(false)
		self._schedulerHander = scheduler.performWithDelayGlobal(function ()
			self._avatar:setVisible(true)
    		self._forceHideSelf = false
		end, 0.2)
	end
end

--播放怪物死亡
function QUIWidgetNightmareInstanceLayer:playMonsterDead(callback)
	if self._monster ~= nil then
	    self._monster:displayWithBehavior(ANIMATION_EFFECT.DEAD)
	    self._monster:setAutoStand(false)
	end
    self:playChestOpen(callback)
end

--播放结束动画
function QUIWidgetNightmareInstanceLayer:playEndEffect(callback)
    local animationPlayer = QUIWidgetAnimationPlayer.new()
    animationPlayer:setPositionY(-17)
    animationPlayer:setPositionX(-12)
    self._ccbOwner.node_boss1:addChild(animationPlayer)
    animationPlayer:setScale(self._scale)
    animationPlayer:playAnimation("ccb/effects/nightmare_emeng_yidong_fx.ccbi",function (ccbOwner)
		if self._avatar ~= nil then 
			self._avatar:setVisible(false)
		end
		self._animationAvatar = QUIWidgetHeroInformation.new()
		self._animationAvatar:setPositionX(-10)
		self._animationAvatar:setPositionY(167)
		self._animationAvatar:setBackgroundVisible(false)
		self._animationAvatar:setNameVisible(false)
		self._animationAvatar:setAvatarByHeroInfo(self._heroInfo, self._heroInfo.actorId, self._heroScale * 1/self._scale)
		self._animationAvatar:setStarVisible(false)
		ccbOwner.node_hero:addChild(self._animationAvatar)
    end,callback)
    scheduler.performWithDelayGlobal(function ()
    	if self._animationAvatar ~= nil then 
    		self._animationAvatar:setVisible(false)
    		self._animationAvatar:removeFromParent()
    		self._animationAvatar = nil
    	end
    end, 22/30)
end

--播放结束动画
function QUIWidgetNightmareInstanceLayer:playAppearEffect(callback)
	self:showSelfAvatar()
	self._avatar:setVisible(false)
    local animationPlayer = QUIWidgetAnimationPlayer.new()
    animationPlayer:setPositionY(-17)
    animationPlayer:setPositionX(-12)
    self._ccbOwner.node_boss1:addChild(animationPlayer)
    animationPlayer:setScale(self._scale)
    animationPlayer:playAnimation("ccb/effects/nightmare_emeng_yidong_fx.ccbi",function (ccbOwner)
		self._animationAvatar = QUIWidgetHeroInformation.new()
		self._animationAvatar:setPositionX(-10)
		self._animationAvatar:setPositionY(167)
		self._animationAvatar:setBackgroundVisible(false)
		self._animationAvatar:setNameVisible(false)
		self._animationAvatar:setAvatarByHeroInfo(self._heroInfo, self._heroInfo.actorId, self._heroScale * 1/self._scale)
		self._animationAvatar:setStarVisible(false)
		ccbOwner.node_hero:addChild(self._animationAvatar)
		self._animationAvatar:setVisible(false)
    end,function ()
    	if callback ~= nil then callback() end
    	if self._avatar ~= nil then 
    		self._avatar:setVisible(true)
    	end
    	self._animationAvatar:removeFromParent()
    	self._animationAvatar = nil
    end)
    scheduler.performWithDelayGlobal(function ()
    	if self._animationAvatar ~= nil then 
    		self._animationAvatar:setVisible(true)
    	end
    end, 22/30)
end

--播放宝箱打开动画
function QUIWidgetNightmareInstanceLayer:playChestOpen(callback)
	local chestAnimationPlay = QUIWidgetAnimationPlayer.new()
	self._chest:getParent():addChild(chestAnimationPlay)
	chestAnimationPlay:setPositionY(-18)
	chestAnimationPlay:setPositionX(-8)
    local layerConfig = remote.nightmare:getConfigByNightmareId(self._layerInfo.int_instance_id)
    local ccbFile = "ccb/effects/box4.ccbi"
    if self._layerInfo.layer == #layerConfig.configs then
		chestAnimationPlay:setPositionY(-19)
		chestAnimationPlay:setPositionX(-18)
    	ccbFile = "ccb/effects/Box3.ccbi"
    end
    self._chest:setVisible(false)
	chestAnimationPlay:playAnimation(ccbFile, nil, function ()
		self:showChest(true)
    	self._chest:setVisible(true)
    	if callback ~= nil then callback() end
	end)
end

function QUIWidgetNightmareInstanceLayer:showChest(isOpen)
    local pngName = "ui/common2/baoxiang2_close.png"
    local layerConfig = remote.nightmare:getConfigByNightmareId(self._layerInfo.int_instance_id)
	self._chest:setScale(1)
    if isOpen then
    	pngName = "ui/common2/baoxiang2_open.png"
    end
    if self._layerInfo.layer == #layerConfig.configs then
    	
    	if isOpen == false then
    		pngName = "ui/update_plist/SunWell/sunwell_baoxiang1_close.png"
    	else
    		pngName = "ui/update_plist/SunWell/sunwell_baoxiang1_open2.png"
    	end
    end
    local displayFrame = QSpriteFrameByPath(pngName)
    if displayFrame then
		self._chest:setDisplayFrame(displayFrame)
	end
	self._chest:setVisible(true)
end

function QUIWidgetNightmareInstanceLayer:_checkSelfAvatar()
	if self._avatar == nil then
		self._avatar = QUIWidgetHeroInformation.new()
		self._avatar:setBackgroundVisible(false)
		self._avatar:setNameVisible(false)
		self._avatar:setPositionY(150)
		self._avatar:setPositionX(-20)
		self._ccbOwner.node_boss1:addChild(self._avatar)
	end
end

function QUIWidgetNightmareInstanceLayer:_onTriggerTouch(event)
	if event.name == "began" then 
		return true
	elseif event.name == "moved" then	
	elseif event.name == "ended" or event.name == "cancelled" then 
		self:_onTriggerClick()
	end
end

function QUIWidgetNightmareInstanceLayer:_onTriggerClick()
	self:dispatchEvent({name = QUIWidgetNightmareInstanceLayer.EVENT_CLICK_CHEST, dungeonId = self._layerInfo.dungeon_id})
end

function QUIWidgetNightmareInstanceLayer:_onTriggerFighter()
	if self._layerInfo.layer == self._progress then
		self:dispatchEvent({name = QUIWidgetNightmareInstanceLayer.EVENT_CLICK_FIGHT, dungeonId = self._layerInfo.dungeon_id})
	end
end

function QUIWidgetNightmareInstanceLayer:_onTriggerHonor()
	self:dispatchEvent({name = QUIWidgetNightmareInstanceLayer.EVENT_CLICK_RECORD, dungeonId = self._layerInfo.dungeon_id})
end

return QUIWidgetNightmareInstanceLayer