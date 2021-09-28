--time.lua
--/*-----------------------------------------------------------------
 --* Module:  time.lua
 --* Author:  Huang YingTian
 --* Modified: 2008年5月23日 16:03:57
 --* Purpose: time功能函数集合:目前仅支持format: t="2009-05-15 09:10:44"
 -------------------------------------------------------------------*/

time = {}
function time.year(timeStr)
	if (type(timeStr)=="string" and string.len(timeStr)>4) then
		return tonumber(string.sub(timeStr,1,4))
	end
end

function time.month(timeStr)
	if (type(timeStr)=="string" and string.len(timeStr)>7) then
		return tonumber(string.sub(timeStr,6,7))
	end
end

function time.day(timeStr)
	if (type(timeStr)=="string" and string.len(timeStr)>10) then
		return tonumber(string.sub(timeStr,9,10))
	end
end

function time.hour(timeStr)
	if (type(timeStr)=="string" and string.len(timeStr)>13) then
		return tonumber(string.sub(timeStr,12,13))
	end
end

function time.min(timeStr)
	if (type(timeStr)=="string" and string.len(timeStr)>16) then
		return tonumber(string.sub(timeStr,15,16))
	end
end

function time.sec(timeStr)
	if (type(timeStr)=="string" and string.len(timeStr)>=19) then
		return tonumber(string.sub(timeStr,18,19))
	end
end

function time.weekday(day)
	local daysw = {
		[1] = "星期日",
		[2] = "星期一",
		[3] = "星期二",
		[4] = "星期三",
		[5] = "星期四",
		[6] = "星期五",
		[7] = "星期六",
	}
	return daysw[day]
end

--(format :"2009-05-15 09:10:44")字符串转换为lua time
function time.totime(timeStr)
	local y=time.year(timeStr)
	local m=time.month(timeStr)
	local d=time.day(timeStr)
	local h=time.hour(timeStr)
	local min=time.min(timeStr)
	local sec=time.sec(timeStr)
	if (y and m and d and h and min and sec) then
		local ttime={year=y,month=m,day=d,hour=h,
		min=min,sec=sec}
		return os.time(ttime)
	end
end

--lua time转换为字符串(format :"2009-05-15 09:10:44")
function time.tostring(lua_time)
	local t=os.date("*t",lua_time)
	if (type(t)=="table" and table.size(t)==9) then
		return string.format("%d-%.2d-%.2d %.2d:%.2d:%.2d", t.year, t.month, t.day, t.hour, t.min, t.sec)
	end
end

--lua time转换为字符串(format :"2011年09月16日 13:28:21 星期五")
function time.totext(lua_time)
	local t=os.date("*t",lua_time)
	if (type(t)=="table" and table.size(t)==9) then
		return string.format("%d年%.2d月%.2d日 %.2d:%.2d:%.2d %s", t.year, t.month, t.day, t.hour, t.min, t.sec, time.weekday(t.wday))
	end
end

local __delayTime = 0 * 60 * 60
local __EditionBaseTime=time.totime("2011-07-31 00:00:00")	--周日为每周第一天
local __WeekSeconds=60*60*24*7
function time.toedition(period, lua_time)
	local edition = 0
	lua_time =lua_time or os.time()
	lua_time = lua_time - __delayTime
	if period=="hour" then					--2011080319(10)
		local t=os.date("*t",lua_time)
		edition= t["year"]*1000000+t["month"]*10000+t["day"]*100+t["hour"]
	elseif period=="mday" then				--20110804(8)
		local t=os.date("*t",lua_time)
		edition= t["year"]*10000+t["month"]*100+t["day"]
	elseif period=="day" then				--20110803(8)
		local t=os.date("*t",lua_time)
		edition= t["year"]*10000+t["month"]*100+t["day"]
	elseif period=="date" then				--20110803(8)
		local t=os.date("*t",lua_time)
		edition= t["year"]*10000+t["month"]*100+t["day"]
	elseif period=="yday" then				--20110803(8)
		local t=os.date("*t",lua_time)
		edition= t["year"]*10000+t["month"]*100+t["day"]
	elseif period=="month" then				--201108(6)
		local t=os.date("*t",lua_time)
		edition= t["year"]*100+t["month"]
	elseif period=="wday" then				--100013(6)
		local t=os.date("*t",lua_time)
		local past=os.difftime(lua_time, __EditionBasetime)
		local week=math.ceil(past/__WeekSeconds)
		edition=week+10000+t["wday"]
	elseif period=="year" then				--2011(4)
		local t=os.date("*t",lua_time)
		edition=t["year"]
	elseif period=="week" then				--10001(5)
		local past=os.difftime(lua_time,__EditionBasetime)
		edition=10000+math.ceil(past/__WeekSeconds)
	end
	return edition
end

function time.todate(dtype, day, quarter)
	quarter = quarter or 0
	local datevalue = 0
	local lua_time = os.time()

	if dtype=="mday" then					--20110800(8)
		day = day or 1
		local t=os.date("*t",lua_time)
		datevalue= t["year"]*1000000+t["month"]*10000+day*100+quarter
	elseif dtype=="day" then				--20110803(8)
		local t=os.date("*t",lua_time)
		datevalue= t["year"]*1000000+t["month"]*10000+t["day"]*100+quarter
	elseif dtype=="yday" then				--20110803(8)
		local t=os.date("*t",lua_time)
		day = day or 0101
		datevalue=t["year"]*1000000+day*100+quarter
	elseif dtype=="wday" then				--10100(5)
		day = day or 1
		local t=os.date("*t",lua_time)
		local past=os.difftime(lua_time,__EditionBasetime)
		local week=math.ceil(past/__WeekSeconds)
		datevalue=(week+10000+day)*100+quarter
	elseif dtype=="date" then
		day = day or 20120101
		datevalue=day*100+quarter
	end
	return datevalue
end

function time.towday(dtype, day)
	local t = os.date("*t", os.time())
	if dtype=="mday" then
		local luaTime = time.totime(string.format("%d-%.2d-%.2d 12:00:00", t.year, t.month, day))
		local tm = os.date("*t", luaTime)
		return tm.wday
	elseif dtype=="day" then
		return t.wday
	elseif dtype=="yday" then
		local luaTime = time.totime(string.format("%d-%.2d-%.2d 12:00:00", t.year, (day-day%100)/100, day%100))
		local tm = os.date("*t", luaTime)
		return tm.wday
	elseif dtype=="wday" then
		return day
	elseif dtype=="date" then
		local luaTime = time.totime(string.format("%d-%.2d-%.2d 12:00:00", (day-day%10000)/10000, (day%10000-day%100)/100, day%100))
		local tm = os.date("*t", luaTime)
		return tm.wday
	end
	return 0
end

function time.toquarter()
	local t=os.date("*t",os.time())
	return t["hour"]*4 + math.floor(t["min"]/15)
end

function time.tominute()
	local t=os.date("*t",os.time())
	return t["min"], t["sec"]
end


function time.isclock()
	local t = os.date("*t", os.time())
	if t.min == 0 and t.sec == 0 then
		return true, t.hour, t.day
	end
	return false, t.hour, t.day
end