--EventSetDoer.lua
--/*-----------------------------------------------------------------
 --* Module:   EventListener.lua
 --* Author:   Yang ChangGao
 --* Modified: 2012年10月18日 16:07:08
 --* Purpose:  事件集对象，所有时间监听器必须从此类继承
 -------------------------------------------------------------------*/
require("event.EventListener")

EventSetDoer = class(nil, EventSetListener)
--------------------------------------------------------
--EventSetDoer 初始化
--------------------------------------------------------
function EventSetDoer:__init()
	self._doer = {}
	self._actived = true
end

--------------------------------------------------------
--EventSetDoer 获取监听的所有事件
--------------------------------------------------------
function EventSetDoer:getEvents()
	local evtSet = {}
	for i, _ in pairs(self._doer) do
		table.insert(evtSet, i)
	end
	return evtSet
end

--------------------------------------------------------
--EventSetDoer 获取监听的所有事件的数量
--------------------------------------------------------
function EventSetDoer:getEventsCount()
	return table.size(self._doer)
end

--------------------------------------------------------
--EventSetDoer 激活此Doer
--------------------------------------------------------
function EventSetDoer:setActive(bActive)
	self._actived = bActive
	if self._actived then
		self:onDoerActive()
	else
		self:onDoerClose()
	end
end

--------------------------------------------------------
--EventSetDoer 监听的事件触发
--------------------------------------------------------
function EventSetDoer:action(evt)
	local id = evt:getID()
	self._eventID = id
	local doer = self._doer[id]
	if not self._actived then
		Logger.getLogger():warn(string.format("[EventSetDoer]: this system(%x) has been not actived yet",id))
		return
	end
	if doer then
		doer(self,evt)
	else
		Logger.getLogger():warn(string.format("[EventSetDoer]: this event(%x) has not been supported yet",id))
	end
end

--------------------------------------------------------
--EventSetDoer 监听的事件触发
--------------------------------------------------------
function EventSetDoer:getCurEventID()
	return self._eventID or 0
end

--------------------------------------------------------
--EventSetDoer 触发事件
--------------------------------------------------------
function EventSetDoer:onDoerActive()
end

function EventSetDoer:onDoerClose()
end