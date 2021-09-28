

local ServerTime = class("ServerTime")


--计算本地时区比UTC0快了多少秒
local function get_timezone()
    local now = os.time()
    return os.difftime(now, os.time(os.date("!*t", now)))
end


function ServerTime:ctor(t, zone)
    self._zone = 8 -- 默认服务器时区,北京时区
    self._diff =0 -- 客户端时区比服务器时区快了多少秒
    self._t = FuncHelperUtil:getCurrentTime() -- 时间戳
    self._lastSetTime = FuncHelperUtil:getCurrentTime() -- 最后一次setTime时, 本地时间点
end

function ServerTime:setTime(t, zone)
    self._t = t
    self._zone = zone
    self._lastSetTime = FuncHelperUtil:getCurrentTime()

    self._diff = get_timezone() - zone*3600


    --print("currrendate:" .. self:getTimeString())
end

--获取当前的服务器时间戳
function ServerTime:getTime()
    local elapsed = FuncHelperUtil:getCurrentTime() - self._lastSetTime
    return self._t + elapsed
end

function ServerTime:getDateObject(t)
    if t == nil then
        t = self:getTime()
    end
    --需要根据时区计算
    local localdate = os.date('*t', t - self._diff)

    return localdate
end

function ServerTime:getDataObjectFormat( format, t )
    t = t or self:getTime()

    return os.date(format, t - self._diff)
end

--获取当前时间对应的服务器日期
function ServerTime:getDate(t)

    local localdate = self:getDateObject(t)

    return string.format("%04d-%02d-%02d", localdate.year, localdate.month, localdate.day)    
end


--获取时间戳t对应的服务器时间的字符串
function ServerTime:getTimeString(t)
    if t == nil then
        t = self:getTime()
    end
    --需要根据时区计算
    local localdate = os.date('*t', t - self._diff)


    return string.format("%04d-%02d-%02d %02d:%02d:%02d", localdate.year, localdate.month, localdate.day,localdate.hour, localdate.min, localdate.sec)    
end


--计算时间戳t还有多少秒
--如果t已经过去了,那么返回负数
function ServerTime:getLeftSeconds(t)
    local nowTime = self:getTime()
    return t - nowTime
end


--计算时间戳t还有多少秒, 并返回一个时间字符串
--如果t已经过去了,那么返回 "-"
--不用天数计算
function ServerTime:getLeftSecondsString(t)
    local day,hour,minute,second = self:getLeftTimeParts(t)
    if (day+hour+minute+second) == 0 then
        --结束了
        return "-"
    else
        hour = day*24+hour
        return  string.format("%02d:%02d:%02d",hour,minute,second)
    end
end

function ServerTime:getLeftSecondsStringWithDays(t)
    local day,hour,minute,second = self:getLeftTimeParts(t)
    -- local timeLeft = self:getLeftSeconds(t)
    if (day+hour+minute+second) == 0 then
        --结束了
        return "-"
    end
    return G_lang:get("LANG_DAYS7_OVERTIME_FORMAT",{dayValue=day, hourValue=hour, minValue=minute, secondValue=second})
end

function ServerTime:getDateFormat(t)
    local localdate = self:getDateObject(t)
    return G_lang:get("LANG_ACTIVITY_TIME_FORMAT",{year=localdate.year,month=localdate.month, day=localdate.day,hour =localdate.hour})
end

function ServerTime:getActivityTimeFormat(t1,t2)
    local start_time = self:getDateFormat(t1)
    local end_time = self:getDateFormat(t2)
    return G_lang:get("LANG_ACTIVITY_TIME_FORMAT_START_END",{start_time=start_time,end_time=end_time})
end

function ServerTime:getEndSellDateFormat(t)
    print("day=self:getDateFormat(t) = " .. self:getDateFormat(t))
    return G_lang:get("LANG_ITEM_XIAN_SHI_END_TIME",{day=self:getDateFormat(t)})
end

function ServerTime:getLeftTimeParts( t )
    local timeLeft = self:getLeftSeconds(t)
    if timeLeft < 0 then
        return 0, 0, 0, 0
    else
        local hour = (timeLeft-timeLeft%3600)/3600
        local day = (hour - hour%24)/24
        local minute = (timeLeft-hour*3600 -timeLeft%60)/60

        hour = hour%24
        local second = timeLeft%60

        return day, hour, minute, second
    end
end


--计算倒计时,例如排行榜12点发放奖励.需计算当前时间和12点剩余时间,如果是凌晨24:00:00 点 hour传24 minute 0,second 0
function ServerTime:getAwardLeftTime(_hour,_minute,_second)
    --先计算当前时分秒
    local nowTime = self:getTime()
   -- local tab=os.date("*t",nowTime); 
   local tab = self:getDateObject(nowTime)
    
    local awardT = _hour*3600 + _minute *60 + _second
    local t = tab.hour*3600 + tab.min*60 + tab.sec

    if  awardT > t then
        --不能使用os.date("%X",awardT-t)
        return self:secondToString(awardT-t)
    else
        --今日领奖时间已过
        return "_"
    end
end

--获取当前离24:00:00点的seconds
function ServerTime:getCurrentDayLeftSceonds()
    local nowTime = self:getTime()
--    local tab=os.date("*t",nowTime); 
    local tab = self:getDateObject(nowTime)
    return 24*3600 -  tab.hour*3600 - tab.min*60 - tab.sec
end


--倒计时 toString ,不含天数
function ServerTime:secondToString(t)
    local hour = (t-t%3600)/3600
        local minute = (t-hour*3600 -t%60)/60
        local second = t%60
        
        local text = ""
        
        if hour <10 then
            text = text .. "0".. hour .. ":"
        else
            text = text .. hour .. ":"
        end 
        
        if minute <10 then
            text = text .. "0".. minute .. ":"
        else
            text = text .. minute .. ":"
        end 
        
        if second <10 then
            text = text .. "0".. second
        else
            text = text .. second
        end  
        return  text
end

function ServerTime:getCurrentHHMMSS(t)
    local localdate = self:getDateObject(t)

    return localdate.hour, localdate.min,localdate.sec
end

--比较t跟今天零点相差的秒数, 如果是今天之前的t,那么返回负数
function ServerTime:secondsFromToday(t)
    --首选需要知道今天的零点的那个t1
    local now = self:getTime()
    local date = self:getDateObject(now)
    local t1 = now - date.hour*3600 - date.min*60 - date.sec 
    return t - t1
end

function ServerTime:isToday(t)
    local distance = self:secondsFromToday(t)
    local daySeconds = 3600*24
    if distance < 0  or distance >  daySeconds then
        return false
    end

    return true
end


function ServerTime:isBeforeToday(t)
    local distance = self:secondsFromToday(t)

    if distance < 0   then
        return true
    end
    return false
end

function ServerTime:getFutureTimeDesc( t, noSecond )
    if not t then 
        return "", 0
    end

    local nowTime = self:getTime()
    local curTime = self:getDateObject(nowTime)
    local futureTime = self:getDateObject(t)
    --local curTime = os.date("*t", nowTime)
    --local futureTime = os.date("*t", t)

    if type(curTime) ~= "table" or type(futureTime) ~= "table" or t <= nowTime then 
        return "", 0
    end

    local dayStr = ""
    if futureTime.day  == curTime.day then 
        dayStr = G_lang:get("LANG_TIME_TODAY")
    elseif futureTime.day == curTime.day + 1 then
        dayStr = G_lang:get("LANG_TIME_TOMORROW")
    elseif futureTime.day == curTime.day + 2 then
        dayStr = G_lang:get("LANG_TIME_AFTER_TOMORROW")
    else
        dayStr = G_lang:get("LANG_TIME_DAYS_LATER", {dayValue = futureTime.yday - curTime.yday })
    end
    local timeStr = string.format(noSecond and "%02d:%02d" or "%02d:%02d:%02d", futureTime.hour, futureTime.min, futureTime.sec)

    return dayStr..timeStr, t - nowTime
end


return ServerTime

