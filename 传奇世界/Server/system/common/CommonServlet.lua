--CommonServlet.lua
--/*-----------------------------------------------------------------
--* Module:  CommonServlet.lua
--* Author:  HE Ningxu
--* Modified: 2014年6月24日
--* Purpose: Implementation of the class CommonServlet
-------------------------------------------------------------------*/

CommonServlet = class(EventSetDoer, Singleton)

function CommonServlet:__init()
	self._doer = {
			[DOWNLOAD_CS_REQ]		    =	CommonServlet.ReqDownload,
			[ACTIVITY_CS_RECORD_REQ]	=	CommonServlet.ReqPayRecord,
			[GAMECONFIG_CS_LOG]			=   CommonServlet.GameConfigLog,
			[DART_CS_CREATTEAM]			=   CommonServlet.creatTeam,
			[DART_CS_JOINTEAM]			=	CommonServlet.joinTeam,
			[DART_CS_POSITION]			=	CommonServlet.getPosition,
			[DART_CS_STATUS] 			=   CommonServlet.getStatus,
			[DART_CS_ANSWER_TEAMDART] 	=   CommonServlet.answerTeamDart,
			[DART_CS_INVITE_TEAMDART] 	=   CommonServlet.inviteTeamDart,
			[CONVOY_CS_POSITION] 		=   CommonServlet.getConvoyPosition,
			[NAME_NW_INSERT_NONPLAYER]	=	CommonServlet.onInsertNonPlayerNameRet,
			[COMMON_CS_GETMAINOBJECTREWARD] = CommonServlet.onGetMainObjectReward,
			[COMMON_CS_DONEMAINOBJECT] = CommonServlet.onDoneMainObject,
			[COMMON_CS_VITURALESCROTTIME] = CommonServlet.onVirtualEscrotTime,
			[COMMON_CS_VITURALESCROTEXIT] = CommonServlet.onVirtualEscrotExit,
		}
end

function CommonServlet:onDoerActive()
	g_commonMgr:on()
	SYSTEM_DART_SWITCH = true
end

function CommonServlet:onDoerClose()
	g_commonMgr:off()
	SYSTEM_DART_SWITCH = false
end

function CommonServlet:ReqPayRecord(event)
	local params = event:getParams()
	local buffer = params[1]	
	local roleID = buffer:popInt()
	local player = g_entityMgr:getPlayer(roleID)
	local comInfo = g_commonMgr:getCommonInfo(roleID)
	if player and comInfo then
		local buff = LuaEventManager:instance():getLuaRPCEvent(ACTIVITY_SC_RECORD_RET)
		comInfo:writePayRecord(buff)
		g_engine:fireLuaEvent(roleID, buff)
	end
end

function CommonServlet:ReqDownload(event)
	local params = event:getParams()
	local buffer = params[1]	
	local roleID = buffer:popInt()
	local id = buffer:popChar()
	local player = g_entityMgr:getPlayer(roleID)
	local comInfo = g_commonMgr:getCommonInfo(roleID)
	if player and comInfo then
		local result = 0
		local buff = g_buffMgr:getLuaRPCEvent(DOWNLOAD_SC_RET)
		if not comInfo:hasDownload(id) then
			result = 1
			local itemMgr = player:getItemMgr()
			local reward = g_commonMgr:getDownloadReward(id)
			if itemMgr and reward then
				local errorCode = 0
				local ret = itemMgr:addItemByDropList(1, reward, 83, errorCode)
				if ret ~= "-1" then
					result = 2
					comInfo:download(id)
				end
			end
		end		
		buff:pushChar(result)
		g_engine:fireLuaEvent(roleID, buff)
	end
end

function CommonServlet:GameConfigLog(event)
	-- local params = event:getParams()
	-- local buffer = params[1]
	-- local roleID = buffer:popInt()
	-- local userEquip = buffer:popString()
	-- local dpi = buffer:popString()
	-- local hangHP = buffer:popInt()
	-- local hangHP1 = buffer:popInt()
	-- local hangMP = buffer:popInt()
	-- local attack = buffer:popString()
	-- local pick = buffer:popString()
	-- local system = buffer:popString()
	-- local palyer = g_entityMgr:getPlayer(roleID)
	-- 	if palyer then
	-- 		local SID = palyer:getSerialID()	
	-- 		g_logManager:writeSetting(SID,userEquip,dpi,hangHP,hangHP1,hangMP,attack,pick,system)
	-- 	end
end


function CommonServlet:sendErrMsg2Client( eCode, paramCnt, params, roleID)
	fireProtoSysMessage(self:getCurEventID(), roleID, EVENT_DART_SETS, eCode, paramCnt, params)
end

-- 点击NPC
function CommonServlet.clickNPC(roleID, npcId)
	local player = g_entityMgr:getPlayer(roleID)
	local User = g_commonMgr._infosBySID[player:getSerialID()]
	if User then
		if User._dart_datas.rewardExp == 0 then
			User:clinkNPC(npcId)
		else
			--提示
			g_commonServlet:sendErrMsg2Client(DART_PICK_REWARD,0,{},roleID)
		end
	end
end

function CommonServlet.clickNPCpick(roleID,npcId)
	local player = g_entityMgr:getPlayer(roleID)
	local User = g_commonMgr._infosBySID[player:getSerialID()]
	if User and player then
		if User._dart_datas.rewardExp ~= 0 then 
			local exp = User._dart_datas.rewardExp
			addExpToPlayer(player,exp,87)
			User._dart_datas.rewardExp = 0 
			User:fireDartState()
			User._dart_datas.rewardType = 0
			User:cast2db()

			g_commonServlet:sendErrMsg2Client(DART_GET_REWARD,1,{exp},roleID)
		else
			g_commonServlet:sendErrMsg2Client(DART_NOT_REWARD,0,{},roleID)
		end
	end
end

-- 创建队伍运镖
function CommonServlet:creatTeam(event)
	local params = event:getParams()
	local pbc_string, roleSID, hGate = params[1], params[2], params[3]
	local data = protobuf.decode("DartCreatTeamProtocol" , pbc_string)
	local rewardType = data.rewardType
	local teamMaxCnt = data.maxCnt
	local teamType = data.teamType
	g_commonMgr:creatTeam(roleSID, rewardType,teamMaxCnt,teamType)

end

function CommonServlet:joinTeam( event )
	local params = event:getParams()
	local pbc_string, roleSID, hGate = params[1], params[2], params[3]
	local data = protobuf.decode("DartJoinTeamProtocol" , pbc_string)

	local teamID = data.teamID
	local rewardType = data.rewardType

	local player = g_entityMgr:getPlayerBySID(roleSID)
	local teamData = g_commonMgr._dart_datas.teamList[teamID]
	
	if not player then
		return 
	end 

	local roleID = player:getID()

	if not teamData then
		g_commonServlet:sendErrMsg2Client(DART_TEAM_NULL,0,{}, roleID)
	end

	if teamData.teamRealCnt == teamData.teamMaxCnt then 
		g_commonServlet:sendErrMsg2Client(DART_NOT_QUIT,0,{}, roleID)
		return 
	end
	
	if rewardType ~= 0 then 
		g_commonMgr:joinTeam(roleID,teamID,rewardType)
	elseif roleSID == teamData.roleSID  then -- 是队长,解散队伍
		g_commonMgr:releaseTeam(teamID)
	else
		g_commonMgr:leaveTeam(player,teamID)
	end
end

-- 获取镖车当前位置
function CommonServlet:getPosition(event)
	local params = event:getParams()
	local pbc_string, roleSID, hGate = params[1], params[2], params[3]

	local x = -1
	local y = -1
	local dartID = 0
	local player = g_entityMgr:getPlayerBySID(roleSID)
	local User = g_commonMgr._infosBySID[player:getSerialID()]
	if User then
		local teamID = User._dart_datas.teamID 
		local teamData = g_commonMgr._dart_datas.sendList[teamID]
		if teamData then 
			local leaderUser = g_commonMgr._infosBySID[teamData.roleSID] 
			local dart = g_entityMgr:getMonster(leaderUser._dart_datas.id)
			if dart and leaderUser._dart_datas.state == 3 then
				local pos = dart:getPosition()
				x = pos.x
				y = pos.y
				dartID = dart:getID()
			end
		end
	end
	local retData = {
					x = x,
					y = y,
					dartID = dartID,

				}
	fireProtoMessage(player:getID(),DART_SC_POSITION_RET,"DartPositionRetProtocol",retData)
end
--获取当前镖车状态
function CommonServlet:getStatus(event)
	local params = event:getParams()
	local pbc_string, roleSID, hGate = params[1], params[2], params[3]
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if player then 
		local User = g_commonMgr._infosBySID[roleSID]
		if User then
			local status = User._dart_datas.state
			local retData = {
							status = status and true or false
			}
			fireProtoMessage(player:getID(),DART_SC_STATUS_RET,"DartStatusRetProtocol",retData)
		end
	end
end

-- 回答队伍运镖询问
function CommonServlet:answerTeamDart(event)
	local params = event:getParams()
	local pbc_string, roleSID, hGate = params[1], params[2], params[3]
	local data = protobuf.decode("DartAnswerTeamDartProtocol" , pbc_string)

	local player = g_entityMgr:getPlayerBySID(roleSID)
	if player then 
		g_commonMgr:answerTeamDart(player:getID(), data.teamID, data.rewardType, data.answer)
	end
end

-- 邀请队伍运镖
function CommonServlet:inviteTeamDart(event)
	local params = event:getParams()
	local pbc_string, roleSID, hGate = params[1], params[2], params[3]
	local data = protobuf.decode("DartInviteTeamDartProtocol" , pbc_string)

	local player = g_entityMgr:getPlayerBySID(roleSID)
	if player then 
		g_commonMgr:inviteTeamDart(player:getID(), data.roleSID)
	end
end

-- 获得护送目标的位置
function CommonServlet:getConvoyPosition(event)
	local params = event:getParams()
	local pbc_string, roleSID, hGate = params[1], params[2], params[3]
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if player then 
		local playerConvoy = g_ConvoyMgr:getPlayerConvoy(player:getSerialID())
		if playerConvoy then
			local target = g_entityMgr:getMonster(playerConvoy:getTargetID())
			if target then
				local pos = target:getPosition()
				local retData = {
								x = pos.x,
								y = pos.y,
								targetID = playerConvoy:getTargetID(),
							}
				fireProtoMessage(player:getID(),CONVOY_SC_POSITION_RET,"ConvoyPositionRetProtocol",retData)
			end
		end
	end
end

function CommonServlet:onInsertNonPlayerNameRet(event)
	print("CommonServlet:onInsertNonPlayerNameRet")
	local params = event:getParams()
	local buff = params[1]
	local name_type = buff:popInt()
	local roleSID = buff:popString()
	local result = buff:popBool()
	print("name_type:",name_type, ",roleSID:",roleSID,",result:", result)
	if name_type == NAME_TYPE_FACTION then
		g_FactionServlet:onCheckUniNameRet(roleSID, result)
	elseif name_type == NAME_TYPE_FIGHTTEAM then
		g_fightTeamMgr:onCheckUniNameRet(roleSID, result)
	else
		print("Error!!! Wrong Type!!!")
	end
end

function CommonServlet:onGetMainObjectReward(event)
	local params = event:getParams()
	local pbc_string, roleSID, hGate = params[1], params[2], params[3]
	local player = g_entityMgr:getPlayerBySID(roleSID)
	local data = protobuf.decode("GetMainObjectRewardRetProtocol" , pbc_string)

	if player then
		g_MainObjectMgr:takeReward(roleSID, data.objectID)
	end
end


function CommonServlet:onDoneMainObject(event)
	local params = event:getParams()
	local pbc_string, roleSID, hGate = params[1], params[2], params[3]
	local player = g_entityMgr:getPlayerBySID(roleSID)
	local data = protobuf.decode("DoneMainObjectProtocol" , pbc_string)

	if player then
		g_MainObjectMgr:clientNotify(roleSID, data.objectID)
	end
end


function CommonServlet:onVirtualEscrotTime(event)
	local params = event:getParams()
	local pbc_string, roleSID, hGate = params[1], params[2], params[3]
	local player = g_entityMgr:getPlayerBySID(roleSID)
	local data = protobuf.decode("VitrualEscrotTimeProtocol" , pbc_string)

	if player then
		g_VirtualEscorMgr:getLeftTime(roleSID)
	end
end

function CommonServlet:onVirtualEscrotExit(event)
	local params = event:getParams()
	local pbc_string, roleSID, hGate = params[1], params[2], params[3]
	local player = g_entityMgr:getPlayerBySID(roleSID)
	local data = protobuf.decode("VitrualEscrotExitProtocol" , pbc_string)

	if player then
		g_VirtualEscorMgr:close(roleSID)
	end
end

function CommonServlet.getInstance()
	return CommonServlet()
end

g_commonServlet = CommonServlet.getInstance()
g_eventMgr:addEventListener(g_commonServlet)
