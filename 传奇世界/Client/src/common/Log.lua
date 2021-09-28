--Author:		bishaoqing
--DateTime:		2016-04-25 19:15:05
--Region:		debug log
local Log = class("Log")

function Log:debug(...)
    self:doLog("DEBUG|" .. string.format(...))
end

function Log:info(...)
	if select("#", ...) > 0 then
		local t = {...}
		local s = ""
		for k,v in pairs(t) do
			s = s .. " " .. tostring(v)
		end
		self:doLog("INFO |" .. s)
	else
		self:doLog("INFO |")
	end
end

function Log:warn(...)
    self:doLog1("WARN |" .. string.format(...))
end 

function Log:error(...)
    self:doLog2("ERROR|" .. string.format(...))
end

function Log:doLog(...)
    local info = debug.getinfo(3, "Sl")
    print(info.source .. ",".. info.currentline .. '|'.. string.format(...))
end

function Log:doLog1(...)
    local info = debug.getinfo(3, "Sl")
    print(info.source .. ",".. info.currentline .. '|'.. string.format(...))
end

function Log:doLog2(...)
    local info = debug.getinfo(3, "Sl")
    print(info.source .. ",".. info.currentline .. '|'.. string.format(...))
end

function Log:d( ... )
	local info = debug.getinfo(2, "Sl")
	local nTime = "";
	local nFrame = "";
	if not g_bServer then
		nTime = mtTimeUtil():GetTickCount();
		nFrame = cc.Director:getInstance():getTotalFrames();
	end
    global:OutputLog(0, info.source .. ",".. info.currentline .. '|DEBUG|' .. nFrame .. '|' .. nTime .. '|' .. string.format(...))
end
function Log:i( ... )
	local info = debug.getinfo(2, "Sl")
    global:OutputLog(1, info.source .. ",".. info.currentline .. '|WARN|'.. string.format(...))
end
function Log:e( ... )
	local info = debug.getinfo(2, "Sl")
    global:OutputLog(2, info.source .. ",".. info.currentline .. '|ERROR|'.. string.format(...))
end

function Log:Stack()
	for i=2,10 do
		local oInfo = debug.getinfo(i);
		if nil == oInfo then
			break;
		end
		print( oInfo.source .. ":" .. oInfo.currentline );
	end
end

function Log:Stack2( strLog )
	if nil ~= strLog then
		Log:d( "Stack head:" .. tostring(strLog) );
	end
	for i=2,10 do
		local oInfo = debug.getinfo(i);
		if nil == oInfo then
			break;
		end
		Log:d( oInfo.source .. ":" .. oInfo.currentline );
	end
end

function Log:Stack3( strLog )
	if nil ~= strLog then
		Log:t( "Stack head:" .. tostring(strLog) );
	end
	for i=2,10 do
		local oInfo = debug.getinfo(i);
		if nil == oInfo then
			break;
		end
		Log:t( oInfo.source .. ":" .. oInfo.currentline );
	end
end

function Log:Stack4( strLog )
	if nil ~= strLog then
		Log:f( "Stack head:" .. tostring(strLog) );
	end
	for i=2,10 do
		local oInfo = debug.getinfo(i);
		if nil == oInfo then
			break;
		end
		Log:f( oInfo.source .. ":" .. oInfo.currentline );
	end
end

function Log:File( strLog, strFile )
	if IsWin32() then
		if nil == strFile then
			strFile = "log.log";
		end
		local file = io.open( strFile, "a+" );
		if nil ~= file then
			file:write( strLog .. "\n" );
			file:close();
		end
	end
end

function Log:f( strLog )
	if IsDebug() then
		local oDate = os.date("*t", mtTimeUtil():getTime() );
		local strLogRoot = GetRootDir() .. "/log";
		MakeDir( strLogRoot, oDate.year, oDate.month, oDate.day );
		local strFile = strLogRoot .. "/" .. oDate.year .. "/" .. oDate.month .. "/" .. oDate.day .. "/" .. oDate.hour .. ".log";
		local file = io.open( strFile, "a+" );
		if nil ~= file then
			file:write( FormatDate( oDate ) .. ":" );
			file:write( strLog .. "\r\n" );
			file:close();
		end
	end
end
function Log:t( strLog )
	-- Log:d( strLog );
	-- if nil ~= CGameFunc.ThreadLog then
	-- 	CGameFunc:ThreadLog( strLog, mtTimeUtil():GetTickCount(), GetNetworkSubDir() );
	-- end
end

return Log