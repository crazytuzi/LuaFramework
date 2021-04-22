-- @Author: xurui
-- @Date:   2019-01-22 11:24:26
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-11-26 10:53:15
local QActivityCarnival = class("QActivityCarnival")
local QStaticDatabase = import("..controllers.QStaticDatabase")

QActivityCarnival.UPDATE_CARNIVAL_ACTIVITY = "UPDATE_CARNIVAL_ACTIVITY"

function QActivityCarnival:ctor( activityType )
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
	-- body
	self._activityInfoDict = {}						--兑换活动
	self._dayActivityInfoList = {}             		--根据天数存放活动列表
	self._activityDayNum = nil
end

function QActivityCarnival:init()
    self._activityProxy = cc.EventProxy.new(remote.activity)
    self._activityProxy:addEventListener(remote.activity.EVENT_CHANGE, handler(self, self.updateActivityInfo))
    self._activityProxy:addEventListener(remote.activity.EVENT_COMPLETE_UPDATE, handler(self, self.updateActivityInfo))
end

function QActivityCarnival:loginEnd(success)
	if success then
		success()
	end
end

function QActivityCarnival:updateActivityInfo()
	local tbl = {}
	tbl[remote.activity.TYPE_ACTIVITY_FOR_CARNIVAL_EXCHANGE] = 1
	self._activityInfoDict = (remote.activity:getActivityData(tbl) or {})[1] or {}

	tbl = {}
	tbl[remote.activity.TYPE_ACTIVITY_FOR_CARNIVAL] = 1
	local activityInfoList = remote.activity:getActivityData(tbl)
	self._dayActivityInfoList = {}
	if q.isEmpty(activityInfoList) == false then
		for _, value in ipairs(activityInfoList) do
			local day, num
			if value.params then
				local data = string.split(value.params, ",")
				day = tonumber(data[1])
				num = tonumber(data[2])
			end
			if day then
				if self._dayActivityInfoList[day] == nil then
					self._dayActivityInfoList[day] = {}
				end
				if num then
					self._dayActivityInfoList[day][num] = value
				else
					table.insert(self._dayActivityInfoList[day], value)
				end
			end
		end
	end

	self:dispatchEvent({name = QActivityCarnival.UPDATE_CARNIVAL_ACTIVITY})
end

function QActivityCarnival:disappear()
	if self._activityProxy then
		self._activityProxy:removeAllEventListeners()
		self._activityProxy = nil
	end
end

function QActivityCarnival:getActivityInfo()
	return self._activityInfoDict
end

function QActivityCarnival:getCarnivalActivityDayList()
	return self._dayActivityInfoList
end

function QActivityCarnival:getCurrentDayNum()
	local curTime = q.serverTime()
	local startTime = (self._activityInfoDict.start_at or 0)/1000

	local dayNum = math.ceil((curTime - startTime) / DAY)
	return dayNum
end

function QActivityCarnival:checkActivityIsAvailable()
	if q.isEmpty(self._activityInfoDict) then return false end

	local curTime = q.serverTime()
	local startTime = (self._activityInfoDict.start_at or 0)/1000
	local awardEndTime = (self._activityInfoDict.award_end_at or 0)/1000

	if curTime >= startTime and curTime < awardEndTime then
		return true
	end

	return false
end

function QActivityCarnival:checkActivityIsAwardTime()
	if q.isEmpty(self._activityInfoDict) then return false end

	local dayNum = #self._dayActivityInfoList
	local curTime = q.serverTime()
	local endTime = (self._activityInfoDict.end_at or 0) / 1000
	local awardEndTime = (self._activityInfoDict.award_end_at or 0) / 1000

	if endTime < curTime and curTime <= awardEndTime then
		return true, awardEndTime
	end

	return false
end

function QActivityCarnival:checkCarnivalActivityTips()
	local tip = false
	if q.isEmpty(self._dayActivityInfoList) == false then
		local allDay = #self._dayActivityInfoList
		for i = 1, allDay do
			tip = self:checkDayCarnivalActivityTipByDay(i)
			if tip then
				break
			end
		end
	end

	--积分兑换活动
	if q.isEmpty(self._activityInfoDict) == false then
		local targets = self._activityInfoDict.targets or {}
		for _, value in ipairs(targets) do
			if value.completeNum == 2 then
				tip = true
				break
			end
		end
	end

	return tip
end

function QActivityCarnival:checkDayCarnivalActivityTipByDay(dayNum)
	if dayNum == nil or self._dayActivityInfoList[dayNum] == nil then return false end

	local tip = false
	local dayActivityNum = #self._dayActivityInfoList[dayNum]
	for i = 1, dayActivityNum do
		tip = self:checkSubCarnivalActivityTipByIndex(dayNum, i)
		if tip then
			break
		end
	end

	return tip
end

function QActivityCarnival:checkSubCarnivalActivityTipByIndex(dayNum, index)
	if dayNum == nil or index == nil or self._dayActivityInfoList[dayNum] == nil then return false end

	local tip = false
	local curDayNum = self:getCurrentDayNum()
	if curDayNum >= dayNum then
		local activityInfo = self._dayActivityInfoList[dayNum][index] or {}
		local targets = activityInfo.targets or {}
		for _, value in ipairs(targets) do
			if value.completeNum == 2 then
				if remote.activity:isExchangeActivity(value.type) then
					tip = remote.activity:checkActivityTipEveryDay(activityInfo)
					if tip then
						break
					end
				else
					tip = true
					break
				end
			end	
		end
	end

	return tip
end

return QActivityCarnival