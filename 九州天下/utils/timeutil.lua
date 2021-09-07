--[[
	时间函数库
	常用时间格式
	%a abbreviated weekday name (e.g., Wed)
	%A full weekday name (e.g., Wednesday)
	%b abbreviated month name (e.g., Sep)
	%B full month name (e.g., September)
	%c date and time (e.g., 09/16/98 23:48:10)
	%d day of the month (16) [01-31]
	%H hour, using a 24-hour clock (23) [00-23]
	%I hour, using a 12-hour clock (11) [01-12]
	%M minute (48) [00-59]
	%m month (09) [01-12]
	%p either "am" or "pm" (pm)
	%S second (10) [00-61]
	%w weekday (3) [0-6 = Sunday-Saturday]
	%x date (e.g., 09/16/98)
	%X time (e.g., 23:48:10)
	%Y full year (1998)
	%y two-digit year (98) [00-99]
	%% the character '%'
	用法：
	os.date("%x",os.time()) --> 07/29/2014
	os.date("%Y-%m-%d", os.time()) --> 2014-07-29
]]

TimeUtil = TimeUtil or {}

function TimeUtil.FormatSecond(time, model)
	local s = ""
	if time > 0 then
		local hour = math.floor(time / 3600)
		local minute = math.floor((time / 60) % 60)
		local second = math.floor(time % 60)
		if 4 == model then
			s = string.format("%02d分%02d秒", minute, second)
		elseif 2 == model then
			s = string.format("%02d:%02d", minute, second)
		elseif 1 == model then
			s = string.format("%02d时%02d分", hour, minute)
		else
			s = string.format("%02d:%02d:%02d", hour, minute, second)
		end
	else
		if 2 == model then
			s = string.format("%02d:%02d", 0, 0)
		elseif 3 == model then
			s = string.format("%02d:%02d:%02d", 0, 0, 0)
		elseif 4 == model then
			s = string.format("%02d分%02d秒", 0, 0)
		end
	end

	return s
end

function TimeUtil.Format2TableDHM(time)
	local time_tab = {day = 0, hour = 0, min = 0}
	if time > 0 then
		time_tab.day = math.floor(time / (60 * 60 * 24))
		time_tab.hour = math.floor((time / (60 * 60)) % 24)
		time_tab.min = math.floor((time / 60) % 60)
	end
	return time_tab
end

function TimeUtil.Format2TableDHMS(time)
	local time_tab = {day = 0, hour = 0, min = 0, s = 0}
	if time > 0 then
		time_tab.day = math.floor(time / (60 * 60 * 24))
		time_tab.hour = math.floor((time / (60 * 60)) % 24)
		time_tab.min = math.floor((time / 60) % 60)
		time_tab.s = math.floor(time % 60)
	end
	return time_tab
end

function TimeUtil.FormatSecond2HMS(time)
	local s = TimeUtil.FormatSecond(time, 3)

	return s
end

function TimeUtil.FormatSecond2MS(time)
	local s = TimeUtil.FormatSecond(time, 2)

	return s
end

function TimeUtil.FormatTable2HMS(time_tab)
	if nil == time_tab then
		return
	end

	local hour = time_tab.hour
	local minute = time_tab.min
	local second = time_tab.sec or time_tab.s
	s = string.format("%02d:%02d:%02d", hour, minute, second)

	return s
end

function TimeUtil.FormatSecond2Str(time, model)
	if nil == time then
		return ""
	end
	local time_t = TimeUtil.Format2TableDHMS(time)
	local time_str = ""
	if time_t.day > 0 then
		time_str = time_str .. time_t.day .. Language.Common.TimeList.d
	end
	if time_t.hour > 0 or "" ~= time_str then
		time_str = time_str .. time_t.hour .. Language.Common.TimeList.h
	end
	if time_t.min > 0 or "" ~= time_str or model == 1 then
		time_str = time_str .. time_t.min .. Language.Common.TimeList.min
	end
	if time_t.s >= 0 or "" ~= time_str then
		if model ~= 1 then
			time_str = time_str .. time_t.s .. Language.Common.TimeList.s
		end
	end
	return time_str
end

-- 计算时区
function TimeUtil.GetTimeZone()
	local now = os.time()
	return os.difftime(now, os.time(os.date("!*t", now)))
end

-- 比较两个时间，返回相差多少时间
function TimeUtil.Timediff(long_time,short_time)
    local n_short_time,n_long_time,carry,diff = os.date('*t',short_time),os.date('*t',long_time),false,{}
    local colMax = {60,60,24,os.date('*t',os.time{year=n_short_time.year,month=n_short_time.month+1,day=0}).day,12,0}
    n_long_time.hour = n_long_time.hour - (n_long_time.isdst and 1 or 0) + (n_short_time.isdst and 1 or 0) -- handle dst
    for i,v in ipairs({'sec','min','hour','day','month','year'}) do
        diff[v] = n_long_time[v] - n_short_time[v] + (carry and -1 or 0)
        carry = diff[v] < 0
        if carry then
            diff[v] = diff[v] + colMax[i]
        end
    end
    return diff
end

--获取当天的开始时间戳
function TimeUtil.NowDayTimeStart(now_time)
	local tab = os.date("*t", now_time)
	tab.hour = 0
	tab.min = 0
	tab.sec = 0
	return os.time(tab)
end

--获取当天的结束时间戳
function TimeUtil.NowDayTimeEnd(now_time)
	local tab = os.date("*t", now_time)
	tab.hour = 0
	tab.min = 0
	tab.sec = 0
	return tonumber(os.time(tab) + 86400)
end

--某个时间点距离当前是多久前发生
function TimeUtil.LastDonateTime(time)
	if nil == time then
		return ""
	end
	local t_time = TimeUtil.Format2TableDHMS(time)
	local last_time = ""

	if t_time.day ~= 0 then
        last_time = string.format(Language.Common.BeforeXXDay, t_time.day)
        return last_time
    end
    if t_time.hour ~= 0 then
        last_time = string.format(Language.Common.BeforeXXHour, t_time.hour)
        return last_time
    end
    if t_time.min ~= 0 then
        last_time = string.format(Language.Common.BeforeXXMinute, t_time.min)
        return last_time
    end
    if t_time.s ~= 0 then
	    last_time = string.format(Language.Common.JustMoment)
    end
    return last_time
end

function TimeUtil.FormatSecond2DHMS(time,sflag)
	local time_tab = TimeUtil.Format2TableDHMS(time)
	local str_list = Language.Common.TimeList
	if sflag == 1 then
		return string.format("%02d%s%02d%s%02d%s",
					time_tab.day, str_list.d,
					time_tab.hour, str_list.h,
					time_tab.min, str_list.min)
	elseif sflag == 2 then
		return string.format("%02d%s%02d%s",
			time_tab.day, str_list.d,
			time_tab.hour, str_list.h)
	elseif sflag == 3 then
        return string.format("%d%s%02d%s",
			time_tab.day, str_list.d,
			time_tab.hour, str_list.h)
    elseif sflag == 4 then
	    return string.format("%d%s%d%s",
			time_tab.day, str_list.d,
			time_tab.hour, str_list.h)
	elseif sflag ==5 then
		return string.format("%02d%s%02d%s%02d%s",
			time_tab.hour, str_list.h,
			time_tab.min, str_list.min,
			time_tab.s, str_list.s)
	else
		return string.format("%02d%s%02d%s%02d%s%02d%s",
			time_tab.day, str_list.d,
			time_tab.hour, str_list.h,
			time_tab.min, str_list.min,
			time_tab.s, str_list.s)
	end
end