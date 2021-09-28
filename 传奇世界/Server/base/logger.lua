--[[logger.lua
描述：
	提供日志消息输出
--]]

require "base.common"

local debug = require "debug"

local ALL   = "ALL"
local DEBUG = "DEBUG"
local INFO  = "INFO"
local WARN  = "WARN"
local ERROR = "ERROR"
local FATAL = "FATAL"
local OFF   = "OFF"

--@note：输出等级的定义，只有输出方式的等级大于等于当前等级，输出才会进行
local LEVEL = {
	[ALL]   = 0,                          --允许所有等级消息输出
	[DEBUG] = 1,                          --用于调试消息的输出
	[INFO]  = 2,                          --用于跟踪程序运行进度
	[WARN]  = 3,                          --程序运行时发生异常
	[ERROR] = 4,                          --程序运行时发生可预料的错误,此时通过错误处理,可以让程序恢复正常运行
	[FATAL] = 5,                          --程序运行时发生不可预料的严重错误,一般将终止程序运行
	[OFF]   = 100,                        --关闭所有消息输出
}

--@note：设置当前输出等级
local function log_setLevel(logger, level)
	logger.level = level
end

--@note：输出函数，将信息输出到指定的logger上面
local function log_output(logger, level, message, ...)
	if logger == nil or level == nil then
		return false
	end

	if LEVEL[level] < LEVEL[logger.level] then
		return false
	end
	return logger:append(level, string.format(tostring(message), unpack({...})))
end

--@note：生成一个新的logger
--@param append：logger持有的信息处理函数
local function log_new(_, append)
	if type(append) ~= "function" then
		return nil, "Appender must be a function."
	end

	local logger = {
		level = DEBUG,
		setLevel = log_setLevel,
		append = append
	}

	logger.isDebug = function(logger) return LEVEL[DEBUG] >= LEVEL[logger.level] end
	logger.isInfo  = function(logger) return LEVEL[INFO] >= LEVEL[logger.level]  end
	logger.isWarn  = function(logger) return LEVEL[WARN] >= LEVEL[logger.level]  end
	logger.isError = function(logger) return LEVEL[ERROR] >= LEVEL[logger.level] end
	logger.isFatal = function(logger) return LEVEL[FATAL] >= LEVEL[logger.level] end

	logger.debug   = function(logger, message, ...) return log_output(logger, DEBUG, message, ...) end
	logger.info    = function(logger, message, ...) return log_output(logger, INFO, message, ...)  end
	logger.warn    = function(logger, message, ...) return log_output(logger, WARN, message, ...)  end
	logger.error   = function(logger, message, ...) return log_output(logger, ERROR, message, ...) end
	logger.fatal   = function(logger, message, ...) return log_output(logger, FATAL, message, ...) end

	return logger
end

--@note：logger类
Logger = define({ __call = log_new }, {
	OFF   = OFF,
	ALL   = ALL,
	DEBUG = DEBUG,
	INFO  = INFO,
	WARN  = WARN,
	ERROR = ERROR,
	FATAL = FATAL,
})

----------------------------------------下面是定制logger--------------------------------------------
--note：定制一个控制台logger
local MAX_STRING_LENGTH = 512
local _print = print
local _warning = warning

--@note：把字符串按最大长度拆分输出
local function output(str, fn_print)
	if not fn_print then fn_print = _print end
	
	if str == nil then
		fn_print(nil)
	else
		local len = #str
		if len < MAX_STRING_LENGTH then
			fn_print(str)
		elseif len > 0 then
			local idx = 1
			local substr = str
			while #substr > 0 do
				local s = string.substr(substr, 1, MAX_STRING_LENGTH)
				fn_print(s)
				substr = string.substr(substr, #s+1)
			end
		end
	end
end

--@note：重新定义print，替换%,避免出现Trace参数个数与格式不匹配
function print(...)
	local t = {}
	for i = 1, select("#", ...) do
		table.insert(t, tostring(select(i, ...)))
	end
	local str = string.gsub(table.concat(t, " "), "%%", "%%%%")
	local info = debug.getinfo(2,"nSl");
	if info then
		local filename = "";
		local nIndex = string.find(info.short_src,".lua",1,true);
		local nIndexString = string.find(info.short_src,"string",1,true)
		if nIndex and nIndexString and nIndex > 1 and nIndexString > 1 then
			filename = string.sub(info.short_src,nIndexString + 6,nIndex);
			filename = string.gsub(filename,"%A","",20);
			filename = filename .. ".lua";
		end
		str = str..' - '..(filename or "unknown")..':'..tostring(info.currentline or -1)
	end
	
	output(str)
end

function warning(...)
	local t = {}
	for i = 1, select("#", ...) do
		table.insert(t, tostring(select(i, ...)))
	end
	local str = string.gsub(table.concat(t, " "), "%%", "%%%%")
	local info = debug.getinfo(2,"nSl");
	if info then
		local filename = "";
		local nIndex = string.find(info.short_src,".lua",1,true);
		local nIndexString = string.find(info.short_src,"string",1,true)
		if nIndex and nIndexString and nIndex > 1 and nIndexString > 1 then
			filename = string.sub(info.short_src,nIndexString + 6,nIndex);
			filename = string.gsub(filename,"%A","",20);
			filename = filename .. ".lua";
		end
		str = str..' - '..(filename or "unknown")..':'..tostring(info.currentline or -1)
	end
	
	output(str, _warning)
end

function __print(...)
	local t = {}
	for i = 1, select("#", ...) do
		table.insert(t, tostring(select(i, ...)))
	end
	local str = string.gsub(table.concat(t, "\t"), "%%", "%%%%")
	output(str)
end

--@note：定制的append函数，"%d %p %m"分别对应日期，等级，内容
--param message：是经过string.format格式化后的字符串
local function appendFun(self, level, message)
	message = string.gsub(message, "%%", "%%%%")
	local logMsg = "[%p] %m"
	if level then
		logMsg = string.gsub(logMsg, "%%p", level)
	end
	if message then
		logMsg = string.gsub(logMsg, "%%m", message)
	end
	print(logMsg)
	return true
end

local logger
function Logger.getLogger()
	if not logger then
		logger = Logger(appendFun)
	end
	return logger
end

g_logger = Logger.getLogger()

-----------------------------------------log的全局函数---------------------------------------------------
function debuglog(...)
	if LEVEL[DEBUG] < LEVEL[logger.level] then
		return
	end

	_print(...)
end

function infolog(...)
	if LEVEL[INFO] < LEVEL[logger.level] then
		return
	end

	_print(...)
end

function warnlog(...)
	if LEVEL[WARN] < LEVEL[logger.level] then
		return
	end

	_print(...)
end

function errorlog(...)
	if LEVEL[ERROR] < LEVEL[logger.level] then
		return
	end

	_print(...)
end