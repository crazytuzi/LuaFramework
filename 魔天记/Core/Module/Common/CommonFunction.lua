local socket = require "socket"
local ceil = math.ceil
-- tsTime:单位毫秒 输出文本
function TimeTranslate(tsTime, n)
	return TimeTranslateSecond(tsTime / 1000)
end
local day,hour,minute,second = 86400,3600,60,1
local insert, floor, concat = table.insert, math.floor, table.concat
-- tsTime:单位秒 输出文本
function TimeTranslateSecond(tsTime, n)
    n = n or 1
    local res = {}
    local act = function(u, fm)
        local t = floor(tsTime / u)
        tsTime = tsTime - u * t
        insert(res, t) insert(res, fm) 
        n = n - 1
    end
    if n > 0 and tsTime > day then act(day, LanguageMgr.Get("time/day")) end
    if n > 0 and tsTime > hour then act(hour, LanguageMgr.Get("time/hour")) end
    if n > 0 and tsTime > minute then act(minute, LanguageMgr.Get("time/minute")) end
    if n > 0 and tsTime > second then act(second, LanguageMgr.Get("time/second")) end
    if #res  == 0 then s = LanguageMgr.Get("time/permanent") end
    return concat(res)
end

local _setserverTime = os.time()
local _serverTime = _setserverTime
local _offset = 0
local function GetTimezone()
  local now = os.time()
  return os.difftime(now, os.time(os.date("!*t", now)))
end
--获取时区之间的偏移值
function GetTimezoneOffset()
	return _offset
end
-- 设置服务器时间
function SetServerTime(Millisecond,off)	
	_offset = GetTimezone() - off /1000
	_serverTime = ceil(Millisecond / 1000) 
	_setserverTime = socket.gettime()
	 
end
-- 返回当前服务器时间(秒)

--获取游戏进行时间
function GetGameTime()
	return socket.gettime() - _setserverTime;
end 

local _GetGameTime = GetGameTime

function GetTime()
	return _serverTime + ceil(_GetGameTime());
end
-- 返回当前服务器时间(毫秒)
function GetTimeMillisecond()
	return _serverTime * 1000 + ceil(_GetGameTime() *1000)
end

--获取偏移后的时间值 单位秒
function GetOffsetTime( )
	return GetTime() + _offset
end

--获取偏移后的时间值 单位秒
function GetOffsetTimeMillisecond( )
	return GetOffsetTime()* 1000
end



function GetAffterTimeByStr(sec)	
	local day = math.floor(sec /(3600 * 24));
	local hour = math.floor(sec / 3600);
	local minute = math.floor(sec / 60);	
	if day > 0 then
		return LanguageMgr.Get("time/step/3", {t = day});
	elseif hour > 0 then
		return LanguageMgr.Get("time/step/2", {t = hour});
	elseif minute > 0 then
		return LanguageMgr.Get("time/step/1", {t = minute});
	end
	
	return LanguageMgr.Get("time/step/1", {t = 1});	
end

-- 获取一个字符串日期的时间戳 格式 "2057-09-20 09:00:00"
function GetTimestamp(str)
	local year = string.sub(str, 1, 4);
	local month = string.sub(str, 6, 7);
	local day = string.sub(str, 9, 10);
	
	local hour = string.sub(str, 12, 13);
	local min = string.sub(str, 15, 16);
	local sec = string.sub(str, 18, 19);
	
	--[[    log("year "..year);
    log("month "..month);
    log("day "..day);
    log("hour "..hour);
    log("min "..min);
     log("sec "..sec);
    ]]
	local t = os.time({year = tonumber(year), month = tonumber(month), day = tonumber(day), hour = tonumber(hour), min = tonumber(min), sec = tonumber(sec)});
	
	return t;
end
-- 获取一个字符串日期的时间戳 格式 "x-x-x x:x:x"
local TimestampFormat = "(%d+)-(%d+)-(%d+)%s+(%d+):(%d+):(%d+)"
function GetTimestamp2(str)
	local y, mo, d, h, m, s = str:match(TimestampFormat)
	local t = os.time({ year = y, month = mo, day = d, hour = h, min = m, sec = s })   
	return t;
end

--[[17:37:50.349-355: --sec= [50]
--min= [37]
--day= [5]
--isdst= [false]
--wday= [5]
--yday= [5]
--year= [2017]
--month= [1]
--hour= [17]

]]
function GetDateObj(add_day)
	
	local currTime = os.time();
	
	if add_day ~= nil then
		currTime = currTime + Date.Day * add_day;
	end
	
	local newTime = os.date("*t", currTime)
	
	return newTime;
end


-- 把 单位为 秒的 数字转换成   00:00:00 格式 的 字符串
function GetTimeByStr(sec)
	if sec < 0 then
		return "-- --";
	end
	

	local m = math.floor(sec) % 60;
	local h = math.floor(math.floor(sec) / 3600);
	local f = math.floor(math.floor(sec - 3600 * h) / 60);
	
	return string.format("%.2d:%.2d:%.2d", h, f, m);
end

-- 把 单位为 秒的 数字转换成   00:00 格式 的 字符串
function GetTimeByStr1(sec)
	if sec < 0 then
		return "-- --";
	end
	
	-- local res = "";
	-- local hour = math.floor(sec / 3600);
	-- local elseSec = sec - hour * 3600;
	-- local minute = math.floor(elseSec / 60);
	-- if minute > 9 then
	-- 	res = res .. minute .. ":";
	-- else
	-- 	res = res .. "0" .. minute .. ":";
	-- end
	-- elseSec = math.floor(elseSec - minute * 60);
	-- if elseSec > 9 then
	-- 	res = res .. elseSec;
	-- else
	-- 	res = res .. "0" .. elseSec;
	-- end
	-- return res;
	local m = math.floor(sec) % 60;
	local f = math.floor(math.floor(sec) / 60);
	return string.format("%.2d:%.2d", f, m);
end



function GetTimeMinuteByStr(sec)
	local minute = math.floor(sec / 60);
	return minute .. LanguageMgr.Get("time/minute");
end

--  x分钟x秒
function GetTimeByStr3(sec)
	local minute = math.floor(sec / 60);	
	local elseSec = math.floor(sec - minute * 60);
	return minute .. LanguageMgr.Get("time/minute") .. elseSec .. LanguageMgr.Get("time/second");
	
end

function GetNumStrW(v)
	
	if v >= 100000 then
		local res = v / 10000;
		res = math.floor(res);
		return res .. LanguageMgr.Get("Common/W");
	end
	return "" .. v;
end

local _lvDes = "Lv."
local _lvAdvance = LanguageMgr.Get("player/lvAdvance")
function GetLvDes(level)	
	return _lvDes .. GetLvDes1(level)	
end

function GetLvDes1(level)
	if(level > 400) then
		return _lvAdvance ..(level - 400)
	end
	return level
end

function GetLv(level)
	if(level > 400) then
		return level - 400
	end
	return level
end


function GetNumByCh(i)
	return LanguageMgr.Get("number/"..i);
end

function ConfigSplit(str)
	if(str and str ~= "") then
		return string.split(str, "_")
	end
	
	return nil
end
Date = {}
Date.Second = 1-- 000 --秒
Date.Minute = 60 * Date.Second -- 分
Date.Hour = 60 * Date.Minute -- 时
Date.Day = 24 * Date.Hour -- 天
Date.Week = 7 * Date.Day -- 周

-- 设置sprite显示的数字,sprs有序的显示sprite,num数值
function SetNumForSprite(sprs, num)
    local sn = num .. ""
    local sl = #sprs
    local nl = string.len(sn)
    for i = 1, sl, 1 do
        local s = sprs[i]
        s.spriteName = i <= nl and string.sub(sn, i, i) or ""
    end
end