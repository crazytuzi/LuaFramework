--RemoteEventProxy.lua
--/*-----------------------------------------------------------------
 --* Module:   RemoteEventProxy.lua
 --* Author:   Yang ChangGao
 --* Modified: 2012年10月18日 16:07:08
 --* Purpose:  远程事件处理代理类
 -------------------------------------------------------------------*/
require("base.util")

RemoteEventProxy = {}
--------------------------------------------------------------------------------
--广播远程事件
--------------------------------------------------------------------------------
function RemoteEventProxy.broadcast(event, baseRole, radius)
	if not event then return end
	local eEventID = event:getID()
	local params = event:getParams()
	local rpcMsg = g_frame:genRPCMessage(eEventID, -1, unpack(params))
	if (rpcMsg.msgLen > _MaxMsgLength) then
		Logger.getLogger():error("rpc message too long(%d).EventID(%d).Event(%s)", rpcMsg.msgLen, eEventID, toString(event))
	end
	g_engine:boardcastMsg(baseRole, rpcMsg, radius)
end

--------------------------------------------------------------------------------
--发送端对端事件
--------------------------------------------------------------------------------
function RemoteEventProxy.send(event, baseRole, radius)
	if not event then return end	
	local eEventID = event:getID()	
	if eEventID and baseRole then	
		if baseRole:getFakePlayer() then return end		
		radius = radius or 0
		local params = event:getParams()				
		local rpcMsg = g_frame:genRPCMessage(eEventID, -1, unpack(params))
		if (rpcMsg.msgLen > _MaxMsgLength) then
			Logger.getLogger():error("rpc message too long(%d).EventID(%d).Event(%s)", rpcMsg.msgLen, eEventID, toString(event))
		end		
		g_engine:boardcastMsg(baseRole, rpcMsg, radius)
	else
		Logger.getLogger():error(string.format("Event(id=0x%x): nil baseRole", eEventID))
	end
end

--------------------------------------------------------------------------------
--接收事件
--------------------------------------------------------------------------------
function RemoteEventProxy.receive(peer, eventId, _, actorId, ...)
	--g_logger:info("a event just came in, eventId=0x%x, actorId=%d",eventId,actorId)
	RemoteEventProxy.onPeerEvent(peer, eventId, _, actorId, ...)
end

--------------------------------------------------------------------------------
--发送组消息，为了通用，不依赖实体
--------------------------------------------------------------------------------
function RemoteEventProxy.sendGroupEvent(event, peerHandles)
	if type(peerHandles) ~= "table" or not event then
		return
	end
	local eventID = event:getID()
	local params = event:getParams()
	local rpcMsg = g_frame:genRPCMessage(eventID, -1, unpack(params))
	g_frame:sendMsgToPeerGroup(peerHandles, rpcMsg)
end

function RemoteEventProxy.onPeerEvent(peer, eventId, _, actorId, ...)
	--Kirk: anytime there is a valid remote event comes in, it means the player is active
	--self:activatePlayer(player, status==eEntityLoading)
	local event = g_eventFct:getEvent(eventId, peer, actorId, unpack({...}))
	if event then
		local call = string.format("RPCCall#0X%x",eventId)
		--gBeginEval(call)		
		gEventMgr:fireEvent(event)		
		--gEndEval(call)
	end
end