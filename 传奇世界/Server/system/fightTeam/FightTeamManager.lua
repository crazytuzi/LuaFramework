--FightTeamManager.lua
--战队管理类

require ("system.fightTeam.FightTeamConstant")
require ("system.fightTeam.FightTeam")
require ("system.fightTeam.FightTeamServlet")
require ("system.fightTeam.FightTeamMember")



FightTeamManager = class(nil, Singleton)

function FightTeamManager:__init()
	self.m_allFightTeams = {} --所有战队

	self._maxFightTeamID = g_worldID*10000 --最大的战队编号
	self._tempNames = {}
	g_entityDao:loadMaxFightTeamID()
	g_listHandler:addListener(self)
end

function FightTeamManager.setMaxFightTeamID(fightTeamID)
	if fightTeamID > 0 then 
		g_fightTeamMgr._maxFightTeamID = fightTeamID
	end
end

function FightTeamManager:getNewFightTeamID()
	self._maxFightTeamID = self._maxFightTeamID+1
	return self._maxFightTeamID
end


function FightTeamManager:addFightTeam(fightTeam)
	self.m_allFightTeams[fightTeam:getFightID()] = fightTeam
end

--创建战队
function FightTeamManager:create(roleID, name)
	local player = g_entityMgr:getPlayer(roleID)
	local roleSID = player:getSerialID()
	print("FightTeamManager:create name="..name)

	if not name or name == "" then
		g_FightTeamServlet:sendErrMsg2Client(roleID, FIGHTTEAM_NO_NAME, 0)
		return
	end

	--判断名字长度
	local ansi = string.len(string.gsub(name, "[\128-\254]+",""))
	local total = string.len(name)
	if (ansi+2*(total-ansi)/3) > 12 or (ansi+2*(total-ansi)/3) < 4 then
		g_FightTeamServlet:sendErrMsg2Client(roleID, FIGHTTEAM_NAME_TOO_LONG, 0)
		return
	end

	--首先得是组队状态
	local teamId = player:getTeamID()
	if teamId <= 0 then
		g_FightTeamServlet:sendErrMsg2Client(roleID, FIGHTTEAM_NO_TEAM_STATE, 0)
		return
	end

	local team = g_TeamPublic:getTeam(teamId)

	--如果不是队长
	if team:getLeaderID() ~= roleSID then
		g_FightTeamServlet:sendErrMsg2Client(roleID, FIGHTTEAM_NO_TEAM_LEADER, 0)
		return
	end

	local leaderPos = player:getPosition()
	local leaderPosX = leaderPos.x
	local leaderPosY = leaderPos.y
	
	local teamMember = team:getOnLineMems()

	--队伍超过最大人数
	if table.size(teamMember) ~= FIGHTTEAM_MAX_TEAM_NUM then
		g_FightTeamServlet:sendErrMsg2Client(roleID, FIGHTTEAM_CREATE_NEED_NUM, 1, {FIGHTTEAM_MAX_TEAM_NUM})
		return
	end

	for _,memberId in pairs(teamMember) do
		local memPlayer = g_entityMgr:getPlayerBySID(memberId)
		local fightTeamID = memPlayer:getFightTeamID()
		--判断队伍里是不是已经有其他战队的人了
		if fightTeamID > 0 then
			g_FightTeamServlet:sendErrMsg2Client(roleID, FIGHTTEAM_HAS_OTHER_TEAM, 1, {memPlayer:getName()})
			return
		end
		
		local needLevel = FIGHTTEAM_MIN_LEVEL
		--判断队伍成员的等级
		if memPlayer:getLevel() < needLevel then
			g_FightTeamServlet:sendErrMsg2Client(roleID, FIGHTTEAM_NEED_LEVEL, 2, {memPlayer:getName(), needLevel})
			return
		end
		
		local memPos = memPlayer:getPosition()
		local memPosPosX = memPos.x
		local memPosPosY = memPos.y
		if player:getMapID() ~= memPlayer:getMapID() or (math.abs(leaderPosX - memPosPosX) > 5) or (math.abs(leaderPosY - memPosPosY) > 5) then
			g_FightTeamServlet:sendErrMsg2Client(roleID, FIGHTTEAM_MEMBER_TOO_FAR, 1, {memPlayer:getName()})
			return
		end
	end

	local needMoney = FIGHTTEAM_NEED_MONEY
	if not isMoneyEnough(player, needMoney) then
		g_FightTeamServlet:sendErrMsg2Client(roleID, FIGHTTEAM_MONEY_NOT_ENOUGH, 1, {needMoney})
		return
	end
	
	self:checkUniqueName(roleSID, name)
	self._tempNames[roleSID] = name
end

function FightTeamManager:checkUniqueName(roleSID, name)
	g_commonMgr:insertUniqueName("fightTeam", roleSID, name)
end

function FightTeamManager:onCheckUniNameRet(roleSID, result)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		print("FightTeamManager onCheckUniNameRet while player " .. roleSID .. "not found!!!")
		return
	end
	local roleID = player:getID()
	if not result then
		g_FightTeamServlet:sendErrMsg2Client(roleID, FIGHTTEAM_NAME_EXISTED, 0)
		return
	end
	local name = self._tempNames[roleSID]
	if not name then
		print("can't find fight team name, player:", roleSID)
		return
	end
	
	--条件都满足的话，开始创建战队
	local fightTeam = FightTeam()
	fightTeam:setFightID(self:getNewFightTeamID())
	fightTeam:setFightName(name)
	fightTeam:setLeaderID(roleSID)
	fightTeam:setLeaderName(player:getName())
	
	--加队伍里的成员进战队
	local team = g_TeamPublic:getTeam(player:getTeamID())	
	local teamMember = team:getOnLineMems()
	for _,memberId in pairs(teamMember) do
		local isLeader = memberId == roleSID and true or false
		fightTeam:addNewMember(memberId, isLeader)
	end

	self:addFightTeam(fightTeam)
	costMoney(player, FIGHTTEAM_NEED_MONEY, 231)

	--数据库操作
	g_entityDao:createFightTeam(fightTeam:getFightID(), fightTeam:getFightName(), roleSID, player:getName())

	--给所有人发提示战队创建了
	self:sendErrMsg2ClientForAll(fightTeam:getFightID(), FIGHTTEAM_CREATE_TEAM_SUC, 2, {player:getName(), name})

	--通知队长创建队伍成功
	local ret = {}
	ret.fightTeamID = fightTeam:getFightID()

	local allMem = fightTeam:getAllMembers()
	for memberId, mem in pairs(allMem or {}) do
		local memPlayer = g_entityMgr:getPlayerBySID(memberId)
		if memPlayer then
			fireProtoMessage(memPlayer:getID(), FIGTHTEAM_SC_CREATE_RET, 'FightTeamCreateRetProtocol', ret)
		end
	end
	
end

function FightTeamManager:addMember(roleID, targetPlayerName)
	local player = g_entityMgr:getPlayer(roleID)

	if not player then
		return
	end

	if player:getFightTeamID() <= 0 then
		return
	end

	local fightTeam = self:getFightTeam(player:getFightTeamID())
	
	if not fightTeam then
		return
	end

	if not self:canOp(roleID) then
		return
	end	

	if fightTeam:getAllMemberCnt() >= FIGHTTEAM_MAX_TEAM_NUM then
		g_FightTeamServlet:sendErrMsg2Client(roleID, FIGHTTEAM_OUT_MAX_TEAM_NUM, 0)
		return
	end

	local sMem = fightTeam:getMember(player:getSerialID())
	if not sMem then
		return
	end

	if sMem:getPosition() ~= FIGHTTEAM_POSITION.Leader then
		g_FightTeamServlet:sendErrMsg2Client(roleID, FIGHTTEAM_NO_DROIT, 0)
		return
	end

	--给目标玩家发送战队邀请
	local targetPlayer = g_entityMgr:getPlayerByName(targetPlayerName)

	if not targetPlayer then
		g_FightTeamServlet:sendErrMsg2Client(roleID, FIGHTTEAM_TARGET_PLAYER_OFFLINE, 0)
		return
	end

	if targetPlayer:getFightTeamID() > 0 then
		g_FightTeamServlet:sendErrMsg2Client(roleID, FIGHTTEAM_TARGET_PLAYER_HAS_TEAM, 0)
		return
	end
	
	local ret = {}
	ret.fightTeamID = fightTeam:getFightID()
	ret.fightTeamName = fightTeam:getFightName()
	ret.LeaderName = fightTeam:getLeaderName()
	fireProtoMessage(targetPlayer:getID(), FIGTHTEAM_SC_BE_INVITE, 'FightTeamBeInviteProtocol', ret)
end

function FightTeamManager:replyInvite(roleID, fightTeamID, result)
	local player = g_entityMgr:getPlayer(roleID)

	if not player then
		return
	end

	if player:getFightTeamID() > 0 then
		return
	end

	local fightTeam = self:getFightTeam(fightTeamID)
	
	if not fightTeam then
		return
	end

	if not result then
		local leader = g_entityMgr:getPlayerBySID(fightTeam:getLeaderID())
		if leader then
			g_FightTeamServlet:sendErrMsg2Client(leader:getID(), FIGHTTEAM_REFUSE, 1, {player:getName()})
		end
		return
	end

	if fightTeam:getAllMemberCnt() >= FIGHTTEAM_MAX_TEAM_NUM then
		g_FightTeamServlet:sendErrMsg2Client(roleID, FIGHTTEAM_OUT_MAX_TEAM_NUM, 0)
		return
	end

	fightTeam:addNewMember(player:getSerialID(), false)
	--给所有队员提示
	self:sendErrMsg2ClientForAll(fightTeam:getFightID(), FIGHTTEAM_ADD_TEAM_SUC, 2, {player:getName(), fightTeam:getFightName()})
	--给所有队员刷新数据
	self:notifyAllmemFreshData(fightTeamID)
end

function FightTeamManager:removeMember(roleID, targetSID)
	local player = g_entityMgr:getPlayer(roleID)

	if not player then
		return
	end

	local fightTeamID = player:getFightTeamID()
	if fightTeamID <= 0 then
		return
	end

	local fightTeam = self:getFightTeam(fightTeamID)
	
	if not fightTeam then
		return
	end

	if not self:canOp(roleID) then
		return
	end	

	local sMem = fightTeam:getMember(player:getSerialID())
	local tMem = fightTeam:getMember(targetSID)
	if not sMem or not tMem then
		return
	end

	if sMem:getPosition() ~= FIGHTTEAM_POSITION.Leader then
		g_FightTeamServlet:sendErrMsg2Client(roleID, FIGHTTEAM_NO_DROIT, 0)
		return
	end

	--给所有队员提示
	self:sendErrMsg2ClientForAll(fightTeam:getFightID(), FIGHTTEAM_REMOVE_TEAM_SUC, 2, {sMem:getName(), tMem:getName()})
	fightTeam:removeMember(targetSID)
	
	--给所有队员刷新数据
	self:notifyAllmemFreshData(fightTeamID)

	--通知被T的人
	local targetPlayer = g_entityMgr:getPlayerBySID(targetSID)
	if targetPlayer then
		local ret = {}
		fireProtoMessage(targetPlayer:getID(), FIGTHTEAM_SC_LEAVE_RET, 'FightTeamLeaveRetProtocol', ret)
	end
end

function FightTeamManager:leave(roleID)
	local player = g_entityMgr:getPlayer(roleID)

	if not player then
		return
	end

	local fightTeamID = player:getFightTeamID()
	if fightTeamID <= 0 then
		return
	end

	local fightTeam = self:getFightTeam(player:getFightTeamID())
	
	if not fightTeam then
		return
	end

	if not self:canOp(roleID) then
		return
	end	

	self:dealLeave(fightTeam, player:getSerialID())

	local ret = {}
	fireProtoMessage(player:getID(), FIGTHTEAM_SC_LEAVE_RET, 'FightTeamLeaveRetProtocol', ret)
end

function FightTeamManager:canOp(roleID)
	local player = g_entityMgr:getPlayer(roleID)

	if not player then
		return false
	end

	if g_configMgr:isForbiddenChangeFightTeam(player:getSerialID()) then
		fireProtoSysMessage(g_FightTeamServlet:getCurEventID(), roleID, EVENT_FIGHTTEAM_SETS, FIGHTTEAM_CANNOT_OP, 0, {})
		return false
	end

	return true
end

function FightTeamManager:dealLeave(fightTeam, roleSID)
	local fightTeamID = fightTeam:getFightID()
	local mem = fightTeam:getMember(roleSID)
	if not mem then
		return
	end

	--给所有队员提示
	self:sendErrMsg2ClientForAll(fightTeam:getFightID(), FIGHTTEAM_LEAVE_TEAM_SUC, 1, {mem:getName()})
	
	local teamNum = fightTeam:getAllMemberCnt()
	--移除队员
	fightTeam:removeMember(roleSID)

	--只有一个人的战队就直接解散了
	if teamNum <= 1 then
		self:disbandFightTeam(fightTeam:getFightID())
	else
		if mem:getPosition() == FIGHTTEAM_POSITION.Leader then
			--队长退出就找战力最高的做队长
			local newLeaderID = fightTeam:getHighBattleMem()
			local newLeaderMem = fightTeam:getMember(newLeaderID)

			fightTeam:setLeaderID(newLeaderID)
			fightTeam:setLeaderName(newLeaderMem:getName())
			newLeaderMem:setPosition(FIGHTTEAM_POSITION.Leader)
			newLeaderMem:updateMem(fightTeamID)
		end
		--给所有队员刷新数据
		self:notifyAllmemFreshData(fightTeamID)
		fightTeam:update2DB()
	end
end

function FightTeamManager:disbandFightTeam(fightTeamID)
	local fightTeam = self:getFightTeam(fightTeamID)
	
	if not fightTeam then
		return
	end

	self.m_allFightTeams[fightTeamID] = nil

	self:delUniqueName(fightTeamID, fightTeam:getFightName())
	g_entityDao:deleteFightTeam(fightTeamID)
end

function FightTeamManager:delUniqueName(teamID, teamName)
	print("FightTeamManager delUniqueName, teamID=" .. teamID..", teamName="..teamName)
	local luabuf = g_buffMgr:getLuaEvent(NAME_WN_DELETE_NONPLAYER)
	luabuf:pushInt(NAME_TYPE_FIGHTTEAM)
	luabuf:pushInt(teamID)
	luabuf:pushString(teamName)
	g_engine:fireSessionEvent(luabuf)
end

function FightTeamManager:sendTeamInfo(roleID)
	local player = g_entityMgr:getPlayer(roleID)
	if not player then
		return
	end

	if player:getFightTeamID() <= 0 then
		return
	end
	
	local fightTeam = self:getFightTeam(player:getFightTeamID())
	if not fightTeam then
		return
	end

	local ret = {}
	ret.fightTeamID = player:getFightTeamID()
	ret.fightTeamName = fightTeam:getFightName()
	ret.winNum = fightTeam:getWinNum()
	ret.loseNum = fightTeam:getLoseNum()
	ret.fightTeamMemInfo = {}

	local allMem = fightTeam:getAllMembers()
	for memberId, mem in pairs(allMem or {}) do
		local info = {}
		info.roleSID = memberId
		info.name = mem:getName()
		info.level = mem:getLevel()
		info.school = mem:getSchool()
		info.battle = mem:getAbility()
		info.position = mem:getPosition()
		table.insert(ret.fightTeamMemInfo, info)
	end
	fireProtoMessage(player:getID(), FIGTHTEAM_SC_GET_TEAMINFO_RET, 'FightTeamGetInfoRetProtocol', ret)
end

function FightTeamManager:getFightTeam(fightTeamID)
	if self.m_allFightTeams[fightTeamID] then
		return self.m_allFightTeams[fightTeamID]
	end
end

--给所有队员推送最新的战队数据用来刷新界面
function FightTeamManager:notifyAllmemFreshData(fightTeamID)
	local fightTeam = self:getFightTeam(fightTeamID)

	if not fightTeam then
		return
	end

	local allMem = fightTeam:getAllMembers()
	for memberId, mem in pairs(allMem or {}) do
		local memPlayer = g_entityMgr:getPlayerBySID(memberId)
		if memPlayer then
			self:sendTeamInfo(memPlayer:getID())
		end
	end
end

--给所有队员发提示
function FightTeamManager:sendErrMsg2ClientForAll(fightTeamID, errId, paramCount, params)
	local fightTeam = self:getFightTeam(fightTeamID)

	if not fightTeam then
		return
	end

	local allMem = fightTeam:getAllMembers()
	for memberId, mem in pairs(allMem or {}) do
		local memPlayer = g_entityMgr:getPlayerBySID(memberId)
		if memPlayer then
			fireProtoSysMessage(g_FightTeamServlet:getCurEventID(), memPlayer:getID(), EVENT_FIGHTTEAM_SETS, errId, paramCount, params)
		end
	end
end

function FightTeamManager.setWinData(fightTeamID, winNum, loseNum)
	local fightTeam = FightTeamManager.getInstance():getFightTeam(fightTeamID)
	if not fightTeam then
		return
	end
	if winNum and winNum >= 0 then
		fightTeam:setWinNum(winNum)
	end
	if loseNum and loseNum >= 0 then
		fightTeam:setLoseNum(loseNum)
	end
	fightTeam:update2DB()
end

function FightTeamManager.getFightTeamData2C(fightTeamID, teamData)
	teamData = tolua.cast(teamData, "FightTeamData")

	local fightTeam = g_fightTeamMgr:getFightTeam(fightTeamID)
	if not fightTeam then
		teamData.fightTeamID = 0
		return
	end

	teamData.fightTeamID = fightTeamID
	teamData.teamName = fightTeam:getFightName()
	teamData.win = fightTeam:getWinNum()
	teamData.lose = fightTeam:getLoseNum()

	local allMem = fightTeam:getAllMembers()
	local tmpMem = {}
	for memberId, mem in pairs(allMem or {}) do
		table.insert(tmpMem, mem)
	end

	for i = 1, 3 do
		local mem = tmpMem[i]
		if mem then
			teamData.members[i].roleSID = mem:getRoleSID()
			teamData.members[i].name = mem:getName()
			teamData.members[i].level = mem:getLevel()
			teamData.members[i].school = mem:getSchool()
			teamData.members[i].battle = mem:getAbility()
			teamData.members[i].position = mem:getPosition()
		else
			teamData.members[i].roleSID = 0
		end
	end
end

function FightTeamManager.getAllFightTeamID2C()
	local retTb = {}

	for fightId, data in pairs(g_fightTeamMgr.m_allFightTeams) do
		table.insert(retTb, fightId)
	end
	
	return retTb
end

--加载战队数据
function FightTeamManager.loadFightTeam(buff)
	local luabuf = tolua.cast(buff, "LuaMsgBuffer")
	local fightTeam = FightTeam(roleSID)
	fightTeam:readString(luabuf)
	FightTeamManager.getInstance():addFightTeam(fightTeam)
end

--加载一个战队成员
function FightTeamManager.loadFightTeamMember(fightID, roleID, name, school, level, battle, memsStr)
	local fightTeam = FightTeamManager.getInstance():getFightTeam(fightID)
	if not fightTeam then return end 

	local member = FightTeamMember(roleID, fightID)
	member:setName(name)
	member:setSchool(school)
	member:setLevel(level)
	member:setAbility(battle)
	member:readString(memsStr)
		
	local memPlayer = g_entityMgr:getPlayerBySID(member:getRoleSID())
	if memPlayer then
		memPlayer:setFightTeamID(fightID)
	end

	if member:getRoleSID() == fightTeam:getLeaderID() then
		member:setPosition(FIGHTTEAM_POSITION.Leader)
	end
	fightTeam:addFactionMember(member)
end

function FightTeamManager:onPlayerDelete(roleSID)
	local fightTeam = nil
	for fightID, team in pairs(self.m_allFightTeams) do
		if team:hasMember(roleSID) then
			fightTeam = team
		end
	end

	if not fightTeam then
		return
	end

	self:dealLeave(fightTeam, roleSID)
end


function FightTeamManager:onLevelChanged(player)
	local figthTeam = self:getFightTeam(player:getFightTeamID())
	if figthTeam then
		local myMem = figthTeam:getMember(player:getSerialID())
		if myMem then
			myMem:setLevel(player:getLevel())
		end
	end
end

function FightTeamManager:battleChanged(player, battle)
	local figthTeam = self:getFightTeam(player:getFightTeamID())
	if figthTeam then
		local myMem = figthTeam:getMember(player:getSerialID())
		if myMem then
			myMem:setAbility(battle)
		end
	end
end

function FightTeamManager.getInstance()
	return FightTeamManager()
end

g_fightTeamMgr = FightTeamManager.getInstance()