--[[--
	事件管理器:

	--By: yun.bo
	--2013/7/8
]]
local TFFunction 			= TFFunction
local TFLOGERROR 			= TFLOGERROR
local TFLOGWARNING 			= TFLOGWARNING
local pairs 				= pairs

local TFBaseManager 		= require('TFFramework.client.manager.TFBaseManager')
local TFEventManager 		= class('TFEventManager', TFBaseManager)
local TFEventManagerModel 	= {}
local TFGlobalEventTarget	= {}

function TFEventManager:reset()
	TFEventManagerModel.tEvents = {}
end

function TFEventManager:ctor()
	TFEventManagerModel.tEvents = {}
end

local function nilCheck(obj, szName)
	if not obj then 
		TFLOGERROR("TFEventManager:[" .. szName .. '] can not be nil')
		return true
	end
	return false
end

--[[--
	添加指定对象的指定事件类型的指定事件
	@param objTarget:事件对象
	@param szEventType:事件类型
	@param func:事件回调
	@param bIsOnce:事件回调的执行次数,true表示只执行一次,false表示无限制,默认为false
]]
function TFEventManager:addMEListener(objTarget, szEventType, func, bIsOnce)
	if 	nilCheck(objTarget, 'objTarget') or
		nilCheck(szEventType, 'szEventType') or
		nilCheck(func, 'func') then
		return	
	end
	bIsOnce = bIsOnce or false
	--TFLOGINFO("TFEventManager: " .. tostring(objTarget) .. " Add a custom Event:" .. '[' .. szEventType .. ']')

	local tEvents = TFEventManagerModel.tEvents
	tEvents[szEventType] = tEvents[szEventType] or {}
	tEvents[szEventType][objTarget] = tEvents[szEventType][objTarget] or {}
	local tFuncs = tEvents[szEventType][objTarget]
	for k, v in pairs(tFuncs) do
		if v.func and v.func == func then return end
	end
	tFuncs[func] = {func = func, bIsOnce = bIsOnce}
end

--[[--
	添加全局指定事件类型的指定事件
	@param szEventType:事件类型
	@param func:事件回调
	@param bIsOnce:事件回调的执行次数,true表示只执行一次,false表示无限制,默认为false
]]
function TFEventManager:addMEGlobalListener(szEventType, func, bIsOnce)
	self:addMEListener(TFGlobalEventTarget, szEventType, func, bIsOnce)	
end

--[[--
	添加指定对象的指定事件类型的指定事件, 事件回调只会执行一次
	@param objTarget:事件对象
	@param szEventType:事件类型
	@param func:事件回调
]]
function TFEventManager:addMEListenerOnce(objTarget, szEventType, func)
	self:addMEListener(objTarget, szEventType, func, true)
end

--[[--
	添加全局的指定事件类型的指定事件, 事件回调只会执行一次
	@param szEventType:事件类型
	@param func:事件回调
]]
function TFEventManager:addMEGlobalListenerOnce(szEventType, func)
	self:addMEListenerOnce(TFGlobalEventTarget, szEventType, func)
end

--[[--
	移除指定对象的指定事件类型的指定事件
	@param objTarget:事件对象
	@param szEventType:事件类型
	@param func:事件回调, 如果为空,表示移除当前事件的所有回调
]]
function TFEventManager:removeMEListener(objTarget, szEventType, func)
	if 	nilCheck(objTarget, 'objTarget') or
		nilCheck(szEventType, 'szEventType') then
		return
	end
	local tEvents = TFEventManagerModel.tEvents
	if not tEvents[szEventType] then
		TFLOGWARNING("TFEventManager: Not exist" .. tostring(objTarget) .. "[" .. szEventType .. "]的事件处理")
		return
	end

	local funcs = tEvents[szEventType][objTarget]
	if not funcs then return end
	for k, v in pairs(funcs) do
		if v.func == func or func == nil then
			funcs[k] = nil
		end
	end
end

--[[--
	移除全局对象的指定事件类型的指定事件
	@param szEventType:事件类型
	@param func:事件回调, 如果为空,表示移除当前事件的所有回调
]]
function TFEventManager:removeMEGlobalListener(szEventType, func)
	self:removeMEListener(TFGlobalEventTarget, szEventType, func)
end

function TFEventManager:funcBefore(func, ...)
end

function TFEventManager:funcAfter(func, ...)
end

function TFEventManager:execute(func, tEvent)
	--funcBefore(func, tEvent);
	if tEvent.target == TFGlobalEventTarget then
		TFFunction.call(func, tEvent)
	else
		TFFunction.call(func, tEvent.target, tEvent)
	end
	--funcAfter(func, tEvent);
end

--[[--
	给指定对象的指定事件类型派发事件
	@param objTarget:事件对象
	@param szEventType:事件类型
	@param ...:事件数据
]]
function TFEventManager:dispatchEventWith(objTarget, szEventType, ...)
	if 	nilCheck(szEventType, 'szEventType') then
		return
	end
	objTarget = objTarget or TFGlobalEventTarget

	local tEvents = TFEventManagerModel.tEvents
	if tEvents[szEventType] then
		for tar, funcs in pairs(tEvents[szEventType]) do
			if tar == objTarget then
				if tEvents[szEventType][objTarget] == nil then return end
				for k, v in pairs(funcs) do
					self:execute(v.func, {name = szEventType, target = objTarget, data = {...}})
					if v.bIsOnce then
						self:removeMEListener(objTarget, szEventType, v.func)
					end
				end
			else 
				if type(tar) == 'userdata' and tolua.isnull(tar) then 
					print("[TFEventManager] => target:[", tar, "]is already disposed.")
					tEvents[szEventType][tar] = nil
				end
			end
		end
	end
end

--[[--
	给全局对象的指定事件类型派发事件
	@param szEventType:事件类型
	@param ...:事件数据
]]
function TFEventManager:dispatchGlobalEventWith(szEventType, ...)
	self:dispatchEventWith(TFGlobalEventTarget, szEventType, ...)
end

return TFEventManager:new()