
local QActivityRoundsBaseChild = class("QActivityRoundsBaseChild", QBaseModel)

function QActivityRoundsBaseChild:ctor( activityType )
	-- body
	self._type = activityType
	self.isOpen = false
	self.isActivityNotEnd = false
end

function QActivityRoundsBaseChild:removeSelf( ... )
	-- body
	remote.activityRounds[self._type] = nil
end

function QActivityRoundsBaseChild:timeRefresh( event )
	-- body
	
end

function QActivityRoundsBaseChild:activityShowEndCallBack(  )
	-- body
end


function QActivityRoundsBaseChild:activityEndCallBack(  )
	-- body
end

function QActivityRoundsBaseChild:handleOnLine( )
	-- body
end

function QActivityRoundsBaseChild:handleOffLine( )
	-- body
end



function QActivityRoundsBaseChild:getActivityInfoWhenLogin( success, fail )
	-- body
	if success then
		success()
	end
end

function QActivityRoundsBaseChild:setActivityInfo( data )
	if not data or not data.rowNum  then
		return 
	end
	-- 是否开服14天内
	if remote.activity:checkActivityIsInDays(0, 14) and data.luckyType ~= remote.activityRounds.LuckyType.SKY_FALL_REWARD --天降福袋活动可以在开服14天内
		and data.luckyType ~= remote.activityRounds.LuckyType.PRIZE_WHEEL_ACTIVITY 
		and data.luckyType ~= remote.activityRounds.LuckyType.NEW_SERVER_RECHARGE 
		then --活跃转盘活动可以在开服14天内
		return
	end

	self.rowNum = data.rowNum
	self.activityId = data.luckyDrawId
	self.startAt = math.floor(data.startAt/1000)
	self.endAt = math.floor(data.endAt/1000)
	self.showEndAt = math.floor(data.showEndAt/1000)
	if self.endAt > self.showEndAt then
		self.showEndAt = self.endAt
	end
	local curTime = q.serverTime()
	local timeEndStr = string.format("%sEnd", data.luckyType or "")
	local timeShowEndStr = string.format("%sShowEnd", data.luckyType or "")
	app:getAlarmClock():deleteAlarmClock(timeEndStr)
	app:getAlarmClock():deleteAlarmClock(timeShowEndStr)

	if data.luckyType == remote.activityRounds.LuckyType.NEW_WEEK_FUND then --新服基金根据策划需求，超过购买截止时间就活动消失（前端屏蔽）
		local newWeekFound = remote.activityRounds:getNewServiceFund()
		local userInfo = newWeekFound:getUserWeekFundInfo() or {}
		local buyDayNum = newWeekFound:getActiveDayNum()
		local buyEndAt = self.startAt + DAY * buyDayNum 
		if userInfo and userInfo.status == false and buyEndAt <  curTime then
			return
		end
	end
	if self.showEndAt < curTime or self.startAt > curTime then
		print("self.isOpen = false")
		self.isOpen = false
		self.isActivityNotEnd = false
	elseif self.endAt > curTime then
		self.isOpen = true
		self.isActivityNotEnd = true

		if self.endAt == self.showEndAt then
			app:getAlarmClock():createNewAlarmClock(timeShowEndStr, self.endAt, function (  )
				-- body
				self.isActivityNotEnd = false
				self.isOpen = false
				self:activityShowEndCallBack()
			end)
		else
			app:getAlarmClock():createNewAlarmClock(timeEndStr, self.endAt, function (  )
				-- body
				self.isActivityNotEnd = false
				self:activityEndCallBack()
			end)

			app:getAlarmClock():createNewAlarmClock(timeShowEndStr, self.showEndAt, function (  )
			-- body
				self.isOpen = false
				self:activityShowEndCallBack()
			end)
		end	
	else
		self.isOpen = true
		self.isActivityNotEnd = false
		app:getAlarmClock():createNewAlarmClock(timeShowEndStr, self.showEndAt, function (  )
			-- body
			self.isOpen = false
			self:activityShowEndCallBack()
		end)
	end
end

return QActivityRoundsBaseChild