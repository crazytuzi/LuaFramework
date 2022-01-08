--[[--
	帧频事件管理器:

	--By: yun.bo
	--2013/7/8
]]

local TFFunction 					= TFFunction
local unpack 						= unpack
local TFArray 						= TFArray

local TFBaseManager 				= require('TFFramework.client.manager.TFBaseManager')
local TFLogType 					= require('TFFramework.client.entity.TFLogType')
local TFEnterFrameManager 			= class('TFEnterFrameManager', TFBaseManager)
local TFEnterFrameManagerModel 		= {}
TFEnterFrameManagerModel.removeFuncBuff = TFArray:new()


function TFEnterFrameManager:reset()
	self:removeAllEnterFrameEvents()
end

function TFEnterFrameManager:ctor()
	self:removeAllEnterFrameEvents()
end

function TFEnterFrameManager:size()
	return TFEnterFrameManagerModel.tHandles:size()
end

function TFEnterFrameManager:update(nElapse)
	if not TFEnterFrameManagerModel.tHandles then return end
	local tProp, func
	while true do
		func = TFEnterFrameManagerModel.removeFuncBuff:pop()
		if not func then break end
		TFEnterFrameManagerModel.tHandleProperties[func] = nil
		TFEnterFrameManagerModel.tHandles:removeObject(func)
	end

	for func in TFEnterFrameManagerModel.tHandles:iterator() do
		tProp = TFEnterFrameManagerModel.tHandleProperties[func]
		if tProp and #tProp > 0 then
			tProp[#tProp] = nElapse
			TFFunction.call(func, unpack(tProp))
		else
			TFFunction.call(func, nElapse)
		end
	end
end

--[[--
	添加帧频事件
]]
function TFEnterFrameManager:addEnterFrameEvent(enterFrameFunc, ...)
	if not enterFrameFunc then return end
	TFEnterFrameManagerModel.tHandles = TFEnterFrameManagerModel.tHandles or TFArray:new()
	if TFEnterFrameManagerModel.tHandles:indexOf(enterFrameFunc) == -1 then
		TFEnterFrameManagerModel.tHandles:push(enterFrameFunc)
		local tParam = {...}
		tParam[#tParam+1] = 0
		TFEnterFrameManagerModel.tHandleProperties[enterFrameFunc] = tParam
		--TFLOGINFO("TFEnterFrameManager => Add a new enterFrameEvent.")
	end
end

--[[--
	移除指定帧频事件
]]
function TFEnterFrameManager:removeEnterFrameEvent(enterFrameFunc)
	if not enterFrameFunc or not TFEnterFrameManagerModel.tHandles or TFEnterFrameManagerModel.tHandles:length() < 1 then
		return
	end
	TFEnterFrameManagerModel.removeFuncBuff:push(enterFrameFunc)
end

--[[--
	移除所有帧频事件
]]
function TFEnterFrameManager:removeAllEnterFrameEvents()
	TFEnterFrameManagerModel.tHandles = TFArray:new()
	TFEnterFrameManagerModel.tHandleProperties = {}
end

return TFEnterFrameManager:new()