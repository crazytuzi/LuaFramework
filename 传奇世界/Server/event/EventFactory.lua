--EventFactory.lua
--/*-----------------------------------------------------------------
 --* Module:   EventFactory.lua
 --* Author:   Yang ChangGao
 --* Modified: 2012年10月18日 16:07:08
 --* Purpose:  用于定义事件和创建Event对象实例
 -------------------------------------------------------------------*/
require "event.Event"

EventFactory = class(nil, Singleton)
--------------------------------------------------------
--EventFactory 初始化
--------------------------------------------------------
function EventFactory:__init()
	self.events = {}
end

--------------------------------------------------------
--获得单例的EventFactory实例
--------------------------------------------------------
function EventFactory.getInstance()
	return EventFactory()
end

--------------------------------------------------------
--获得事件对象
--	id         事件的ID
--	source     事件源对象
--	...        事件的附带参数
--------------------------------------------------------
function EventFactory:getEvent(id, source, ...)
--	assert(id, "ID can't be null.")
--	assert(source, "source can't be null.")
--	assert(self.events[id], "error EventID " .. tostring(id))

	--local def = self.events[id]
	local event = Event(id, 0, source, {...})
	return event
end

--------------------------------------------------------
--定义事件
--	id       事件的ID
--	group    事件的分组类别
--	...      事件的附带参数的名称
--------------------------------------------------------
function EventFactory:defineEvent(id, group)
--	assert(id, "ID can't be null.")
--	assert(group, "group can't be null.")

	local def = {group = group}
	if self.events[id] then
		Logger.getLogger():warn(string.format("0x%X ID event already defined.", toNumber(id)))
	end
	self.events[id] = def
end

---------------------------------------
--供系统全局使用的 EventFactory 对象（必须全局唯一）
---------------------------------------
g_eventFty = EventFactory.getInstance()
