--
-- Created by IntelliJ IDEA.
-- User: Stefan
-- Date: 2014/6/20
-- Time: 9:20
-- To change this template use File | Settings | File Templates.
--


function _G.Debug(...)
    _G.print(...)
end

function _G.Error(...)
    _G.print("#Error: ", ...)
end

_G.Utils = {}
function Utils.dump(obj)
    local getIndent, quoteStr, wrapKey, wrapVal, dumpObj
    getIndent = function(level)
        return string.rep("\t", level)
    end
    quoteStr = function(str)
        return '"' .. string.gsub(str, '"', '\\"') .. '"'
    end
    wrapKey = function(val)
        if type(val) == "number" then
            return "[" .. val .. "]"
        elseif type(val) == "string" then
            return "[" .. quoteStr(val) .. "]"
        else
            return "[" .. tostring(val) .. "]"
        end
    end
    wrapVal = function(val, level)
        if type(val) == "table" then
            return dumpObj(val, level)
        elseif type(val) == "number" then
            return val
        elseif type(val) == "string" then
            return quoteStr(val)
        else
            return tostring(val)
        end
    end
    dumpObj = function(obj, level)
        if type(obj) ~= "table" then
            return wrapVal(obj)
        end
        level = level + 1
        local tokens = {}
        tokens[#tokens + 1] = "{"
        for k, v in pairs(obj) do
            tokens[#tokens + 1] = getIndent(level) .. wrapKey(k) .. " = " .. wrapVal(v, level) .. ","
        end
        tokens[#tokens + 1] = getIndent(level - 1) .. "}"
        return table.concat(tokens, "\n")
    end
    return dumpObj(obj, 0)
end

_G.table = _G.table or {}

table.loadstring = function(strData)
    if strData == nil or strData == "" then
        return {}
    end
    local f = loadstring("do local ret=" .. strData ..  " return ret end")
    if f then
        return f() or {}
    else
        return {}
    end
end

table.tostring = function(t)
    local mark={}
    local assign={}
    local ser_table 
    if type(t) ~= "table" then
        return "{}"
    end
    ser_table = function (tbl,parent)
        mark[tbl]=parent
        local tmp={}
        for k,v in pairs(tbl) do
            local key= type(k)=="number" and "["..k.."]" or "[".. string.format("%q", k) .."]"
            if type(v)=="table" then
                local dotkey= parent.. key
                if mark[v] then
                    table.insert(assign,dotkey.."="..mark[v])
                else
                    table.insert(tmp, key.."="..ser_table(v,dotkey))
                end
            elseif type(v) == "string" then
                table.insert(tmp, key.."=".. string.format('%q', v))
            elseif type(v) == "number" or type(v) == "boolean" then
                table.insert(tmp, key.."=".. tostring(v))
            end
        end
        return "{"..table.concat(tmp,",").."}"
    end
    if #assign > 0 then
        Debug(debug.traceback())
    end
    return ser_table(t, "ret") .. table.concat(assign," ")
end

table.clone = function(srctable)
    if (srctable == nil) then
        return nil
    else
        return table.loadstring(table.tostring(srctable))
    end
end


_G.NULL_FUNCTION = function() end

_G.trace = function(e)
    if type(e) == "table" then
        print(tostringex(e))
    else
        print(tostring(e))
    end
end

_G.tostringex = function(v, len)
    if len == nil then len = 0 end
    local pre = string.rep('\t', len)
    local ret = ""
    if type(v) == "table" then
        if len > 5 then return "\t{ ... }" end
        local t = ""
        local keys = {}
        for k, v1 in pairs(v) do
            table.insert(keys, k)
        end
        for k, v1 in pairs(keys) do
            k = v1
            v1 = v[k]
            t = t .. "\n\t" .. pre .. tostring(k) .. ":"
            t = t .. tostringex(v1, len + 1)
        end
        if t == "" then
            ret = ret .. pre .. "{ }\t(" .. tostring(v) .. ")"
        else
            if len > 0 then
                ret = ret .. "\t(" .. tostring(v) .. ")\n"
            end
            ret = ret .. pre .. "{" .. t .. "\n" .. pre .. "}"
        end
    else
        ret = ret .. pre .. tostring(v) .. "\t(" .. type(v) .. ")"
    end
    return ret
end

_G.MAX_COPY_LAY = 7
_G.deepcopy = function(tbSrc, nMaxLay)
    nMaxLay = nMaxLay or MAX_COPY_LAY
    if (nMaxLay <= 0) then
        return
    end
    
    local tbRet = {}
    for k, v in pairs(tbSrc) do
        if (type(v) == "table") then
            tbRet[k] = deepcopy(v, nMaxLay-1)
        else
            tbRet[k] = v
        end
    end
    
    return tbRet
end

_G.split = function(s, delim)
    assert (type (delim) == "string" and string.len (delim) > 0,"bad delimiter")
	if s == "" then return {}; end
    local start = 1  local t = {}
    while true do
        local pos = string.find (s, delim, start, true) -- plain find
        if not pos then
            break
        end
        table.insert (t, string.sub (s, start, pos - 1))
        start = pos + string.len (delim)
    end
    table.insert (t, string.sub (s, start))
    return t
end

_G.strtrim = function(s) 
  return (string.gsub(s, "^%s*(.-)%s*$", "%1")) 
end 

_G.getTableLen = function(input)
    local ret = 0
    for i, v in pairs(input) do
        ret = ret + 1
    end
    return ret
end

_G.printguid = function(guid)
	if type(guid) ~= "string" then
		print(guid);
		return "";
	end
	local t = split(guid,"_");
	local result = "";
	local lowUint = tonumber(t[2]);
	local highUint = tonumber(t[1]);
	local highRemain = 0;
	local lowRemain = 0;
	local tempNum = 0;
	local MaxLowUint = math.pow(2,32);
	while highUint~=0 or lowUint~=0 do
		highRemain = highUint%10;
		tempNum = highRemain*MaxLowUint + lowUint;
		lowRemain = tempNum%10;
		result = tostring(lowRemain) .. result;
		highUint = toint((highUint-highRemain)/10);
		lowUint = toint((tempNum-lowRemain)/10);
	end
	print(result);
	return result;
end

function _G.writeBytes(input, maxsize)
    local size = input:len()
    local result = input
    if maxsize == nil then
        maxsize = 32
    end
    local pad = maxsize - size
    if pad > 0 then
        for i = 1, pad do
            result = result .. '\0'
        end
    else
        result = result:sub(1, maxsize)
    end
    return result
end

--写String
function _G.writeString(input,len)
	local size = input:len();
	local result = input;
	if len then
		local pad = len - size
		if pad > 0 then
			for i = 1, pad do
				result = result .. '\0'
			end
		else
			result = result:sub(1, len)
		end
	else
		result = string.from32l(size) .. result;
	end
	return result;
end

--写变长字节
function _G.writeBuffBytes(input)
	local len = input:len();
	local result = string.from32l(len);
	result = result .. input;
	return result;
end

function _G.writeInt(input)
    return string.from32l(input)
end

function _G.writeInt64(input)
    return string.from64l(input)
end

--写Guid
function _G.writeGuid(input)
	if type(input) == "number" or input=="" then
		local result = "";
		result = result .. string.from32l(0);
		result = result .. string.from32l(0);
		return result;
	else
		local t = split(input,"_");
		local result = "";
		result = result .. string.from32l(tonumber(t[2]));
		result = result .. string.from32l(tonumber(t[1]));
		return result;
	end
end

function _G.writeDouble(input)
	return string.fromDl(input);
end

function _G.readInt(input, begin)
    local value
    local idx
    if begin == nil then
        begin = 1
    end
    value = input:to32l(begin, true)
    idx = begin + 4
    return value, idx
end

function _G.readString32(input, begin)
    local value
    local idx
    if begin == nil then
        begin = 1
    end
    value = input:tostr(begin, begin + 32)
    idx = begin + 32
	local findEndFlag = string.find(value,"\0");
	if findEndFlag then
		value = string.sub(value,1,findEndFlag-1);
	end
    return value, idx
end

function _G.readString64(input, begin)
    local value
    local idx
    if begin == nil then
        begin = 1
    end
    value = input:tostr(begin, begin + 64)
    idx = begin + 64
	local findEndFlag = string.find(value,"\0");
	if findEndFlag then
		value = string.sub(value,1,findEndFlag-1);
	end
    return value, idx
end

--不传长度会默认先读一个长度
function _G.readString(input,begin,len)
	local value,idx
	if not begin then begin=1; end
	if not len then 
		len = input:to32l(begin, true)
		begin = begin + 4;
	end
	value = input:tostr(begin, begin+len);
	idx = begin + len;
	local findEndFlag = string.find(value,"\0");
	if findEndFlag then
		value = string.sub(value,1,findEndFlag-1);
	end
	return value, idx
end

--读变长字节
function _G.readBuffBytes(input,begin,len)
	local value,idx
	if not begin then begin=1;end
	value = input:tobytes(begin,len);
	idx = begin + len;
	return value, idx
end

function _G.readByte(input, begin)
    local value
    local idx
    if begin == nil then
        begin = 1
    end
    value = input:tobytes(begin, begin + 1)
    idx = begin + 1
    return string.byte(value), idx

end

function _G.readShort(input, begin)
    local value
    local idx
    if begin == nil then
        begin = 1
    end
    value = input:to16l(begin, true)
    idx = begin + 2
    return value, idx

end

function _G.readInt64(input, begin)
    local value
    local idx
    if begin == nil then
        begin = 1
    end
    value = input:to64l(begin, true)
    idx = begin + 8
    return value, idx
end

--读Guid
function _G.readGuid(input,begin)
	local value,idx
	local v1 = input:to32l(begin,false);
	local v2 = input:to32l(begin+4,false);
	value = tostring(v2) .."_".. tostring(v1);
	idx = begin + 8;
	return value,idx
end

function _G.readNumber(input, begin)
    local value
    local idx
    if begin == nil then
        begin = 1
    end
    value = input:toDl(begin)
    idx = begin + 8
    return value, idx

end

function _G.readDouble(input, begin)
    local value
    local idx
    if begin == nil then
        begin = 1
    end
    value = input:toDl(begin)
    idx = begin + 8
    return value, idx

end

function string:tokenize()
    local tokens={}
    for token in string.gmatch(self, "[^%s]+") do
        table.insert(tokens, token)
    end
    return tokens
end
--[[
string.split = function(str, pattern)
    pattern = pattern or "[^%s]+"
    if pattern:len() == 0 then pattern = "[^%s]+" end
    local parts = {__index = table.insert}
    setmetatable(parts, parts)
    str:gsub(pattern, parts)
    setmetatable(parts, nil)
    parts.__index = nil
    return parts
end
--]]
function string:split(delimiter)
    local result={}
    local from=1
    local delim_from, delim_to = string.find(self, delimiter, from)
    while delim_from do
        table.insert(result, string.sub(self, from, delim_from-1))
        from = delim_to +1
        delim_from, delim_to = string.find(self,delimiter,from)
    end
    table.insert(result, string.sub(self,from))
    return result
end

string.leftpad = function(str, len, char)
    if char == nil then char = ' ' end
    return string.rep(char, len - #str) .. str
end

--返回字符串长度 一个中文字符长度为2
string.getLen = function(str)
    local i = 1
    local characterCount = 0
    local strLen = str:len()
    while i <= strLen do
        local a = string.byte(str, i, i)
        if type(a) == "number" then
            if a >= 128 then
                i = i + 3
                characterCount = characterCount + 2
            else
                i = i + 1
                characterCount = characterCount + 1
            end
        end
    end
    return characterCount
end

--字符串切割，参数： 源字符串，切割符
--返回：切割后的表
string.strTotable = function (szFullString, szSeparator)
    local nFindStartIndex = 1
    local nSplitIndex = 1
    local nSplitArray = {}
    while true do
        local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)
        if not nFindLastIndex then
            nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))
            break
        end
        nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
        nFindStartIndex = nFindLastIndex + string.len(szSeparator)
        nSplitIndex = nSplitIndex + 1
    end
    return nSplitArray
end


-- 时间（若测试要时间加速，重新定义MINUTE HOUR DAY的进制S2M M2H H2D）
_G.CTimeFormat = {}
_G.SECOND = 1
_G.S2M = 60
_G.MINUTE = S2M * SECOND
_G.M2H = 60
_G.HOUR = M2H * MINUTE
_G.H2D = 24
_G.DAY = H2D * HOUR

--时间转换（支持测试时的时间加速）
local function toint(n)
    return tonumber(math.floor(n))
end
local function leapyear(year)
    local f1, f2, f3
    f1 = ((year%4) == 0)
    f2 = ((year%100) == 0)
    f3 = ((year%400) == 0)
    if (f1 and not f2) or (f2 and f3) then
        return true
    else
        return false
    end
end

-- quick为true则代表时间加速
local function today(sec, quick)
    local day, hour, minute, second
    day=quick and toint(sec/DAY) or toint(sec/24/60/60)
    local ds = quick and day*DAY or day*24*60*60
    hour=quick and toint((sec-ds)/HOUR) or toint((sec-ds)/60/60)
    local hs = quick and hour*HOUR or hour*60*60
    minute=quick and toint((sec-ds-hs)/MINUTE) or toint((sec-ds-hs)/60)
    local ms = quick and minute*MINUTE or minute*60
    second=sec-ds-hs-ms
    return day, hour, minute, second
end

local function toyear(startyear, day)
    local y=startyear
    local d=day
    while true do
        if leapyear(y) then
            if d <= 366 then break end
            d=d-366
            y=y+1
        else
            if d<=365 then break end
            d=d-365
            y=y+1
        end
    end
    return y, d
end


local function month2day(year, month, day)
    local md = {0,31,28,31,30,31,30,31,31,30,31,30,31}
    if leapyear(year) then md[3]=md[3]+1 end
    local d=0
    for i=1,month do
        d=d+md[i]
    end
    return d+day
end

local yearday1970 = {}
local function setYearday1970()
    local cnt=0
    for i=1970,9970 do
        cnt = leapyear(i) and cnt+366 or cnt+365
        yearday1970[i+1]=cnt
    end
end
setYearday1970()

local function dayfrom1970(year, month, day)
    local d = yearday1970[year]
    d = d + month2day(year,month,day)
    return d
end
-----add by lkj 返回从2000年1月1日到现在的天数 04/29/2012
local function dayfrom2000(year, month, day)
    local d1 = dayfrom1970(2000, 1, 1);
    local d2 = dayfrom1970(year, month, day);
    local d = d2 - d1;
    return d;
end;

local function day2month(year, day)
    local md = {31,28,31,30,31,30,31,31,30,31,30,31}
    if leapyear(year) then md[2]=md[2]+1 end
    local m,d = 1,0
    while true do
        if day <= md[m] then
            d = day
            break
        end
        day = day-md[m]
        m = m+1
    end
    return m,d
end

-- quick为true则代表时间加速
local function diffdate(startdate, sec, quick)
    local d, h, m, s = today(sec, quick)
    local year,month,day,hour,minute,second
    local carry=0
    second = startdate.second + s
    if second >= (quick and S2M or 60) then
        carry=1
        second = second - (quick and S2M or 60)
    end
    minute = startdate.minute + carry + m
    if minute >= (quick and M2H or 60) then
        carry=1
        minute = minute - (quick and M2H or 60)
    else
        carry=0
    end
    hour = startdate.hour + carry + h
    if hour >= (quick and H2D or 24) then
        carry=1
        hour = hour-(quick and H2D or 24)
    else
        carry=0
    end
    day = month2day(startdate.year, startdate.month, startdate.day) + carry + d
    year, day = toyear(startdate.year, day)
    month, day = day2month(year, day)
    return year, month, day, hour, minute, second
end

-- 以下用于判断，带时间加速
local OneDayMsec = DAY*1000
local TodayStartMsec
--- 返回今天的起始时间（毫秒）
local function todayStartMsec()
    local cur = _now()
    if TodayStartMsec and cur-TodayStartMsec<OneDayMsec then return TodayStartMsec end
    local y,m,d = CTimeFormat:mtodate(cur,true,true)
    TodayStartMsec = dayfrom2000(y,m,d)*OneDayMsec
    return TodayStartMsec
end

local function day2week(y,m,d)
    if(m==1) then
        m=13;
        y = y - 1
    end
    if(m==2) then
        m=14;
        y = y - 1
    end
    local week=math.floor((d+2*m+math.floor(3*(m+1)/5)+y+math.floor(y/4)-math.floor(y/100)+math.floor(y/400))%7);
    return week;
end
-----------------------------
--Public:
-----------------------------

_G.ONE_SECOND_MSEC = 1000;
_G.ONE_MINUTE_MSEC = 60 * ONE_SECOND_MSEC;
_G.ONE_HOUR_MSEC = 60 * ONE_MINUTE_MSEC;
_G.ONE_DAY_MSEC = 24 * ONE_HOUR_MSEC;
local TODAY_START_MSEC
--返回今天的起始时间（毫秒） add by lkj 不采用时间加速
function CTimeFormat:GetTodayStartMsec()
    local cur = _now()
    if TODAY_START_MSEC and cur - TODAY_START_MSEC < ONE_DAY_MSEC then return TODAY_START_MSEC end;
    local y, m, d = CTimeFormat:mtodate(cur, true, false);
    TODAY_START_MSEC = dayfrom2000(y, m, d)* ONE_DAY_MSEC;
    return TODAY_START_MSEC
end
--返回今天hour:minute的时间戳毫秒数
function CTimeFormat:GetTodayThisTimeMsec(hour, minute)
    local today_start_msec = self:GetTodayStartMsec();
    return today_start_msec + hour * ONE_HOUR_MSEC + minute * ONE_MINUTE_MSEC;
end;
--返回指定时间的时间戳毫秒数 --add by lkj 05/09/2012
function CTimeFormat:GetThisTimeMsec(year, month, day, hour, minute, second)
    local msec = dayfrom2000(year, month, day) * ONE_DAY_MSEC;
    msec = msec + hour * ONE_HOUR_MSEC;
    msec = msec + minute * ONE_MINUTE_MSEC;
    msec = msec + second * ONE_SECOND_MSEC;
    return msec;
end;--add over

--- 输入_now(1)返回的时间整数（秒），返回日期时间字符串
--转换的时间是服务器时间 !!!!UTC
-- 如果fmt为true，则返回year,month,day,hour,min,sec
-- 如果quick为true，则用时间加速的计算方法
function CTimeFormat:todate(sec, fmt, quick)
	--时区问题，直接加8小时
	sec = sec + 8*3600;
    local startdate={year=1970,month=1,day=1,hour=0,minute=0,second=0}
    if type(fmt)=='boolean' and fmt == true then
        return diffdate(startdate, sec, quick)
    elseif type(fmt)=='string' then
        return string.format(fmt, diffdate(startdate, sec, quick))
    end
    return string.format('%04d-%02d-%02d %02d:%02d:%02d',diffdate(startdate, sec, quick))
end
--- 输入_now(0.001)返回的时间整数（毫秒），返回日期时间字符串
function CTimeFormat:mtodate(msec, fmt,quick)
    return CTimeFormat:todate(msec/1000,fmt,quick)
end
--- 输入一个毫秒参数，如果是今天返回true，否则返回false
function CTimeFormat:isToday(msec)
    local t = todayStartMsec()
    return msec>=t and msec<t+OneDayMsec
end
--- 输入一个秒参数，如果是今天返回true，否则返回false
function CTimeFormat:isTodayEx(sec)
    local msec = sec*1000
    local t = todayStartMsec()
    return msec>=t and msec<t+OneDayMsec
end
-- 输入_now(1)返回的时间整数（秒）,返回星期几，6为星期天，0为星期一
function CTimeFormat:toweekEx(sec)
    local y,m,d = CTimeFormat:todate(sec,true,true)
    return day2week(y,m,d)
end
---输入一个毫秒参数，如果是本周返回true，否则返回false
function CTimeFormat:isThisWeek(msec)
    local sec = math.floor(msec/1000)
    return CTimeFormat:isThisWeekEx(sec)
end
---输入一个秒参数，如果是本周返回true，否则返回false
function CTimeFormat:isThisWeekEx(sec)
    local y, m, d = CTimeFormat:todate(_now(1),true,true)
    local y2, m2, d2 = CTimeFormat:todate(sec,true,true)
    if math.ceil((dayfrom1970(y, m, d)+3)/7) ~= math.ceil((dayfrom1970(y2, m2, d2)+3)/7) then
        return false
    else
        return true
    end
end
function CTimeFormat:GetSecFrom1970()
	local y, m, d, h, min ,sec = CTimeFormat:todate(_now(1),true,false);
	return _G.GetTimeByDate(y, m, d, h, min ,sec);
end
--获得格式化的 分：秒
function CTimeFormat:sec2formatMinSec(secs)
	local hour,min,sec = CTimeFormat:sec2format(secs)
	if hour > 0 then
		min = hour * 60;
	end
	return min,sec
end
--获得格式化的 时：分：秒
function CTimeFormat:sec2format(secs)
    local now_time = secs
    local sec = math.floor(math.mod(now_time,60))
    local min = math.floor(math.mod(now_time/60,60))
    local hour = math.floor(math.mod(now_time/3600,24))
    return hour,min,sec
end

--获得格式化的 天：时：分：秒
function CTimeFormat:sec2formatEx(secs)
    local now_time = secs
    local sec = math.floor(math.mod(now_time,60))
    local min = math.floor(math.mod(now_time/60,60))
    local hour = math.floor(math.mod(now_time/3600,24))
    local day = math.floor(now_time/(3600*24))
    return day,hour,min,sec
end

--将秒转为字符串 "分：秒"
function CTimeFormat:sec2ToMinSec(secs)
	local hour, min, sec = CTimeFormat:sec2format(secs);
	if hour > 0 then
		min = hour * 60;
	end
	return string.format("%s:%s", min, sec);
end

function CTimeFormat:diffDayNum(servertime1,servertime2)
	local y1, m1, d1 = CTimeFormat:todate(servertime1, true);
	local day1 = dayfrom1970(y1, m1, d1);
	local y2, m2, d2 = CTimeFormat:todate(servertime2, true);
	local day2 = dayfrom1970(y2, m2, d2);
	return day1 - day2;
end

--将一天中的时间字符串转换成秒 (时：分：秒)
function CTimeFormat:daystr2sec(str)
	local t = split(str,":");
	local sec = 0;
	sec = sec + tonumber(t[1]) * 3600;
	sec = sec + tonumber(t[2]) * 60;
	if t[3] then
		sec = sec + tonumber(t[3]);
	end
	return sec;
end

--获取某个点（pos）某个朝向(dir)上的某个距离（dis）的点的坐标
function GetPosByDis(pos, dir, dis)
    local x = pos.x + dis * math.sin(dir)
    local y = pos.y - dis * math.cos(dir)
    return x, y
end

function GetMidPos(pos1, pos2)
    local x = (pos1.x + pos2.x) / 2
    local y = (pos1.y + pos2.y) / 2
    local z = math.max(pos1.z, pos2.z) + 30
    return x, y, z
end

function GetDistanceTwoPoint(pos1, pos2)
    return math.sqrt((pos1.x - pos2.x)^2 + (pos1.y - pos2.y)^2)
end

function GetAngleTwoPoint(startPos, endPos)
	local x = math.abs(startPos.x - endPos.x);
	local y = math.abs(startPos.y - endPos.y);
	local z = math.sqrt(math.pow(x, 2) + math.pow(y, 2));
	local cos = y / z;
	local radina = math.acos(cos);
	local angle = math.floor(180 / (math.pi / radina));
	if endPos.x > startPos.x and endPos.y > startPos.y then
		angle = 180 - angle;
	end
	if endPos.x == startPos.x and endPos.y > startPos.y then
		angle = 180;
	end
	if endPos.x > startPos.x and endPos.y == startPos.y then
		angle = 90;
	end
	if endPos.x < startPos.x and endPos.y > startPos.y then
		angle = 180 + angle;
	end
	if endPos.x < startPos.x and endPos.y == startPos.y then
		angle = 270;
	end
	if endPos.x < startPos.x and endPos.y < startPos.y then
		angle = 360 - angle;
	end
	return angle;
end

local dir = _Vector3.new()
local tar = _Vector3.new()
local cur = _Vector3.new()
local mat = _Matrix3D.new()
local tabTarRot = _Vector4.new()
function GetDirTwoPoint(pos1, pos2)
    tar.x, tar.y, tar.z = pos2.x, pos2.y, pos2.z
    cur.x, cur.y, cur.z = pos1.x, pos1.y, pos1.z 
    dir.x,dir.y,dir.z = tar.x - cur.x, tar.y - cur.y, 0
    dir:normalize()
    mat:setFaceTo(0, -1, 0, dir.x, dir.y, 0):getRotation(tabTarRot)
    local dwTarRot = tabTarRot.r * tabTarRot.z
    if dwTarRot < 0 then
        dwTarRot = 2 * math.pi + dwTarRot
    end
    return dwTarRot
end

function IsContain(p1, p2, p3, p4, p)
    if (Multiply(p, p1, p2) * Multiply(p, p4, p3) <= 0 
        and Multiply(p, p4, p1) * Multiply(p, p3, p2) <= 0) then
        return true
    end
    return false
end

function Multiply(p1, p2, p)
    return ((p1.x - p.x) * (p2.y - p.y) - (p2.x - p.x) * (p1.y - p.y))
end

function NumberToString(number)
    local numString = tostring(number)
    local length = string.len(numString)
    local tempString = ""
    local tempIndex = 0
    for index = length, 1, -1 do
        tempIndex = tempIndex + 1
        local tempChar = string.char(string.byte(numString, index))
        tempString = tempChar .. tempString
        if tempIndex % 3 == 0 and tempIndex ~= length then
            tempString = "," .. tempString
        end
    end
    return tempString
end

function DestroyTbl(tbl)
	if tbl == nil then return end
	for k,v in pairs(tbl) do
		tbl[k] = nil
	end
	tbl = nil
end

function avgTbl(tbl)
	local ret = 0;
	local i = 0;
	for _, v in pairs(tbl) do
		i = i + 1
		ret = ret + v;
	end
	ret = ret / i 
	return ret;
end

function round(value)
    return math.floor(value + 0.5)
end

function sysMonitor()
	_debug:frameMonitor(true)
	-- Monitor IO read.
	_debug:ioReadMonitor(false, 1000)
	-- Monitor IO read in main thread.
	_debug:ioReadMonitor(true, 1000)
	-- _debug:objectMonitor(_Vector3.typeid, 1000)
	-- Monitor object count.
	_debug:objectMonitor(_Matrix3D.typeid, 1000)
	--_debug:objectMonitor(_Rect.typeid, 1000)
	_debug:objectMonitor(_DrawBoard.typeid, 1000)
	_debug:objectMonitor(_Scene.typeid, 1000)
	_debug:objectMonitor(_SceneNode.typeid, 1000)
	_debug:objectMonitor(_Mesh.typeid, 1000)
	_debug:objectMonitor(_Image.typeid, 1000)
	_debug:objectMonitor(_Skeleton.typeid, 1000)
	_debug:objectMonitor(_Animation.typeid, 1000)
	_debug:objectMonitor(_Particle.typeid, 1000)
	_debug:objectMonitor(_ParticlePlayer.typeid, 1000)
	_debug:objectMonitor(_ParticleEmitter.typeid, 1000)

	_debug:objectMonitor(_SWFComponent.typeid, 1000)
	_debug:objectMonitor(_PointLight.typeid, 1000)
	_debug:objectMonitor(_SkyLight.typeid, 1000)
	--_debug:objectMonitor(_SWFManager.typeid, 1000)
	_debug:objectMonitor(_Blender.typeid, 1000)
	_debug:objectMonitor(_Vector2.typeid, 1000)
	_debug:objectMonitor(_Vector3.typeid, 1000)

end

function hack(text)
	if text == "debug" then
		_dofile("debug.txt");
	end
end

function isInCircle(p, centre, dis)
    return (GetDistanceTwoPoint(p, centre) <= dis)
end


function getAddress(res1)
	local a1 = bit.rshift(res1, 24)
	local a2 = bit.rshift(bit.lshift(res1, 8), 24)
	local a3 = bit.rshift(bit.lshift(res1, 16), 24)
	local a4 = bit.rshift(bit.lshift(res1, 24), 24)
	local ip = a1 .. '.' .. a2 .. '.' .. a3 .. '.' .. a4
	return ip;
end

function GetIP(input)
	local tmp = split(input, ':')
	local host = tmp[1]
	local port = tmp[2]
	local res, res1 = pcall( _hostips, host)
	if not res or not res1 then
		Debug("parse host error.");
		return nil;
	else
		local ip = getAddress(res1)
		Debug("parse host.ip:", ip);
		return ip .. ':' .. port
	end
end

function GetMousePos()
    local mousePos = _sys:getRelativeMouse()
    local mousePickPos = {}
    local pickPos = CPlayerMap:GetSceneMap():DoPick(mousePos.x, mousePos.y)
    if not pickPos then
        return
    end
    local z = CPlayerMap:GetSceneMap():getSceneHeight(pickPos.x, pickPos.y)
    if not z then
        return
    end
    mousePickPos.x = pickPos.x
    mousePickPos.y = pickPos.y
    mousePickPos.z = z + 0.2
    return mousePickPos
end

function LuaGC()
    _gc()
end

function GuidToInt(guid)
    if type(guid) ~= "string" then
        return 0;
    end
    local t = split(guid,"_");
    local result = "";
    local lowUint = tonumber(t[2]);
    local highUint = tonumber(t[1]);
    local highRemain = 0;
    local lowRemain = 0;
    local tempNum = 0;
    local MaxLowUint = math.pow(2,32);
    while highUint~=0 or lowUint~=0 do
        highRemain = highUint%10;
        tempNum = highRemain*MaxLowUint + lowUint;
        lowRemain = tempNum%10;
        result = tostring(lowRemain) .. result;
        highUint = toint((highUint-highRemain)/10);
        lowUint = toint((tempNum-lowRemain)/10);
    end
    return tonumber(result) or 0
end

function GetFileName(file)
	local result = string.match(file, ".+\\([^\\]*%.%w+)$");
	if not result then
		result = file;
	end
	return result;
end

function GetExtension(file)
	local idx = file:match(".+()%.%w+$");
	if idx then
		return file:sub(1, idx-1);
	else
		return file;
	end
end

function GetExtensionName(file)
    return file:match(".+%.(%w+)");
end

function Get16String(num)
	return string.format("%#x",num);
end

function FileFormatTransform(file,format)
	if not file or #file==0 or not format then
		return;
	end
	local name = GetFileName(file);
	name = GetExtension(name)..'.'..format;
	return name;
end

_G.RandomUtil = {};
--获得一个范围内的有符号整数 区间为 [min,max-1]
function RandomUtil:int(min, max)
	min = toint(min);
	max = toint(max);
	local r = 0;
	r = min + math.random()*(max - min);
	return toint(r);
end

--随机切分数字，生成一个数组。这个数组的总和等于原数字。
function RandomUtil:randomSeparate(amount, count)
	local result = {};
	local c = 0;
	for i = 1, count do
		local v = math.random();
		table.push(result, v);
		c = c + v;
	end
	for j = 1, count do
		result[j] = result[j] * amount / c;
	end
	return result;
end

--整数随机切分数字，fluctuateProp为浮动比例
function RandomUtil:randomaAvgSeparate(amount, count, fluctuateProp)
	local result = {};
	local avg = amount / count;
	local t = 0;
	for i = 1, count - 1 do
		local item = RandomUtil:int(avg - toint(avg * fluctuateProp), avg + toint(avg * fluctuateProp));
		if item > 0 then
			t = t + item;
			table.push(result, item);
		end
	end
	table.push(result, amount - t);
	return result;
end

_G.UIDisplayUtil = {}

function UIDisplayUtil:MatrixLayout(items, col, colWidth, rowHeight, offsetX, offsetY)
	offsetX = offsetX or 0;
	offsetY = offsetY or 0;
	for i = 1, #items do
		local item = items[i];
		item._x = offsetX + colWidth * ((i - 1) % col);
		item._y = offsetY + rowHeight * math.floor((i - 1) / col);
	end
end
--制定一个坐标为起始点，横向布局
function UIDisplayUtil:HLayout(items, colWidth, offsetX, offsetY)
	UIDisplayUtil:MatrixLayout(items, #items, colWidth, 0, offsetX, offsetY);
end
--制定一个坐标为起始点，纵向布局
function UIDisplayUtil:VLayout(items, rowHeight, offsetX, offsetY)
	UIDisplayUtil:MatrixLayout(items, 1, 0, rowHeight, offsetX, offsetY);
end
--指定一个坐标为中心点，横向布局
function UIDisplayUtil:HCenterLayout(count, items, colWidth, x, y)
	local offsetX = x - (count * colWidth / 2);
	local offsetY = y;
	UIDisplayUtil:HLayout(items, colWidth, offsetX, offsetY);
end
--指定一个坐标为中心点，纵向布局
function UIDisplayUtil:VCenterLayout(count, items, rowHeight, x, y)
	local offsetX = x;
	local offsetY = y - (count * rowHeight / 2);
	UIDisplayUtil:VLayout(items, rowHeight, offsetX, offsetY);
end

function math.round(decimal)
	decimal = decimal * 100;
	if decimal % 1 >= 0.5 then 
		decimal=math.ceil(decimal);
	else
		decimal=math.floor(decimal);
	end
	return  decimal * 0.01;
end

function bit.SetBitField(num,index,state)
	if state then
		num = _or(num,_lshift(1,index));
	else
		num = _and(num,bit.bnot(_lshift(1,index)));
	end
	return num;
end

function bit.OrBitField(num,index,state)
	if state then
		num = _or(num , _lshift(1,index));
	end
	return num;
end

function bit.IsSetBitField(num,index)
	return _and(num,_lshift(1,index)) ~= 0;
end

function GetURLParams(params,format)
	local result = '';
	if not params then
		return result;
	end
	
	format = format or '&';
	for name,value in pairs(params) do
		result = result..name..'='..value..format;
    end
	result = string.sub(result,1,#result-1);
	return result;
end
