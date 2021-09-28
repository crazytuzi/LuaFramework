
TimeTool = {}

--[[
功能：生成时间格式为00:00:00的(时：分：秒)
--]]
function TimeTool.GetTimeFormat(less_time)
	local hour = math.floor(less_time / 3600)
	hour = (hour < 10) and "0"..hour or hour
	local min = math.floor((less_time % 3600) / 60)
	min = (min < 10) and "0"..min or min
	local sec = less_time % 3600 % 60
	sec = (sec < 10) and "0"..sec or sec
	return hour .. ":" .. min .. ":" .. sec
end


--[[
功能：生成时间格式为00:00:00的(时：分：秒)
--]]
function TimeTool.GetTimeFormatII(less_time)
	local hour = math.floor(less_time / 3600)
	-- hour = (hour < 10) and "0"..hour or hour
	local min = math.floor((less_time % 3600) / 60)
	-- min = (min < 10) and "0"..min or min
	local sec = math.floor(less_time % 3600 % 60)
	-- sec = (sec < 10) and "0"..sec or sec

	if sec <= 0 then
		if min <= 0 then
			return hour .. "小时"
		else
			return hour .. string.format("小时%s分", min)
		end
	end
	return hour .. string.format("小时%s分%s秒", min, sec)
end

--[[
功能：生成时间格式为00:00:00的(时：分：秒)
--]]
function TimeTool.GetTimeFormatIII(less_time)
	local hour = math.floor(less_time / 3600)
	hour = (hour < 10) and "0"..hour or hour
	local min = math.floor((less_time % 3600) / 60)
	min = (min < 10) and "0"..min or min
	return hour .. ":" .. min
end


--[[
功能：生成时间格式为00:00:00的(分：秒)
--]]
function TimeTool.GetTimeMS(less_time,isNum)
	local hour = math.floor(less_time / 3600)
	local min = math.floor((less_time % 3600) / 60)
	local sec = math.floor(less_time % 3600 % 60)
	if isNum then
		sec = (sec < 10) and "0"..sec or sec
		local max_m = hour*60+min
		max_m = (max_m < 10) and "0".. max_m or max_m
		return  max_m .. ":" .. sec
	else
		return string.format("%s分%s秒", hour*60+min, sec)
	end
end
function TimeTool.GetTimeHMS(less_time,isNum)
	local hour = math.floor(less_time / 3600)
	local min = math.floor((less_time % 3600) / 60)
	local sec = math.floor(less_time % 3600 % 60)
	if isNum then
		sec = (sec < 10) and "0"..sec or sec
		local max_m = min
		max_m = (max_m < 10) and "0".. max_m or max_m
		return  hour..":"..max_m .. ":" .. sec
	else
		return string.format("%s时%s分%s秒",hour, min, sec)
	end
end

function TimeTool.GetTimeDHM(less_time)
	if less_time <= 0 then return -1 end
	local day = math.floor(less_time / (3600 * 24))
	local hour = math.floor((less_time % (3600 * 24) / 3600))
	local min = math.floor((less_time % 3600) / 60)

	local strTime = ""
	if day > 0 then
		strTime = string.format("%s天" , day)
	end

	if hour > 0 then
		strTime = string.format("%s%s时" , strTime , hour)
	end

	if min > 0 then
		strTime = string.format("%s%s分" , strTime ,  min)
	end

	return strTime
end
function TimeTool.GetTimeDHM2(less_time)
	if less_time <= 0 then return -1 end
	local day = math.floor(less_time / (3600 * 24))
	local hour = math.floor((less_time % (3600 * 24) / 3600))
	local min = math.floor((less_time % 3600) / 60)

	local strTime = ""
	if day > 0 then
		strTime = string.format("%s天" , day)
	end

	if hour > 0 then
		strTime = string.format("%s%s小时" , strTime , hour)
	end

	if min > 0 then
		strTime = string.format("%s%s分钟" , strTime ,  min)
	end

	return strTime
end

function TimeTool.GetTimeD(less_time)
	if less_time <= 0 then return -1 end
	local day = math.floor(less_time / (3600 * 24))
	local strTime = ""
	if day > 0 then
		strTime = string.format("%s天" , day)
	end
	return strTime
end

-- 相隔时间
function TimeTool.GetTimeOutTime(t)
	return TimeTool.GetTimeDHM2((TimeTool.GetCurTime()-t)*0.001)
end
-- x年x月x日
function TimeTool.GetTimeYMD(less_time)
	return os.date("%Y年%m月%d日", less_time*0.001)
end
-- x月-x日
function TimeTool.GetTimeYMD2(less_time)
	return os.date("%m月%d日", less_time*0.001)
end
-- 年-月-日 时：分：秒
function TimeTool.getYMDHMS(less_time)
   return os.date("%Y-%m-%d %X ", less_time*0.001)
end
function TimeTool.getYMDHMS2(less_time)
   return os.date("%Y年%m月%d日 %X ", less_time*0.001)
end
-- 生成时间格式为(日 时：分：秒)
function TimeTool.getDHMS(less_time)
   return os.date("%d %X ", less_time*0.001)
end
-- 生成时间格式为(年-月-日)
function TimeTool.getYMD(less_time)
   return os.date("%Y-%m-%d", less_time*0.001)
end
-- 生成时间格式为(月-日)
function TimeTool.getYMD2(less_time)
   return os.date("%m-%d", less_time*0.001)
end

--生成时间格式为（年-月-日 00:00:00）
function TimeTool.getYMD3(less_time)
	return os.date("%Y-%m-%d" , less_time*0.001) .. " 00:00:00"
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

function TimeTool.GetDiffTime(timestamp)
	return os.difftime(timestamp*0.001 , os.time())
end

--获取指定字符串时间
--@param str YY-MM-DD HH:MM:SS 2017-04-27 19:33:00
function TimeTool.GetTimeByYYMMDD_HHMMSS(str)
	local yy = string.sub(str, 1, 4)
	local mm = string.sub(str, 6, 7)
	local dd = string.sub(str, 9, 10)
	local h = string.sub(str, 12, 13)
	local m = string.sub(str, 15, 16)
	local s = string.sub(str, 18, 19)
	return os.time({year=yy, month=mm, day=dd, hour=h, min=m, sec=s, isdst=false})
end

function TimeTool.SetServerTime( t, notice )
	TimeTool._srvTime = t
	if notice then
		GlobalDispatcher:DispatchEvent(EventName.SERVER_TIME_CHANGE, t)
	end
end
-- 后端系统时间
function TimeTool.GetCurTime()
	return TimeTool._srvTime or os.time()*1000
end

--获取星期几
function TimeTool.GetWeekDay()
	local result = os.date("%w", TimeTool.GetCurTime()*0.001)
	if tonumber(result) == 0 then
		return 7
	else
		return result
	end
end

--获取当时服务器时间的时分秒
function TimeTool.GetServerTimeHMS()
 	return os.date("%H:%M:%S" , TimeTool.GetCurTime() * 0.001)
end

--比较两个时间(24小时制)的先后
function TimeTool.DiffTimeHM(h1 , m1 , h2 , m2)
	local isAfter = false
	if (h1 < h2) or (h1 == h2  and m1 < m2) then
		isAfter = true
	end
	return isAfter
end

--获取时分表示 00:00
function TimeTool.GetHHSS(hour, minute)
	local tHour = hour
	if tHour < 10 then
		tHour = "0"..tHour
	end
	local tMinute = minute
	if tMinute < 10 then
		tMinute = "0"..tMinute
	end
	return tHour..":"..tMinute
end
