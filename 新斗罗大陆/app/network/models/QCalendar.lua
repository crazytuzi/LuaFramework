-- 
-- zxs
-- 玩法日历
-- 

local QBaseModel = import("...models.QBaseModel")
local QCalendar = class("QCalendar", QBaseModel)
local QNavigationController = import("...controllers.QNavigationController")

QCalendar.SYSTEM_SETTING = "CALENDAR_SYSTEM_SETTING"	-- 保存字符串
QCalendar.SELECT_UPDATE_EVENT = "SELECT_UPDATE_EVENT"	-- 勾选事件

QCalendar.ONE_WEEK_TYPE = 1		-- 每周循环活动
QCalendar.TWO_WEEK_TYPE = 2		-- 双周循环活动

function QCalendar:ctor(options)
	QCalendar.super.ctor(self)

	self._calendarData = {} 		-- 日历数据
	self._calendarSetting = {}		-- 日历通知设置
end

function QCalendar:didappear()
end

function QCalendar:disappear()
end

function QCalendar:loginEnd()
	self:initCalendarData()
end

function QCalendar:checkCalendarInIsOpen()
	-- 等级开启
	if app.unlock:getUnlockGameCalendar() then
		return true
	end

	-- 是否开服14天内
	if not remote.activity:checkActivityIsInDays(0, 14) then
		return true
	end

	return false
end

-- 所有时间+7天
local function addSevenDay(value)
	if value.date then
		value.date = value.date + 7*DAY
	end
	for i = 1, #(value.openTimes or {}) do
		value.openTimes[i] = value.openTimes[i] + 7*DAY
		value.closeTimes[i] = value.closeTimes[i] + 7*DAY
	end
end

-- 分双周活动和每周活动
-- 双周活动是全天的，单周活动每天有个时间段
function QCalendar:initCalendarData()
	self._calendarData = {}
	local calendar = db:getGameCalendar()
	for _, value in pairs(calendar) do
		if value.type == QCalendar.ONE_WEEK_TYPE then
			local dates = string.split(value.open_time, "#")
			for i = 1, #dates do
				local times = string.split(dates[i], ";")
				value["openTime"..i] = times[1]
				value["closeTime"..i] = times[2]
			end
			table.insert(self._calendarData, value)
		else
			local times = string.split(value.open_time, ";")
			for _, v in pairs(times) do
				local time = string.split(v, "^")
				local info = clone(value)
				info.weekNum = tonumber(time[1])
				info.weekDay = tonumber(time[2])

				table.insert(self._calendarData, info)
			end
		end
	end
end

function QCalendar:getCalendarDataByIdAndDate(id, data)
	if id == nil or data == nil then return nil end

	for _, value in pairs(data) do
		if value.id == id and value.date <= q.serverTime() and q.serverTime() < value.date+DAY then
			return value
		end
	end

	return nil
end

function QCalendar:getCalendarData()
	-- 初始选择
	self._calendarSetting = {}
	local selectIds = self:getCalendarSetting()
	for i, selectId in pairs(selectIds) do
		self._calendarSetting[selectId] = {id = selectId, isSelect = true}
	end
	
	local isOdd = self:getIsOddWeek()
	local calendar = {}
	for _, value in pairs(self._calendarData) do
		local openTimes, closeTimes = self:checkCalendarTimeById(value)
		value.openTimes = openTimes 
		value.closeTimes = closeTimes
		value.date = openTimes[1]
		value.isShow, value.unlockConditionStr = self:checkCalendarIsUnlock(value)
		value.isSelect = false
		local setting = self._calendarSetting[value.id]
		if setting then
			value.isSelect = setting.isSelect
		end

		if value.type == QCalendar.TWO_WEEK_TYPE then
			-- 当前为奇数周，第二周的时间加7天
			-- 当前为偶数周，第一周的时间加7天
			-- 其他情况不变
			if isOdd and value.weekNum == 2 then
				addSevenDay(value)
			elseif not isOdd and value.weekNum == 1 then
				addSevenDay(value)
			end
		end
		value.isOpen = self:checkCalendarIsOpen(value)

		table.insert(calendar, value)
	end

	-- 每周活动多加一遍
	for _, value in pairs(self._calendarData) do
		if value.type == QCalendar.ONE_WEEK_TYPE then
			local info = clone(value)
			addSevenDay(info)
			table.insert(calendar, info)
		end
	end
	table.sort( calendar, function(a, b)
			return a.date < b.date
		end)

	return calendar
end

-- 检查是否开启
function QCalendar:checkCalendarTimeById(data)
	if data == nil then return {} end

	local calculateTime = function (weekTime, times)
		local time = q.date("*t", weekTime)
		time = q.getTimeForYMDHMS(time.year, time.month, time.day, times[1], times[2], "0")
		-- 量表只配到分，没有配秒要加上最后一分钟
		if times[2] == "59" then
			time = time + 60
		end
		return time
	end

	local openTimes = {}
	local closeTimes = {}
	local startTime = self:getCurWeekStartTime()
	local index = 1
	if data.type == QCalendar.ONE_WEEK_TYPE then 
		while data["openTime"..index] do
			local day1 = string.split(data["openTime"..index], "^")
			local day2 = string.split(data["closeTime"..index], "^")
			local curWeek1 = startTime + (tonumber(day1[1])-1)*DAY
			local curWeek2 = startTime + (tonumber(day2[1])-1)*DAY
			openTimes[index] = calculateTime(curWeek1, string.split(day1[2], ":"))
			closeTimes[index] = calculateTime(curWeek2, string.split(day2[2], ":"))
			index = index + 1
		end
	else
		openTimes[index] = startTime + (data.weekDay-1)*DAY+5*HOUR
		closeTimes[index] = startTime + data.weekDay*DAY
	end

	return openTimes, closeTimes
end

function QCalendar:checkCalendarIsOpen(data)
	if not data.openTimes then
		return false
	end

	local nowTime = q.serverTime()
	local isOpen = false
	local index = 1
	while data.openTimes[index] do
		if data.openTimes[index] <= nowTime and nowTime < data.closeTimes[index] then
			isOpen = true
		end
		index = index + 1
	end
	return isOpen
end

function QCalendar:checkCalendarRedTips()
	if self:checkCalendarInIsOpen() == false then
		return false
	end
	-- 不要小红点，先注释，防止加回来
	-- for _, value in pairs(self._calendarData) do
	-- 	if self:checkCalendarIsUnlock(value) then   -- 功能是否解锁
	-- 		if self:checkRedTip(value) then
	-- 			return true
	-- 		end
	-- 	end
	-- end

	return false
end

function QCalendar:checkCalendarIsUnlock(data)
	local unlockConditionStr = ""
	-- 双倍活动
	if data == nil then return false, "" end

	if data.type == QCalendar.TWO_WEEK_TYPE then
		-- 是否开服14天内
		if remote.activity:checkActivityIsInDays(0, 14) then
			unlockConditionStr = unlockConditionStr.."开服15天"
			-- return false
		end
	end
	local unlock = data.unlock
	if unlock then
		if not app.unlock:checkLock(unlock) then
			local unlockConfig = app.unlock:getConfigByKey(unlock)
			if unlockConfig.team_level then
				unlockConditionStr = unlockConditionStr..unlockConfig.team_level.."级开启"
			end
		end
		-- return app.unlock:checkLock(unlock)
	-- else
	-- 	return true
	end
	return true, unlockConditionStr
end

function QCalendar:checkRedTip(value)
	local openTimes, closeTimes = self:checkCalendarTimeById(value)
	local info = {}
	info.openTimes = openTimes 
	info.closeTimes = closeTimes
	if value.type == QCalendar.TWO_WEEK_TYPE then
		if isOdd and value.weekNum == 2 then
			addSevenDay(info)
		elseif not isOdd and value.weekNum == 1 then
			addSevenDay(info)
		end
	end
	return self:checkCalendarIsOpen(info)
end

function QCalendar:checkCalendarIsSelect(id, selectIds)
	for i, selectId in pairs(selectIds) do
		if selectId == id then
			return true
		end
	end
	return false
end

-- 两周循环的第一天
function QCalendar:getCurTwoWeeksStartTime()
	local nowTime = q.serverTime()
	local firstTime = "2018-10-01 00:00:00"--db:getConfiguration()["game_calendar_firsttime"].value or
	firstTime = q.getDateTimeByStandStr(firstTime)
	
	local offsetTime = (nowTime - firstTime) % (14*DAY)
	local curFirstTime = nowTime - offsetTime
	local weekDay = math.ceil(offsetTime/DAY)
	local isOdd = (weekDay <= 7)

	return curFirstTime, isOdd
end

-- 一周循环的第一天
function QCalendar:getCurWeekStartTime()
	local curFirstTime, isOdd = self:getCurTwoWeeksStartTime()
	if isOdd then
		return curFirstTime
	else
		return curFirstTime + 7*DAY
	end
end

-- 是否单数周
function QCalendar:getIsOddWeek()
	local curFirstTime, isOdd = self:getCurTwoWeeksStartTime()
	return isOdd
end

-- 获取设置通知的日历
function QCalendar:getCalendarSetting()
	local idTble = {}
	local str = app:getUserData():getUserValueForKey(QCalendar.SYSTEM_SETTING)
	if str then
		idTble = string.split(str, ";")
	else 
		local calendar = db:getGameCalendar()
		for _, value in pairs(calendar) do
			if value.type == QCalendar.ONE_WEEK_TYPE then
				table.insert(idTble, value.id)
			end
		end
	end                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
	local tbl = {}
	for i, id in pairs(idTble) do
		if id ~= "" then
			table.insert(tbl, tonumber(id))
		end
	end
	return tbl
end

-- 设置开启变化
function QCalendar:updateCalendarSetting(setting)
	self._calendarSetting[setting.id] = setting

	self:dispatchEvent({name = QCalendar.SELECT_UPDATE_EVENT, setting = setting})
end

-- 设置开启变化
function QCalendar:setCalendarSetting()
	local tbl = {}
	for i, setting in pairs(self._calendarSetting) do
		if setting.isSelect then
			table.insert(tbl, setting.id)
		end
	end
	local str = table.join(tbl, ";")
	app:getUserData():setUserValueForKey(QCalendar.SYSTEM_SETTING, str)
end

function QCalendar:getCalendarNotificationSetting()
	-- 是否开启
 	if not self:checkCalendarInIsOpen() then
		return {}
	end

	local selectIds = self:getCalendarSetting()
	local todayZeroTime = q.getTimeForHMS(0, 0, 0)
	local isOdd = self:getIsOddWeek()
	local settings = {}
	local data = self:getCalendarData()
	for i, id in pairs(selectIds) do
		local calendar = self:getCalendarDataByIdAndDate(id, data)
		if calendar then
			local openTimes = self:checkCalendarTimeById(calendar)
			local index = 1
			while (openTimes[index]) do
				-- 开始时间在今天
				local time = openTimes[index]
				if calendar.type == QCalendar.TWO_WEEK_TYPE then
					if isOdd and calendar.weekNum == 2 then
						time = time + 7*DAY
					elseif not isOdd and calendar.weekNum == 1 then
						time = time + 7*DAY
					end
				end
				if todayZeroTime <= time and time <= todayZeroTime + DAY then
					local date = q.date("*t", time)
					-- 全天的通知设置到早上9点
					if calendar.type == QCalendar.TWO_WEEK_TYPE then
						date.hour = 9
					end
					local info = {}
					info.id = calendar.id
					info.index = index		-- 可能有多个时间段
					info.date = date
					info.push = calendar.push or "通知"
					table.insert(settings, info)
				end
				index = index + 1
				-- 暂时只用第一个时间段
				break
			end
		end
	end
	return settings
end

-- 活动翻倍信息
function QCalendar:getCalendarStartTime(params)
	local tbl = string.split(params, ",")
	local startTime = self:getCurTwoWeeksStartTime()
	local date = startTime + (tonumber(tbl[3])-1)*DAY
	if tonumber(tbl[2]) == 2 then
		date = date + 7*DAY
	end

	local startTime = date
	if tbl[4] then
		startTime = startTime + tonumber(tbl[4]) * HOUR
	end
	local endTime = date + (DAY-1)
	if tbl[5] then
		endTime = endTime + tonumber(tbl[5]) * HOUR
	end

	return startTime * 1000, endTime * 1000
end

function QCalendar:setIsSetting(isSetting)
	self._isSetting = isSetting
	self:dispatchEvent({name = QCalendar.SELECT_UPDATE_EVENT})
end

function QCalendar:getIsSetting()
	return self._isSetting
end

return QCalendar