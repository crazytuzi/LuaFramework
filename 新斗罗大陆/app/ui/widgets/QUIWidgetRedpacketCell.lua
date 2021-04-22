--
-- Author: Kumo.Wang
-- 宗门红包cell
--

local QUIWidget = import(".QUIWidget")
local QUIWidgetRedpacketCell = class("QUIWidgetRedpacketCell", QUIWidget)

QUIWidgetRedpacketCell.OPEN_EFFECT_START = "QUIWIDGETREDPACKETCELL_OPEN_EFFECT_START"
QUIWidgetRedpacketCell.OPEN_EFFECT_END = "QUIWIDGETREDPACKETCELL_OPEN_EFFECT_END"

function QUIWidgetRedpacketCell:ctor(options)
	local ccbFile = "ccb/Widget_Society_Redpacket_Client.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
	}
	QUIWidgetRedpacketCell.super.ctor(self,ccbFile,callBacks,options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._facStandbyBgEffect = tolua.cast(self._ccbOwner.fca_standby_bg, "QFcaSkeletonView_cpp")
    self._facStandbyBgEffect:stopAnimation()
    self._facStandbyBgEffect:setVisible(false)

	self._facStandbyEffect = tolua.cast(self._ccbOwner.fca_standby, "QFcaSkeletonView_cpp")
    self._facStandbyEffect:stopAnimation()
    self._facStandbyEffect:setVisible(false)

    self._facOpenEffect = tolua.cast(self._ccbOwner.fca_open, "QFcaSkeletonView_cpp")
    self._facOpenEffect:stopAnimation()
    self._facOpenEffect:setVisible(false)
end

function QUIWidgetRedpacketCell:onEnter()
end

function QUIWidgetRedpacketCell:onExit()
	if self._scheduler then
		scheduler.unscheduleGlobal(self._scheduler)
		self._scheduler = nil
	end
end

function QUIWidgetRedpacketCell:showStandbyEffect()
	if self._facOpenEffect then
		self._facOpenEffect:stopAnimation()
	    self._facOpenEffect:setVisible(false)
	end
	if self._facStandbyEffect then
		self._facStandbyEffect:setVisible(true)
	    self._facStandbyEffect:resumeAnimation()
	    self._facStandbyEffect:connectAnimationEventSignal(handler(self, self._fcaStandbyHandler))
	    self._facStandbyEffect:playAnimation("animation", true)
   	end
   	if self._facStandbyBgEffect then
   		self._facStandbyBgEffect:setVisible(true)
	    self._facStandbyBgEffect:resumeAnimation()
	    self._facStandbyBgEffect:connectAnimationEventSignal(handler(self, self._fcaStandbyHandler))
	    self._facStandbyBgEffect:playAnimation("animation", true)
   	end
end

function QUIWidgetRedpacketCell:showOpenEffect()
	if self._facStandbyEffect then
		self._facStandbyEffect:stopAnimation()
	    self._facStandbyEffect:setVisible(false)
	end
	if self._facStandbyBgEffect then
		self._facStandbyBgEffect:stopAnimation()
	    self._facStandbyBgEffect:setVisible(false)
	end
	if self._facOpenEffect then
		self._facOpenEffect:setVisible(true)
	    self._facOpenEffect:resumeAnimation()
	    self._facOpenEffect:connectAnimationEventSignal(handler(self, self._fcaOpenHandler))
	    self._facOpenEffect:playAnimation("animation", false)
	    self:dispatchEvent({name = QUIWidgetRedpacketCell.OPEN_EFFECT_START, cell = self, param = self._param})
   	end
end

function QUIWidgetRedpacketCell:_fcaStandbyHandler(eventType)
    if eventType == SP_ANIMATION_END or eventType == SP_ANIMATION_COMPLETE then
        -- self._facStandbyEffect:stopAnimation()
        -- self._facStandbyEffect:setVisible(false)
    end
end

function QUIWidgetRedpacketCell:_fcaOpenHandler(eventType)
    if eventType == SP_ANIMATION_END or eventType == SP_ANIMATION_COMPLETE then
    	self:dispatchEvent({name = QUIWidgetRedpacketCell.OPEN_EFFECT_END, cell = self, param = self._param})
        self._facOpenEffect:stopAnimation()
        self._facOpenEffect:setVisible(false)

        self._itemData.isOpened = true
        self:_setRedpacketImg()
    end
end

function QUIWidgetRedpacketCell:setInfo(param)
	self:_resetAll()
	if not param then return end
	self._param = param
	self._selectedTab = param.selectedTab or remote.redpacket.GAIN
	self._itemData = clone(param.itemData) or {}
	-- QPrintTable(self._itemData)
	if self._selectedTab == remote.redpacket.GAIN then
		if next(self._itemData) then
			self._ccbOwner.node_have:setVisible(true)
	    	self._ccbOwner.node_playerName:setVisible(true)
			self:_setRedpacketImg()
			-- 和时间有关的数据
			self:_setCountDown()
			if self._scheduler then
				scheduler.unscheduleGlobal(self._scheduler)
				self._scheduler = nil
			end
			self._scheduler = scheduler.scheduleGlobal(function ()
				self:_setCountDown()
			end, 1)
			self:_setInfo()
			-- if self._itemData.type == remote.redpacket.ITEM_REDPACKET and not self._itemData.isOpened and self._itemData.redpacketNum > 0 then
			if not self._itemData.isOpened and self._itemData.redpacketNum > 0 then
				self:showStandbyEffect()
			end
		else
			self._ccbOwner.node_no:setVisible(true)
		end
    elseif self._selectedTab == remote.redpacket.SEND then
    	self._ccbOwner.node_have:setVisible(true)
    	self._ccbOwner.node_playerName:setVisible(false)
    	self:_setRedpacketImg()
    	self:_setRedpacketTypeNameImg()
    	-- self:showStandbyEffect()
    end
end

function QUIWidgetRedpacketCell:update(itemData)
	self._itemData = clone(itemData)
	if self._selectedTab == remote.redpacket.GAIN then
		if next(self._itemData) then
			self._ccbOwner.node_have:setVisible(true)
			self:_setRedpacketImg()
			self:_setInfo()
		else
			self._ccbOwner.node_no:setVisible(true)
		end
    end
end

function QUIWidgetRedpacketCell:_setCountDown()
	local isOvertime, countDownStr = remote.redpacket:updateTime(self._itemData.offAt)
	if isOvertime and self._scheduler then
		scheduler.unscheduleGlobal(self._scheduler)
		self._scheduler = nil
	end
	self._ccbOwner.tf_countDownTime:setString(countDownStr)
	self._ccbOwner.tf_playerName:setString(self._itemData.nickname)
	self._ccbOwner.node_countDown:setVisible(true)
end

function QUIWidgetRedpacketCell:_setInfo()
	local config = remote.redpacket:getRedpacketConfigById(self._itemData.id)
	if config then
		self._ccbOwner.tf_redPacketName:setString(config.name)
	end
	self._ccbOwner.tf_totalBonusNumber:setString(self._itemData.item_num)
	local maxNum = config and config.recipients_num or 0
	local curNum = self._itemData.redpacketNum or maxNum
	self._ccbOwner.tf_bonusProgress:setString(curNum.."/"..maxNum)
	self._ccbOwner.node_info:setVisible(true)
end

function QUIWidgetRedpacketCell:_setRedpacketImg()
	local path
	local isNeedGray = false
	if self._selectedTab == remote.redpacket.GAIN then
		local state = remote.redpacket.NEW_REDPACKET_STATE
		if self._itemData.isOpened then
			state = remote.redpacket.OPENED_REDPACKET_STATE
			self._ccbOwner.sp_isMine:setVisible(true)
			isNeedGray = true
		else
			local isOvertime = remote.redpacket:updateTime(self._itemData.offAt)
			if self._itemData.redpacketNum == 0 or isOvertime then
				state = remote.redpacket.END_REDPACKET_STATE
				isNeedGray = true
			end
		end
		path = remote.redpacket:getRedPacketPathByTypeAndState(self._itemData.type, state)
    elseif self._selectedTab == remote.redpacket.SEND then
    	path = remote.redpacket:getRedPacketPathByTypeAndState(self._itemData, remote.redpacket.NEW_REDPACKET_STATE)
    end
    if path then
    	local sprite = CCSprite:create(path)
    	if sprite then
    		self._ccbOwner.node_redpacket:addChild(sprite)
    	end
	end
	if isNeedGray then
		makeNodeFromNormalToGray(self._ccbOwner.node_redpacket)
	else
		makeNodeFromGrayToNormal(self._ccbOwner.node_redpacket)
	end
end

function QUIWidgetRedpacketCell:_setRedpacketTypeNameImg()
	local path
	if self._selectedTab == remote.redpacket.GAIN then
		return
    elseif self._selectedTab == remote.redpacket.SEND then
    	path = remote.redpacket:getRedPacketTypePathByType(self._itemData)
    end
    if path then
    	-- local sprite = CCSprite:create(path)
    	-- if sprite then
    	-- 	self._ccbOwner.node_typeName:addChild(sprite)
    	-- end
		self._ccbOwner.tf_typeName:setString(path)
		self._ccbOwner.tf_typeName:setVisible(true)
	else
		self._ccbOwner.tf_typeName:setVisible(false)
	end
end

function QUIWidgetRedpacketCell:_resetAll()
	self._ccbOwner.node_countDown:setVisible(false)
	self._ccbOwner.node_info:setVisible(false)
	self._ccbOwner.node_no:setVisible(false)
	self._ccbOwner.node_have:setVisible(false)
	self._ccbOwner.sp_isMine:setVisible(false)
	self._ccbOwner.sp_send_tips:setVisible(false)
	self._ccbOwner.node_redpacket:removeAllChildren()
	self._ccbOwner.tf_typeName:setVisible(false)
	-- self._ccbOwner.node_typeName:removeAllChildren()
	if self._facStandbyBgEffect then
	    self._facStandbyBgEffect:stopAnimation()
	    self._facStandbyBgEffect:setVisible(false)
	end
	if self._facStandbyEffect then
	    self._facStandbyEffect:stopAnimation()
	    self._facStandbyEffect:setVisible(false)
	end
	if self._facOpenEffect then
	    self._facOpenEffect:stopAnimation()
	    self._facOpenEffect:setVisible(false)
	end
end

function QUIWidgetRedpacketCell:getName()
	return "QUIWidgetRedpacketCell"
end

function QUIWidgetRedpacketCell:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

return QUIWidgetRedpacketCell
