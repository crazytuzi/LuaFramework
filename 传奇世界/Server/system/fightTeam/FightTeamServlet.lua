--FightTeamServlet.lua
--/*-----------------------------------------------------------------
 --* Module:  FightTeamServlet.lua
 --* Author:  seezon
 --* Modified: 2016年6月14日
 --* Purpose: FightTeam消息接口
 -------------------------------------------------------------------*/

FightTeamServlet = class(EventSetDoer, Singleton)

function FightTeamServlet:__init()
	self._doer = {
		[FIGTHTEAM_CS_CREATE]	=		FightTeamServlet.doCreate,
		[FIGTHTEAM_CS_ADD_MEMBER]	=		FightTeamServlet.doAddMember,
		[FIGTHTEAM_CS_REPLY_INVITE]	=		FightTeamServlet.doReplyInvite,
		[FIGTHTEAM_CS_REMOVE_MEMBER]	=		FightTeamServlet.doRemoveMember,
		[FIGTHTEAM_CS_LEAVE]	=		FightTeamServlet.doLeave,
		[FIGTHTEAM_CS_GET_TEAMINFO]	=		FightTeamServlet.doGetTeamInfo,
}
end


--玩家请求创建战队
function FightTeamServlet:doCreate(event)
    local params = event:getParams()
	local pbc_string, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("FightTeamCreateProtocol" , pbc_string)
	if not req then
		print('FightTeamServlet:doCreate '..tostring(err))
		return
	end

	local roleID = dbid
	local player = g_entityMgr:getPlayerBySID(roleID)
	local name = req.name
	g_fightTeamMgr:create(player:getID(), name)
end

--玩家请求增加战队成员
function FightTeamServlet:doAddMember(event)
    local params = event:getParams()
	local pbc_string, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("FightTeamAddProtocol" , pbc_string)
	if not req then
		print('FightTeamServlet:doAddMember '..tostring(err))
		return
	end

	local roleID = dbid
	local player = g_entityMgr:getPlayerBySID(roleID)
	local targetPlayerName = req.targetPlayerName
	g_fightTeamMgr:addMember(player:getID(), targetPlayerName)
end

--玩家回应邀请
function FightTeamServlet:doReplyInvite(event)
    local params = event:getParams()
	local pbc_string, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("FightTeamReplyInviteProtocol" , pbc_string)
	if not req then
		print('FightTeamServlet:doReplyInvite '..tostring(err))
		return
	end

	local roleID = dbid
	local player = g_entityMgr:getPlayerBySID(roleID)

	local fightTeamID = req.fightTeamID
	local result = req.result
	g_fightTeamMgr:replyInvite(player:getID(), fightTeamID, result)
end

--玩家请求删除战队成员
function FightTeamServlet:doRemoveMember(event)
    local params = event:getParams()
	local pbc_string, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("FightTeamRemoveProtocol" , pbc_string)
	if not req then
		print('FightTeamServlet:doRemoveMember '..tostring(err))
		return
	end

	local roleID = dbid
	local player = g_entityMgr:getPlayerBySID(roleID)
	local targetSID = req.targetSID
	g_fightTeamMgr:removeMember(player:getID(), targetSID)
end

--玩家请求离开战队成员
function FightTeamServlet:doLeave(event)
    local params = event:getParams()
	local pbc_string, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("FightTeamLeaveProtocol" , pbc_string)
	if not req then
		print('FightTeamServlet:doLeave '..tostring(err))
		return
	end

	local roleID = dbid
	local player = g_entityMgr:getPlayerBySID(roleID)

	g_fightTeamMgr:leave(player:getID())
end

--玩家请求获取战队信息
function FightTeamServlet:doGetTeamInfo(event)
    local params = event:getParams()
	local pbc_string, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("FightTeamGetInfoProtocol" , pbc_string)
	if not req then
		print('FightTeamServlet:doGetTeamInfo '..tostring(err))
		return
	end

	local roleID = dbid
	local player = g_entityMgr:getPlayerBySID(roleID)

	g_fightTeamMgr:sendTeamInfo(player:getID())
end

--给客户端发送错误提示的接口
function FightTeamServlet:sendErrMsg2Client(roleId, errId, paramCount, params)
	fireProtoSysMessage(self:getCurEventID(), roleId, EVENT_FIGHTTEAM_SETS, errId, paramCount, params)
end

function FightTeamServlet:onCheckUniNameRet(event)
    local params = event:getParams()
	local buffer, dbid, hGate = params[1], params[2], params[3]
	local roleID = buffer:popString()
	local result = buffer:popBool()
	local player = g_entityMgr:getPlayerBySID(roleID)
	if player then
		g_fightTeamMgr:onCheckUniNameRet(player, result)
	end
end

function FightTeamServlet.getInstance()
	return FightTeamServlet()
end

g_FightTeamServlet = FightTeamServlet.getInstance()

g_eventMgr:addEventListener(FightTeamServlet.getInstance())