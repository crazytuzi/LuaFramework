--EventManager.lua
--/*-----------------------------------------------------------------
 --* Module:   EventManager.lua
 --* Author:   Yang ChangGao
 --* Modified: 2012年10月18日 16:07:08
 --* Purpose:  提供消息监听的注册管理,消息的分发
 -------------------------------------------------------------------*/
require "event.EventListener"
require "event.EventSetDoer"

EventManager = class(nil, Singleton)
--------------------------------------------------------
--EventManager 初始化
--------------------------------------------------------
function EventManager:__init()
	self.eventListeners = {}
end

--------------------------------------------------------
--EventManager 转化成字符串
--------------------------------------------------------
function EventManager:tostring()
	return string.format("EventManager: {event=%d}", table.size(self.eventListeners))
end

--------------------------------------------------------
--获得单例的EventManager实例
--------------------------------------------------------
function EventManager.getInstance()
	return EventManager()
end

gEventMgr = EventManager.getInstance()

--------------------------------------------------------------------------------
--注册监听
--listener 监听对象
--listener对象可以是下面类的实例
--    EventListener          用于监听某个具体的事件类型
--    EventSetListener       用于监听若干事件集合的事件
--------------------------------------------------------------------------------
function EventManager:addEventListener(listener)
	if not instanceof(listener, ActionListener) then
		Logger.getLogger():warn("error ActionListener interface type " .. tostring(listener))
		return false
	end
	if instanceof(listener, EventListener) then
		local id = listener:getEventID()
		if not self.eventListeners[id] then self.eventListeners[id] = {} end
		table.insert(self.eventListeners[id], listener)
	end
	if instanceof(listener, EventSetListener) then
		local ids = listener:getEvents()
		local count = listener:getEventsCount()
		for i, id in pairs(ids) do
			if not self.eventListeners[id] then self.eventListeners[id] = {} end
			table.insert(self.eventListeners[id], listener)
		end
	end
	return true
end

----------------------------------------------------
--移除注册的监听
----------------------------------------------------
function EventManager:removeEventListener(listener)
	if not instanceof(listener, ActionListener) then
		Logger.getLogger():warn("error ActionListener interface type " .. tostring(listener))
		return false
	end
	if instanceof(listener, EventListener) then
		local id = listener:getEventID()
		table.removeValue(self.eventListeners[id], listener)
	end
	if instanceof(listener, EventSetListener) then
		local ids = listener:getEvents()
		local count = listener:getEventsCount()
		for i, id in pairs(ids) do
			table.removeValue(self.eventListeners[id], listener)
		end
	end
	return true
end

--------------------------------------------------------------------------------
--判断是否有指定事件类型的事件监听
--------------------------------------------------------------------------------
function EventManager:hasEventListener(eventID)
	return self.eventListeners[eventID] ~= nil
end

--------------------------------------------------------------------------------
--发送事件
--------------------------------------------------------------------------------
local function fire(list, event)
	for _, v in pairs(list or table.empty) do
		v:action(event)
	end
end

--------------------------------------------------------------------------------
--触发事件
--------------------------------------------------------------------------------
function EventManager:fireEvent(event)
	local id = event:getID()
	fire(self.eventListeners[id], event)
	release(event)
end

--------------------------------------------------------------------------------
--向玩家终端广播事件
--radius<0时，有四个频道radius=eSceneChannel/eWorldChannel/eUniverseChannel/eSightChannel:场景/本世界/宇宙 /附近
--radius>=0时，以radius为半径广播，==0时则仅发给玩家自己
--------------------------------------------------------------------------------
function EventManager:broadcastRemoteEvent(event, baseRole, radius)
	RemoteEventProxy.broadcast(event, baseRole, radius)
end

--------------------------------------------------------------------------------
--触发远程事件
--------------------------------------------------------------------------------
function EventManager:fireRemoteEvent(event, baseRole, radius)
	require "event.RemoteEventProxy"
	if type(baseRole) == "number" then
		baseRole = g_entityMgr:getPlayer(baseRole)
	end
	if baseRole then
		RemoteEventProxy.send(event, baseRole, radius)
	else
		Logger.getLogger():error("[EventManager:fireRemoteEvent] invalid event(0x%x) baseEntity is nil", event:getID())
	end
	release(event)
end

--------------------------------------------------------------------------------
--触发组事件
--------------------------------------------------------------------------------
function EventManager:fireGroupEvent(event, players)
	local peerHandles = {}
	for _, player in pairs(players) do
		if type(player) == "number" then
			player = g_entityMgr:getPlayer(player)
		end	
		if player then
			local peer = player:getRemotePeer()
			if peer > 0 then
				table.insert(peerHandles, peer)
			end	
		end			
	end
	RemoteEventProxy.sendGroupEvent(event, peerHandles)
	release(event)
end

---------------------------------------
--供系统全局使用的 EventManager 对象（必须全局唯一）
---------------------------------------
g_eventMgr = EventManager.getInstance()
