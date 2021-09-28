--队伍相关服务器信息(因为目前监听有问题，一个协议号只能有一个函数监听，所以监听部分还是用TeamMsgHandler文件中的，这里回与这个文件做一些交互)
local TeamNetCtr = class("TeamNetCtr")

function TeamNetCtr:ctor( ... )
	-- body
	self:addEvent()
end

function TeamNetCtr:addEvent( ... )
	-- body
	--创建队伍返回
end

function TeamNetCtr:removeEvent( ... )
	-- body
end

--创建队伍(创建队伍返回在teamMsgHandler中处理)
function TeamNetCtr:createTeam( nCaptainId )
	-- body
	nCaptainId = nCaptainId or userInfo.currRoleId
	g_msgHandlerInst:sendNetDataByTableExEx(TEAM_CS_CREATE_TEAM, "CreateTeamProtocol", {roleId = nCaptainId})
end

--设置队伍目标
function TeamNetCtr:setTarget( nTarget )
	-- body
	g_msgHandlerInst:sendNetDataByTableExEx(TEAM_CS_CHANGE_AUTOINVITE, "TeamChangeAutoInviteProtocol", { ["inviteValue"] = nTarget ,["inviteType"] = 3 })
end

--邀请入队
function TeamNetCtr:invite( sTargetName )
	-- body
	InviteTeamUp(sTargetName)
end

--申请入队
function TeamNetCtr:apply( sCapTainName, nTeamId )
	-- body
	g_msgHandlerInst:sendNetDataByTableExEx(TEAM_CS_INVITE_TEAM, "InviteTeamProtocol", {["tName"] = sCapTainName, ["isApply"] = true,["iTeamID"] = nTeamId or 0})
end

--移除队员
function TeamNetCtr:removeMem( nTargetSid )
	-- body
	g_msgHandlerInst:sendNetDataByTableExEx(FIGTHTEAM_CS_REMOVE_MEMBER, "FightTeamRemoveProtocol", {targetSID = nTargetSid})
end

--离开队伍
function TeamNetCtr:leave( ... )
	-- body
	g_msgHandlerInst:sendNetDataByTableExEx(TEAM_CS_LEAVE_TEAM, "TeamLeaveTeamProtocol", {})
end

--提升队长
function TeamNetCtr:changeCaptain( nRoleId )
	-- body
	g_msgHandlerInst:sendNetDataByTableExEx(TEAM_CS_CHANGE_LEADER, "TeamChangeLeaderProtocol", {["tRoleId"] = nRoleId})
end

--获取队伍信息 
function TeamNetCtr:getTeamInfo( ... )
	-- body
	g_msgHandlerInst:sendNetDataByTableExEx(TEAM_CS_GET_TEAMINFO, "TeamGetTeamInfoProtocol", {})
end

--[[
// TEAM_SC_GET_AOUNDPLAYER_RET 4012
message TeamGetArroundPlayerRetProtocol
{
	optional int32 noTeamCnt = 1;
	repeated SpeRoleInfo noTeaminfos = 2;
	optional int32 withTeamCnt = 3;
	repeated AroundTeamInfo teamInfos = 4;
	optional int32 aroundType = 5; 			//1 is around team info, 2 is around no team player 
}
}]]
--获取队伍列表(返回的是简单队伍)
function TeamNetCtr:getTeamList( nTeamTarget )
	-- body
	g_msgHandlerInst:sendNetDataByTableExEx(TEAM_CS_GET_AOUNDPLAYER, "TeamGetAroundPlayerProtocol", {aroundType = 3, aroundValue = nTeamTarget})
	g_msgHandlerInst:registerMsgHandler(TEAM_SC_GET_AOUNDPLAYER_RET,function(buff)	
		local t = g_msgHandlerInst:convertBufferToTable("TeamGetArroundPlayerRetProtocol", buff)
		GetTeamCtr():update(t.teamInfos, false)
	end)
end

--[[
// COPY_CS_ANSWER_ATTEND_MULTICOPY 13084
message MultiCopyAnswerAttendProtocol
{
	optional int32 answer = 1;
}
]]
--回复队长请求
function TeamNetCtr:answerCaptain( bOk )
	-- body
	local nAnswer = bOk
	if type(bOk) == "boolean" then
		if bOk == true then
			nAnswer = 1
		else
			nAnswer = 0
		end
	end

	local t = 
	{
		answer = nAnswer,
	}
	g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_ANSWER_ATTEND_MULTICOPY, "MultiCopyAnswerAttendProtocol", t)
end

function TeamNetCtr:dispose( ... )
	-- body
	self:removeEvent()
end

return TeamNetCtr