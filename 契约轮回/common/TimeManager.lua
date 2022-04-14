-- 
-- @Author: LaoY
-- @Date:   2018-08-11 17:23:53
-- 改写os.time os.clock os.date。保证系统api获取的时间都是服务端时间

TimeManager = TimeManager or class("TimeManager", BaseManager)
local this = TimeManager

local system = {
    get_time = os.time,
    get_time_ms = os.clock,
    date = os.date
}

local weekdayChs = { "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday" }

TimeManager.HourSec = 60 * 60
TimeManager.DaySec = TimeManager.HourSec * 24

function TimeManager:ctor()
    TimeManager.Instance = self
    self:Reset()
    self:Init()
    --self:SetErrorTimeMs(0)
    self.error_time = 0
    self.error_time_ms = 0

    self:SetErrorTimeMs(self:GetClientMs() * 1000)

    self:StartTime()
end

function TimeManager:Reset()
    self.zero_time = nil
end

function TimeManager.GetInstance()
    if TimeManager.Instance == nil then
        TimeManager()
    end
    return TimeManager.Instance
end

function TimeManager:Init()
    function os.time(tab)
        if tab then
            return system.get_time(tab)
        else
            -- return system.get_time() + self.error_time
            -- return math.floor(Time.fixedTime + self.error_time)
            return math.floor(Time.time + self.error_time)
        end
    end
    -- os.date("t")
    --通过时间戳生成日期
    function os.date(format, time)
        if not format and not time then
            local time = os.time()
            local t = system.date("*t", time)
            return string.format("%s/%s%s %s:%s:%s", t.month, t.day, t.year, t.hour, t.min, t.sec)
        elseif format then
            time = time or os.time()
            return system.date(format, time)
        else
            return nil
        end
    end

    function os.clock()
        -- return system.get_time_ms() * 1000 + self.error_time_ms
        return math.floor(Time.time * 1000 + self.error_time_ms)
    end
end

local time_id
-- time-2019.4.24-23.57.00
function TimeManager:StartTime()
    if time_id then
        GlobalSchedule:Stop(time_id)
        time_id = nil
    end
    local function step()
        if not LoginModel:GetInstance().server_time_id then
            return
        end
        local cur_time = os.time()
        if not self.zero_time then
            self.zero_time = self:GetZeroTime(cur_time)
        end
        if self.zero_time and cur_time >= self.zero_time + TimeManager.DaySec then
            self.zero_time = self:GetZeroTime(cur_time)
            if AppConfig.GameStart then
                GlobalEvent:Brocast(EventName.CrossDay)
            end

            local function CrossDayDelayCall()
                if AppConfig.GameStart then
                    GlobalEvent:Brocast(EventName.CrossDayAfter)
                end
            end
            GlobalSchedule:StartOnce(CrossDayDelayCall, 60)
        end
    end
    time_id = GlobalSchedule:Start(step, 1.0)
end

--[[
	@author LaoY
	@des	设置误差时间，时间毫秒
--]]
function TimeManager:SetErrorTimeMs(server_timems)
    -- self.error_time = math.floor(server_timems / 1000) - system.get_time()
    -- self.error_time_ms = server_timems - system.get_time_ms() * 1000
    if self.last_server_time and self.last_server_time - os.clock() > 400 then
        logWarn('--LaoY TimeManager.lua,line 76--', server_timems, self.last_server_time, server_timems - self.last_server_time)
        logWarn('--LaoY TimeManager.lua,line 77--', os.clock(), self.last_client_time, os.clock() - self.last_client_time)
    end
    self.error_time = math.floor(server_timems / 1000 - Time.time)
    self.error_time_ms = server_timems - Time.time * 1000
    self.last_server_time = server_timems
    self.last_client_time = os.clock()
end

function TimeManager:GetServerTime()
    return os.time()
end

function TimeManager:GetServerTimeMs()
    return os.clock()
end

--[[
	@author LaoY
	@des	获取本地时间戳
--]]
function TimeManager:GetClient(...)
    return system.get_time(...)
end

--[[
	@author LaoY
	@des	获取本地cpu启动时间 毫秒
--]]
function TimeManager:GetClientMs()
    return system.get_time_ms()
end

--[[
	@author LaoY
	@des	本地时间格式化
--]]
function TimeManager:GetClientDataTime(...)
    return system.date(...)
end

--时间戳转日期
--time 时间戳
function TimeManager:GetTimeDate(time)
    if time and time >= 0 then
        return os.date("*t", time)
    end
end

function TimeManager:FormatTime2Date(time)
    return os.date("%Y-%m-%d %H:%M:%S", time)
    --local date = self:GetTimeDate(time)
    --return date.year .. "-" .. date.month .. "-" .. date.day .. " " .. date.hour .. ":" .. date.min .. ":" .. date.sec
end

--[[
	@author LaoY
	@des	获取当天0点时间戳
--]]
function TimeManager:GetZeroTime(time)
    local data = self:GetTimeDate(time)
    data.hour = 0
    data.min = 0
    data.sec = 0
    time = os.time(data)
    return time
end

--[[
    获取当天晚上12点的时间戳
--]]
function TimeManager:GetTomorZeroTime()
    local data = self:GetTimeDate(os.time())
    data.hour = 24
    data.min = 0
    data.sec = 0
    return os.time(data)
end

TimeManager.ServerTimeZone = 3600 * 7
TimeManager.ServerTimeZoneIndex  = 8

function TimeManager:SetServerTimeZone(timeZone)
    TimeManager.ServerTimeZoneIndex = timeZone
    TimeManager.ServerTimeZone = 3600 * timeZone
end

--[[
    获取当天0点的时间戳 （服务端时间）
--]]
function TimeManager:GetServerZeroTime(time)
    time = time or os.time()
    local data = self:ServerTimeDate(time,"*t")
    data.hour = 24
    data.min = 0
    data.sec = 0
    return os.time(data)
end

-- 替代os.date函数，忽略本地时区设置，按服务器时区格式化时间
-- @param format: 同os.date第一个参数
-- @param timestamp:服务器时间戳
function TimeManager:ServerTimeDate(timestamp,format)
    timestamp = timestamp or os.time()
    format = format or "*t"
    local timeZoneDiff = TimeManager.ServerTimeZone - self:GetLocalTimeZone()
    return os.date(format, timestamp + timeZoneDiff)
end

-- 替代os.time函数，忽略本地时区设置，返回服务器时区时间戳
-- @param timedata: 服务器时区timedate
function TimeManager:Time(timedate)
    local timeZoneDiff = TimeManager.ServerTimeZone - self:GetLocalTimeZone()
    return os.time(timedate) - timeZoneDiff
end

-- 获取客户端本地时区
function TimeManager:GetLocalTimeZone()
    local now = os.time()
    local localTimeZone = os.difftime(now, os.time(os.date("!*t", now)))
    local isdst = os.date("*t", now).isdst
    if isdst then localTimeZone = localTimeZone + 3600 end
    return localTimeZone
end

--[[
    @author LaoY
    @des    獲取兩個时间戳的天數間隔，晚上11点-次日中午11点，间隔算一天。
            转成服务器时区再计算
--]]
function TimeManager:GetServerDifDay(time1, time2)
    time1 = self:GetServerZeroTime(time1)
    time2 = self:GetServerZeroTime(time2)
    if time1 == nil or time2 == nil then
        return 0
    end
    return math.floor(math.abs(time1 - time2) / TimeManager.DaySec)
end

--[[
	@author LaoY
	@des	获取两个时间戳的天数间隔，晚上11点-次日中午11点，间隔算一天。
--]]
function TimeManager:GetDifDay(time1, time2)
    time1 = self:GetZeroTime(time1)
    time2 = self:GetZeroTime(time2)
    if time1 == nil or time2 == nil then
        return 0
    end
    return math.floor(math.abs(time1 - time2) / TimeManager.DaySec)
end

function TimeManager:GetWeekZeroTime(time)
    local data = self:GetTimeDate(time)
    data.hour = 0
    data.min = 0
    data.sec = 0
    time = os.time(data)
    if data.wday == 1 then
        time = time - TimeManager.DaySec * 6
    else
        time = time - TimeManager.DaySec * (data.wday - 2)
    end
    return time
end

--[[
	@author LaoY
	@des	获取两个时间戳的周数间隔，周日晚上11点-周一中午11点，间隔算一周。
--]]
function TimeManager:GetDifWeek(time1, time2)
    time1 = self:GetWeekZeroTime(time1)
    time2 = self:GetWeekZeroTime(time2)
    return math.floor(math.abs(time1 - time2) / (TimeManager.DaySec * 7))
end

--[[
	@author LaoY
	@des	获取倒计时
	@return table {day,hour,min,sec}
--]]
function TimeManager:GetLastTimeData(start_time, end_time)
    local last_time = end_time - start_time
    if last_time < 0 then
        return nil
    end
    return self:GetLastTimeBySeconds(last_time)
end

function TimeManager:GetLastTimeBySeconds(seconds)
    local data = {}
    data.sec = seconds
    --data.min = 0
    --data.hour = 0
    --data.day = 0
    if data.sec >= TimeManager.DaySec then
        data.day = math.floor(data.sec / TimeManager.DaySec)
        data.sec = data.sec % TimeManager.DaySec
        data.min = 0
        data.hour = 0
    end
    if data.sec >= TimeManager.HourSec then
        data.hour = math.floor(data.sec / TimeManager.HourSec)
        data.sec = data.sec % TimeManager.HourSec
        data.min = 0
    end
    if data.sec >= 60 then
        data.min = math.floor(data.sec / 60)
        data.sec = data.sec % 60
    end
    return data
end

function TimeManager:GetLastTimeStr(start_time, end_time)
    local data = self:GetLastTimeData(start_time, end_time)
    if not data then
        return
    end
    local str = ""
    if data.day then
        str = string.format("%s days left", data.day)
    elseif data.hour then
        str = string.format("%sh%smin left", data.hour, data.min)
    elseif data.min then
        str = string.format("%02dmin%02dsec left", data.min, data.sec)
        -- elseif data.sec > 10 then
    else
        str = string.format("%02dsec left", data.sec)
    end
    return str
end

function TimeManager:GetDifTime(send_time, server_time)
    local difDay = TimeManager.Instance:GetDifDay(send_time, server_time)
    if difDay <= 0 then
        local difTime = server_time - send_time
        difTime = math.abs(difTime)
        if difTime < 59 then
            return ConfigLanguage.Mix.Just
        elseif difTime >= 60 and difTime < 3600 then
            return math.floor(difTime / 60) .. ConfigLanguage.Mix.Minute .. ConfigLanguage.Mix.Before
        else
            return math.floor(difTime / 3600) .. ConfigLanguage.Mix.Hour .. ConfigLanguage.Mix.Before
        end
    else
        return difDay .. ConfigLanguage.Date.Day .. ConfigLanguage.Mix.Before
    end
end


--日期转时间戳
--传入日期格式为："2018-12-22 17:00:00"
function TimeManager:String2Time(timeString)
    if string.isempty(timeString) then
        return nil
    end
    if timeString then
        local fun = string.gmatch(timeString, "%d+")
        local y = fun() or 0
        local m = fun() or 0
        local d = fun() or 0
        local H = fun() or 0
        local M = fun() or 0
        local S = fun() or 0
        return os.time({ year = y, month = m, day = d, hour = H, min = M, sec = S })
    else
        return 0
    end
end

--当天时分秒转当天时间戳
function TimeManager:GetStampByHMS(hour, min, sec)
    local tbl = os.date("*t")
    tbl.hour = hour
    tbl.min = min
    tbl.sec = sec
    return os.time(tbl)
end

function TimeManager:GetWeekDay(day)
    local d = day
    if type(d) ~= "number" then
        d = tonumber(day);
    end
    return weekdayChs[d]
end