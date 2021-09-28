--TeamEventParse.lua
--/*-----------------------------------------------------------------
 --* Module:  TeamEventParse.lua
 --* Author:  Wang Lin
 --* Modified: 2014年4月3日 15:49:14
 --* Purpose: Implementation of the class TeamEventParse
 -------------------------------------------------------------------*/

SCMESSAGE = {} --提示消息 
--FRAME_SC_MESSAGE 后端写消息
--params:wData[1]对应是哪一个系统的提示,wData[2]对应提示信息号客户端根据前两个参数取配置
--wData[3]一共要传几个参数给客户端,wData[4]参数表
SCMESSAGE.writeFun = function(wData)
	local ret = {}
	local paramlist = {}
	ret.eventId = wData[1]
	ret.eCode = wData[2]
	ret.mesId = wData[3]
	local paramCnt = wData[4]
	local params = wData[5]
	for i=1, paramCnt do
		table.insert(paramlist,params[i])
	end
	ret.param = paramlist
	

	--[[local retBuff = LuaEventManager:instance():getLuaRPCEvent(FRAME_SC_MESSAGE) 
	retBuff:pushShort(wData[1])
	retBuff:pushShort(wData[2])
	retBuff:pushShort(wData[3])
	retBuff:pushChar(wData[4])
	local paramCnt = wData[4]
	local params = wData[5]

	for i=1, paramCnt do
		retBuff:pushString(tostring(params[i]))
	end]]
	return ret
end
--FRAME_SC_MESSAGE 前端读消息
SCMESSAGE.readFun = function(buffer)
	--客户端按照writeFun规格读取数据
end

--创建队伍
CSCREATETEAM = {}
--TEAM_CS_CREATE_TEAM前端写消息
--params:roleID
CSCREATETEAM.writeFun = function(roleID)
	--[[local retBuff = LuaEventManager:instance():getLuaRPCEvent(TEAM_CS_CREATE_TEAM)
	retBuff:pushInt(roleID)]]
	local ret = {}
	ret.roleId = roleID
	return ret
end

--TEAM_CS_CREATE_TEAM后端读消息
CSCREATETEAM.readFun = function(buffer)
	local roleID = buffer:popInt()
	return roleID
end

--创建队伍返回
SCCREATETEAMRET = {}
--TEAM_SC_CREATE_TEAM_RET 后端写消息
--retBuff:队伍ID，roleSID, roleName, roleLevel, school
SCCREATETEAMRET.writeFun = function(wData)
	local retBuff = {}
	retBuff.teamId = wData[1]
	retBuff.roleSid  = wData[2]
	retBuff.name = wData[3]
	retBuff.roleLevel = wData[4]
	retBuff.sex = wData[5]
	retBuff.school = wData[6]
	retBuff.wingId = wData[7]
	retBuff.weapon = wData[8]
	retBuff.upperBody = wData[9]
	--retBuff:pushString(wData[4])
	return retBuff 
end

--TEAM_SC_CREATE_TEAM_RET前端读消息
SCCREATETEAMRET.readFun = function(buff)

end

SCADDNEWMEMBER = {}
--TEAM_SC_ADD_NEW_MEMBER后端写消息
--retBuff:队伍ID，roleSID, roleName, 所在地图名字 mapName
--[[SCADDNEWMEMBER.writeFun = function(wData)
	local retBuff = LuaEventManager:instance():getLuaRPCEvent(TEAM_SC_ADD_NEW_MEMBER)
	retBuff:pushInt(wData[1])
	retBuff:pushInt(wData[2])
	retBuff:pushString(wData[3])
	retBuff:pushInt(wData[4])
	retBuff:pushChar(wData[5])		--添加性别 20150319
	retBuff:pushChar(wData[6])
	--retBuff:pushString(wData[4])
	return retBuff 
end]]

--TEAM_SC_ADD_NEW_MEMBER前端读消息
SCADDNEWMEMBER.readFun = function(rData)
	--客户端应该给队长某人加入的提示
end

SCJOINTEAM = {} --加入队伍成功
--TEAM_SC_JOIN_TEAM后端写消息
--[[SCJOINTEAM.writeFun = function(teamID)
	local retBuff = LuaEventManager:instance():getLuaRPCEvent(TEAM_SC_JOIN_TEAM)
	retBuff:pushInt(teamID)
	return retBuff 
end]]
--TEAM_SC_JOIN_TEAM前端读消息
SCJOINTEAM.readFun = function(teamID)
	--客户端应该还要给加入者提示加入成功的提示
end

CSTEAMINFOTB = {}
--TEAM_CS_GET_TEAMINFO前端事件接口
--params:wData: {roleID} 玩家运行时ID
CSTEAMINFOTB.writeFun = function(wData)
	local retBuff = LuaEventManager:instance():getLuaRPCEvent(TEAM_CS_GET_TEAMINFO)
	retBuff:pushInt(wData[1])
	return retBuff
end

--TEAM_CS_GET_TEAMINFO后端事件接口
--params:buffer: 里面只有一个roleID
CSTEAMINFOTB.readFun = function(buffer)
	return ""
end

SCTEAMINFOTB = {}
--TEAM_SC_GET_TEAMINFO_RET前端接收事件接口
SCTEAMINFOTB.readFun = function(buffer)
	
end

--TEAM_SC_GET_TEAMINFO_RET后端事件接口
--params:wData: {teamID, memCnt, {rolesID, name, roleLvl, school, actived}...} 
--memCnt:队伍人数 roleID:角色静态ID;name:名字;roleLvl:玩家等级;school 职业；actived：是否在线，0表示离线，1表示在线
--{rolesID, name, roleLvl, school, actived}为一个玩家的数据 一共有memCnt组数据
SCTEAMINFOTB.writeFun = function(wData, teamID)
	--[[local retBuff = LuaEventManager:instance():getLuaRPCEvent(TEAM_SC_GET_TEAMINFO_RET)
	retBuff:pushBool(true)--表示有队伍
	retBuff:pushInt(teamID)
	local memCnt = wData[2]
	retBuff:pushChar(memCnt)
	for i=3, memCnt+2 do
		local temp = wData[i]
		for j=1, 4 do 
			retBuff:pushInt(temp[1])
			retBuff:pushString(temp[2])
			retBuff:pushInt(temp[3])
			retBuff:pushChar(temp[4])		--添加性别	20150319
			retBuff:pushChar(temp[5])
			retBuff:pushChar(temp[6])
		end
	end]]
	local retBuff = {}
	retBuff.hasTeam = true
	retBuff.teamId = teamID
	local memCnt = wData[2]
	retBuff.memCnt = memCnt
	retBuff.infos = {}
	for i=3, memCnt+2 do
		local temp = wData[i]
		for j=1, 4 do 
			local info = {}
			info.roleSid = temp[1]
			info.name = temp[2]
			info.roleLevel = temp[3]
			info.sex = temp[4]
			info.school = temp[5]
			info.actived = temp[6]
			table.insert(retBuff.infos,info)
		end
	end
	return retBuff
end

--获取周围玩家信息
CSGETROUNDINFO = {}
--TEAM_CS_GET_AOUNDPLAYER前端写事件接口
CSGETROUNDINFO.writeFun = function(roleID)
	local retBuff = LuaEventManager:instance():getLuaRPCEvent(TEAM_CS_GET_AOUNDPLAYER)
	retBuff:pushInt(roleID)
	return retBuff
end

--TEAM_CS_GET_AOUNDPLAYER后端接收事件接口
CSGETROUNDINFO.ReadFun = function(buffer)
	local roleID = buffer:popInt()
	return roleID
end

SCGETROUNDINFO = {}
--TEAM_CS_GET_AOUNDPLAYER前端接收事件接口
SCGETROUNDINFO.readFun = function(buffer)

end

--TEAM_SC_GET_AOUNDPLAYER_RET 后端写事件接口
--params:teamCnt:队伍数量;noTeamCnt:无队伍玩家数量;allTeamInfo:队伍以及队长数据;noTeamInfo:无队伍玩家数据
--table.insert(allTeamInfo, team, aPlayer) ;noTeamInfo为player构成的表
SCGETROUNDINFO.writeFun = function(teamCnt, noTeamCnt, allTeamInfo, noTeamInfo)
	local retBuff = {}
	retBuff.noTeamCnt = noTeamCnt
	table.sort(noTeamInfo, function(a,b) return a:getLevel()>b:getLevel() end)
	retBuff.noTeaminfos = {}
	for i=1, noTeamCnt do
		local tmp = noTeamInfo[i]
		local info = {}
		info.roleId = tmp:getID()
		info.name = tmp:getName()
		info.level = tmp:getLevel()
		info.factionName = tmp:getFactionName()
		info.school = tmp:getSchool() or 0
		table.insert(retBuff.noTeaminfos,info)
	end
	retBuff.withTeamCnt = teamCnt
	retBuff.withTeaminfos = {}
	for k, v in pairs(allTeamInfo) do
		local info = {}
		info.roleId = v[1]
		info.name = v[2]
		info.level = v[3]
		info.factionName = v[4]
		info.school = v[5]
		info.curNum = v[6]
		info.maxNum = TEAM_MAX_MEMBER
		info.teamId = v[7]
		table.insert(retBuff.withTeaminfos,info)
	end
	return retBuff
end

--TEAM_CS_INVITE_TEAM前端写消息
CSINVITETEAM = {}
--params:sRoleID操作发起者，tRoleID 操作接收者
CSINVITETEAM.writeFun = function(sRoleID, tRoleID)
	local retBuff = LuaEventManager:instance():getLuaRPCEvent(TEAM_CS_INVITE_TEAM)
	retBuff:pushInt(sRoleID)
	retBuff:pushInt(tRoleID)
	return retBuff
end
--TEAM_CS_INVITE_TEAM后端读消息
--buffer中只有两个ID
CSINVITETEAM.readFun = function(buffer)
	local sRoleID, tRoleID
	sRoleID = buffer:popInt()
	tRoleID = buffer:popInt()
	return sRoleID, tRoleID
end

SCINVITETEAMRET = {}
--TEAM_SC_INVITE_TEAM_RET 后端写消息
--params:sRoleID操作发起者静态ID, teamID 队长所在队伍ID， isInvite表示是否是邀请加入，如果为false则表示是申请加入
SCINVITETEAMRET.writeFun = function(sRoleID, teamID, isInvite,name)
	local ret = {}
	ret.roleId = sRoleID
	ret.teamId = teamID
	ret.isInvite = isInvite
	ret.name = name
	return ret
end

--TEAM_SC_INVITE_TEAM_RET 前端读消息
SCINVITETEAMRET.readFun = function(buffer)
	local retBuff = LuaEventManager:instance():getLuaRPCEvent(TEAM_SC_INVITE_TEAM_RET)
	local leaderID = buffer:popInt()
	local roleID = buffer:popInt(tRoleID)
	local teamID = buffer:popInt()
	local isInvite = buffer:popBool(isInvite)
	return {leaderID, roleID, teamID, isInvite}
end

CSANSWERINVITE = {} --回应入队邀请
--TEAM_CS_ANSWER_INVITE 前端写消息
--params:队长ID  被邀请人ID 队伍ID 是否同意邀请
CSANSWERINVITE.writeFun = function(leaderID, tRoleID, teamID, bAnswer)
	local retBuff = LuaEventManager:instance():getLuaRPCEvent(TEAM_CS_ANSWER_INVITE)
	retBuff:pushInt(leaderID)
	retBuff:pushInt(tRoleID)
	retBuff:pushInt(teamID)
	retBuff:pushBool(bAnswer)
	return retBuff
end
--TEAM_CS_ANSWER_INVITE后端读消息
CSANSWERINVITE.readFun = function(buffer)
	local req, err = protobuf.decode("TeamAnswerInviteProtocol" , buffer)
	if not req then
		print('CSANSWERINVITE.readFun '..tostring(err))
		return
	end
	local tRoleID = req.tRoleId
	local teamID = req.teamId
	local bAnswer = req.bAnswer
	return tRoleID, teamID, bAnswer
end

CSANSWERAPPLY = {} --回应入队申请
--TEAM_CS_ANSWER_APPLY前端写消息
--params:队长ID  申请人ID 队伍ID 是否同意邀请
CSANSWERAPPLY.writeFun = function(leaderID, tRoleSID, teamID, bAnswer)
	local retBuff = LuaEventManager:instance():getLuaRPCEvent(TEAM_CS_ANSWER_APPLY)
	retBuff:pushInt(leaderID)
	retBuff:pushInt(tRoleID)
	retBuff:pushInt(teamID)
	retBuff:pushBool(bAnswer)
	return retBuff
end
--TEAM_CS_ANSWER_APPLY后端读消息
CSANSWERAPPLY.readFun = function(buffer)
	local req, err = protobuf.decode("TeamAnswerApplyProtocol" , buffer)
	if not req then
		print('CSANSWERAPPLY.readFun '..tostring(err))
		return
	end
	local tRoleID = req.tRoleId
	local teamID = req.teamId
	local bAnswer = req.bAnswer
	return tRoleID, teamID, bAnswer
end

CSGETTEAMAPPLY = {} --队伍申请记录
--TEAM_CS_GET_TEAM_APPLY 前端写消息
CSGETTEAMAPPLY.writeFun = function(leaderID, teamID)
	local retBuff = LuaEventManager:instance():getLuaRPCEvent(TEAM_CS_GET_TEAM_APPLY)
	retBuff:pushInt(leaderID)
	retBuff:pushInt(teamID)
	return retBuff
end

--TEAM_CS_GET_TEAM_APPLY 后端读消息
CSGETTEAMAPPLY.readFun = function(buff)
	local req, err = protobuf.decode("TeamGetTeamApplyProtocol" , buff)
	if not req then
		print('CSGETTEAMAPPLY.readFun '..tostring(err))
		return
	end
	local teamID = req.teamId
	return teamID
end

SCGETTEAMAPPLYRET = {}
--TEAM_SC_GET_TEAM_APPLY_RET

CSREMOVEMEMBER = {} --移除队友
--TEAM_CS_REMOVE_MEMBER前端写消息
CSREMOVEMEMBER.writeFun = function(leaderID, tRoleID)
	local retBuff = LuaEventManager:instance():getLuaRPCEvent(TEAM_CS_REMOVE_MEMBER)
	retBuff:pushInt(leaderID)
	retBuff:pushInt(tRoleID)
	return retBuff
end
--TEAM_CS_REMOVE_MEMBER后端读消息
CSREMOVEMEMBER.readFun = function(buffer)
	local req, err = protobuf.decode("TeamRemoveMemberProtocol" , buffer)
	if not req then
		print('CSREMOVEMEMBER.readFun '..tostring(err))
		return
	end
	local tRoleID = req.tRoleId
	return tRoleID
end

SCREMOVEMEMBERRET = {} --移除队友返回
--TEAM_SC_REMOVE_MEMBER_RET 后端写消息
--roleSID,eCodeID,对其余队员的提示ID 
SCREMOVEMEMBERRET.writeFun = function(roleSID, eCodeID)
	--[[local retBuff = LuaEventManager:instance():getLuaRPCEvent(TEAM_SC_REMOVE_MEMBER_RET)
	retBuff:pushBool(true) --表示是开除队友
	retBuff:pushInt(roleSID)
	retBuff:pushInt(eCodeID)]]
	local retBuff = {}
	retBuff.bLeave = true
	retBuff.roleSid = roleSID
	retBuff.eCode = eCodeID
	return retBuff
end
--TEAM_CS_REMOVE_MEMBER_RET 前端读消息
SCREMOVEMEMBERRET.readFun = function(buffer)
	--读被移除者ID，并且和自己的ID比较如果相等则提示被移除队伍 如果不相等则进行别的处理
end

CSCHANGELEADER = {} --提升队长
--TEAM_CS_CHANGE_LEADER 前端写消息
--params:队长ID 队员ID
CSCHANGELEADER.writeFun = function(leaderID, tRoleSID)
	local retBuff = LuaEventManager:instance():getLuaRPCEvent(TEAM_CS_CHANGE_LEADER)
	retBuff:pushInt(leaderID)
	retBuff:pushInt(tRoleSID)
	return retBuff
end
--TEAM_CS_CHANGE_LEADER 后端读消息
--params:队长ID 队员ID
CSCHANGELEADER.readFun = function(buffer)
	local req, err = protobuf.decode("TeamChangeLeaderProtocol" , buffer)
	if not req then
		print('CSCHANGELEADER.readFun '..tostring(err))
		return
	end
	local tRoleID = req.tRoleId
	return tRoleID
end

SCCHANGELEADERRET = {} --提升队长
--TEAM_SC_CHANGE_LEADER_RET 后端写消息
--params:leaderSID 改变后的队长ID
SCCHANGELEADERRET.writeFun = function(leaderSID, eCodeID, hasApply)
	--[[local retBuff = LuaEventManager:instance():getLuaRPCEvent(TEAM_SC_CHANGE_LEADER_RET)
	retBuff:pushInt(leaderSID)
	retBuff:pushInt(eCodeID)]]
	local ret = {}
	ret.leaderSid = leaderSID
	ret.eCodeId = eCodeID
	ret.hasApply = hasApply
	return ret
end
--TEAM_SC_CHANGE_LEADER_RET 前端读消息
SCCHANGELEADERRET.readFun = function(buffer)
	--对于被提升为队长的人，应该提示你被提升为队长与其余人的提示不一样
	local leaderID = buffer:popInt()
	return leaderID
end

CSLEAVETEAM = {} --主动离开队伍
--TEAM_CS_LEAVE_TEAM 前端写消息
CSLEAVETEAM.writeFun = function(roleID)
	local retBuff = LuaEventManager:instance():getLuaRPCEvent(TEAM_CS_LEAVE_TEAM)
	retBuff:pushInt(roleID)
	return retBuff
end
--TEAM_CS_LEAVE_TEAM 后端读消息
CSLEAVETEAM.readFun = function(buffer)
	local roleID = buffer:popInt()
	return roleID
end

SCLEAVETEAMRET = {} --主动离开队伍返回
--TEAM_SC_REMOVE_MEMBER_RET 后端写消息
SCLEAVETEAMRET.writeFun = function(roleSID, eCode,memberCount1,memberCount2)
	--[[local retBuff = LuaEventManager:instance():getLuaRPCEvent(TEAM_SC_REMOVE_MEMBER_RET)
	retBuff:pushBool(false) --表示主动离开队伍
	retBuff:pushInt(roleSID)
	retBuff:pushInt(eCode)]]
	local retBuff = {}
	retBuff.bLeave = false
	retBuff.roleSid = roleSID
	retBuff.eCode = eCode
	retBuff.memberCount1 = memberCount1
	retBuff.memberCount2 = memberCount2
	return retBuff
end
--TEAM_SC_REMOVE_MEMBER_RET 前端读消息
SCLEAVETEAMRET.readFun = function(buffer)
end

CSCHANGEAUTOINVITE = {} --改变是否组队状态
--TEAM_CS_CHANGE_AUTOINVITE 前端写消息
--roleID玩家ID，autoInvite自动状态 true表示自动
CSCHANGEAUTOINVITE.writeFun = function(roleID, autoInvite)
	local retBuff = LuaEventManager:instance():getLuaRPCEvent(TEAM_CS_CHANGE_AUTOINVITE)
	retBuff:pushInt(roleID)
	retBuff:pushBool(autoInvite)
	return retBuff
end
--TEAM_CS_CHANGE_AUTOINVITE 后端读消息
CSCHANGEAUTOINVITE.readFun = function(buffer)
	local req, err = protobuf.decode("TeamChangeAutoInviteProtocol" , buffer)
	if not req then
		print('CSCHANGEAUTOINVITE.readFun '..tostring(err))
		return
	end
	local autoInvite = req.autoInvite
	return autoInvite
end