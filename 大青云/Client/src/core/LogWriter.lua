--
-- 日志存盘
-- Author Tielei.Yan
--

_G.LogType = 
{
	Error = 'Error',
	Normal = 'Normal',
}

local file = nil;
local name = nil;

_G.WriteLog = function(logtype,traceback,...)
	if not Debug and not IsWriteLog then
		return;
	end;
	
	local args = {...};
	local str = '';
	for i=1,#args do
		if i == #args then
			str = str..tostring(args[i]);
		else
			str = str..tostring(args[i])..',';
		end;
	end;
	if traceback then
		str = str..'\r\n'..debug.traceback();
	end;
	
	if Debug then
		Debug(str);
	end
	
	if not IsWriteLog then
		return;
	end
	
	local date = nil;
	if not file then
		file = _File.new();
		date = _localDate();
		name = tostring(date.year)..'-'..tostring(date.month)..'-'..tostring(date.day)..'-'..tostring(date.hour)..'-'..tostring(date.minute)..'-'..tostring(date.second)..'.log';
		file:create(name,'utf8');
		file:write('INIT');
		file:close();
	end
	
	if file:open(name) then
		logtype = logtype or LogType.Normal;
		file:write('\r\n'..logtype..':');
		date = _localDate();
		local datestr = tostring(date.year)..'-'..tostring(date.month)..'-'..tostring(date.day)..' '..tostring(date.hour)..':'..tostring(date.minute)..':'..tostring(date.second)..':'..tostring(date.millisecond)..'\r\n';
		file:write(datestr);
		file:write(str);
		file:close();
	end
end

_G.SWLog = function(...)
	_G.WriteLog(LogType.Normal,true,...);
end

_G.WriteFile = function(content,folder,format,name)
	if not Debug then
		return;
	end
	
	if not name then
		local date = _localDate();
		name = tostring(date.day)..'-'..tostring(date.hour)..'-'..tostring(date.minute)..'-'..tostring(date.second);
	end
	if folder then
		_sys:createFolder(folder);
		name = folder..'\\'..name;
	end
	if not format then
		format = '.lua';
	end
	name = name..format;
	local file = _File.new();
	if not file:open(name) then
		file:create(name,'utf8');
		file:close();
	end
	file:write(content);
	file:close();
end
