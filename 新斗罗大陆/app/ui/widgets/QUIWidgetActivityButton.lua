--
-- Author: Your Name
-- Date: 2015-03-20 14:30:22
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetActivityButton = class("QUIWidgetActivityButton", QUIWidget)


QUIWidgetActivityButton.EVENT_CLICK = "EVENT_CLICK"

function QUIWidgetActivityButton:ctor(options)
	local ccbFile = "ccb/Widget_Activity_client3.ccbi"
	QUIWidgetActivityButton.super.ctor(self,ccbFile,callBacks,options)
end

function QUIWidgetActivityButton:refreshInfo()
	self:setInfo(self._info)
end

function QUIWidgetActivityButton:setInfo(info)
	self._info = info
	self._ccbOwner.btn_click:setTitleForState(CCString:create(self._info.title or ""), CCControlStateNormal)
	self._ccbOwner.btn_click:setTitleForState(CCString:create(self._info.title or ""), CCControlStateHighlighted)
	self._ccbOwner.btn_click:setTitleForState(CCString:create(self._info.title or ""), CCControlStateDisabled)
		
	if self._info.type == remote.activity.TYPE_ACTIVITY_FOR_CARD then
		self._ccbOwner.node_tips:setVisible(remote.activity:checkMonthCardReady())
	elseif self._info.type == remote.activity.TYPE_MONTHFUND then
		local isClicked = remote.activity:isActivityClicked(self._info)
		self._ccbOwner.node_tips:setVisible(remote.activityMonthFund:checkRedTips(self._info.activityId) or not isClicked)
		if remote.activityMonthFund:checkRedTips(self._info.activityId) then
			self._ccbOwner.node_tips:setVisible(true)
		else
			self._ccbOwner.node_tips:setVisible(not remote.activity:isActivityClicked(self._info))
		end
	elseif self._info.type == remote.activity.TYPE_WEEKFUND then
		local weekFund = remote.activityRounds:getWeekFund()
		self._ccbOwner.node_tips:setVisible(weekFund:checkRedTips())
	elseif self._info.type == remote.activity.VIP_GIFT_DAILY then
		self._ccbOwner.node_tips:setVisible(remote.activityVipGift:checkDailyRedTips())
	elseif self._info.type == remote.activity.VIP_GIFT_WEEK then
		self._ccbOwner.node_tips:setVisible(remote.activityVipGift:checkWeekRedTips())
	elseif self._info.type == remote.activity.TYPE_CRYSTAL_SHOP then
		self._ccbOwner.node_tips:setVisible(remote.crystal:checkCrystalRedtips())	
	elseif self._info.type == remote.activity.TYPE_VIP_INHERIT then
		self._ccbOwner.node_tips:setVisible(not remote.user.warmBloodVipGet)
	elseif self._info.type == remote.activity.TYPE_ACTIVITY_FOR_REPEATPAY and remote.activity:checkIsSixRepeatPayActivity(self._info) then
		local isClicked = remote.activity:checkIsSixRepeatPayComplete(self._info) --app:getUserOperateRecord():isActivityClicked(self._info.activityId) or 0
		self._ccbOwner.node_tips:setVisible(isClicked)
	else
		local dataProxy = remote.activity:getDataProxyByActivityId(self._info.activityId)

		if dataProxy ~= nil and dataProxy.getBtnTips ~= nil then
			self._ccbOwner.node_tips:setVisible(dataProxy:getBtnTips(self._info))
		else
			self._ccbOwner.node_tips:setVisible(self._info.isHaveComplete or (not remote.activity:isActivityClicked(self._info)))
		end
	end
	
	self._ccbOwner.icon:removeAllChildren()
	if self._info.icon ~= nil and self._info.icon ~= "" then
		self._ccbOwner.node_icon:setVisible(true)
		local path = nil
		if string.find(self._info.icon, "/") then
			path = self._info.icon
		else
			path = "icon/activity/"..self._info.icon
		end
		if QCheckFileIsExist(path) then
			self._ccbOwner.icon:addChild(display.newSprite(path))		
		else
			print(self._info.title.."|", path, "[not exist]")
			self._ccbOwner.node_icon:setVisible(false)
		end
	else
		print(self._info.title.."|[no icon]")
		self._ccbOwner.node_icon:setVisible(false)
	end

	if self._info.subject == remote.activity.THEME_ACTIVITY_RAT_FESTIVAL_1 then
		local curTime = q.serverTime() * 1000
		local startTime = self._info.start_at
		local oneDay = DAY * 1000
		if curTime >= startTime then
			-- 已經開啟
			self:setUnlock(false)
		elseif curTime + oneDay >= startTime then
			-- 明日開啟
			self._ccbOwner.node_tips:setVisible(false)
			self:setUnlock(false)
		else
			-- 未開啟
			self._ccbOwner.node_tips:setVisible(false)
			self:setUnlock(true)
		end
	else
		self:setUnlock(false)
	end
end

function QUIWidgetActivityButton:getInfo()
	return self._info
end

function QUIWidgetActivityButton:setSelect(b)
	if self._info.subject == remote.activity.THEME_ACTIVITY_RAT_FESTIVAL_1 then
		local curTime = q.serverTime() * 1000
		local startTime = self._info.start_at
		local oneDay = DAY * 1000
		if curTime >= startTime then
			-- 已經開啟
			self:setUnlock(false)
		elseif curTime + oneDay >= startTime then
			-- 明日開啟
			self._ccbOwner.btn_click:setHighlighted(b)
			self._ccbOwner.btn_click:setEnabled(not b)
			self._ccbOwner.node_tips:setVisible(false)
			self:setUnlock(false)
			return
		else
			-- 未開啟
			self._ccbOwner.btn_click:setHighlighted(false)
			self._ccbOwner.btn_click:setEnabled(true)
			self._ccbOwner.node_tips:setVisible(false)
			self:setUnlock(true)
			return
		end
	else
		self:setUnlock(false)
	end

	self._ccbOwner.btn_click:setHighlighted(b)
	self._ccbOwner.btn_click:setEnabled(not b)
	
	if b then
		remote.activity:setActivityClicked(self._info)		
	end

	if self._info.type == remote.activity.TYPE_ACTIVITY_FOR_CARD then
		self._ccbOwner.node_tips:setVisible(remote.activity:checkMonthCardReady())
	elseif self._info.type == remote.activity.TYPE_MONTHFUND then
		if remote.activityMonthFund:getMonthFundStatus(self._info.activityId) == 1 and b then
			if app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.MONTH_FUND) then
				app:getUserOperateRecord():recordeCurrentTime(DAILY_TIME_TYPE.MONTH_FUND)
				self._ccbOwner.node_tips:setVisible(false)
			end
		else
			if remote.activityMonthFund:checkRedTips(self._info.activityId) then
				self._ccbOwner.node_tips:setVisible(true)
			else
				self._ccbOwner.node_tips:setVisible(not remote.activity:isActivityClicked(self._info))
			end
		end
	elseif self._info.type == remote.activity.TYPE_WEEKFUND then
    	local weekFund = remote.activityRounds:getWeekFund()
    	if weekFund then
			self._ccbOwner.node_tips:setVisible(weekFund:checkRedTips())
    	end
	elseif self._info.type == remote.activity.VIP_GIFT_DAILY then
		self._ccbOwner.node_tips:setVisible(remote.activityVipGift:checkDailyRedTips())
	elseif self._info.type == remote.activity.VIP_GIFT_WEEK then
		self._ccbOwner.node_tips:setVisible(remote.activityVipGift:checkWeekRedTips())
	elseif self._info.type == remote.activity.TYPE_CRYSTAL_SHOP then
		self._ccbOwner.node_tips:setVisible(remote.crystal:checkCrystalRedtips())
		if b and remote.crystal:checkCrystalRedtips() then
			self._ccbOwner.node_tips:setVisible(false)
		end
	elseif self._info.type == remote.activity.TYPE_VIP_INHERIT then
		self._ccbOwner.node_tips:setVisible(not remote.user.warmBloodVipGet) 	
	elseif self._info.type == remote.activity.TYPE_ACTIVITY_FOR_REPEATPAY and remote.activity:checkIsSixRepeatPayActivity(self._info) then
		local isClicked = remote.activity:checkIsSixRepeatPayComplete(self._info) --app:getUserOperateRecord():isActivityClicked(self._info.activityId) or 0
		self._ccbOwner.node_tips:setVisible(isClicked)	
	else
		local dataProxy = remote.activity:getDataProxyByActivityId(self._info.activityId)
		if dataProxy ~= nil and dataProxy.getBtnTips ~= nil then
			self._ccbOwner.node_tips:setVisible(dataProxy:getBtnTips(self._info))
		else
			self._ccbOwner.node_tips:setVisible(self._info.isHaveComplete or (not remote.activity:isActivityClicked(self._info)))
		end
	end
end

function QUIWidgetActivityButton:setUnlock(boo)
	self._ccbOwner.sp_unlock:setVisible(boo)
end

function QUIWidgetActivityButton:isUnlock()
	return self._ccbOwner.sp_unlock:isVisible()
end


return QUIWidgetActivityButton