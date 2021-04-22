--[[	
	文件名称：QActivityMonthFund.lua
	创建时间：2017-01-18 11:10:46
	作者：nieming
	描述：基金返利活动
]]
local QBaseModel = import("..models.QBaseModel")
local QActivityMonthFund = class("QActivityMonthFund",QBaseModel)
local QActivity = import(".QActivity")

QActivityMonthFund.STATUS_CHANGE = "STATUS_CHANGE"
QActivityMonthFund.TYPE_1 = "a_monthfund"  -- 288
QActivityMonthFund.TYPE_2 = "a_monthfund2" -- 128


function QActivityMonthFund:ctor(options) 
	self._itemData = {}
	self._open = false
	self._awardOpen = false
	self._open128 = false
	self._awardOpen128 = false
	self.startTime = 0
	self.awardStartTime = 0
	self.endTime = 0
	self._userMonthFundInfo = {}
	self._awardTaken = {}
	self._awardTaken[QActivityMonthFund.TYPE_1] = {}
	self._awardTaken[QActivityMonthFund.TYPE_2] = {}

end

function QActivityMonthFund:didappear()
   	self._userEventProxy = cc.EventProxy.new(remote.user)
    self._userEventProxy:addEventListener(remote.user.EVENT_TIME_REFRESH, handler(self, self.timeRefreshHandler))
end

function QActivityMonthFund:disappear()
	if self._userEventProxy then
		self._userEventProxy:removeAllEventListeners()
		self._userEventProxy = nil
	end
	if self._scheduler then
		scheduler.unscheduleGlobal(self._scheduler)
        self._scheduler = nil
	end
end

function QActivityMonthFund:timeRefreshHandler( event )
	if event and event.time == 0 then
		if (self._open and self._awardOpen) or (self._open128 and self._awardOpen128) then
			self._userMonthFundInfo.login_days = self._userMonthFundInfo.login_days + 1
		end
		self._scheduler = scheduler.performWithDelayGlobal(function()
				self:setActivityOpen(self._open, self._awardOpen, QActivityMonthFund.TYPE_1)
				self:setActivityOpen(self._open128, self._awardOpen128, QActivityMonthFund.TYPE_2)
				if self._scheduler then
					scheduler.unscheduleGlobal(self._scheduler)
			        self._scheduler = nil
				end
			end, 1)
	end
end

function QActivityMonthFund:loginEnd( )
	self:getActivityInfo()
end

function QActivityMonthFund:getAwardsList(activityId)
	return self._itemData[activityId]
end

function QActivityMonthFund:getUserMonthFundInfo()
	return self._userMonthFundInfo
end

function QActivityMonthFund:getMonthFundInfo()
	return self._monthFundInfo
end

function QActivityMonthFund:getMonthFundStatus(activityId)
	if (self._userMonthFundInfo.status and activityId == QActivityMonthFund.TYPE_1) or 
		(self._userMonthFundInfo.status128 and activityId == QActivityMonthFund.TYPE_2) then
    	return 0
    end

    local isActiveMonthCard = remote.activity:checkMonthCardActive()
    if not isActiveMonthCard then
    	return 1
    end

    if (not self._userMonthFundInfo.hasRechargedMoreThan288 and activityId == QActivityMonthFund.TYPE_1) or
    	(not self._userMonthFundInfo.hasRechargedMoreThan128 and activityId == QActivityMonthFund.TYPE_2) then
    	return 2
    end

    return 0
end


function QActivityMonthFund:updateMonthFundStatus( value )
	local isActiveMonthCard = remote.activity:checkMonthCardActive()
	if self._open and not self._awardOpen then
		if value == 268 or value == 418 or value == 648 then
			if not self._userMonthFundInfo.hasRechargedMoreThan288 then		
				if isActiveMonthCard then
					self._userMonthFundInfo.status = true
				end
				self._userMonthFundInfo.hasRechargedMoreThan288 = true
				self:setActivityOpen(self._open, self._awardOpen, QActivityMonthFund.TYPE_1)	
			end
	    elseif value == 25 then
	    	local remainingDays2 = (remote.recharge.monthCard2EndTime/1000 - q.refreshTime(remote.user.c_systemRefreshTime))/(3600 * 24)
	    	if remainingDays2 > 0 and self._userMonthFundInfo.hasRechargedMoreThan288 then
	    		self._userMonthFundInfo.status = true
	    		self:setActivityOpen(self._open, self._awardOpen, QActivityMonthFund.TYPE_1)
	    	end	    
	    elseif value == 60 then	
			local remainingDays1 = (remote.recharge.monthCard1EndTime/1000 - q.refreshTime(remote.user.c_systemRefreshTime))/(3600 * 24)
	    	if remainingDays1 > 0 and self._userMonthFundInfo.hasRechargedMoreThan288 then
	    		self._userMonthFundInfo.status = true
	    		self:setActivityOpen(self._open, self._awardOpen, QActivityMonthFund.TYPE_1)
	    	end
	    end
	end

	if self._open128 and not self._awardOpen128 then
		if value == 168 or value == 418 or value == 648 then
			if not self._userMonthFundInfo.hasRechargedMoreThan128 then		
				if isActiveMonthCard then
					self._userMonthFundInfo.status128 = true
				end
				self._userMonthFundInfo.hasRechargedMoreThan128 = true
				self:setActivityOpen(self._open128, self._awardOpen128, QActivityMonthFund.TYPE_2)	
			end
	    elseif value == 25 then
	    	local remainingDays2 = (remote.recharge.monthCard2EndTime/1000 - q.refreshTime(remote.user.c_systemRefreshTime))/(3600 * 24)
	    	if remainingDays2 > 0 and self._userMonthFundInfo.hasRechargedMoreThan128 then
	    		self._userMonthFundInfo.status128 = true
	    		self:setActivityOpen(self._open128, self._awardOpen128, QActivityMonthFund.TYPE_2)
	    	end	    
	    elseif value == 60 then	
			local remainingDays1 = (remote.recharge.monthCard1EndTime/1000 - q.refreshTime(remote.user.c_systemRefreshTime))/(3600 * 24)
	    	if remainingDays1 > 0 and self._userMonthFundInfo.hasRechargedMoreThan128 then
	    		self._userMonthFundInfo.status128 = true
	    		self:setActivityOpen(self._open128, self._awardOpen128, QActivityMonthFund.TYPE_2)
	    	end
	    end
	end
end

function QActivityMonthFund:isTakenAward( activityId, awardsIndex )
	return self._awardTaken[activityId][awardsIndex]
end

function QActivityMonthFund:isMonthFundOpen(activityId)
	if activityId == QActivityMonthFund.TYPE_1 then
		return (self._open and not self._awardOpen)
	elseif activityId == QActivityMonthFund.TYPE_2 then
		return (self._open128 and not self._awardOpen128)
	end
end

function QActivityMonthFund:isFundAwardOpen(activityId)
	if activityId == QActivityMonthFund.TYPE_1 then
		return (self._open and self._awardOpen)
	elseif activityId == QActivityMonthFund.TYPE_2 then
		return (self._open128 and self._awardOpen128)
	end
end


function QActivityMonthFund:getLoginDays(  )
	return self._userMonthFundInfo.login_days or 1
end

function QActivityMonthFund:setActivityOpenAll(tureOrFalse,  tureOrFalse2)
	self:setActivityOpen(tureOrFalse, tureOrFalse2, QActivityMonthFund.TYPE_1)
	self:setActivityOpen(tureOrFalse, tureOrFalse2, QActivityMonthFund.TYPE_2)
end

function QActivityMonthFund:setActivityOpen( tureOrFalse, tureOrFalse2, activityId )
	local isCanOpen = tureOrFalse
	local isin14Day = remote.activity:checkActivityIsInDays(0, 14)
	if isin14Day then
		-- 月基金活动在开服14天内默认不显示（注意！）
		isCanOpen = false	
	end

	local titleName
	if activityId == QActivityMonthFund.TYPE_1 then
		self._open = tureOrFalse
		self._awardOpen = tureOrFalse2
		titleName = "268月基金"
	elseif activityId == QActivityMonthFund.TYPE_2 then
		self._open128 = tureOrFalse
		self._awardOpen128 = tureOrFalse2
		titleName = "168月基金"
	end
	if isCanOpen then
		local activities = {}
		table.insert(activities, {type = QActivity.TYPE_MONTHFUND, activityId = activityId, title = titleName or "月基金", weight = 7.9, targets = {}})
		remote.activity:setData(activities)
	else
		remote.activity:removeActivity(activityId)
		remote.activity:refreshActivity(true)
	end
end

function QActivityMonthFund:checkRedTips(activityId)
	local isOpen = false
	if activityId == QActivityMonthFund.TYPE_1 then
		isOpen = self._open
	elseif activityId == QActivityMonthFund.TYPE_2 then
		isOpen = self._open128
	end
	local awardOpen = false
	if activityId == QActivityMonthFund.TYPE_1 then
		awardOpen = self._awardOpen
	elseif activityId == QActivityMonthFund.TYPE_2 then
		awardOpen = self._awardOpen128
	end
	if isOpen then
		if awardOpen then
			if activityId == QActivityMonthFund.TYPE_1 and self._userMonthFundInfo.status == false then
				return false
			end
			if activityId == QActivityMonthFund.TYPE_2 and self._userMonthFundInfo.status128 == false then
				return false
			end
			for k, v in pairs(self._itemData[activityId]) do
				if self._userMonthFundInfo.login_days >= v.awardIndex then
					if not self:isTakenAward(activityId, v.awardIndex) then
						return true
					end
				else
					return false
				end
			end
		else
			if self:getMonthFundStatus(activityId) == 0 then
				return false
			elseif self:getMonthFundStatus(activityId) == 1 then
				if app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.MONTH_FUND) then
					return true
				else
					return false
				end
			else
				return true
			end
		end
	end

	return false
end


function QActivityMonthFund:getRedTipsType(activityId)
	local isOpen = false
	if activityId == QActivityMonthFund.TYPE_1 then
		isOpen = self._open
	elseif activityId == QActivityMonthFund.TYPE_2 then
		isOpen = self._open128
	end
	local awardOpen = false
	if activityId == QActivityMonthFund.TYPE_1 then
		awardOpen = self._awardOpen
	elseif activityId == QActivityMonthFund.TYPE_2 then
		awardOpen = self._awardOpen128
	end
	if isOpen then
		if awardOpen and q.isEmpty(self._itemData) == nil then
			for k, v in pairs(self._itemData[activityId]) do
				if self._userMonthFundInfo.login_days >= v.awardIndex then
					if not self:isTakenAward(activityId, v.awardIndex) then
						return 3
					end
				else
					return 0
				end
			end
		else
			if self:getMonthFundStatus(activityId) == 0 then
				return 0
			elseif self:getMonthFundStatus(activityId) == 1 then
				if app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.MONTH_FUND) then
					return 1
				else
					return 0
				end
			else
				return 1
			end
		end
	end

	return 0
end


function QActivityMonthFund:updateMonthFundDataInfo( monthFundInfo,  userMonthFundInfo)
	if monthFundInfo then
		local time = q.serverTime() 
		local startTime = monthFundInfo.startAt/1000
		local awardStartTime = monthFundInfo.awardStartAt/1000
		local endTime = monthFundInfo.endAt/1000
		local buyTime = awardStartTime
		if userMonthFundInfo and userMonthFundInfo.buy_at and userMonthFundInfo.buy_at > 0 and userMonthFundInfo.buy_at ~= FOUNDER_TIME then
			buyTime = userMonthFundInfo.buy_at/1000
		end
		self.startTime = startTime
		self.buyTime = buyTime
		self.awardStartTime = awardStartTime
		self.endTime = endTime

		app:getAlarmClock():deleteAlarmClock("startYuejijin")
		app:getAlarmClock():deleteAlarmClock("startJijinFanLi")
		app:getAlarmClock():deleteAlarmClock("endActivity")
		if time < startTime then
			self:setActivityOpenAll(false, false)
			app:getAlarmClock():createNewAlarmClock("startYuejijin", self.startTime, function (  )
				self:setActivityOpenAll(true, false)
				app:getAlarmClock():createNewAlarmClock("startJijinFanLi", self.awardStartTime, function (  )
					if userMonthFundInfo and userMonthFundInfo.status then
						self:setActivityOpen(true, true, QActivityMonthFund.TYPE_1)
						app:getAlarmClock():createNewAlarmClock("endActivity", self.endTime, function (  )
							self:setActivityOpen(false, false, QActivityMonthFund.TYPE_1)
						end)
					else
						self:setActivityOpen(false, false, QActivityMonthFund.TYPE_1)
					end

					if userMonthFundInfo and userMonthFundInfo.status128 then
						self:setActivityOpen(true, true, QActivityMonthFund.TYPE_2)
						app:getAlarmClock():createNewAlarmClock("endActivity128", self.endTime, function (  )
							self:setActivityOpen(false, false, QActivityMonthFund.TYPE_2)
						end)
					else
						self:setActivityOpen(false, false, QActivityMonthFund.TYPE_2)
					end
				end)
			end)
		elseif time < buyTime then
			self:setActivityOpenAll(true, false)
			app:getAlarmClock():createNewAlarmClock("startJijinFanLi", self.buyTime, function (  )
				if userMonthFundInfo and userMonthFundInfo.status then
					self:setActivityOpen(true, true, QActivityMonthFund.TYPE_1)
					app:getAlarmClock():createNewAlarmClock("endActivity", self.endTime, function (  )
						self:setActivityOpen(false, false, QActivityMonthFund.TYPE_1)
					end)
				else
					self:setActivityOpen(false, false, QActivityMonthFund.TYPE_1)
				end
				if userMonthFundInfo and userMonthFundInfo.status128 then
					self:setActivityOpen(true, true, QActivityMonthFund.TYPE_2)
					app:getAlarmClock():createNewAlarmClock("endActivity128", self.endTime, function (  )
						self:setActivityOpen(false, false, QActivityMonthFund.TYPE_2)
					end)
				else
					self:setActivityOpen(false, false, QActivityMonthFund.TYPE_2)
				end
			end)
		elseif time < awardStartTime then
			self:setActivityOpenAll(true, false)
			local isNeedAlarmClock = false
			if userMonthFundInfo and userMonthFundInfo.status then
				self:setActivityOpen(true, true, QActivityMonthFund.TYPE_1)
				app:getAlarmClock():createNewAlarmClock("endActivity", self.endTime, function (  )
					self:setActivityOpen(false, false, QActivityMonthFund.TYPE_1)
				end) 
			else
				isNeedAlarmClock = true
			end
			if userMonthFundInfo and userMonthFundInfo.status128 then
				self:setActivityOpen(true, true, QActivityMonthFund.TYPE_2)
				app:getAlarmClock():createNewAlarmClock("endActivity128", self.endTime, function (  )
					self:setActivityOpen(false, false, QActivityMonthFund.TYPE_2)
				end)
			else
				isNeedAlarmClock = true
			end

			if isNeedAlarmClock then
				app:getAlarmClock():createNewAlarmClock("startJijinFanLi", self.awardStartTime, function (  )
					if userMonthFundInfo and userMonthFundInfo.status then
						self:setActivityOpen(true, true, QActivityMonthFund.TYPE_1)
						app:getAlarmClock():createNewAlarmClock("endActivity", self.endTime, function (  )
							self:setActivityOpen(false, false, QActivityMonthFund.TYPE_1)
						end)
					else
						self:setActivityOpen(false, false, QActivityMonthFund.TYPE_1)
					end
					if userMonthFundInfo and userMonthFundInfo.status128 then
						self:setActivityOpen(true, true, QActivityMonthFund.TYPE_2)
						app:getAlarmClock():createNewAlarmClock("endActivity128", self.endTime, function (  )
							self:setActivityOpen(false, false, QActivityMonthFund.TYPE_2)
						end)
					else
						self:setActivityOpen(false, false, QActivityMonthFund.TYPE_2)
					end
				end)
			end
		elseif time < endTime then
			self:setActivityOpenAll(true, true)
			if userMonthFundInfo and userMonthFundInfo.status then
				self:setActivityOpen(true, true, QActivityMonthFund.TYPE_1)
				app:getAlarmClock():createNewAlarmClock("endActivity", self.endTime, function (  )
					self:setActivityOpen(false, false, QActivityMonthFund.TYPE_1)
				end) 
			else
				self:setActivityOpen(false, false, QActivityMonthFund.TYPE_1)
			end
			if userMonthFundInfo and userMonthFundInfo.status128 then
				self:setActivityOpen(true, true, QActivityMonthFund.TYPE_2)
				app:getAlarmClock():createNewAlarmClock("endActivity128", self.endTime, function (  )
					self:setActivityOpen(false, false, QActivityMonthFund.TYPE_2)
				end)
			else
				self:setActivityOpen(false, false, QActivityMonthFund.TYPE_2)
			end
		end
		self._itemData = {}
		self._itemData[QActivityMonthFund.TYPE_1] = monthFundInfo.monthFundAwardList or {}
		self._itemData[QActivityMonthFund.TYPE_2] = monthFundInfo.monthFund128AwardList or {}
		table.sort(self._itemData[QActivityMonthFund.TYPE_1], function (item1, item2)
			return item1.awardIndex < item2.awardIndex
		end)
		table.sort(self._itemData[QActivityMonthFund.TYPE_2], function (item1, item2)
			return item1.awardIndex < item2.awardIndex
		end)

		self._awardTaken = {}
		self._awardTaken[QActivityMonthFund.TYPE_1] = {}
		self._awardTaken[QActivityMonthFund.TYPE_2] = {}
		if userMonthFundInfo and userMonthFundInfo.award_taken_info then
			local awardTaken = string.split(userMonthFundInfo.award_taken_info or "", ";")
			for k, v in pairs(awardTaken) do
				local awardIndex = tonumber(v)
				if awardIndex then
					self._awardTaken[QActivityMonthFund.TYPE_1][awardIndex] = true
				end
			end
		end
		if userMonthFundInfo and userMonthFundInfo.award128_taken_info then
			local awardTaken = string.split(userMonthFundInfo.award128_taken_info or "", ";")
			for k, v in pairs(awardTaken) do
				local awardIndex = tonumber(v)
				if awardIndex then
					self._awardTaken[QActivityMonthFund.TYPE_2][awardIndex] = true
				end
			end
		end
	end
	self._userMonthFundInfo = userMonthFundInfo or self._userMonthFundInfo
	self._monthFundInfo = monthFundInfo or self._monthFundInfo
end

function QActivityMonthFund:getActivityInfo( success, fail )
	local request = {api = "MONTH_FUND_GET_INFO"}
	local successCallBack = function ( data )
		if data.monthFundGetInfoResponse then
			self:updateMonthFundDataInfo(data.monthFundGetInfoResponse.monthFundInfo, data.monthFundGetInfoResponse.userMonthFundInfo)
		end
		if success then
			success()
		end
	end

    app:getClient():requestPackageHandler("MONTH_FUND_GET_INFO", request, successCallBack, fail)
end

function QActivityMonthFund:getAwards( awardIndex, activityId, success, fail )
	local request = {api = "MONTH_FUND_GET_AWARD", monthFundGetAwardRequest = {awardIndex = awardIndex, is128MonthFund = (activityId == QActivityMonthFund.TYPE_2)}}

	local successCallBack = function ( data )
		self._awardTaken[activityId][awardIndex] = true
		local isOpen = false
		if activityId == QActivityMonthFund.TYPE_1 then
			isOpen = self._open
		elseif activityId == QActivityMonthFund.TYPE_2 then
			isOpen = self._open128
		end
		local awardOpen = false
		if activityId == QActivityMonthFund.TYPE_1 then
			awardOpen = self._awardOpen
		elseif activityId == QActivityMonthFund.TYPE_2 then
			awardOpen = self._awardOpen128
		end
		self:setActivityOpen(isOpen, awardOpen, activityId)

		if success then
			success()
		end
	end
    app:getClient():requestPackageHandler("MONTH_FUND_GET_AWARD", request, successCallBack, fail)
end

return QActivityMonthFund