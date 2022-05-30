
TimeTool = TimeTool or {}

--[[
功能：生成时间格式为00:00:00的(时：分：秒)
--]]
function TimeTool.GetTimeFormat(less_time)
    less_time = tonumber(less_time) or 0
    local hour = math.floor(less_time / 3600)
    local min = math.floor((less_time % 3600) / 60)
    local sec = less_time % 3600 % 60
    hour = (hour < 10) and "0"..hour or hour
    min = (min < 10) and "0"..min or min
    sec = (sec < 10) and "0"..sec or sec
    return hour .. ":" .. min .. ":" .. sec
end

--[[
功能：生成时间格式为00:00的(分：秒)
--]]
function TimeTool.GetMinSecTime(less_time)
    less_time = tonumber(less_time) or 0
    local hour = math.floor(less_time / 3600)
    local min = math.floor((less_time % 3600) / 60)
    local sec = math.floor(less_time % 3600 % 60)
    min = hour * 60 + min
    min = (min<10) and "0"..min or min
    sec = (sec<10) and "0"..sec or sec
    return  min .. ":" .. sec
end

--[[
功能：生成时间格式为00:00:00的(时：分：秒)
--]]
function TimeTool.GetTimeFormatII(less_time)
    less_time = tonumber(less_time) or 0
    local hour = math.floor(less_time / 3600)
    local min = math.floor((less_time % 3600) / 60)
    local sec = math.floor(less_time % 3600 % 60)

    if sec <= 0 then
        if min <= 0 then
            return string.format(TI18N("%s小时"), hour)
        else
            return string.format(TI18N("%s小时%s分"), hour, min)
        end
    end
    return string.format(TI18N("%s小时%s分%s秒"), hour, min, sec)
end


--[[
功能：生成时间格式为00:00:00的(时：分)
--]]
function TimeTool.GetTimeFormatTwo(less_time, is_num)
    less_time = tonumber(less_time) or 0
    local hour = math.floor(less_time / 3600)
    local min = math.floor((less_time % 3600) / 60)
    local sec = math.floor(less_time % 3600 % 60)

    local str_hour = (hour < 10) and "0"..hour or hour
    local str_min = (min < 10) and "0"..min or min
    local str_sec = (sec < 10) and "0"..sec or sec

    if hour <= 0 then
        if is_num then
            return string.format("%s:%s", str_min, str_sec)
        end
        return string.format(TI18N("%s分%s秒"), str_min, str_sec)
    else
        if is_num then
            return string.format("%s:%s", str_hour, str_min)
        end
        return string.format(TI18N("%s小时%s分"), str_hour, str_min)
    end
end


--[[
功能：生成时间格式为00:00的(时：分)
--]]
function TimeTool.GetTimeFormatIII(less_time)
    less_time = tonumber(less_time) or 0
    local hour = math.floor(less_time / 3600)
    local min = math.floor((less_time % 3600) / 60)
    hour = (hour < 10) and "0"..hour or hour
    min = (min < 10) and "0"..min or min
    return hour .. ":" .. min
end

--[[
功能：生成时间格式为00:00的(分：秒)
--]]
function TimeTool.GetTimeMS(less_time,isNum)
    less_time = tonumber(less_time) or 0
    local hour = math.floor(less_time / 3600)
    local min = math.floor((less_time % 3600) / 60)
    local sec = math.floor(less_time % 3600 % 60)
    if isNum then
        sec = (sec < 10) and "0"..sec or sec
        local max_m = hour*60+min
        max_m = (max_m < 10) and "0".. max_m or max_m
        return  max_m .. ":" .. sec
    else
        return tipsFormat(TI18N("%s分%s秒"), hour*60+min, sec)
    end
end

--[[
功能：传入时间戳，生成时间格式为(年-月-日 时：分：秒)
--]]
function TimeTool.getYMDHMS(less_time)
   return os.date("%Y-%m-%d %X ", less_time)
end

-- 传入时间戳，生成 年-月-日 时：分
function TimeTool.getYMDHM(less_time)
   return os.date("%Y-%m-%d %H:%M", less_time)
end

-- 功能：传入时间戳，生成时间格式为(月-日 时：分：秒)
function TimeTool.getMDHMS(less_time)
   return os.date("%m-%d %X ", less_time)
end

function TimeTool.getMD(less_time)
   return os.date("%m.%d", less_time)
end

function TimeTool.getMDHM(less_time)
   return os.date("%m-%d %H:%M", less_time)
end

function TimeTool.getHMS(less_time)
    return os.date("%X ", less_time)
end

function TimeTool.getYDHM(less_time)
   return os.date("%m/%d %H:%M ", less_time)
end

function TimeTool.getMS(less_time)
    return os.date("%M:%S", less_time)
end
function TimeTool.getHM(less_time)
    return os.date("%H:%M", less_time)
end

--[[
功能：传入时间戳，生成时间格式为(xxxx-xx-xx)
--]]
function TimeTool.getYMD(less_time)
   return os.date("%Y-%m-%d", less_time)
end
function TimeTool.getYMD1(less_time)
   return os.date("%Y.%m.%d", less_time)
end

--功能：传入时间戳，生成时间格式为(xxxx年xx月xx日)
function TimeTool.getYMD2(less_time)
    local y = os.date("%Y", less_time) 
    local m = os.date("%m", less_time) 
    local d = os.date("%d", less_time) 
    return string.format(TI18N("%s年%s月%s日"), y, m, d)
end

--功能：传入时间戳，生成时间格式为(xxxx.xx.xx)
function TimeTool.getYMD3(less_time)
    local y = os.date("%Y", less_time) 
    local m = os.date("%m", less_time) 
    local d = os.date("%d", less_time) 
    return y.."."..m.."."..d
end

function TimeTool.getMD2(less_time)
    -- local y = os.date("%Y", less_time) 
    local m = os.date("%m", less_time) 
    local d = os.date("%d", less_time) 
    return string.format(TI18N("%s月%s日"), m, d)
end

-- 功能：传入时间戳，生成时间格式为(月-日)
function TimeTool.getMD3(less_time)
   return os.date("%m-%d", less_time)
end

-- 获取距离第二天凌晨0点所剩下的时间
function TimeTool.getOneDayLessTime()
    local year = tonumber(os.date("%Y"))
    local mon= tonumber(os.date("%m"))
    local day= tonumber(os.date("%d"))+1
    local last = os.time({year=year, month=mon, day=day, hour=0, min=0, sec=0, isdst=false})
    local less = os.difftime(last, os.time())
    return less
end

--获取今天0点的时间点
function TimeTool.getToDayZeroTime()
    local cur_time = GameNet:getInstance():getTime()
    local year = os.date("%Y", curTime) 
    local month = os.date("%m", curTime)
    local day = os.date("%d", curTime) 
    local last = os.time({year=year, month=month, day=day, hour=0, min=0, sec=0, isdst=false})
    local value = last or 0
    return value
end

function TimeTool.day2s()
    return 86400
end

function TimeTool.getDayDifference(time_tmps)
    if type(time_tmps) ~= "number" then return 0 end
    local time = os.time()
    return (time - time_tmps) / TimeTool.day2s()
end

-- xx天xx小时xx分xx秒
function TimeTool.GetTimeFormatDay(less_time)
    less_time = tonumber(less_time) or 0
    local day = math.floor(less_time/TimeTool.day2s())
    local lessT = math.floor(less_time%TimeTool.day2s())
    local hour = math.floor(lessT / 3600)
    local min = math.floor((lessT % 3600) / 60)
    local sec = math.floor(lessT % 3600 % 60)
    
    if day >= 1 then
        if hour > 0 then
            return string.format(TI18N("%s天%s小时"), day, hour)
        else
            return string.format(TI18N("%s天"), day)
        end 
    else
        if sec <= 0 then
            if min <= 0 then
                if hour <=0 then
                    return ""
                end
                return string.format(TI18N("%s小时"), hour)
            else
                return string.format(TI18N("%s小时%s分"), hour, min)
            end
        end
        return string.format(TI18N("%s小时%s分"), hour, min)
    end
end

-- 大于1天显示xx天 小于一天显示 00:00:00
function TimeTool.GetTimeDayOrTime(less_time)
    less_time = tonumber(less_time) or 0
    local day = math.floor(less_time/TimeTool.day2s())
    -- local lessT = math.floor(less_time%TimeTool.day2s())
    -- local hour = math.floor(lessT / 3600)
    -- local min = math.floor((lessT % 3600) / 60)
    -- local sec = math.floor(lessT % 3600 % 60)
    local dayStr = ""
    if day >= 1 then
        dayStr = string.format(TI18N("%d天"), day)
        return dayStr
    end
    if day < 1 then
        return TimeTool.GetTimeFormat(less_time)
    end
end

-- 显示两单位计时
function TimeTool.GetTimeFormatDayII(less_time)
    less_time = tonumber(less_time) or 0
    local day = math.floor(less_time/86400)
    local lessT = math.floor(less_time%86400)
    local hour = math.floor(lessT / 3600)
    local min = math.floor((lessT % 3600) / 60)
    local sec = math.floor(lessT % 3600 % 60)
    local dayStr = ""
    local hourStr = ""
    local minStr = ""
    local secStr = ""

    if day >= 1 then
        if hour >= 1 then
            return string.format(TI18N("%s天%s小时"), day, hour)
        else
            return string.format(TI18N("%s天"), day)
        end
    end

    if hour >= 1 then
        if min >= 1 then
            return string.format(TI18N("%s小时%s分"), hour, min)
        else
            return string.format(TI18N("%s小时"), hour)
        end
    end

    if min >= 1 then
        if sec >= 1 then
            return string.format(TI18N("%s分%s秒"), min, sec)
        else
            return string.format(TI18N("%s 分"), min)
        end
    end

    return string.format(TI18N("%s秒"), sec)
end
-- 显示两单位计时
function TimeTool.GetTimeFormatDayIII(less_time)
    less_time = tonumber(less_time) or 0
    local day = math.floor(less_time/86400)
    local lessT = math.floor(less_time%86400)
    local hour = math.floor(lessT / 3600)
    local min = math.floor((lessT % 3600) / 60)
    local sec = math.floor(lessT % 3600 % 60)
    local dayStr = ""
    local hourStr = ""
    local minStr = ""
    local secStr = ""


    if day >= 1 then
        if hour >= 1 then
            return string.format(TI18N("%s天%s小时"), day, hour)
        else
            return string.format(TI18N("%s天"), day)
        end
    else
        return string.format(TI18N("%s小时%s分%s秒"), hour, min, sec)
    end
end

--当大于1天时，显示x天，小于一天时，显示x时x分
function TimeTool.GetTimeFormatDayIV(less_time)
    less_time = tonumber(less_time) or 0
	local day = math.floor(less_time/86400)
	local time_str = ""
	if day >= 1 then
		time_str = string.format(TI18N("%s天"), day)
	else
		local lessT = math.floor(less_time%86400)
		local hour = math.floor(lessT / 3600)
        local min = math.floor((lessT % 3600) / 60)
        local sec = math.floor(lessT % 3600 % 60)
		time_str = string.format("%02d:%02d:%02d", hour, min,sec)
	end
	return time_str
end



-- 获得天，小时，分，秒
function TimeTool.GetTimeName(less_time)
    less_time = tonumber(less_time) or 0
    local day = math.floor(less_time/TimeTool.day2s())
    local lessT = math.floor(less_time%TimeTool.day2s())
    local hour = math.floor(lessT / 3600)
    local min = math.floor((lessT % 3600) / 60)
    local sec = math.floor(lessT % 3600 % 60)
    
    return day, hour, min, sec
end

--大于1天显示x天x小时，少于一天显示x小时xfen
function TimeTool.GetTimeFormatDayIIIIII(less_time)
    less_time = tonumber(less_time) or 0
    local day = math.floor(less_time/TimeTool.day2s())
    local lessT = math.floor(less_time%TimeTool.day2s())
    local hour = math.floor(lessT / 3600)
    local min = math.floor((lessT % 3600) / 60)
    local sec = math.floor(lessT % 3600 % 60)
    local dayStr = ""

    if day >= 1 then
        if hour >= 1 then
            return string.format(TI18N("%s天%s小时"), day, hour)
        else
            return string.format(TI18N("%s天"), day)
        end
    end

    if hour >= 1 then
        if min >= 1 then
            return string.format(TI18N("%s小时%s分"), hour, min)
        else
            return string.format(TI18N("%s小时"), hour)
        end
    end

    return string.format(TI18N("%s小时%s分"), hour, min)
end

--大于1天显示x天x小时，少于一天显示x小时xfen
function TimeTool.GetTimeFormatDay2(less_time)
    less_time = tonumber(less_time) or 0
    local day = math.floor(less_time/TimeTool.day2s())
    local lessT = math.floor(less_time%TimeTool.day2s())
    local hour = math.floor(lessT / 3600)
    local min = math.floor((lessT % 3600) / 60)
    local sec = math.floor(lessT % 3600 % 60)
    local dayStr = ""

    if day >= 1 then
        if hour >= 1 then
            return string.format(TI18N("%s天%s小时"), day, hour)
        else
            return string.format(TI18N("%s天"), day)
        end
    end

    if hour >= 1 then
        if min >= 1 then
            return string.format(TI18N("%s小时%s分"), hour, min)
        else
            return string.format(TI18N("%s小时"), hour)
        end
    end

    if min >= 1 then
        if sec >= 1 then
            return string.format(TI18N("%s分%s秒"), min, sec)
        else
            return string.format(TI18N("%s 分"), min)
        end
    end

    return string.format(TI18N("%s秒"), sec)
end


--- 图标需要的时间显示
function TimeTool.GetTimeForFunction(less_time)
    less_time = tonumber(less_time) or 0
    local day = math.floor(less_time/TimeTool.day2s())
    local lessT = math.floor(less_time%TimeTool.day2s())
    local hour = math.floor(lessT / 3600)
    local min = math.floor((lessT % 3600) / 60)
    local sec = math.floor(lessT % 3600 % 60)
    if day >= 1 then
        return string.format(TI18N("%s天%s小时"), day, hour)
    else
        if hour >= 1 then
            return string.format("%02d:%02d:%02d", hour, min,sec)
        else
            return string.format("%02d:%02d", min,sec)
        end
    end
end

--大于1天显示x天x小时x分，小于1天显示x时x分x秒
function TimeTool.GetTimeFormatDayIIIIIII(less_time)
    less_time = tonumber(less_time) or 0
    local day = math.floor(less_time/86400)
    local lessT = math.floor(less_time%86400)
    local hour = math.floor(lessT / 3600)
    local min = math.floor((lessT % 3600) / 60)
    local time_str = ""
    if day >= 1 then
        time_str = string.format(TI18N("%s天%s小时%d分钟"), day, hour, min)
    else
        local sec = math.floor(lessT % 3600 % 60)
        time_str = string.format(TI18N("%s时%s分%s秒"), hour, min,sec)
    end
    return time_str
end

--
function TimeTool.GetTimeFormatDayIIIIIIII(less_time)
    less_time = tonumber(less_time) or 0
    local day = math.floor(less_time/86400)
    local lessT = math.floor(less_time%86400)
    local hour = math.floor(lessT / 3600)
    local min = math.floor((lessT % 3600) / 60)
    local sec = math.floor(lessT % 3600 % 60)
    local time_str = ""
    if day >= 1 then
        time_str = string.format(TI18N("%d天%02d:%02d:%02d"),day,hour,min,sec)
    else
        time_str = string.format("%02d:%02d:%02d", hour, min,sec)
    end
    return time_str
end
--邮件用 不满1天显示小时 以此类推
function TimeTool.getDayOrHour( less_time  )
    less_time = tonumber(less_time) or 0
    local day = math.floor(less_time/TimeTool.day2s())
    local lessT = math.floor(less_time%TimeTool.day2s())
    local hour = math.floor(lessT / 3600)
    local min = math.floor((lessT % 3600) / 60)
    local sec = math.floor(lessT % 3600 % 60)

    if day>=1 then
        return string.format(TI18N("%d天"), day)
    elseif hour>=1 then
        return string.format(TI18N("%d小时"), hour)
    elseif min>=1 then
        return string.format(TI18N("%d分钟"), min)
    elseif sec>=1 then
        return string.format(TI18N("%d秒"), sec)
    else
        return 0
    end
end

--留言板时间
-- 4、时间显示规则：①若小于1分钟则显示文字【刚刚】
--                  ②大于1分钟小于1小时则显示【X分钟前】
--                  ③大于1小时且在今天内则显示【X小时前】
--                  ④其余显示年-月-日
function TimeTool.getMessageBoardTime(less_time )
    less_time = tonumber(less_time) or 0

    local time = GameNet:getInstance():getTime() - less_time
    if time < 0 then
        time = 0
    end
    
    local day = math.floor(time/TimeTool.day2s())
    if day > 0 then
        return TimeTool.getYMD2(less_time)
    end
    
    local lessT = math.floor(time%TimeTool.day2s())
    local hour = math.floor(lessT / 3600)
    if hour >= 1 then
        return string.format(TI18N("%s小时前"), hour)
    end

    local min = math.floor((lessT % 3600) / 60)
    if min >= 1 then
        return string.format(TI18N("%s分钟前"), min)
    end
    return TI18N("刚刚")
end


-- 获取周几
local Num_To_Week = {TI18N("周一"),TI18N("周二"),TI18N("周三"),TI18N("周四"),TI18N("周五"),TI18N("周六"),TI18N("周日")}
function TimeTool.getWeekDay( day_list )
    if not day_list or next(day_list) == nil then return "" end
    local is_weekend = false
    local count = 0
    for k,day in pairs(day_list) do
        if day == 6 or day == 7 then
            count = count + 1
        end
    end
    is_weekend = (count >= 2)
    local week_str = ""
    local add_flag = false
    for i,day in ipairs(day_list) do
        if (day == 6 or day == 7) and is_weekend then
            if not add_flag then
                if week_str == "" then
                    week_str = TI18N("周末")
                else
                    week_str = string.format(TI18N("%s、周末"), week_str)
                end
                add_flag = true
            end
        else
            if week_str == "" then
                week_str = Num_To_Week[day]
            else
                week_str = string.format(TI18N("%s、%s"),week_str,Num_To_Week[day])
            end
        end
    end
    return week_str
end

--好友列表显示时间
-- 1   小于24小时以内，显示“xx小时前”，小时向上取整   
-- 2   大于24小时以上，显示“xx天前”，天数向上取整    
-- 3   大于72小时以上，统一显示“3天以上” 
function TimeTool.GetTimeFormatFriendShowTime(less_time)
    less_time = tonumber(less_time) or 0
    local day = math.floor(less_time/TimeTool.day2s())
    if day >= 3 then
        return TI18N("3天以上")
    end
    if day > 0 then
        return string.format(TI18N("%s天前"), day)
    end
    local lessT = math.floor(less_time%TimeTool.day2s())
    local hour = math.ceil(lessT / 3600)
    if hour <= 0 then
        hour = 1
    end
    return string.format(TI18N("%s小时前"), hour)
end

-- 获取时间，将XX-XX格式转成XXXX数字
-- 例如：06-10 -->  610
function TimeTool.getMixTime(time)
    if not time then return end
    if type(time) == "string" then
        local month = 0
        local day = 0
        local begin_index, end_index = string.find(time, "-")
        if begin_index and end_index then
            month = string.sub(time, 1, begin_index - 1)
            day = string.sub(time, end_index + 1)
        end
        return tonumber(month..day)
    end
    return nil
end

-- 获取时间，将XXXX数字转成XX-XX格式
-- 例如：610 --> 06-10 
function TimeTool.getSplitTime(time)
    if not time then return end
    if type(time) == "number" then
        local month = 0
        local day = 0
        time = tostring(time)
        if string.len(time) == 3 then
            month = string.sub(time, 1, 1)
            month = "0"..month
            day = string.sub(time, 2, 3)
        elseif string.len(time) == 4 then
            month = string.sub(time, 1, 2)
            day = string.sub(time, 3, 4)
        end
        return month.."-"..day
    end
    return nil
end

--[[
    @desc: 获取手机所在的时区 
    author:{author}
    time:2019-12-21 14:54:30
    @return:
]]
function TimeTool.getTimeZone()
    local now = os.time()
    local time_zone = os.difftime(now, os.time(os.date("!*t", now)))
    return time_zone/3600
end


