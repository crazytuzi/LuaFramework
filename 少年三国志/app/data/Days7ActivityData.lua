--Days7ActivityData.lua

require("app.cfg.days7_activity_info")
require("app.cfg.days7_sell_info")

local Days7ActivityData = class("Days7ActivityData")

Days7ActivityData.ACTIVITY_STATUS = {
	CLOSED = 0,
	OPEN = 1, 
	OVER = 2,
}

function Days7ActivityData:ctor( ... )
	self._curDayIndex = 0
	self._curStatus = 0
	self._overTime = 0

	self._activityContent = {}
	self._activitySellInfo = {}

	self._activityAward = {}

	self._hasDataInit = false
end

function Days7ActivityData:hasDataInit( ... )
	return self._hasDataInit
end

function Days7ActivityData:isOpen( ... )
	return self._curStatus > 0
end

function Days7ActivityData:isOnActivity( ... )
	return self._curStatus == Days7ActivityData.ACTIVITY_STATUS.OPEN
end

function Days7ActivityData:overTime( ... )
	return self._overTime
end

function Days7ActivityData:isActivityOverTime( ... )
	return self._curStatus == Days7ActivityData.ACTIVITY_STATUS.OVER
end

function Days7ActivityData:updateActivityData( bufferData )
	if type(bufferData) ~= "table" then 
		return 
	end

	if bufferData.status then
		self._curStatus = bufferData.status
	end
	if bufferData.current_day then 
		self._curDayIndex = bufferData.current_day or 100
	end

	if bufferData.end_time then 
		self._overTime = bufferData.end_time
	end

	local activityData = bufferData.days_activity or bufferData.activitys 
	self:flushActivityData(activityData)

	self._hasDataInit = true
end

function Days7ActivityData:flushActivityData( bufferData )
	if bufferData then
		for key, value in pairs(bufferData) do 
			self._activityContent[value.id] = value
		end

		self:_checkActivityAward()
	end
end

function Days7ActivityData:updateActivitySellInfo( bufferData )
	if type(bufferData) ~= "table" then 
		return 
	end

	if bufferData.sells then
		for key, value in pairs(bufferData.sells) do 
			if value.id then 
				self._activitySellInfo[value.id] = value
			end
		end
	end
end

function Days7ActivityData:updateSellInfo( sellInfo )
	if type(sellInfo) == "table" then 
		if sellInfo.id then 
			self._activitySellInfo[sellInfo.id] = sellInfo.sell
		end
	end
end

function Days7ActivityData:getActivityInfoById( activityId )
	if type(activityId) ~= "number" then 
		return {}
	end

	return self._activityContent[activityId] 
end

function Days7ActivityData:getActivitySellInfoByIndex( dayIndex )
	if type(dayIndex) ~= "number" then 
		return {}
	end

	return self._activitySellInfo[dayIndex] 
end

function Days7ActivityData:_checkActivityAward( ... )
	local activityIds = {}
	for key, value in pairs(self._activityContent) do 
		if value.status == Days7ActivityData.ACTIVITY_STATUS.OPEN then 
			table.insert(activityIds, #activityIds + 1, key)
		end
	end

	self._activityAward = {}

	local _addActivityAward = function ( dayIndex, activityId, tagId )
		if type(dayIndex) ~= "number" or 
			type(activityId) ~= "number" or 
			type(tagId) ~= "number" or dayIndex < 1 or dayIndex > 7 then 
			return 
		end

		local dayActivity = self._activityAward[dayIndex] or {}
		local dayTabActivity = dayActivity[tagId] or {}
		table.insert(dayTabActivity, #dayTabActivity + 1, activityId)
		dayActivity[tagId] = dayTabActivity
		self._activityAward[dayIndex] = dayActivity
	end

	for key, value in pairs(activityIds) do 
		local activityInfo = days7_activity_info.get(value)
		if activityInfo and activityInfo.limit_time_client <= self._curDayIndex then 
			_addActivityAward(activityInfo.limit_time_client, value, activityInfo.tags)
		end
	end
end

function Days7ActivityData:hasAwardActivity( ... )
	if self._curDayIndex > 0 then 
		local maxDay = self._curDayIndex
		if self._curDayIndex > 7 then 
			maxDay = 7
		end
		for loopi = 1, self._curDayIndex do 
			if self._activityAward[loopi] then 
				return true
			end

			if self:canBuySellInfoByDay(loopi) then 
				return true
			end
		end
	end

	return false
end

function Days7ActivityData:hasAwardActivityByDay( dayIndex )
	if type(dayIndex) ~= "number" then 
		return false
	end

	local dayActivity = self._activityAward[dayIndex]
	if not dayActivity then 
		return self:canBuySellInfoByDay(dayIndex)
	end

	return dayActivity and true or false
end

function Days7ActivityData:hasAwardActivityByTag( dayIndex, tagId )
	if type(dayIndex) ~= "number" or type(tagId) ~= "number" then 
		return false
	end

	local dayActivity = self._activityAward[dayIndex]

	if not dayActivity then 
		return false
	end

	local tagActivity = dayActivity[tagId]
	return tagActivity and true or false
end

function Days7ActivityData:canBuySellInfoByDay( dayIndex )
	if type(dayIndex) ~= "number" or dayIndex < 1 or dayIndex > 7 then 
		return false
	end

	local curSellInfo = self:getActivitySellInfoByIndex(dayIndex)
	if curSellInfo then 
		return (not curSellInfo.bought) and (curSellInfo.num > 0)
	end

	return false
end

return Days7ActivityData
