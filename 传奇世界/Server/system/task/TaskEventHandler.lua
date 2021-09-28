--TaskEventHandler.lua
--/*-----------------------------------------------------------------
 --* Module:  TaskEventHandler.lua
 --* Author:  seezon
 --* Modified: 2014年4月9日
 --* Purpose: 任务目标事件类
 -------------------------------------------------------------------*/
TaskEventHandler = class()

function TaskEventHandler:__init()
	self._watcherTable={}
end
--增加监听者
function TaskEventHandler:addWatcher(eventName, watcher)
	if self._watcherTable[eventName] then
		self._watcherTable[eventName][watcher] = true
	else
		self._watcherTable[eventName] = {[watcher] = true}
	end
end
--移除监听者
function TaskEventHandler:removeWatcher(eventName, watcher)
	if self._watcherTable[eventName] then
		self._watcherTable[eventName][watcher] = nil
	end
end

--通知任务目标
function TaskEventHandler:notifyWatchers(eventName, ...)
	local sucess = false
	if self._watcherTable[eventName] then
		for watcher, yes in pairs(self._watcherTable[eventName] or {}) do
			if yes and type(watcher[eventName])=="function" then
				--已经完成的行会任务不再触发了
				if watcher:belongFactionTask() ~= true or watcher:completed() ~= true then
					watcher[eventName](watcher, ...)
				end
				sucess = true
 			end
		end
	end
	return sucess
end	