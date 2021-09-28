--MarriageEventHandler.lua
--/*-----------------------------------------------------------------
 --* Module:  MarriageEventHandler.lua
 --* Author:  goddard
 --* Modified: 2016年8月19日
 --* Purpose: 结婚目标事件类
 -------------------------------------------------------------------*/
MarriageEventHandler = class()

function MarriageEventHandler:__init()
	self._watcherTable={}
end

--增加监听者
function MarriageEventHandler:addWatcher(eventName, watcher)
	if self._watcherTable[eventName] then
		self._watcherTable[eventName][watcher] = true
	else
		self._watcherTable[eventName] = {[watcher] = true}
	end
end

--移除监听者
function MarriageEventHandler:removeWatcher(eventName, watcher)
	if self._watcherTable[eventName] then
		self._watcherTable[eventName][watcher] = nil
	end
end

--通知目标
function MarriageEventHandler:notifyWatchers(eventName, ...)
	if self._watcherTable[eventName] then
		for watcher, yes in pairs(self._watcherTable[eventName] or {}) do
			if yes and type(watcher[eventName]) == "function" then
				watcher[eventName](watcher, ...)
 			end
		end
	end
end