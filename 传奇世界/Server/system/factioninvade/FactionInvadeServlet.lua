--FactionInvadeServlet.lua
--/*-----------------------------------------------------------------
--* Module:  FactionInvadeServlet.lua
--* Author:  Chu Zhihua
--* Modified: 2016年5月20日
--* Purpose: Implementation of the class FactionInvadeServlet
-------------------------------------------------------------------*/

FactionInvadeServlet = class(EventSetDoer, Singleton)

function FactionInvadeServlet:__init()
	self._doer = {
			--行会入侵
		[FACTION_INVADE_CS_GET_FACTION]				= 		FactionInvadeServlet.doGetFactions,
		[FACTION_INVADE_CS_ENTER]					= 		FactionInvadeServlet.doEnter,
		[FACTION_INVADE_CS_GET_CUR_FACTION_INFO] 	=		FactionInvadeServlet.doGetCurFactionInfo,
	}
end

--取得行会数据
function FactionInvadeServlet:doGetFactions(event)
	print("FactionInvadeServlet:doGetFactions")
    local params = event:getParams()
	local pbc_string, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("FactionInvadeGetFactionReq" , pbc_string)
	if not req then
		print('FactionInvadeServlet:doGetFactions '..tostring(err))
		return
	end

	local roleSID = dbid
	g_factionInvadeMgr:getInvadedFaction(roleSID)

end

--进入行会驻地
function FactionInvadeServlet:doEnter(event)
	print("FactionInvadeServlet:doEnter")
    local params = event:getParams()
	local pbc_string, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("FactionInvadeEnterReq" , pbc_string)
	if not req then
		print('FactionInvadeServlet:doEnter '..tostring(err))
		return
	end

	local factionID = req.facID
	local roleSID = dbid

	--进入行会驻地
	g_factionInvadeMgr:enterFactionArea(roleSID, factionID)
end

--获取当前入侵行会信息
function FactionInvadeServlet:doGetCurFactionInfo(event)
	print('FactionInvadeServlet:doGetCurFactionInfo')
	local params = event:getParams()
	local pbc_string, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("FactionInvadeGetCurFactionInfoReq" , pbc_string)
	if not req then
		print('FactionInvadeServlet:doGetCurFactionInfo '..tostring(err))
		return
	end

	local roleSID = dbid
	g_factionInvadeMgr:getCurFactionInfo(roleSID)

end

--发送错误消息
function FactionInvadeServlet:sendErrMsg2Client(roleId, errId, paramCount, params)
	fireProtoSysMessage(self:getCurEventID(), roleId, EVENT_FACTION_SETS, errId, paramCount, params)
end

function FactionInvadeServlet:sendErrMsg2Client2(roleSId, errId, paramCount, params)
	fireProtoSysMessageBySid(self:getCurEventID(), roleSId, EVENT_FACTION_SETS, errId, paramCount, params)
end

function FactionInvadeServlet.getInstance()
	return FactionInvadeServlet()
end

g_factionInvadeServlet = FactionInvadeServlet.getInstance()
g_eventMgr:addEventListener(g_factionInvadeServlet)