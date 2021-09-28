--LuoxiaServlet.lua
--/*-----------------------------------------------------------------
 --* Module:  LuoxiaServlet.lua
 --* Author:  seezon
 --* Modified: 2015年6月24日
 --* Purpose: Luoxia消息接口
 -------------------------------------------------------------------*/

LuoxiaServlet = class(EventSetDoer, Singleton)

function LuoxiaServlet:__init()
	self._doer = {
		[LUOXIA_CS_JOIN]	=		LuoxiaServlet.doJoin,
		[LUOXIA_CS_OUT]	=		LuoxiaServlet.doOut,
		[LUOXIA_CS_GETREMAINTIME]	=		LuoxiaServlet.doGetRemainTime,
}
end


--玩家请求参加活动
function LuoxiaServlet:doJoin(event)
    local params = event:getParams()
	local pbc_string, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("LuoxiaJoinProtocol" , pbc_string)
	if not req then
		print('LuoxiaServlet:doJoin '..tostring(err))
		return
	end

	local roleID = dbid
	local player = g_entityMgr:getPlayerBySID(roleID)
	g_LuoxiaMgr:join(player:getID())
end

--玩家请求退出活动
function LuoxiaServlet:doOut(event)
    local params = event:getParams()
	local pbc_string, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("LuoxiaOutProtocol" , pbc_string)
	if not req then
		print('LuoxiaServlet:doOut '..tostring(err))
		return
	end

	local roleID = dbid
	local player = g_entityMgr:getPlayerBySID(roleID)
	g_LuoxiaMgr:out(player:getID())
end

--玩家请求获取活动剩余时间
function LuoxiaServlet:doGetRemainTime(event)
    local params = event:getParams()
	local pbc_string, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("LuoxiaGetRmainTimeProtocol" , pbc_string)
	if not req then
		print('LuoxiaServlet:doGetRemainTime '..tostring(err))
		return
	end

	local roleID = dbid
	local player = g_entityMgr:getPlayerBySID(roleID)

	g_LuoxiaMgr:getRemainTime(player:getID())
end

function LuoxiaServlet:onDoerActive()
	g_normalLimitMgr:setActiveState(ACTIVITY_NORMAL_ID.LUOXIA, true)
end

function LuoxiaServlet:onDoerClose()
	g_normalLimitMgr:setActiveState(ACTIVITY_NORMAL_ID.LUOXIA, false)
end

--给客户端发送错误提示的接口
function LuoxiaServlet:sendErrMsg2Client(roleId, errId, paramCount, params)
	fireProtoSysMessage(self:getCurEventID(), roleId, EVENT_LUOXIA_SET, errId, paramCount, params)
end

function LuoxiaServlet.getInstance()
	return LuoxiaServlet()
end

g_eventMgr:addEventListener(LuoxiaServlet.getInstance())