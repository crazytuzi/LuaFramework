--FactionCopyServlet.lua
--/*-----------------------------------------------------------------
 --* Module:  FactionCopyServlet.lua
 --* Author:  seezon
 --* Modified: 2014年11月26日
 --* Purpose: FactionCopy消息接口
 -------------------------------------------------------------------*/

FactionCopyServlet = class(EventSetDoer, Singleton)

function FactionCopyServlet:__init()
	self._doer = {
		[FACTIONCOPY_CS_JOIN]	=		FactionCopyServlet.doJoin,
		[FACTIONCOPY_CS_OUT]	=		FactionCopyServlet.doOut,
		--[FACTIONCOPY_CS_CALL_BOSS]	=		FactionCopyServlet.doCallBoss,
		--[FACTIONCOPY_SS_CALL_BOSS]	=		FactionCopyServlet.onCallBoss,
		[FACTIONCOPY_CS_GET_PASS_TIME]	=		FactionCopyServlet.doGetPassTime,
		[FACTIONCOPY_SS_GET_PASS_TIME]	=		FactionCopyServlet.onGetPassTime,
		[FACTIONCOPY_CS_GET_ALL_RANK]	=		FactionCopyServlet.doGetAllRank,
		[FACTIONCOPY_SS_NOTIFYOPEN]	=		FactionCopyServlet.onNotifyOpen,

		--设置行会副本开启时间
		[FACTIONCOPY_CS_SETOPEN_TIME]	=		FactionCopyServlet.doSetOpenTime,
		[FACTIONCOPY_SS_SETOPEN_TIME]	=		FactionCopyServlet.onSetOpenTime,
}
end


--玩家请求参加活动
function FactionCopyServlet:doJoin(event)
	local params = event:getParams()
	local buffer, dbid, hGate = params[1], params[2], params[3]
	local player = g_entityMgr:getPlayerBySID(dbid)
	if not player then
		return
	end
	
	local roleID = player:getID()
	g_FactionCopyMgr:join(roleID)
end

--玩家请求退出活动
function FactionCopyServlet:doOut(event)
	local params = event:getParams()
	local buffer, dbid, hGate = params[1], params[2], params[3]
	local player = g_entityMgr:getPlayerBySID(dbid)
	if not player then
		return
	end
	
	local roleID = player:getID()
	g_FactionCopyMgr:out(roleID)
end

--玩家召唤BOSS
function FactionCopyServlet:doCallBoss(event)
    local params = event:getParams()
	local buffer, dbId, hGate = params[1], params[2], params[3]
	local roleID = buffer:popInt()
	local copyID = buffer:popInt()
	g_FactionCopyMgr:callBoss(roleID, hGate, copyID)
end

--玩家召唤BOSS
function FactionCopyServlet:onCallBoss(event)
	local params = event:getParams()
	local buffer, serverId = params[1], params[2]
	local dbId = buffer:popInt()
	local hGate = buffer:popInt()
	local facId = buffer:popInt()
	local copyID = buffer:popInt()
	g_FactionCopyMgr:callBoss2(dbId, hGate, facId, copyID)
end


--获取活动开启多久
function FactionCopyServlet:doGetPassTime(event)
	local params = event:getParams()
	local buffer, dbId, hGate = params[1], params[2], params[3]
	local player = g_entityMgr:getPlayerBySID(dbId)
	if not player or player:getFactionID() <= 0 then
		return
	end
	
	--[[
	local roleID = player:getID()
	--切换到数据服处理
	local retBuff = LuaEventManager:instance():getWorldEvent(FACTIONCOPY_SS_GET_PASS_TIME)
	retBuff:pushInt(dbId)
	retBuff:pushInt(hGate)
	retBuff:pushInt(player:getFactionID())
	g_engine:fireWorldEvent(FACTION_DATA_SERVER_ID, retBuff)
	]]--
	
	g_FactionCopyMgr:getPassTime(dbId, hGate, player:getFactionID())
end

--获取活动开启多久
function FactionCopyServlet:onGetPassTime(event)
	local params = event:getParams()
	local buffer, serverId = params[1], params[2]
	local dbId = buffer:popInt()
	local hGate = buffer:popInt()
	local facId = buffer:popInt()

	if facId <= 0 then
		return
	end
	
	g_FactionCopyMgr:getPassTime(dbId, hGate, facId)
end

--获取活动开启多久
function FactionCopyServlet:onNotifyOpen(event)
	local params = event:getParams()
	local buffer, serverId = params[1], params[2]
	local dbId = buffer:popInt()
	local facId = buffer:popInt()

	g_FactionCopyMgr:notifyClientOpen2(dbId, facId)
end

--获取所有排行数据
function FactionCopyServlet:doGetAllRank(event)
	local params = event:getParams()
	local buffer, dbid, hGate = params[1], params[2], params[3]
	local player = g_entityMgr:getPlayerBySID(dbid)
	if not player then
		return
	end
	
	local roleID = player:getID()
	g_FactionCopyMgr:getAllRank(roleID)
end

--给客户端发送错误提示的接口
function FactionCopyServlet:sendErrMsg2Client(roleId, errId, paramCount, params)
	--[[local retBuff = LuaEventManager:instance():getLuaRPCEvent(FRAME_SC_MESSAGE)
	retBuff:pushShort(EVENT_FACTIONCOPY_SET)
	retBuff:pushShort(errId)
	retBuff:pushShort(self:getCurEventID())
	retBuff:pushChar(paramCount)
	for i=1, paramCount do
		retBuff:pushString(tostring(params[i])or "")
	end

	g_engine:fireLuaEvent(roleId, retBuff)
	]]--
	fireProtoSysMessage(self:getCurEventID(), roleId, EVENT_FACTIONCOPY_SET, errId, paramCount, params)
end

--给客户端发送错误提示的接口
function FactionCopyServlet:sendErrMsg2Client2(dbId, hGate, errId, paramCount, params)
	--[[paramCount = paramCount or 0
	local retBuff = LuaEventManager:instance():getLuaRPCEvent(FRAME_SC_MESSAGE)
	retBuff:pushShort(EVENT_FACTIONCOPY_SET)
	retBuff:pushShort(errId)
	retBuff:pushShort(self:getCurEventID())
	retBuff:pushChar(paramCount)
	for i=1, paramCount do
		retBuff:pushString(tostring(params[i])or "")
	end	
	g_engine:fireClientEvent(hGate, dbId, retBuff)
	]]--
	fireProtoSysMessageBySid(self:getCurEventID(), dbId, EVENT_FACTIONCOPY_SET, errId, paramCount, params)
end

function FactionCopyServlet:SystemMsgIntoChatMsg(roleSID,type1,msg,eventID,tipsID,paramsCount,params)
	local buffer = LuaEventManager:instance():getLuaRPCEvent(CHAT_SC_SYSTEM_MSG)
	buffer:pushChar(type1)
	buffer:pushString(msg or "")
	buffer:pushInt(tonumber(os.time()))
	buffer:pushShort(eventID)
	buffer:pushShort(tipsID)
	buffer:pushChar(paramsCount)

	for i=1, paramsCount do
		buffer:pushString(tostring(params[i]) or "")
	end

	return buffer
end
-----------------------------------------------------------------行会副本定时开启------------------------------------------------------------
function FactionCopyServlet:doSetOpenTime(event)
	local params = event:getParams()
	local pbc_string, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("FactionCopySetOpenTime" , pbc_string)
	if not req then
		print('FactionServlet:doSetOpenTime '..tostring(err))
		return
	end

	local copyID = req.copyID
	--local strtime = req.strtime
	local timeId = req.timeId
	print("FactionCopyServlet:doSetOpenTime1",copyID,timeId)
	if timeId < 0 or timeId > #(FactionCopyCanOpenTime) then
		return
	end

	local strtime = FactionCopyCanOpenTime[timeId]
	local player = g_entityMgr:getPlayerBySID(dbid)
	if not player then
		return
	end
	local roleID = player:getID()
	print("FactionCopyServlet:doSetOpenTime2",copyID,timeId,strtime)
	g_FactionCopyMgr:doSetOpenTime(roleID, hGate, copyID, strtime)
end

function FactionCopyServlet:onSetOpenTime(event)
	local params = event:getParams()
	local buffer, serverId = params[1], params[2]
	local dbId = buffer:popInt()
	local hGate = buffer:popInt()
	local facId = buffer:popInt()
	local copyID = buffer:popInt()
	local strtime = buffer:popString()
	print('FactionCopyServlet:onSetOpenTime',dbId,facId,copyID,strtime)
	g_FactionCopyMgr:onSetOpenTime(dbId, hGate, facId, copyID, strtime)
end


function FactionCopyServlet.getInstance()
	return FactionCopyServlet()
end

g_eventMgr:addEventListener(FactionCopyServlet.getInstance())