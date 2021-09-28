--[[
    文件名：MqTime.lua
	描述：时间转化，计算和格式化的模块
	创建人：liaoyuangang
	创建时间：2016.3.29
-- ]]

MqTime = {}

-- 将秒数转换成hours, minutes, seconds
--[[
--参数
    useHour: 只使用小时，不换算到天数
]]
function MqTime.toHour(seconds, useHour)
    local absseconds = seconds < 0 and 0 or seconds

    local seconds = math.floor(absseconds % 60)
    local minutes = math.floor(absseconds / 60 % 60)
    if useHour then
        local hours = math.floor(absseconds / 60 / 60)
        return hours, minutes, seconds
    else
        local hours = math.floor(absseconds / 60 / 60 % 24)
        local day = math.floor(absseconds / 60 / 60 / 24)
        return day, hours, minutes, seconds
    end
end

-- 根据秒数返回格式化时间： X天前，X小时前，X分钟前，X秒前
function MqTime.toDownFormat(time)
    local day, hours, minutes, seconds = MqTime.toHour(time)
    if day > 0 then
        return string.format(TR("%d天前"), day)
    elseif hours > 0 then
        return string.format(TR("%d小时前"), hours)
    elseif minutes > 0 then
        return string.format(TR("%d分钟前"), minutes)
    elseif seconds > 0 then
        return string.format(TR("%d秒前"), seconds)
    else
        return string.format(TR("%d秒前"), 1)
    end
end

-- 根据秒数返回格式化时间： X天，X小时，X分钟，X秒
function MqTime.toFormat(time)
    local day, hours, minutes, seconds = MqTime.toHour(time)
    if day > 0 then
        return string.format(TR("%d天"), day)
    elseif hours > 0 then
        return string.format(TR("%d小时"), hours)
    elseif minutes > 0 then
        return string.format(TR("%d分钟"), minutes)
    elseif seconds > 0 then
        return string.format(TR("%d秒"), seconds)
    else
        return string.format(TR("%d秒"), 1)
    end
end

--增加xx天 xx小时 xx分 xx秒
function MqTime.toCoutDown(time)
    local day, hours, minutes, seconds = MqTime.toHour(time)
    if day > 0 and hours >= 0 and minutes >= 0 and seconds >= 0 then
        return string.format(TR("%d天%d小时%d分钟%d秒"), day, hours, minutes, seconds)
    elseif hours > 0 and minutes >= 0 and seconds >= 0 then
        return string.format(TR("%d小时%d分钟%d秒"), hours, minutes, seconds)
    elseif minutes > 0 and seconds >= 0 then
        return string.format(TR("%d分钟%d秒"), minutes, seconds)
    elseif seconds >= 0 then
        return string.format(TR("%d秒"), seconds)
    end
end

-- 获取时间显示字符串
--[[
-- 参数
    timeTick: 时间戳
]]
function MqTime.getTimeViewStr(timeStamp)
    if not timeStamp or timeStamp == 0 then
        return "--:--:--"
    end

    local timeStr = ""
    local msgTime = os.date("*t", timeStamp)
    local currTime = os.date("*t", Player:getCurrentTime())
    if msgTime.year == currTime.year then
        if msgTime.month == currTime.month then
            local timeDiff = math.abs(currTime.day - msgTime.day)
            if timeDiff < 3 then
                local tempList = {
                    [0] = "",
                    [1] = TR("昨天"),
                    [2] = TR("前天"),
                }
                timeStr = string.format("%s %s", tempList[timeDiff], os.date("%X", timeStamp))
            else
                timeStr = os.date("%m/%d %X", timeStamp)
            end
        else
            timeStr = os.date("%m/%d %X", timeStamp)
        end
    else
        timeStr = os.date("%y/%m/%d %X", timeStamp)
    end

    return timeStr
end

-- 时间格式化 "X天 XX:XX:XX"
--[[
-- 参数：
    options =  { 显示控制
        sec  = true,
        min  = true,
        hour = true,
        day  = nil,
        sep  = ":"
    }
--]]
function MqTime.formatAsDay(dt, options)
    if not options then options = {} end
    local sep, result = options.sep or ":", ""
    local day, hour, minute, second = MqTime.toHour(dt)

    if options.day or day > 0 then
        result = result..day..TR("天 ")
    end
    hour   = hour > 9 and tostring(hour) or "0"..hour
    minute = minute > 9 and tostring(minute) or "0"..minute
    second = second > 9 and tostring(second) or "0"..second

    if options.hour ~= false then result = result..hour..sep end
    if options.min  ~= false then result = result..minute end
    if options.sec  ~= false then result = result..sep..second end
    return result
end

-- 时间格式化(小时:分:秒) "XX:XX:XX"
function MqTime.formatAsHour(dt, options)
    if not options then options = {} end
    local sep, result = options.sep or ":", ""
    local hour, minute, second = MqTime.toHour(dt, true)

    hour   = hour > 9 and tostring(hour) or "0"..hour
    minute = minute > 9 and tostring(minute) or "0"..minute
    second = second > 9 and tostring(second) or "0"..second

    if options.hour ~= false then result = result..hour..sep end
    if options.min  ~= false then result = result..minute end
    if options.sec  ~= false then result = result..sep..second end
    return result
end

-- xls配置表转换为lua时，time类型字段被转化为了float，
-- 其值为: timeOfDay / 24，可以通过该函数转化为字符串形式：XX:XX:XX
function MqTime.tostring(time)
    local tempTime = math.ceil(time * 24 * 60 * 60)
    return formatTime(tempTime)
end

--- 判断两个时间是否在同一天
function MqTime.isSameDay(time1, time2)
    local oldTime = os.date("*t", time1 or 0)
    local newTime = os.date("*t", time2 or 0)

    return (oldTime.day == newTime.day) and (oldTime.month == newTime.month) and (oldTime.year == newTime.year)
end

-- 获取服务器日期（北京日期）
function MqTime.getLocalDate(time)
    -- 本地时区
    local localTimeZone = MqTime.getTimeZone()

    -- 当前本地时区的时间戳(8是服务器时区-北京)
    local localTime = (time or Player:getCurrentTime()) + 3600*(8-localTimeZone)
    --转换出服务器日期
    local curDate = os.date("*t", localTime)

    return curDate
end

-- 获取本地时区
function MqTime.getTimeZone()
	local a = os.date('!*t',os.time())--中时区的时间
    local b = os.date('*t',os.time())
    local timeZone= (b.hour - a.hour) * 3600 + (b.min - a.min) * 60
    return timeZone/3600
end

-- 服务器日期（北京日期）转时间戳
function MqTime.getLocalTime(date)
	-- 本地时区
    local localTimeZone = MqTime.getTimeZone()
    local localTime = os.time(date) + 3600*(localTimeZone-8)

    return localTime
end

-- 获取当日配置时间时间戳
--[[
	参数：
		timeStr 	配置时间字符串（格式为xx:xx:xx, 如 14:00:00)
]]
function MqTime.getConfigTime(timeStr)
	local curDate = MqTime.getLocalDate()
	local timeList = string.splitBySep(timeStr, ":")
	curDate.hour = timeList[1]
	curDate.min = timeList[2]
	curDate.sec = timeList[3]

	return MqTime.getLocalTime(curDate)
end
