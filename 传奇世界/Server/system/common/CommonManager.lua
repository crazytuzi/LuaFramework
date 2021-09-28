--CommonManager.lua
--/*-----------------------------------------------------------------
--* Module:  CommonManager.lua
--* Author:  HE Ningxu
--* Modified: 2014年6月24日
--* Purpose: Implementation of the class CommonManager
-------------------------------------------------------------------*/

require "system.common.CommonConstant"
require "system.common.CommonServlet"
require "system.common.CommonInfo"
require "system.common.ConvoyManager"
require "system.common.MainObjectManager"
require "system.common.VirtualEscort"

CommonManager = class(nil, Singleton,Timer)

function CommonManager:__init()
	self._infos = {}
	self._infosBySID = {}
	self._downReward = {}

	self._serTeamID = 1
	self._dartDelayMove = nil
	self._dartOffRewardeExp = {}
	self._dart_datas = 
	{
		singleDartList = {},
		
		dartInfos = {},
		dartIds = {},	-- 记录所有的镖车ID
		time = "",		-- 活动时间
		entitys = {},
		data = require "data.DartDB",
		openFlag = true,	-- GM命令开启活动标记
		
		-- 优化处理,添加镖车的最大跟最小ID(镖车ID连续且唯一)，避免每次怪物伤害和死亡都循环镖车ID表
		dartMaxId = 0,		-- 镖车最大ID
		dartMinId = 0,		-- 镖车最小ID
		waitList = {},   -- {
						--{roleSID = 0,
						-- teamID =0, 
						-- teamMaxCnt = 0,
						-- teamRealCnt = 1,
						-- teamEndTime =0,
						-- line = 0,
						-- factionID = 0,
						-- teamRole = {}
						--}
						--}
		sendList= {},
		teamList= {},
		rewardExp = 0,
		ExpPer = 0,
	}
	self._inviteDartStamp = {}			-- 邀请加入组队镖车的时间戳
	self._teamDartInvite = {}			-- 组队镖车邀请

	self:loadDownloadDB()
	self:loadMonsterDrop()
	self._count = 0
	self:loadDart()
	g_listHandler:addListener(self)
	gTimerMgr:regTimer(self, 1000, 500)
	print("CommonManager Timer", self._timerID_)
end

function CommonManager:loadDownloadDB()
	local datas = require "data.DownloadRewardDB"
	for _, record in pairs(datas or {}) do
		local reward = {}
		reward.id = toNumber(record.id, 0)
		reward.drop = toNumber(record.drop, 0)
		self._downReward[reward.id] = reward
	end
end

function CommonManager:loadMonsterDrop()
	local Datas = require "data.MonsterDB"
	self._monsterReward = {}	-- 首杀奖励
	g_DigBossMgr._BossDig = {}
	for _, record in pairs(Datas or {}) do		
		if record.gwsb and record.gwsb ~= 0 then
			--怪物ID=怪物首次爆掉落id
			self._monsterReward[record.q_id] = record.gwsb		
		end
		--如果怪物表里面标记为可挖掘
		if record.q_dig and record.q_dig>0 then
			g_DigBossMgr:addDigBoss(record.q_id)
		end
	end
end

function CommonManager.getInstance()
	return CommonManager()
end

--切换world的通知
function CommonManager:onSwitchWorld2(roleID, peer, dbid, mapId)
	local comInfo = self:getCommonInfo(roleID)
	if comInfo then
		comInfo:switchWorld(peer, dbid, mapId)
	end
end

--切换到本world的通知
function CommonManager:onPlayerSwitch(player, type, luabuf)
	if type == EVENT_TALISMAN_SETS then		
		local cache_buf = luabuf:popLString()
		g_commonMgr:loadDBDataImpl(player, cache_buf)
	end	
end

--获取handler
function CommonManager:getCommonInfo(roleID)
	-- local commonInfo = self._infos[roleID]
	-- if not commonInfo then
	-- 	local player = g_entityMgr:getPlayer(roleID)
	-- 	if player then
	-- 		commonInfo = CommonInfo(roleID, player:getSerialID())			
	-- 		self._infos[roleID] = commonInfo
	-- 	end
	-- end
	-- return self._infos[roleID]

	return self._infos[roleID]
end

function CommonManager:getCommonInfoBySID(roleSID)
--	print("getCommonInfoBySID")
	local commonInfo = self._infosBySID[roleSID]
	local player = g_entityMgr:getPlayerBySID(roleSID)
	print("CommonManager:getCommonInfoBySID>>>>",roleSID,player)
	if not commonInfo then
		if player then
			commonInfo = CommonInfo(player:getID(), roleSID)		
			self._infos[player:getID()] = commonInfo	
			self._infosBySID[roleSID] = commonInfo
		end
	end
	return self._infosBySID[roleSID]
end


--获取下载有礼奖励
function CommonManager:getDownloadReward(id)
	if self._downReward[id] then
		return self._downReward[id].drop
	end
end

--获取免费使用bugle的次数
function CommonManager:getFreeBugle(roleID)
	local comInfo = self:getCommonInfo(roleID)	
	if comInfo then
		return comInfo:getFreeBugle()
	end
	return 0
end

--设置免费使用bugle的次数
function CommonManager:setFreeBugle(roleID, count)
	local comInfo = self:getCommonInfo(roleID)
	if comInfo then
		comInfo:setFreeBugle(count)
	end
end

--设置红包数据
function CommonManager:setRedBagData(roleID, datas)
	local comInfo = self:getCommonInfo(roleID)
	if comInfo then
		comInfo:setRedBagData(datas)
	end
end

--设置山贼入侵奖励掉落ID
function CommonManager:setInvadeDropID(roleID, dropID)
	local comInfo = self:getCommonInfo(roleID)
	if comInfo then
		comInfo:setInvadeDropID(dropID)
	end
end

--玩家数据加载完成
function CommonManager.loadDBData(player, cache_buf, roleSid)		
	g_commonMgr:loadDBDataImpl(player, cache_buf, roleSid)
end

--玩家数据加载完成
function CommonManager:loadDBDataImpl(player, cache_buf, roleSid)
	print(">>>>>>>CommonManager:loadDBDataImpl:  ",roleSid,player:getSerialID())	
	local commonInfo = self._infosBySID[player:getSerialID()]
	if not commonInfo then
		commonInfo = self:getCommonInfoBySID(player:getSerialID())
		commonInfo:loadDBdata(player, cache_buf)
	else  -- 当角色 在镖车还在运行时，切回中州，使用原对象 不重新加载
		commonInfo:loadOtherDBdata(player,cache_buf)
		commonInfo:setRoleID(player:getID())
		self._infos[commonInfo:getRoleID()] = nil
		self._infos[player:getID()] = commonInfo
		--重新设置怪物主人
		for i,v in pairs(self._dart_datas.dartInfos) do
			if v == commonInfo._dart_datas.teamID then 
				local dart = g_entityMgr:getMonster(i)
				if dart:getHost() ~= 0 then 
					dart:setHost(player:getID())
				end
			end
		end
	end
end

function CommonManager:onPlayerLoaded(player)
	if not player then 
		return 
	end
	local roleSID = player:getSerialID()
	local commonInfo = self._infosBySID[roleSID]
	--角色运镖过程中下线,缓存清理后的数据保护
	local offData = self._dartOffRewardeExp[player:getSerialID()]
	if offData then 
		commonInfo:finishClearDart()
		commonInfo._dart_datas.count = offData.count
		commonInfo._dart_datas.rewardExp = offData.rewardExp
		commonInfo._dart_datas.offline = 1		
		g_taskMgr:NotifyListener(player, "onDart") 

		self._dartOffRewardeExp[player:getSerialID()] = nil
		self:cast2Commondata()

		g_ActivityMgr:sevenFestivalChange(player:getID(), ACTIVITY_ACT.DART, 1)
	end
	--角色下线,队伍ID清空处理
	if commonInfo._dart_datas.offline == 1 then 
		player:setCampID(0)
		commonInfo._dart_datas.offline = 0 
	end
	if commonInfo._dart_datas.teamID ~= 0 then 
		player:setCampID(commonInfo._dart_datas.teamID)
	end
	--服务器宕机后的数据清理
	if commonInfo._dart_datas.rewardType ~= 0 and commonInfo._dart_datas.rewardExp == 0 and commonInfo._dart_datas.dartId == 0  then 
		self:backItem(roleSID,commonInfo._dart_datas.rewardType)
		commonInfo._dart_datas.rewardType = 0
		commonInfo:finishClearDart()
		commonInfo._dart_datas.count = commonInfo._dart_datas.count + 1
		if commonInfo._dart_datas.count > 3 then 
			commonInfo._dart_datas.count = 3
		end
	end

	commonInfo:fireDartState()
	
	local bufMgr = player:getBuffMgr()
	if player:getLevel() < TIANSHAN_XUELIAN_LEVEL then
		if not bufMgr:isExist(TIANSHAN_XUELIAN_BUFF) then
			bufMgr:addBuff(TIANSHAN_XUELIAN_BUFF, 0)
		end
	elseif bufMgr:isExist(TIANSHAN_XUELIAN_BUFF) then
		bufMgr:delBuff(TIANSHAN_XUELIAN_BUFF)
	end
end

function CommonManager:onLevelChanged(player)
	if player:getLevel() >= TIANSHAN_XUELIAN_LEVEL then
		local bufMgr = player:getBuffMgr()
		if bufMgr:isExist(TIANSHAN_XUELIAN_BUFF) then
			bufMgr:delBuff(TIANSHAN_XUELIAN_BUFF)
		end
	end	
end

-- 断线重连
function CommonManager:onActivePlayer(player)
	if not player then
		return
	end

	local roleSID = player:getSerialID()

	local commonInfo = self._infosBySID[roleSID]
	if not commonInfo then
		return
	end

	if commonInfo._dart_datas.teamID ~= 0 then 
		player:setCampID(commonInfo._dart_datas.teamID)
	end

	commonInfo:fireDartState()

	self._teamDartInvite[roleSID] = nil
end

--镖车活动相关数据接口
-------------------------------------------------------------------------
-- 怪物死亡发放奖励倍数(默认为1),由运营配置

-- 加载镖车ID
function CommonManager:loadDart()
	local Dartdb = require "data.DartDB"
--	print(serialize(Dartdb))
	self._dart_datas.rewardExp = Dartdb[1].q_reward_exp
	self._dart_datas.ExpPer = unserialize(Dartdb[1].q_expPer)

	self._dart_datas.dartMinId = 80000
	self._dart_datas.dartMaxId = 80003
end

-- 是否在活动时间内
function CommonManager:isDartTime()
	if self._dart_datas.openFlag then
		return true
	end

	return false
end

-- 根据怪物ID判断是否为镖车 
function CommonManager:isDart(monSID)
	if monSID <= self._dart_datas.dartMaxId and monSID >= self._dart_datas.dartMinId then
		return true
	else
		return false
	end
end

-- 添加镖车，镖车ID为索引用于镖车移动后查找镖车信息
function CommonManager:addDart(monID, teamID)
	self._dart_datas.dartInfos[monID] = teamID
end

function CommonManager:removeDart(monID)
	self._dart_datas.dartInfos[monID] = nil
end

--玩家注销
function CommonManager:onPlayerOffLine(player)
	local roleID = player:getID()
	local roleSID = player:getSerialID()
	local User = self._infos[roleID]
	if User then
		User:cast2db()
		-- 完成状态清除
		self._infos[roleID] = nil
		if User._dart_datas.state == 3 or User._dart_datas.state == 4 then
		else
			self._infosBySID[roleSID] = nil
		end
	end

	self._inviteDartStamp[roleSID] = nil
	self._teamDartInvite[roleSID] = nil
end

function CommonManager:cast2Commondata()
	local data = {dart = {}}
	for i,v in pairs(self._dartOffRewardeExp) do
		local temp = {
				roleSID = v.roleSID,
				rewardExp = v.rewardExp,
				count = v.count
		}
		table.insert(data.dart,temp)
	end
	
	local dataValue = protobuf.encode("DartOffRewardExp", data)
	g_entityDao:updateCommonData(COMMON_DATA_ID_DART_REWARD,dataValue,g_frame:getWorldId())
	-- body
end


function CommonManager:onloadDartOffReward(cache_buf)
	if #cache_buf > 0 then 
		local datas = protobuf.decode("DartOffRewardExp", cache_buf)
		for _,v in pairs(datas.dart) do
			self._dartOffRewardeExp[v.roleSID] = {rewardExp = v.rewardExp,
												 count = v.count,
												 roleSID = v.roleSID
												}
		end
	end
end

-- 创建队伍检查
function CommonManager:teamDartCheck(roleSID, teamMaxCnt)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		return
	end

	local team = g_TeamPublic:getTeam(player:getTeamID())
	if not team then
		g_TeamPublic:onCreateTeam(player)
		return true
	end

	if not g_TeamPublic:isTeamLeader(roleSID) then
		g_TeamPublic:onLeaveTeam(player)
		g_TeamPublic:onCreateTeam(player)
		return true
	end

	local _, members = g_TeamPublic:getTeamAllMemBySID(roleSID)

	if #members > teamMaxCnt then
		g_commonServlet:sendErrMsg2Client(DART_TEAM_MEMBER_MAX_CAN_NOT_DART, 0, {}, player:getID())
		return
	end

	for _, id in pairs(members) do
		local member = g_entityMgr:getPlayerBySID(id)
		if member and id ~= roleSID then
			local commonInfo = self._infosBySID[id]
			if commonInfo then
				if DART_NEED_LEVEL > member:getLevel() then
					g_commonServlet:sendErrMsg2Client(DART_TEAM_MEMBER_LEVEL_CAN_NOT_DART, 1, {member:getName()}, player:getID())
					return
				end

				if commonInfo._dart_datas.count == 0 then
					g_commonServlet:sendErrMsg2Client(DART_TEAM_MEMBER_TIMES_CAN_NOT_DART, 1, {member:getName()}, player:getID())
					return
				end

				if commonInfo._dart_datas.rewardExp ~= 0 then
					g_commonServlet:sendErrMsg2Client(DART_TEAM_MEMBER_REWARD_CAN_NOT_DART, 1, {member:getName()}, player:getID())
					return
				end

				if commonInfo._dart_datas.state == 3 or commonInfo._dart_datas.state == 4 or commonInfo._dart_datas.teamID ~= 0 then
					g_commonServlet:sendErrMsg2Client(DART_TEAM_MEMBER_DART_CAN_NOT_DART, 1, {member:getName()}, player:getID())
					return
				end

				if self._teamDartInvite[id] then
					g_commonServlet:sendErrMsg2Client(DART_TEAM_MEMBER_INVITE, 1, {member:getName()}, player:getID())
					return
				end

				local memberPos = member:getPosition()
				local playerPos = player:getPosition()
				local xDiff = math.abs(memberPos.x - playerPos.x)
				local yDiff = math.abs(memberPos.y - playerPos.y)
				if player:getMapID() ~= member:getMapID() or (xDiff*xDiff + yDiff*yDiff) > 100 then
					g_commonServlet:sendErrMsg2Client(DART_TEAM_MEMBER_FAR_CAN_NOT_DART, 1, {member:getName()}, player:getID())
					return
				end
			end
		end
	end

	return true
end

-- 队伍发送组队运镖询问
function CommonManager:sendTeamMemberDartQuery(roleSID, teamID, count)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		return
	end

	local team = g_TeamPublic:getTeam(player:getTeamID())
	if not team then
		return
	end

	if not g_TeamPublic:isTeamLeader(roleSID) then
		return
	end

	local _, members = g_TeamPublic:getTeamAllMemBySID(roleSID)

	for _, id in pairs(members) do
		local member = g_entityMgr:getPlayerBySID(id)
		if member and id ~= roleSID then
			local commonInfo = self._infosBySID[member:getSerialID()]
			if commonInfo then
				local retData = {
						teamID = teamID,
						count = count,
						dartTimes = commonInfo._dart_datas.count,
				}

				self._teamDartInvite[id] = true
				fireProtoMessage(member:getID(), DART_SC_QUERY_TEAMDART,"DartQueryTeamDartProtocol", retData)
			end
		end
	end
end

-- 队伍成员回答
function CommonManager:answerTeamDart(roleID, teamID, rewardType, answer)
	local player = g_entityMgr:getPlayer(roleID)
	if not player then
		return
	end

	self._teamDartInvite[player:getSerialID()] = nil

	local commonInfo = self._infosBySID[player:getSerialID()]
	if not commonInfo then
		return
	end

	local roleSID = player:getSerialID()
	if not answer then
		local teamData = self._dart_datas.waitList[teamID]
		if teamData then 
			local dartPlayer = g_entityMgr:getPlayerBySID(teamData.roleSID)
			if dartPlayer and g_TeamPublic:getTeam(dartPlayer:getTeamID()) and dartPlayer:getTeamID() == player:getTeamID() and commonInfo._dart_datas.teamID == 0 then
				g_TeamPublic:onLeaveTeam(player)
			end

			if dartPlayer and commonInfo._dart_datas.teamID == 0 then
				g_commonServlet:sendErrMsg2Client(DART_TEAM_REFUSE_JOIN,1,{player:getName()},dartPlayer:getID())
			end
		end
		return
	end

	if rewardType == 0 then
		return
	end

	if commonInfo._dart_datas.teamID ~= 0 then
		if answer then
			g_commonServlet:sendErrMsg2Client(DART_TEAM_ERR_DART,0,{},roleID)
		end
		return
	end

	self:joinTeam(roleID, teamID, rewardType)
end

-- 邀请组队运镖
function CommonManager:inviteTeamDart(roleID, targetSID)
	local player = g_entityMgr:getPlayer(roleID)
	if not player then
		return
	end

	local commonInfo = self._infosBySID[player:getSerialID()]
	if not commonInfo then
		return
	end

	if commonInfo._dart_datas.teamID == 0 then
		return
	end

	if commonInfo._dart_datas.dartType ~= 2 then
		return
	end

	local teamData = self._dart_datas.waitList[commonInfo._dart_datas.teamID]
	if not teamData then
		return
	end

	if teamData.teamRealCnt >= teamData.teamMaxCnt then
		g_commonServlet:sendErrMsg2Client(DART_INVITE_ERR_TEAM_DART_FULL,0,{},roleID)
		return
	end

	local target =  g_entityMgr:getPlayerBySID(targetSID)
	if not target then
		g_commonServlet:sendErrMsg2Client(DART_INVITE_ERR_OFFLINE,0,{},roleID)
		return
	end

	local targetCommonInfo =  self._infosBySID[targetSID]
	if not targetCommonInfo then
		return
	end

	local now = os.time()
	if self._inviteDartStamp[targetSID] and now - self._inviteDartStamp[targetSID] < TEAM_DART_INVITE_TIME then
		g_commonServlet:sendErrMsg2Client(DART_INVITE_ERR_OFTEN,0,{},roleID)
		return
	end 

	self._inviteDartStamp[targetSID] = now

	if DART_NEED_LEVEL > target:getLevel() then
		g_commonServlet:sendErrMsg2Client(DART_INVITE_ERR_LEVEL,0,{},roleID)
		return
	end

	if targetCommonInfo._dart_datas.count == 0 then
		g_commonServlet:sendErrMsg2Client(DART_INVITE_ERR_DART_COUNT,0,{},roleID)
		return
	end

	if targetCommonInfo._dart_datas.rewardExp ~= 0 then
		g_commonServlet:sendErrMsg2Client(DART_INVITE_ERR_REWARD,0,{},roleID)
		return
	end

	if targetCommonInfo._dart_datas.state == 3 or targetCommonInfo._dart_datas.state == 4 or targetCommonInfo._dart_datas.teamID ~= 0 then
		g_commonServlet:sendErrMsg2Client(DART_INVITE_ERR_DART,0,{},roleID)
		return
	end

	local retData = {
			teamID = commonInfo._dart_datas.teamID,
			count = teamData.teamMaxCnt,
			dartTimes = targetCommonInfo._dart_datas.count,
	}

	self._teamDartInvite[targetSID] = true
	fireProtoMessage(target:getID(), DART_SC_QUERY_TEAMDART, "DartQueryTeamDartProtocol", retData)
end

--创建队伍
function CommonManager:creatTeam(roleSID, rewardType,teamMaxCnt,teamType)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		return
	end

	local roleID = player:getID()
	local User = self._infosBySID[roleSID]
	if User and player then
		if not User:hasItem(rewardType) then
			if rewardType == 1 then 
				g_commonServlet:sendErrMsg2Client(DART_ITEMS_NOT_ENOUGTH_1,0,{},User:getRoleID())
			elseif rewardType == 2 then 
				g_commonServlet:sendErrMsg2Client(DART_ITEMS_NOT_ENOUGTH_2,0,{},User:getRoleID())
			else
				g_commonServlet:sendErrMsg2Client(DART_ITEMS_NOT_ENOUGTH_3,0,{},User:getRoleID())
			end
			return 
		end

		if teamMaxCnt == 0 then
			return
		end

		if player:getCampID() ~= 0 then
			local teamID = player:getCampID()
			if self._dart_datas.waitList[teamID] or self._dart_datas.sendList[teamID] then
				return
			end
		end

		if User._dart_datas.count == 0 then
			return
		end

		if teamType == 2 then
			if not self:teamDartCheck(roleSID, teamMaxCnt) then
				return
			end
			g_TeamPublic:onSetTeamTarget(roleSID,TeamTargetType.DartEscort)
		end

		if not User:costItem(rewardType) then
			if rewardType == 1 then 
				g_commonServlet:sendErrMsg2Client(DART_ITEMS_NOT_ENOUGTH_1,0,{},User:getRoleID())
			elseif rewardType == 2 then 
				g_commonServlet:sendErrMsg2Client(DART_ITEMS_NOT_ENOUGTH_2,0,{},User:getRoleID())
			else
				g_commonServlet:sendErrMsg2Client(DART_ITEMS_NOT_ENOUGTH_3,0,{},User:getRoleID())
			end
			return 
		end

		local teamID = self:requestTeamID()
		local spaceTime = SINGLETIME
		self._dart_datas.waitList[teamID] = 
		{
		roleSID = roleSID,
		name = player:getName(),
		teamID =teamID, 
		teamMaxCnt = teamMaxCnt,
		teamRealCnt = 1,
		teamEndTime = os.time() + spaceTime,
		line = player:getCurrentLine(),
		factionID = player:getFactionID(),
		teamRole = {}
		}
		player:setCampID(teamID)
	--进入待发序列 
		self:setUserProp(User,rewardType,teamType,teamID)
		self._dart_datas.waitList[teamID].teamRole[roleSID] = {roleSID =roleSID,roleID = roleID,name = player:getName(),rewardType = rewardType}
		if teamType == 2 then 
			self._dart_datas.teamList[teamID] = self._dart_datas.waitList[teamID]
			User:sendStatus()
			local retData = {
					result = true,
					realCnt = self._dart_datas.waitList[teamID].teamRealCnt,
					maxCnt = self._dart_datas.waitList[teamID].teamMaxCnt,
			}
			fireProtoMessage(roleID,DART_SC_CREATTEAM_RET,"DartCreatTeamRetProtocol",retData)

			self:sendTeamMemberDartQuery(roleSID, teamID, teamMaxCnt)
		end
	end
end

function CommonManager:joinTeam(roleID,teamID,rewardType)
	local player = g_entityMgr:getPlayer(roleID)
	local User = g_commonMgr._infosBySID[player:getSerialID()]
	--防御
	if User._dart_datas.teamID ~= 0 then 
		return 
	end
	
	if player and User then 
		local teamData = self._dart_datas.waitList[teamID]
		if teamData then 
			if teamData.teamRealCnt < teamData.teamMaxCnt then 
				if not User:costItem(rewardType) then
				--提示,物品不足
					return  
				end
				self:setUserProp(User,rewardType,TEAMTYPE.TEAM,teamID)
				player:setCampID(teamID)
				teamData.teamRealCnt = teamData.teamRealCnt + 1
				local roleSID = player:getSerialID()
				teamData.teamRole[roleSID] = {roleSID = roleSID,roleID = roleID,name = player:getName(),rewardType = rewardType}
				--通知所有队员
				for i,v in pairs(teamData.teamRole) do
					local User = self._infosBySID[v.roleSID]
					User:sendStatus()
					local Cplayer = g_entityMgr:getPlayerBySID(v.roleSID)
					if Cplayer then 
						local temp = teamData.teamRealCnt .. "/" .. teamData.teamMaxCnt
						g_commonServlet:sendErrMsg2Client(DART_ROLE_JOIN_TEAM,2,{player:getName(),temp},Cplayer:getID())
					end
				end

				local teamLearder = g_entityMgr:getPlayerBySID(teamData.roleSID)
				if teamLearder then
					local team = g_TeamPublic:getTeam(teamLearder:getTeamID())
					if team then
						if g_TeamPublic:getTeam(player:getTeamID()) and player:getTeamID() ~= teamLearder:getTeamID() then
							g_TeamPublic:onLeaveTeam(player)
						end

						if player:getTeamID() ~= teamLearder:getTeamID() then
							g_TeamPublic:memJoinTeamBySID(teamLearder:getTeamID(), player:getSerialID())
						end
					end
				end
			else
				--提示 队列已满
				g_commonServlet:sendErrMsg2Client(DART_TEAM_FULLY,0,{},roleID)
			end
		else
			g_commonServlet:sendErrMsg2Client(DART_TEAM_NULL,0,{},roleID)
		end
	end
end

--退还令牌
function CommonManager:backItem(roleSID,rewardType)
	local data = self._dart_datas.data[rewardType]
	if data.MailID and data.MailID ~= 0 then
		g_entityMgr:dropItemToEmail(roleSID, data.MailDrop, data.MailID, 0)

		local player = g_entityMgr:getPlayerBySID(roleSID)
		if player then
			g_commonServlet:sendErrMsg2Client(DART_RELEASE_TEAM,0,{},player:getID())
		end
	else
		local player = g_entityMgr:getPlayerBySID(roleSID)
		if player then
			g_commonServlet:sendErrMsg2Client(DART_RELEASE_TEAM2,0,{},player:getID())
		end
	end
end

--队长解散队伍
function CommonManager:releaseTeam(teamID)
	local teamData = g_commonMgr._dart_datas.teamList[teamID]
	if teamData then 
		g_commonMgr._dart_datas.teamList[teamID] = nil
		g_commonMgr._dart_datas.waitList[teamID] = nil
		for i,v in pairs(teamData.teamRole) do
			local rewardType = v.rewardType
			local User = self._infosBySID[v.roleSID]
			local player = g_entityMgr:getPlayerBySID(v.roleSID)
			if User then 
				self:backItem(v.roleSID,rewardType)  -- 退还消耗镖车令牌
				User._dart_datas.rewardType = 0
				User:finishClearDart()
				User:clinkNPC()		--给队伍所有玩家重新推送状态 
				
				--消除队伍id
				if player then 
					player:setCampID(0)
				else
					User._dart_datas.offline = 1
				end
			end

		end
	end
end
--退出队伍
function CommonManager:leaveTeam( player,teamID)
	local teamData = g_commonMgr._dart_datas.teamList[teamID]
	local name = ""
	if player and teamData then 
		local roleSID = player:getSerialID()
		local teamRole = teamData.teamRole
		if teamRole then 
			local User = self._infosBySID[roleSID]
			if User then 
				teamData.teamRealCnt = teamData.teamRealCnt - 1
				self:backItem(roleSID,teamRole[roleSID].rewardType)
				name = teamData.teamRole[roleSID].name
				teamData.teamRole[roleSID] = nil
				User._dart_datas.rewardType = 0
				User:finishClearDart()
				User:clinkNPC()
				player:setCampID(0)
				g_commonServlet:sendErrMsg2Client(DART_LEAVE_TEAM,0,{},User:getRoleID())
			end
		end
		for i,v in pairs(teamData.teamRole) do
			local User = self._infosBySID[v.roleSID]
			if User then 
				User:clinkNPC()   --给队伍所有玩家推送当前队伍状态
				g_commonServlet:sendErrMsg2Client(DART_ROLE_LEAVE_TEAM,1,{name},User:getRoleID())				
			end
		end
	end	

end

function CommonManager:setUserProp(User,rewardType,teamType,teamID)
	local player = g_entityMgr:getPlayerBySID(User:getRoleSID())
	if not User or not player then 
		return 
	end

	--print(rewardType,teamType,teamID)
	local data = self._dart_datas.data[rewardType]
	local dartId = unserialize(data.q_dart_id)
	User._dart_datas.rewardType = rewardType
	User._dart_datas.flag = unserialize(data.q_drop_num)
	User:setDartState(4)
	--User._dart_datas.date 			=	time.toedition("day")
	User._dart_datas.startTime	 	= 	os.time()
	User._dart_datas.rewardID 		= 	data.q_dropID
	User._dart_datas.dartId 		= 	dartId[teamType][rewardType]
	User._dart_datas.rewardCount 	= 	data.q_reward_count
	User._dart_datas.dartType 		= 	teamType
	User._dart_datas.flag 			= 	unserialize(data.q_drop_num)
	User._dart_datas.teamID 		=	teamID
	User._dart_datas.gameAppID		= 	player:getGameAppID() 
	User._dart_datas.platID 	  	= 	player:getPlatID()
	User._dart_datas.openid			=	player:getOpenid()
	User._dart_datas.level 			=	player:getLevel()
	--User._dart_datas.count = User._dart_datas.count - 1
	User:cast2db()
end

-- 镖车单次移动完成
function CommonManager:onMonsterStop(monID)
	local teamID = self._dart_datas.dartInfos[monID]
	local teamData = self._dart_datas.sendList[teamID]
	if teamData then
		local roleSID = teamData.roleSID
		local User = self._infosBySID[roleSID]
		if User then
			local aroundMemCnt = User:getAroundTeamPlayerCount(teamData.teamID) or 0
			if aroundMemCnt > 0 then 
				local moveSpeed = math.min(math.floor((aroundMemCnt*2/teamData.teamMaxCnt) * DART_MOVE_SPEED),DART_MOVE_SPEED)
				local result = User:stopMove(moveSpeed)
				if result then
					self:dealTeamRoleReward(teamData)
					User:setCheckMove(false)
							--完成运镖 释放
					table.insert(g_commonMgr._dart_datas.entitys, {monID = teamData.dartId, t = os.time()})
					g_commonMgr:removeDart(teamData.dartId)
					g_commonMgr._dart_datas.sendList[teamID] = nil

				else
					User:setCheckMove(false)
				end
			else
				User:setCheckMove(true)
			end
		end
	end
end

function CommonManager:requestTeamID( )
	self._serTeamID = self._serTeamID + 1
	if self._serTeamID > 1000000 then
		self._serTeamID = 1
	end
	return self._serTeamID
end

function CommonManager:update()
	for teamID ,teamData in pairs(self._dart_datas.sendList or {}) do
		self:updateCheckDartAround(teamID,teamData)
	end

	self._count = self._count + 1

	if math.mod(self._count, 6) == 0 then
		self:updateDart()
	end
	if math.mod(self._count, 10) == 0 then
		self:updateSendList()
	end

	if self._count > 1000000 then
		self._count = 0
	end
end

function CommonManager:updateDart()
	for i =  #self._dart_datas.entitys,1,-1 do
		local entry = self._dart_datas.entitys[i]
		if entry then
			g_entityMgr:destoryEntity(entry.monID)
		end
	end
	self._dart_datas.entitys = {} 
end

function  CommonManager:updateSendList()
	local waitList = self._dart_datas.waitList
	if table.size(waitList) > 0 then 
		for teamID,teamData in pairs(waitList) do
			if teamData.teamMaxCnt == teamData.teamRealCnt then 
				--发车,5S一次
				self._dart_datas.sendList[teamID] = waitList[teamID]
				self._dart_datas.waitList[teamID] = nil
				self._dart_datas.teamList[teamID] = nil
				--开始发车 队伍所有者开始创建镖车,并且跟所有成员进行绑定
				--创建镖车 并且发车
				self:dartRun(teamID)
				break
			elseif os.time() > teamData.teamEndTime + TEAM_RELEASE_TIME then 
				self:releaseTeam(teamID)
			end
		end
	end
end
function CommonManager:dealTeamRoleReward(teamData )
	local teamRoleSID = {}
	for i,v in pairs(teamData.teamRole) do
		table.insert(teamRoleSID,v.roleSID)
	end
	for i,v in pairs(teamData.teamRole) do
		local roleSID = v.roleSID
		local player = g_entityMgr:getPlayerBySID(roleSID)
		local User = self._infosBySID[roleSID]
		if User then 
			User:FinishNotity(true)
			User:dealReward(1)
		end
		if teamData.teamMaxCnt ~= 1 then 
			g_masterMgr:finishMasterTask(MASTER_TASK_ID.DART, roleSID,teamRoleSID)	--师徒运镖	
		end
		
		if not player then
			User._dart_datas.offline = 1 
			self._infosBySID[roleSID] = nil	
		end

	end
end

function CommonManager:updateCheckDartAround(teamID,teamData)
	if not teamID or not teamData then 
		return 
	end
	local User = self._infosBySID[teamData.roleSID]
	if User then 
		--镖车只能存在30分钟
		if User._dart_datas.startTime + DART_SURVIVE_TIME < os.time() then 
			self:onMonsterKill(User._dart_datas.dartId,nil,User._dart_datas.id,2100)
		end
		if  User:getCheckMove() then 
			local aroundMemCnt = User:getAroundTeamPlayerCount(teamData.teamID) or 0
			if aroundMemCnt > 0 then 
				local moveSpeed = math.min(math.floor((aroundMemCnt*2/teamData.teamMaxCnt) * DART_MOVE_SPEED),DART_MOVE_SPEED)
				local result = User:stopMove(moveSpeed)
				if result then
					self:dealTeamRoleReward(teamData)
					User:setCheckMove(false)
							--完成运镖 释放
					table.insert(g_commonMgr._dart_datas.entitys, {monID = teamData.dartId, t = os.time()})
					g_commonMgr:removeDart(teamData.dartId)
					g_commonMgr._dart_datas.sendList[teamID] = nil

				else
					User:setCheckMove(false)
				end
			end
		end
	end
end

function CommonManager:dartRun(teamID)
	local sendTeam = self._dart_datas.sendList[teamID]
	local User = self._infosBySID[sendTeam.roleSID]
	local teamAllName = ""
	local teamNameTable = {}

	local dart = g_entityFct:createMonster(User._dart_datas.dartId)
	if dart then
		User._dart_datas.id = dart:getID()
		if sendTeam.teamMaxCnt ~= 1 then 
			for i,v in pairs(sendTeam.teamRole) do
				local teamUser = self._infosBySID[v.roleSID]
				teamUser:setDartState(3) 
				teamUser._dart_datas.dartHp = dart:getMaxHP()
				teamUser._dart_datas.count = teamUser._dart_datas.count - 1 
				teamUser._dart_datas.startTime = os.time()
				table.insert(teamNameTable,v.name)
				g_commonServlet:sendErrMsg2Client(DART_TEAM_ALREADY_SEND,0,{},v.roleID)

				g_achieveSer:achieveNotify(v.roleSID, AchieveNotifyType.TeamDart, 1)
				local player = g_entityMgr:getPlayerBySID(v.roleSID)
				if player then
					g_normalMgr:activeness(player:getID(), ACTIVENESS_TYPE.DART)
					local petID = player:getPetID()
					local pet = g_entityMgr:getMonster(petID)
					if pet then
						pet:setCampID(teamID)
					end

					for k, v2 in pairs(sendTeam.teamRole) do
						if v.roleSID ~= v2.roleSID then 
							g_relationMgr:addMeet(player:getID(), v2.roleSID)
						end
					end
				end
			end
			teamAllName = table.concat(teamNameTable,"###")
		else
			User:setDartState(3)
			User._dart_datas.dartHp = dart:getMaxHP()
			User._dart_datas.count = User._dart_datas.count - 1 
			User._dart_datas.startTime = os.time()
			g_commonServlet:sendErrMsg2Client(DART_SINGLE_ALREADY_SEND,0,{},User:getRoleID())

			local player = g_entityMgr:getPlayer(User:getRoleID())
			if player then
				g_normalMgr:activeness(player:getID(), ACTIVENESS_TYPE.DART)
				local petID = player:getPetID()
				local pet = g_entityMgr:getMonster(petID)
				if pet then
					pet:setCampID(teamID)
				end
			end
		end
		sendTeam.dartId = dart:getID()
		self:addDart(dart:getID(), teamID)
		if sendTeam.teamMaxCnt == 1 then 
			dart:setHost(User:getRoleID())
		 	dart:setFactionID(sendTeam.factionID)
		else
			dart:setHost(User:getRoleID())
			dart:setStrPropValue(ROLE_STATUS_NAME, teamAllName)
		end
		dart:setCampID(teamID)
		dart:setName(string.format("%s(%s)", dart:getName(), sendTeam.name))
		local pos = DART_RUNING_POSITION[1]
		-- 场景放入镖车
		g_sceneMgr:enterPublicScene(dart:getID(), User._dart_datas.mapId, pos.x, pos.y, line)
		local scene = dart:getScene()
		if scene then
			scene:addMonster(dart)
		end
		User:setCheckMove(true)
	end
end
function CommonManager:dropItem(monID, num)
	local dart = g_entityMgr:getMonster(monID)
	local dropID = self._dart_datas.data[1].q_dropID
	if dart then
		local isBind = true
		local item = g_ActivityMgr:getItemInfo(dropID)
		if item then
			isBind = item.bind
		end
		dart:dropItem(dropID, num, isBind)
	end
end
--镖车被攻击
function CommonManager:onMonsterHurt(monSID, roleID, hurt, monID)
	if not self:isDart(monSID) then
		return
	end
	local teamID = self._dart_datas.dartInfos[monID]
	local teamData = self._dart_datas.sendList[teamID]
	local Count = 0
	if teamData then
		for i,v in pairs(teamData.teamRole) do
			local User = self._infosBySID[v.roleSID]
			if User then 
				local num = User:onDartHurt(monID,hurt)
				if num ~= 0 then 
					if v.rewardType ~= 1 then --青铜镖车不掉宝箱
						Count = Count + num
					end
				end
			end
		end
		if Count ~= 0 then 
			self:dropItem(monID,Count)
		end
	end
end

--镖车被劫
function CommonManager:onMonsterKill(monSID, roleID, monID, mapID)
	if not self:isDart(monSID) then
		if self._monsterReward[monSID] then
			local commonInfo = self._infos[roleID]
			local User = g_entityMgr:getMonster(monID)
			if User and commonInfo then
				local firstLevel = commonInfo:getFirstKill()
				if firstLevel < User:getLevel() then
					User:dropItemByDropID(self._monsterReward[monSID])
					commonInfo:setFirstKill(User:getLevel())
				end
			end
		end	
	else
		local teamID = self._dart_datas.dartInfos[monID]
		local teamData = self._dart_datas.sendList[teamID]
		if teamData then
			for i,v in pairs(teamData.teamRole) do
				local User = self._infosBySID[v.roleSID]
				if User then 
					User:onDartKill(monID)
					User:dealReward(2)
					User:FinishNotity(false)
				end
				local Uplayer = g_entityMgr:getPlayerBySID(v.roleSID)
				if not Uplayer then
					User._dart_datas.offline = 1 
					self._infosBySID[v.roleSID] = nil
				end	
				
			end
			table.insert(g_commonMgr._dart_datas.entitys, {monID = monID, t = os.time()})
			g_commonMgr:removeDart(monID)
			g_commonMgr._dart_datas.sendList[teamID] = nil
		end
		--击杀镖车成就
		local player = g_entityMgr:getPlayer(roleID)
		if player then	-- 通知成就
			g_taskMgr:NotifyListener(player, "onKillDart")
			g_achieveSer:achieveNotify(player:getSerialID(), AchieveNotifyType.DartLoot, 1)
		end	
	end
end

--活动开启
function CommonManager:on()
	self._dart_datas.openFlag = true
end

--活动关闭
function CommonManager:off()
	self._dart_datas.openFlag = false
end

-- 重置镖车
function CommonManager:resetDart(roleID)
	local User = self._infos[roleID]
	if User then
		User:refreshDart()
	end
end

function CommonManager:canJoin(player)
	local roleSID = player:getSerialID()
	local memInfo = self._infosBySID[roleSID]

	if memInfo and memInfo._dart_datas.count ~= 0 and player:getLevel() >= DART_NEED_LEVEL then
		return true 
	else
		return false 
	end
end

-- 加入行会
function CommonManager:onJoinFaction(roleID)
	local player = g_entityMgr:getPlayer(roleID)
	if not player then
		return
	end

	local memInfo = self._infosBySID[player:getSerialID()]
	if not memInfo then
		return
	end

	if not memInfo._dart_datas.id then
		return
	end

	local dart = g_entityMgr:getMonster(memInfo._dart_datas.id)
	if not dart then
		return
	end

	dart:setFactionID(player:getFactionID())
end

-- 离开行会
function CommonManager:onLeaveFaction(roleID)
	local player = g_entityMgr:getPlayer(roleID)
	if not player then
		return
	end

	local memInfo = self._infosBySID[player:getSerialID()]
	if not memInfo then
		return
	end

	local memInfo = self._infosBySID[player:getSerialID()]
	if not memInfo then
		return
	end

	if not memInfo._dart_datas.id then
		return
	end

	local dart = g_entityMgr:getMonster(memInfo._dart_datas.id)
	if not dart then
		return
	end
	dart:setFactionID(0)
end

function CommonManager:hotUpdate()
	package.loaded["data.DartDB"] = nil
	self._dart_datas._data = {}
	self._dart_datas._data = require "data.DartDB"
end

function CommonManager:sendErrMsg2Client(eCode, paramCnt, params, roleID)
	local retBuff = LuaEventManager:instance():getLuaRPCEvent(FRAME_SC_MESSAGE)
	if roleID then
		fireProtoSysMessage(RelationServlet.getInstance():getCurEventID(), roleID, EVENT_RELATION_SETS, eCode, paramCnt, params)
	else
		local ret = {}
		ret.eventId = CommonServlet.getInstance():getCurEventID()
		ret.eCode = eCode
		ret.mesId = EVENT_PUSH_MESSAGE
		ret.param = {}
		paramCnt = paramCnt or 0
		for i=1, paramCnt do
			table.insert(ret.param, params[i] and tostring(params[i]) or "")
		end
		
		boardProtoMessage(EVENT_PUSH_MESSAGE,'FrameScMessageProtocol',ret)
	end
end

function CommonManager.setStoneNumInfo(roleSID, reliveTime, reliveStamp)
	local memInfo = g_commonMgr._infosBySID[roleSID]
	if not memInfo then
		return
	end

	memInfo:setStoneNumInfo(reliveTime, reliveStamp)
end

function CommonManager.getInstance()
	return CommonManager()
end

local name_types = 
{
	fightTeam = NAME_TYPE_FIGHTTEAM,
	faction = NAME_TYPE_FACTION,
}

function CommonManager:insertUniqueName(typeName, roleSID, name)
	local ty = name_types[typeName]
	if ty then
		local luabuf = g_buffMgr:getLuaEvent(NAME_WN_INSERT_NONPLAYER)
		luabuf:pushInt(ty)
		luabuf:pushString(roleSID)
		luabuf:pushString(name)
		g_engine:fireSessionEvent(luabuf)
		print("check Name in NameServer, roleSID=" .. roleSID..", name="..name..", type="..typeName)
	end
end

function CommonManager:deleteUniqueName(typeName, id, name)
	local ty = name_types[typeName]
	if ty then
		local luabuf = g_buffMgr:getLuaEvent(NAME_WN_DELETE_NONPLAYER)
		luabuf:pushInt(ty)
		luabuf:pushInt(id)
		luabuf:pushString(name)
		g_engine:fireSessionEvent(luabuf)
		print("delete unique name, id:"..id..", name=",name," type:", ty)
	end
end

--货币使用相关接口
---------------------------------------------------------------------------
--支付记录
function CommonManager:Record(roleID, payment, currency, operation, payActivity)
	local commonInfo = self._infos[roleID]
	local player = g_entityMgr:getPlayer(roleID)
	if player and commonInfo then
		commonInfo:addRecord(player, payment, currency, operation)
	end
end

--c++接口支持
function CommonManager.AddRecord(roleID, payment, currency, operation, payActivity)
	g_commonMgr:Record(roleID, payment, currency, operation, payActivity)
end

g_PayRecord = CommonManager.getInstance()
g_commonMgr = CommonManager.getInstance()

