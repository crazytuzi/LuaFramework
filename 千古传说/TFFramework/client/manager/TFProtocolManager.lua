--[[--
	协议管理器:

	--By: yun.bo
	--2013/8/1
]]



local pairs 					= pairs
local tostring 					= tostring
local table 					= table
local TFLOGINFO 				= TFLOGINFO

local TFBaseManager 			= require('TFFramework.client.manager.TFBaseManager')
local TFProtocolManager 		= class('TFProtocolManager', TFBaseManager)
local TFProtocolManagerModel 	= {}

function TFProtocolManager:reset()
	TFProtocolManagerModel.tEvents = {}
end

function TFProtocolManager:ctor()
	TFProtocolManagerModel.tEvents = {}
end

local function nilCheck(obj, szName)
	if not obj then 
		TFLOGINFO("TFProtocolManager:[" .. szName .. '] can not be nil')
		return true
	end
	return false
end

--[[--
	添加指定对象的指定协议的指定监听
	@param objTarget:监听对象
	@param nProtoType:协议号
	@param func:监听回调
]]
function TFProtocolManager:addProtocolListener(nProtoType, objTarget, func)
	if 	nilCheck(objTarget, 'objTarget') or 
		nilCheck(nProtoType, 'nProtoType') or
		nilCheck(func, 'func') then
		return	
	end
	local tEvents = TFProtocolManagerModel.tEvents
	tEvents[nProtoType] = tEvents[nProtoType] or {}
	tEvents[nProtoType][objTarget] = tEvents[nProtoType][objTarget] or {}

	local tFuncs = tEvents[nProtoType][objTarget]
	for k, v in pairs(tFuncs) do
		if v.func and v.func == func then return end
	end
	tFuncs[#tFuncs + 1] = {func = func}
end

--[[--
	移除指定对象的指定协议的指定监听
	@param objTarget:监听对象, 如果为空,表示移除指定协议的所有监听
	@param nProtoType:协议号, 如果为空,表示移除所有协议的监听
	@param func:监听回调, 如果为空,表示移除指定对象的所有监听
]]
function TFProtocolManager:removeProtocolListener(nProtoType, objTarget, func)
	if not nProtoType then
		TFProtocolManagerModel.tEvents = {}
		return
	end
	if not objTarget then
		TFProtocolManagerModel.tEvents[nProtoType] = nil
		return
	end
	local tEvents = TFProtocolManagerModel.tEvents
	if not tEvents[nProtoType] then
		TFLOGWARNING("TFProtocolManager: Not exist " .. tostring(objTarget) .. "[" .. tostring(nProtoType) .. "]'s Handle")
		return
	end

	local tFuncs = tEvents[nProtoType][objTarget]
	if not tFuncs then return end
	for k, v in pairs(tFuncs) do
		if v.func == func or func == nil then
			tFuncs[k] = nil
		end
	end
	if #tFuncs == 0 then tEvents[nProtoType][objTarget] = nil end
	local nLen = 0
	for _ in pairs(tEvents[nProtoType]) do nLen = nLen + 1 end
	if nLen <= 0 then tEvents[nProtoType] = nil end
end


function TFProtocolManager:execute(callBack, event)
	TFFunction.call(callBack, event.target, event)
end

--[[--
	派发指定协议事件
	@param nProtoType:协议号
	@param tData:协议数据
]]
function TFProtocolManager:dispatchWith(nProtoType, tData)
	if 	nilCheck(nProtoType, 'nProtoType') then
		return
	end
	local tEvents = TFProtocolManagerModel.tEvents
	if tEvents[nProtoType] then
		local tCloneEvents = table.clone(tEvents[nProtoType])
		for objTarget, tFuncs in pairs(tCloneEvents) do
			if tEvents[nProtoType][objTarget] == nil then return end
			for k, v in pairs(tFuncs) do
				self:execute(v.func, {name = nProtoType, target = objTarget, data = tData})
			end
		end
	end
end

--[[--
	获取指定协议号下注册的事件列表: {objTargets}:{callbacks}
	如果未指定协议号, 则返回所有协议事件: {nProtoType}:{objTargets}:{callbacks}
	@param nProtoType:协议号
	@return 事件列表
]]
function TFProtocolManager:list(nProtoType)
	if nProtoType then
		return TFProtocolManagerModel.tEvents[nProtoType]
	else
		return TFProtocolManagerModel.tEvents
	end
end

return TFProtocolManager:new()