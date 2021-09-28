require "ui.activity.activitydlg"
require "ui.activity.activitycell"
require "ui.activity.activityentrance"
ActivityManager = {}
ActivityManager.__index = ActivityManager

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function ActivityManager.getInstance()
	LogInfo("enter get activitymanager instance")
    if not _instance then
        _instance = ActivityManager:new()
    end
    
    return _instance
end

function ActivityManager.getInstanceNotCreate()
    return _instance
end

function ActivityManager.Destroy()
	if _instance then 
		LogInfo("destroy activitymanager")
		GetDataManager().EventActivityChange:RemoveScriptFunctor(_instance.m_hActivityChange)
		_instance = nil
	end
end

function ActivityManager.ActivityChange()
	LogInfo("activitymanager activity change")
	if _instance then
		_instance.m_iActivityNum = GetDataManager():GetMainCharacterData():GetValue(knight.gsp.attr.AttrType.ACTIVENESS)
		if ActivityDlg.getInstanceNotCreate() then
			ActivityDlg.getInstanceNotCreate():refreshTotalActivity()	
		end
		ActivityEntrance.refreshEffect()
	end
end

function ActivityManager.refreshGiftBox()
	LogInfo("activitymanager refreshgiftbox")
	if _instance then
		_instance.m_iActivityChest = 2 
		if ActivityDlg.getInstanceNotCreate() then
			ActivityDlg.getInstanceNotCreate():refreshGiftBoxBtnState()	
		end
		ActivityEntrance.refreshEffect()
	end
end

function ActivityManager.openActivity(id)
	LogInfo("activitymanager open activity")
	if _instance then
		if _instance:isOpened(id) then
			ActivityEntrance.refreshEffect()
		end
	end
end

function ActivityManager.reqOfflineExp()
	require "protocoldef.knight.gsp.buff.creqofflinehook"
	local req = CReqOffLineHook.Create()
	req.flag = 0
	LuaProtocolManager.getInstance():send(req)
end

------------------- private: -----------------------------------

function ActivityManager:new()
    local self = {}
	setmetatable(self, ActivityManager)
	self.m_iEffect = false
	self:Init()

	self.m_iActivityNum = GetDataManager():GetMainCharacterData():GetValue(knight.gsp.attr.AttrType.ACTIVENESS)
	self.m_iActivityChest = GetDataManager():GetMainCharacterData():GetValue(knight.gsp.attr.AttrType.ACTIVESTAR)
	self.m_hActivityChange = GetDataManager().EventActivityChange:InsertScriptFunctor(ActivityManager.ActivityChange)

    return self
end

function ActivityManager:Init()
	LogInfo("activitymanager init")
	
	local time = StringCover.getTimeStruct(GetServerTime() / 1000)
	local curWeekDay = time.tm_wday
	if curWeekDay == 0 then
		curWeekDay = 7
	end

	local ids = std.vector_int_()
	knight.gsp.task.GetCTaskListTableInstance():getAllID(ids)
	local num = ids:size()
	local roleLevel = GetDataManager():GetMainCharacterLevel()
	for i =0, num - 1 do
		local record = knight.gsp.task.GetCTaskListTableInstance():getRecorder(ids[i])
		if record.tasktype == 1 and roleLevel >= record.level and roleLevel <= record.level2 and bit.band(bit.blshift(1, curWeekDay - 1), record.week) > 0 then
			self:isOpened(record.id)
		end
	end
end

function ActivityManager:isOpened(id)
	LogInfo("activitymanager isOpened")
	if self.m_lActivityList then
		for i,v in pairs(self.m_lActivityList) do
			local record = knight.gsp.task.GetCTaskListTableInstance():getRecorder(i)
			if i == id and v >= record.totaltimes then
				if self.m_timeLeft then
					self.m_timeLeft[i] = nil
					if TableUtil.tablelength(self.m_timeLeft) == 0 then
						self.m_timeLeft = nil
					end
				end
				ActivityEntrance.refreshEffect()		
				return false
			end 
		end
	end

	local time = StringCover.getTimeStruct(GetServerTime() / 1000)
	local curWeekDay = time.tm_wday
	if curWeekDay == 0 then
		curWeekDay = 7
	end
	local curTime = time.tm_hour * 3600 + time.tm_min * 60 + time.tm_sec

	local ids = std.vector_int_()
	knight.gsp.timer.GetCScheculedActivityTableInstance():getAllID(ids)
	local num = ids:size()
	for i =0, num - 1 do
		local record = knight.gsp.timer.GetCScheculedActivityTableInstance():getRecorder(ids[i])

		local starth, startm, starts = string.match(record.startTime, "(%d+):(%d+):(%d+)")
		local endh, endm, ends = string.match(record.endTime, "(%d+):(%d+):(%d+)")
		local startTime = starth * 3600 + startm * 60 + starts
		local endTime = endh * 3600 + endm * 60 + ends
		if record.activityid == id and record.weekrepeat == curWeekDay and curTime >=startTime and curTime <= endTime then
			if not self.m_timeLeft then
				self.m_timeLeft = {}
			end
			self.m_timeLeft[id] = endTime - curTime
			ActivityEntrance.refreshEffect()
			return true
		end
	end
	return false
end

function ActivityManager:isInTime(id)
	LogInfo("activitymanager is in time")
	local time = StringCover.getTimeStruct(GetServerTime() / 1000)
	local curWeekDay = time.tm_wday
	if curWeekDay == 0 then
		curWeekDay = 7
	end
	local curTime = time.tm_hour * 3600 + time.tm_min * 60 + time.tm_sec

	local ids = std.vector_int_()
	knight.gsp.timer.GetCScheculedActivityTableInstance():getAllID(ids)
	local num = ids:size()
	for i =0, num - 1 do
		local record = knight.gsp.timer.GetCScheculedActivityTableInstance():getRecorder(ids[i])

		local starth, startm, starts = string.match(record.startTime, "(%d+):(%d+):(%d+)")
		local endh, endm, ends = string.match(record.endTime, "(%d+):(%d+):(%d+)")
		local startTime = starth * 3600 + startm * 60 + starts
		local endTime = endh * 3600 + endm * 60 + ends
		if record.activityid == id and record.weekrepeat == curWeekDay and curTime >=startTime and curTime <= endTime then
			if not self.m_timeLeft then
				self.m_timeLeft = {}
			end
			self.m_timeLeft[id] = endTime - curTime
			return true
		end
	end
	return false
end

function ActivityManager:run(elapsed)
	local elapse = elapsed / 1000
	if self.m_timeLeft then
		local temp = {}
		for i, v in pairs(self.m_timeLeft) do
			self.m_timeLeft[i] = self.m_timeLeft[i] - elapse
			if self.m_timeLeft[i]<= 0 then
				table.insert(temp, i)
			end
		end
		for i,v in ipairs(temp) do
			self.m_timeLeft[v] = nil
		end
		if TableUtil.tablelength(self.m_timeLeft) == 0 then
			self.m_timeLeft = nil
			ActivityEntrance.refreshEffect()		
		end
	end
end

function ActivityManager:getNeedEffect()
	if self.m_timeLeft then
		return true
	end
    if self.m_iActivityChest == 1 or (self.m_iActivityChest == 0 and self.m_iActivityNum >= 80 ) then
        return true
    end
	return false
end

return ActivityManager
