--
-- Created by IntelliJ IDEA.
-- User: Stefan
-- Date: 2014/6/20
-- Time: 11:43
-- 定时器，当需要在未来某个时刻执行一个函数时候，可以将其注册到该定时器
--

_G.ONE_MINUTE = 60
_G.ONE_HOUR = 60 * 60
_G.ONE_DAY = 24 * 60 * 60

_G.EIGHT_HOURS = 8 * 60 * 60

_G.classlist['CTimer'] = 'CTimer'
_G.CTimer = CSingle:new()
CTimer.objName = 'CTimer'
CTimer.setAllTimer = {}
CTimer.dwGlobalID = 0

CSingleManager:AddSingle(CTimer);

--add
function CTimer:AddTimer(dwTime, bPause, Func, Param)
    self.dwGlobalID = self.dwGlobalID + 1
    self.setAllTimer[self.dwGlobalID] = {
        dwRemain = dwTime,
        bPause = bPause,
        Func = Func,
        Param = Param
    }
    return self.dwGlobalID
end
--update
function CTimer:Update(e)
    for k, v in pairs(self.setAllTimer) do
        if (not v.bPause) then
            v.dwRemain = v.dwRemain - e
            if v.dwRemain <= 0 then
                v.Func(v.Param)
                self.setAllTimer[k] = nil
            end
        end
    end
end

_G.dwCurTime = nil;
_G.GetCurTime = function(dwFlg)
    if dwFlg then
        return math.floor(_G.dwCurTime/1000);
    end
    return _G.dwCurTime;
end;
_G.SetCurTime = function(dwTime)
    if _G.dwCurTime == nil then
        _G.dwCurTime = _now()
    else
        _G.dwCurTime = _G.dwCurTime + dwTime
    end
end;

------单位 ：s ------
_G.loginServerTime = 0
_G.readTime = 0
_G.serverSTime = 0
_G.mergeSTime = 0

--获取服务器时间(UTC)
_G.GetServerTime = function()
    local serverTime = loginServerTime + GetCurTime(1) - readTime
    return serverTime
end

--获取本地时间(北京时间)
_G.GetLocalTime = function()
	local serverTime = loginServerTime + GetCurTime(1) - readTime
	return serverTime + EIGHT_HOURS
end

--获取今天的时间
_G.GetDayTime = function()
	local localTime = GetLocalTime()
	return localTime % ONE_DAY
end

_G.SetServerTime = function(serverTime)
    _G.loginServerTime = serverTime
    _G.readTime = GetCurTime(1)
end

--开服时间
_G.SetServerSTime = function(time)
	_G.serverSTime = time
end

--合服时间
_G.SetMergeSTime = function(time)
	_G.mergeSTime = time
end

--获得当前的小时数
_G.GetCurrHour = function()
    return math.floor((GetLocalTime() % ONE_DAY) / ONE_HOUR)
end

--获得当前的分钟数
_G.GetCurrMinute = function()
    return math.floor((GetLocalTime() % ONE_HOUR) / ONE_MINUTE) 
end

_G.GetZeroTime = function(sec)
	sec = sec + EIGHT_HOURS
	sec = sec - sec % (24 * 60 * 60) 
	return sec - EIGHT_HOURS
end

_G.GetTimeByDate = function(year, month, day, hour, min, sec)     
	return  _time(1, {year = year , month = month, day = day, hour = hour, min = min, sec = sec}) + 946656000
end

_G.GetDateByTime = function(time)
	time = time - 946656000
    return _time({}, time, 1)
end
