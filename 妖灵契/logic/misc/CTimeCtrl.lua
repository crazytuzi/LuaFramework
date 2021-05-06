local CTimeCtrl = class("CTimeCtrl", CDelayCallBase)

function CTimeCtrl.ctor(self)
	CDelayCallBase.ctor(self)
	self.m_LocalTimeSinceStartup = UnityEngine.Time.realtimeSinceStartup
	self.m_BeatDelta = 10
	self.m_ServerTime = os.time()
	self.m_BeatTimer = nil
	self.m_LastStartTickMS = C_api.Timer.GetTickMS()
	self.m_Watchs = {}
end

function CTimeCtrl.StartWatch(self)
	local i = #self.m_Watchs
	local oWatch
	if i > 0 then
		oWatch = self.m_Watchs[i]
		table.remove(self.m_Watchs, i)
	else
		oWatch = CWatch.New()
	end
	oWatch:Start()
	return oWatch
end

function CTimeCtrl.StopWatch(self, oWatch)
	table.insert(self.m_Watchs, oWatch)
	return oWatch:Stop()
end

function CTimeCtrl.ServerHelloTime(self, iTimeS)
	self:SyncServerTime(iTimeS)
	g_ScheduleCtrl:AutoCheckSchedule()
end

function CTimeCtrl.ReciveServerBeat(self)
	self:StopDelayCall("HeartTimeOut")
	print("HeartBeat->心跳包检测正常")
end

function CTimeCtrl.HeartBeat(self)
	if g_NetCtrl:GetNetObj() == nil then
		self:StopBeat()
		return false
	end
	netother.C2GSHeartBeat()
	self.m_ReciveBeatTime = nil
	self:DelayCallNotReplace(70, "HeartTimeOut")
	return true
end

function CTimeCtrl.HeartTimeOut(self)
	print("HeartBeat-->心跳包检测超时")
	self:StopBeat()
	g_NetCtrl:AutoReconnect()
end

function CTimeCtrl.IsBeating(self)
	return self.m_BeatTimer ~= nil
end

function CTimeCtrl.StartBeat(self)
	self:StopBeat()
	print("HeartBeat-->开启心跳包检测")
	self.m_BeatTimer = Utils.AddTimer(callback(self, "HeartBeat"), self.m_BeatDelta, 0)
end

function CTimeCtrl.StopBeat(self)
	if self.m_BeatTimer then
		Utils.DelTimer(self.m_BeatTimer)
		self.m_BeatTimer = nil
	end
	self.m_ReciveBeatTime = nil
	self:StopDelayCall("HeartTimeOut")
end

function CTimeCtrl.SyncServerTime(self, iTimeS)
	self.m_LocalTimeSinceStartup = UnityEngine.Time.realtimeSinceStartup
	self.m_ServerTime = iTimeS
	print("同步服务器时间", self:Convert(self.m_ServerTime))
end

function CTimeCtrl.GetTimeS(self)
	local iSpanS = UnityEngine.Time.realtimeSinceStartup - self.m_LocalTimeSinceStartup
	return math.floor(iSpanS) + self.m_ServerTime
end

function CTimeCtrl.GetTimeMS(self)
	local iSpanMS = UnityEngine.Time.realtimeSinceStartup - self.m_LocalTimeSinceStartup
	return math.floor((iSpanMS + self.m_ServerTime) * 1000)
end

function CTimeCtrl.GetTimeYMD(self)
	local seconds = self:GetTimeS()
	return self:Convert(seconds)
end

function CTimeCtrl.Convert(self, seconds)
	return os.date("%Y/%m/%d %H:%M:%S", seconds)
end

function CTimeCtrl.GetTimeHM(self)
	local seconds = self:GetTimeS()
	return os.date("%H:%M",seconds)
end

function CTimeCtrl.GetTimeWeek(self)
	local seconds = self:GetTimeS()
	return os.date("%w", seconds)
end

function CTimeCtrl.GetTimeInfo(self, iSec)
	iSec = math.modf(iSec)
	return {
		hour = math.modf(iSec / 3600),
		min = math.modf((iSec % 3600) / 60),
		sec = iSec % 60,
	}
end

function CTimeCtrl.GetLeftTime(self, iSec, bShowHour)
	iSec = math.floor(iSec)
	
	local hour = math.modf(iSec / 3600)
	local min = math.floor((iSec % 3600) / 60)
	local sec = iSec % 60
	if hour > 0 then
		return string.format("%02d:%02d:%02d", hour, min, sec)
	elseif bShowHour then
		return string.format("00:%02d:%02d", min, sec)
	else
		return string.format("%02d:%02d", min, sec)
	end
end

function CTimeCtrl.IsToday(self, iSec)
	local t = os.date("*t", iSec)
	local curt = os.date("*t", self:GetTimeS())
	if t["day"] ~= curt["day"] then
		return false
	elseif t["month"] ~= curt["month"] then
		return false
	elseif t["year"] ~= curt["year"] then
		return false
	end
	return true
end

function CTimeCtrl.IsInDays(self, day1, day2)
	local b = false
	if #day1 == 3 and #day2 == 3 then
		if (self:CompareDays(day1) == nil or self:CompareDays(day1) == true) 
			and (self:CompareDays(day2) == nil or self:CompareDays(day2) == false) then
			b = true
		end
	end
	return b
end

function CTimeCtrl.CompareDays(self, day1)
	local b = nil
	local curt = os.date("*t", self:GetTimeS())
	if #day1 == 3 then		
		if curt["year"] == tonumber(day1[1]) then
			if curt["month"] == tonumber(day1[2]) then
				if curt["day"] == tonumber(day1[3]) then
					--为nil时，同一天
					return
				else
					b = curt["day"] > tonumber(day1[3])	
				end	
			else
				b = curt["month"] > tonumber(day1[2])	
			end
		else
			b = curt["year"] > tonumber(day1[1])	
		end
	end
	return b
end

function CTimeCtrl.GetDay(self, s)
	if not s or s == "" then
		return ""
	end	
	local days = string.split(s, "-")

	if not days or #days ~= 3 then
		return ""
	end	
	return string.format("%s年%s月%s日", days[1], days[2], days[3])
end

function CTimeCtrl.GetDayByTimeS(self, s, bHaveYear)
	if not s then
		return ""
	end
	bHaveYear = bHaveYear == nil and true or bHaveYear
	local time = os.date("*t", s)
	if bHaveYear then
		return string.format("%d年%d月%d日", time["year"], time["month"], time["day"])
	else
		return string.format("%d月%d日", time["month"], time["day"])
	end	
end

return CTimeCtrl