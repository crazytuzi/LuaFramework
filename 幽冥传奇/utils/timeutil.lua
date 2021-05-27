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
		if 2 == model then
			s = string.format("%02d:%02d", minute, second)
		else
			s = string.format("%02d:%02d:%02d", hour, minute, second)
		end		
	else
		if 2 == model then
			s = string.format("%02d:%02d", 0, 0)
		elseif 3 == model then
			s = string.format("%02d:%02d:%02d", 0, 0, 0)
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

function TimeUtil.Format2TableHMS(time)
	local time_tab = {hour = 0, min = 0, s = 0}
	if time > 0 then
		time_tab.hour = math.floor(time / (60 * 60))
		time_tab.min = math.floor((time / 60) % 60)
		time_tab.s = math.floor(time % 60)
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
	local second = time_tab.sec
	s = string.format("%02d:%02d:%02d", hour, minute, second)

	return s
end

function TimeUtil.FormatSecond2Str(time)
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
	if time_t.min > 0 or "" ~= time_str then
		time_str = time_str .. time_t.min .. Language.Common.TimeList.min
	end	
	if time_t.s >= 0 or "" ~= time_str then
		time_str = time_str .. time_t.s .. Language.Common.TimeList.s
	end
	return time_str
end

function TimeUtil.FormatHM(time)
	if nil == time then
		return ""
	end
	local time_t = TimeUtil.Format2TableDHMS(time)
	local time_str = ""
	if time_t.hour > 0 or "" ~= time_str then
		time_str = time_str .. time_t.hour .. Language.Common.TimeList.h
	end
	if time_t.min > 0 or "" ~= time_str then
		time_str = time_str .. time_t.min .. Language.Common.TimeList.min
	end	
	return time_str
end

-- 获取这个月的天数
local month_day_list = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
function TimeUtil.GetMonthDay(year, month)
	if month == 2 then
		if year % 4 == 0 and year % 100 ~= 0 then
			return 29
		end
	end
	return month_day_list[month]
end

function TimeUtil.FormatTimeCfg(cfg)
	local server_time = TimeCtrl.Instance:GetServerTime()
	if server_time < 1000 then
		server_time = math.floor(GLOBAL_CONFIG.server_info.server_time + (Status.NowTime - GLOBAL_CONFIG.client_time))
	end
	local date_t = Split(os.date("%w-%H-%M-%S", server_time), "-")
	local weekday = date_t[1]
	if weekday == 0 then
		weekday = 7
	end
	local today_begin_time = server_time - date_t[2] * 3600 - date_t[3] * 60 - date_t[4]
	local ret_time = {is_in_day = true, weeks = {}, times = {}}
	if nil ~= cfg.weeks then
		local len = #cfg.weeks
		local is_in_day = false
		if 1 == len and 0 == cfg.weeks[1] then
			ret_time.weeks = {1, 2, 3, 4, 5, 6, 7}
			is_in_day = true
		else
			for i, v in pairs(cfg.weeks) do
				ret_time.weeks[#ret_time.weeks + 1] = v
				if v == weekday then
					is_in_day = true
				end
			end
		end

		ret_time.is_in_day = is_in_day
	end
	if nil ~= cfg.times then
		for k, v in pairs(cfg.times) do
			local s = today_begin_time + tonumber(v[1]) * 3600 + tonumber(v[2]) * 60
			local e = today_begin_time + tonumber(v[3]) * 3600 + tonumber(v[4]) * 60
			local is_in_time = server_time >= s and server_time <= e
			local left_time = is_in_time and e - server_time or 0
			ret_time.times[#ret_time.times + 1] = {
				start_time = s,
				end_time = e,
				is_in_time = is_in_time,
				left_time = left_time,
				time_str = v[1] .. ":" .. v[2] .. "-" .. v[3] .. ":" .. v[4]
			}
		end
	end
	return ret_time
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

--获取离下个星期几剩余时间（星期天为第一天）
function TimeUtil.RestTimeToWeekDay(wday)
	local cur_time =TimeCtrl.Instance:GetServerTime()
	local tab = os.date("*t", cur_time)
	tab.hour = 0
	tab.min = 0
	tab.sec = 0
	--剩余天数
    local rest_day = (wday - tab.wday + 7)%7 
	--下个星期某一天的时间戳
	if rest_day == 0 then
		rest_day = 7
	end
	local time=   tonumber(os.time(tab)) + rest_day*86400
	return time - cur_time
end