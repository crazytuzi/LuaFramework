--ListenerHandler.lua
--/*-----------------------------------------------------------------
 --* Module:   ListenerHandler.lua
 --* Author:   Yang ChangGao
 --* Modified: 2012年10月18日 16:07:08
 --* Purpose:  一个简单的监听器处理器
 -------------------------------------------------------------------*/

ListenerHandler = class()
--------------------------------------------------------
--ListenerHandler 初始化
--------------------------------------------------------
function ListenerHandler:__init()
	self.listeners = {}
	setmetatable(self.listeners, {__mode = "k"})
end

--------------------------------------------------------
--ListenerHandler 注销
--------------------------------------------------------
function ListenerHandler:__release()
	table.clear(self.listeners)
	self.listeners = nil
end

--------------------------------------------------------
--ListenerHandler 转化成字符串
--------------------------------------------------------
function ListenerHandler:tostring()
	local sb = StringBuffer("ListenerHandler: {count=")
	sb = sb .. table.size(self.listeners) .. ", listener={"
	for k, v in pairs(self.listeners or {}) do
		sb = sb .. toString(k) .. ", "
	end
	sb = sb .. "}}"
	return tostring(sb)
end

--------------------------------------------------------
--ListenerHandler 增加事件监听器
--------------------------------------------------------
function ListenerHandler:addListener(listener)
	self.listeners[listener] = true
end

--------------------------------------------------------
--ListenerHandler 删除事件监听器
--------------------------------------------------------
function ListenerHandler:removeListener(listener)
	self.listeners[listener] = nil
end

--------------------------------------------------------
--ListenerHandler 判断监听器是否注册
--------------------------------------------------------
function ListenerHandler:hasListener(listener)
	return (self.listeners[listener] == true)
end

--------------------------------------------------------
--ListenerHandler 通知监听器
----------------------------------------------------------
function ListenerHandler:notifyListener(eventType, ...)
	for listener, _ in pairs(self.listeners or {}) do
		if type(listener[eventType]) == "function" then
			safeCall(listener[eventType], listener, unpack({...}))
		end
	end
end

--------------------------------------------------------
--ListenerHandler 收集方式通知监听器
------------------------------------------------------------
function ListenerHandler:collectNotifyListener(eventType, ...)
	local result = false

	for listener, _ in pairs(self.listeners or {}) do
		if type(listener[eventType]) == "function" then
			local status, ret = safeCall(listener[eventType], listener, unpack({...}))
			if status then
				result = result or ret
			end
		end
	end
	return result
end
