--TreasureServlet.lua
--/*-----------------------------------------------------------------
 --* Module:  TreasureServlet.lua
 --* Author:  zhihua chu
 --* Modified: 2016年8月11日
 -------------------------------------------------------------------*/

TreasureServlet = class(EventSetDoer, Singleton)

function TreasureServlet:__init()
	self._doer = {
		[TREASURE_CS_JOIN]	=		TreasureServlet.doJoin,
		[TREASURE_CS_OUT]	=		TreasureServlet.doOut,
		[TREASURE_CS_REMAIN_TIME]	= TreasureServlet.doRemainTime,
	}
end

function TreasureServlet:doJoin(event)
	print("TreasureServlet:doJoin")
    local params = event:getParams()
	local pbc_string, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("TreasureJoinProtocol" , pbc_string)
	if not req then
		print('TreasureServlet:doJoin '..tostring(err))
		return
	end

	local  roleSID = tostring(dbid)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if player then
		g_TreasureManger:join(roleSID, false)
	end
end

function TreasureServlet:doOut(event)
	print("TreasureServlet:doOut")
    local params = event:getParams()
	local pbc_string, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("TreasureOutProtocol" , pbc_string)
	if not req then
		print('TreasureServlet:doOut '..tostring(err))
		return
	end

	local  roleSID = tostring(dbid)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if player then
		g_TreasureManger:out(roleSID)
	end
end

function TreasureServlet:doRemainTime(event)
	print("TreasureServlet:doRemainTime")
    local params = event:getParams()
	local pbc_string, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("TreasureReaminTimeProtocol" , pbc_string)
	if not req then
		print('TreasureServlet:doRemainTime '..tostring(err))
		return
	end

	local  roleSID = tostring(dbid)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if player then
		g_TreasureManger:remainTime(roleSID)
	end
end

function TreasureServlet:sendErrMsg2Client(roleId, errId, paramCount, params)
	fireProtoSysMessage(self:getCurEventID(), roleId, EVENT_TREASURE_SET, errId, paramCount, params)
end

function TreasureServlet.getInstance()
	return TreasureServlet()
end

g_eventMgr:addEventListener(TreasureServlet.getInstance())