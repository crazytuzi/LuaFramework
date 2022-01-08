--[[--
	日志管理器:

	--By: yun.bo
	--2013/7/8
]]

local TFBaseManager 		= require('TFFramework.client.manager.TFBaseManager')
local TFLogType 			= require('TFFramework.client.entity.TFLogType')
local TFLogManager 			= class('TFLogManager', TFBaseManager)
local TFLogManagerModel 	= {}

function TFLogManager:reset()
	TFLogManagerModel.nShowType		= TFLogManager.ALL
end

function TFLogManager:ctor()
	TFLogManager.ERROR	 			= 0
	TFLogManager.WARNING	 		= 1
	TFLogManager.SOCKET	 			= 2
	TFLogManager.TEMP	 			= 3
	TFLogManager.INFO	 			= 4
	TFLogManager.EVENT 				= 5
	TFLogManager.ALL	 			= 6
	
	TFLogManagerModel.nShowType		= TFLogManager.ALL
	TFLogManagerModel.bIsDebug		= true
end

function TFLogManager:trace(...)
	print(...)
end

function TFLogManager:filter(nType)
	local nCurType = self:getLogType()
	nType = nType or nCurType
	if type(nType) ~= 'number' then nType = nCurType end
	if nCurType == TFLogManager.ALL then return true end
	return nType == nCurType
end

--[[--
	打印Log
	@param nType: Log类型
	@param szModule: Log所在的模块
	@param ...: 输出参数
]]
function TFLogManager:writeLog(nType, szModule, ...)
	if not self:filter(nType) then return false end
	local szLog = ''
	if 		nType == TFLogManager.ERROR 		then szLog = "ERROR"
	elseif  nType == TFLogManager.WARNING	 	then szLog = "WARNING"
	elseif  nType == TFLogManager.SOCKET	 	then szLog = "SOCKET"
	elseif  nType == TFLogManager.TEMP	 		then szLog = "TEMP" 
	elseif  nType == TFLogManager.INFO	 		then szLog = "INFO" 
	elseif  nType == TFLogManager.EVENT 	 	then szLog = "EVENT" 
	elseif  nType == TFLogManager.ALL	 	 	then szLog = "UNKNOW TYPE" 
	end

	szLog = szLog .. "[" .. szModule .. "]: "
	local arg = {...}
	if arg and type(arg) == 'table' then
		for i = 1, #arg do
			szLog = szLog .. tostring(arg[i]) .. " "
		end
	end
	self:trace(string.format("%q", szLog))
	return true
end

---------------------------getter&&setter------------------------------

--[[--
	设置需要打印的Log的类型
]]
function TFLogManager:setLogType(nType)
	if type(nType) ~= 'number' then nType = TFLogManager.ALL end
	TFLogManagerModel.nShowType = nType
end

function TFLogManager:getLogType()
	return TFLogManagerModel.nShowType
end

return TFLogManager:new()