--SwornBrosServlet.lua

SwornBrosServlet = class(EventSetDoer, Singleton)

function SwornBrosServlet:__init()
	self._doer = {
		[SWORN_CS_START_CEREMONY] = SwornBrosServlet.actOnCeremony,
		[SWORN_CS_REQUEST_INFO] = SwornBrosServlet.requestInfo,
		[SWORN_CS_DO_ACTION] = SwornBrosServlet.doSwornAction,
		[SWORN_CS_OPERATE_PSV_SKILL] = SwornBrosServlet.operatePsvSkill,
		[SWORN_CS_REQUEST_ATV_SKILL_INFO] = SwornBrosServlet.reqAtvSkillInfo,
		[SWORN_CS_OPERATE_ATV_SKILL] = SwornBrosServlet.operateAtvSkill,
	}
end

local function checkBufferParams(buffer, pbName, funcName)		-- provide a general action for msg parsing
	print('start parsing msg from:' .. funcName)
	local params = buffer:getParams()
	local buf, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode(pbName, buf)	
	if not req then
		print(funcName .. ' decode fail: '..tostring(err))
		return nil
	end

	local player = g_entityMgr:getPlayerBySID(dbid)
	if not player then
		print(funcName .. ' player not found'..dbid)
		return nil
	end
	return player, req
end
local function getTeamMembers(player)	--get a table of team members
	if player then
		local team = g_TeamPublic:getTeam(player:getTeamID())
		if team then
			return team:getOnLineMems()
		end
	end
	return nil
end

function SwornBrosServlet.doEnterScene(playerID, npcID, params)	-- try to enter scene
	local player = g_entityMgr:getPlayer(playerID)
	if not player then
		print('doEnterScene player not found '.. playerID)
		return
	end
	if npcID ~= SWORN_SCENE_TRANSNPC then
		return doSwornActionRet(playerID, SwornBrosErrCode.INCORRECT_NPC)
	end
	local teamMems = getTeamMembers(player)
	if not teamMems then
		return doSwornActionRet(playerID, SwornBrosErrCode.NO_TEAM)
	end
	
	if player:getLevel() < SWORN_MIN_LEVEL then
		return doSwornActionRet(playerID, SwornBrosErrCode.NO_ENOUGH_LEVEL)
	end
	
	local pos = {x=SWORN_SCENE_INIT_X, y=SWORN_SCENE_INIT_Y}
	if g_sceneMgr:posValidate(SWORN_SCENE_ID, pos.x, pos.y) then
		print("pos valid",pos.x, pos.y, playerID)
		local old_pos = player:getPosition()
		player:setLastMapID(player:getMapID())
		player:setLastPosX(old_pos.x)
		player:setLastPosY(old_pos.y)
		--g_swornBrosMgr:setPrevPos(player:getMapID(), old_pos.x, old_pos.y)
		g_sceneMgr:enterPublicScene(playerID, SWORN_SCENE_ID, pos.x, pos.y)
	else
		print("pos invalid")
		doSwornActionRet(playerID, SwornBrosErrCode.FAIL_TO_ENTER)
	end
end

function SwornBrosServlet:actOnCeremony(buffer)		--request for ceremony
	local player, req = checkBufferParams(buffer, "StartSwornCeremonyRet", "actOnCeremony")
	if not player then
		return
	end
	if req.ret == 0 then
		return self:swornRefuse(player)
	elseif req.ret == 1 then
		return self:swornAgree(player)
	end
	print("SwornBrosServlet:actOnCeremony with wrong param:" .. req.ret)
end

function SwornBrosServlet:doSwornAction(buffer)
	local player, req = checkBufferParams(buffer, "SwornDoAction", "doSwornAction")
	if not player then
		return
	end
	
	if req.type == SwornActionType.KICK then
		self:swornKick(player, req.target_id)
	elseif req.type == SwornActionType.LEAVE then
		self:swornLeave(player)
	elseif req.type == SwornActionType.HINT then
		self:swornHint(player)
	else
		print("doSwornAction ... unknown type:" .. req.type)
	end
end

--request to start sworn, check preconditions
function SwornBrosServlet.swornStart(playerID, npcID, params)	--try to start ceremony
	print("SwornBrosServlet:swornStart.." .. playerID)
	
	local player = g_entityMgr:getPlayer(playerID)
	if not player then
		print('doEnterScene player not found '.. playerID)
		return
	end
	if npcID ~= SWORN_SCENE_START_NPC then
		return doSwornActionRet(playerID, SwornBrosErrCode.INCORRECT_NPC)
	end
	
	local teamMems = getTeamMembers(player)
	if not teamMems then
		return doSwornActionRet(playerID, SwornBrosErrCode.NO_TEAM)
	end
	local isLeader, teamID = g_TeamPublic:isTeamLeader(player:getSerialID())
	if not isLeader then
		return doSwornActionRet(playerID, SwornBrosErrCode.NOT_LEADER)
	end
	if table.size(teamMems) > SWORN_BROTHERS_MAXNUM then
		return doSwornActionRet(playerID, SwornBrosErrCode.SWORN_MAX_NUM)
	end
	
	local swornBrosID = player:getSwornBrosID()
	print("leader's swornBrosID="..swornBrosID)
	local scene = player:getScene()
	local newBros = {}

	print("==============start sowrn check members==========")
	for _, memberId in pairs(teamMems) do
		print("memberId=", memberId)
		local member = g_entityMgr:getPlayerBySID(memberId)
		if member and member:getScene() == scene then
		 	if member:getLevel() < SWORN_MIN_LEVEL then
		 		return doSwornActionRet(playerID, SwornBrosErrCode.NO_ENOUGH_LEVEL, memberId)
			end
			local brosID = member:getSwornBrosID()
			print("brosID=",brosID)
			if brosID ~= 0 and swornBrosID ~= brosID then	--if member and player havn't sowrn, their sbIDs are both 0.
				return doSwornActionRet(playerID, SwornBrosErrCode.DIFF_SWORN_BROS, memberId)
			end
			if brosID == 0 then
				if os.time() - member:getLeaveSwornTime() < SWORN_LEAVE_TIME_INTERVAL then
					doSwornActionRetBySID(memberId, SwornBrosErrCode.TOO_QUICK_TO_JOIN)
					return doSwornActionRet(playerID, SwornBrosErrCode.TOO_QUICK_TO_JOIN, memberId)
				end

				newBros[#newBros+1] = member:getSerialID()
			end
		end
	end
	
	local swornBros = g_swornBrosMgr:getSwornBrosByID(swornBrosID)
	local curSwornBros = 0
	if swornBros then
		if swornBros:getLeaderID() ~= player:getSerialID() then
			return doSwornActionRet(playerID, SwornBrosErrCode.NOT_BIG_BROTHER)
		end
		curSwornBros = swornBros:getCurNum()
	end
	local newBrosNum = #newBros
	print("curnum=",curSwornBros,"newBrosNum=", newBrosNum)

	if curSwornBros + newBrosNum > SWORN_BROTHERS_MAXNUM then
		return doSwornActionRet(playerID, SwornBrosErrCode.SWORN_MAX_NUM)
	end
	if newBrosNum == 0 then
		return doSwornActionRet(playerID, SwornBrosErrCode.NO_NEW_MEMBER)
	end
	if newBrosNum + curSwornBros < SWORN_BROTHERS_MINNUM then
		return doSwornActionRet(playerID, SwornBrosErrCode.SWORN_MIN_NUM)
	end
	
	for _, memberSID in pairs(newBros) do
		local member = g_entityMgr:getPlayerBySID(memberSID)
		if not isMatEnough(member, SWORN_ITEM_ID, SWORN_ITEM_NUM) then
			return doSwornActionRet(playerID, SwornBrosErrCode.NO_SWORN_ITEM, memberSID)
		end
	end

	if swornBrosID ~= 0 then	--add leader if sbID exists
		newBros[#newBros+1] = player:getSerialID()
	end
	
	g_swornBrosMgr:addTempTeam(teamID, newBros, player:getSerialID(), swornBrosID)
	for _, member in pairs(newBros) do
		fireProtoMessageBySid(member, SWORN_SC_START_CEREMONY, "StartSwornCeremony", {})
	end
end

function SwornBrosServlet:swornAgree(player)
	if not player then
		return
	end
	local teamID = player:getTeamID()
	if teamID == 0 then
		return doSwornActionRet(playerID, SwornBrosErrCode.NO_TEAM)
	end
	g_swornBrosMgr:onSwornAgree(player, teamID)
end
function SwornBrosServlet:swornRefuse(player)
	if not player then
		return
	end
	local teamID = player:getTeamID()
	if teamID == 0 then
		return doSwornActionRet(player:getID(), SwornBrosErrCode.NO_TEAM)
	end
	local team_members = g_swornBrosMgr:getTempTeam(teamID)
	if not team_members then
		return
	end
	print("player:",player:getName()," refused sworn")
	for _, memberSID in pairs(team_members) do
		doSwornActionRetBySID(memberSID, SwornBrosErrCode.REJECT_SWORN)
	end
	g_swornBrosMgr:removeTempTeam(teamID)
end
function SwornBrosServlet:requestInfo(buffer)
	local player, req = checkBufferParams(buffer, "RequestSwornInfo", "requestInfo")
	if not player then
		return
	end
	local sworn = g_swornBrosMgr:getSwornBrosByPlayer(player)
	if not sworn then
		return doSwornActionRet(player:getID(), SwornBrosErrCode.NOT_SWORN)
	end
	if req.type == SwornInfoType.BASIC then
		return sworn:sendBasicInfo(player)
	elseif req.type == SwornInfoType.SKILL then
		return sworn:sendSkillInfo(player)
	end
end

function SwornBrosServlet:swornKick(player, targetID)
	print("SwornBros ", player:getName(), "kick:", targetID)
	local sworn = g_swornBrosMgr:getSwornBrosByPlayer(player)
	if not sworn then
		return doSwornActionRet(player:getID(), SwornBrosErrCode.NOT_SWORN)
	end
	if player:getSerialID() ~= sworn:getLeaderID() then
		return doSwornActionRet(player:getID(), SwornBrosErrCode.NOT_BIG_BROTHER)
	end
	if targetID == 0 or targetID == player:getSerialID() then
		return doSwornActionRet(player:getID(), SwornBrosErrCode.INVALID_TARGET)
	end
	sworn:kick(player, targetID)
end
function SwornBrosServlet:swornLeave(player)
	print("SwornBros Leave", player:getName())
	local sworn = g_swornBrosMgr:getSwornBrosByPlayer(player)
	if not sworn then
		return doSwornActionRet(player:getID(), SwornBrosErrCode.NOT_SWORN)
	end
	local ret = sworn:leave(player)
	print("player:", player:getName(), "leave sworn:", ret)
end
function SwornBrosServlet:swornHint(player)
	print("SwornBros set hint:", player:getName())
	local sworn = g_swornBrosMgr:getSwornBrosByPlayer(player)
	if not sworn then
		return doSwornActionRet(player:getID(), SwornBrosErrCode.NOT_SWORN)
	end
	sworn:setHint(player)
	print("SwornBrosServlet:swornHint", player:getSerialID())
end

function SwornBrosServlet:operatePsvSkill(buffer)
	local player, req = checkBufferParams(buffer, "OperateSwornPsvSkill", "operatePsvSkill")
	if not player then
		return
	end

	local sworn = g_swornBrosMgr:getSwornBrosByPlayer(player)
	if not sworn then 
		return doSwornActionRet(player:getID(), SwornBrosErrCode.NOT_SWORN)
	end
	if player:getSerialID() ~= sworn:getLeaderID() then
		return doSwornActionRet(player:getID(), SwornBrosErrCode.NOT_BIG_BROTHER)
	end
	
	if req.type == SwornPsvSkillOpType.LEARN then
		return sworn:learnPsvSkill(player, req.skill_id)
	elseif req.type == SwornPsvSkillOpType.RESET then
		return sworn:resetPsvSkill(player)
	end
end
function SwornBrosServlet:reqAtvSkillInfo(buffer)
	local player, req = checkBufferParams(buffer, "ReqSwornAtvSkillInfo", "reqAtvSkillInfo")
	if not player then
		return
	end

	local sworn = g_swornBrosMgr:getSwornBrosByPlayer(player)
	if not sworn then 
		return doSwornActionRet(player:getID(), SwornBrosErrCode.NOT_SWORN)
	end
	sworn:reqAtvSkillInfo(player)
end
function SwornBrosServlet.useAtvSkill(player, skillId, targetId)
	print("swornbros useAtvSkill, player:",player:getName(),"target:",targetId,"skill:",skillId)
	local sworn = g_swornBrosMgr:getSwornBrosByPlayer(player)
	if not sworn then
		return doSwornActionRetBySID(player:getID(), SwornBrosErrCode.NOT_SWORN)
	end
	local req_type = SwornAtvOperateType.None
	if skillId == SwornActiveSkill.TRANS_ID then
		req_type = SwornAtvOperateType.Transmit
	elseif skillId == SwornActiveSkill.GATHER_ID then
		req_type = SwornAtvOperateType.ReqGather
	end
	sworn:operateAtvSkill(player, req_type, targetId)
end
function SwornBrosServlet:operateAtvSkill(buffer)
	local player, req = checkBufferParams(buffer, "OperateSwornAtvSkill", "operateAtvSkill")
	if not player then
		return
	end

	local sworn = g_swornBrosMgr:getSwornBrosByPlayer(player)
	if not sworn then
		return doSwornActionRet(player:getID(), SwornBrosErrCode.NOT_SWORN)
	end
	sworn:operateAtvSkill(player, req.type, req.target_id)
end
function SwornBrosServlet.getInstance()
	return SwornBrosServlet()
end

g_SwornBrosServlet = SwornBrosServlet.getInstance()

g_eventMgr:addEventListener(SwornBrosServlet.getInstance())