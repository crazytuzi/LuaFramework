--TeamManager.lua
--/*-----------------------------------------------------------------
 --* Module:  TeamManager.lua
 --* Author:  liu cheng
 --* Modified: 2014年4月3日 15:49:14
 --* Purpose: Implementation of the class TeamManager
 -------------------------------------------------------------------*/
require ("system.team.Team")
require ("system.team.TeamServlet")
require ("system.team.MemberInfo")
require ("system.team.TeamEventParse")
TeamManager = class(nil, Singleton, Timer)

function TeamManager:__init()
	self._xtActive = 1 					--系统功能是否开启

	self._roleMemsBySID = {} 			--数据库ID		
	self._synMemPosInfos = {}			--需要同步队友位置数据的玩家 [roleSID] = true
	self._inviteAndRecruitTick = {} 	--记录使用邀请和招募的时间

	--添加 NewFunctionCfgDB 功能开启表  中  组队开启的数据	20150312
	self._TeamFunAllow = g_configMgr:getNewFuncLevel(13)  --组队功能开启等级
	if not self._TeamFunAllow then self._TeamFunAllow = TEAM_LEVEL_LIMIT end
	--if self._TeamFunAllow<TEAM_LEVEL_LIMIT then self._TeamFunAllow = TEAM_LEVEL_LIMIT end

	self._autoEnterActive = 1 			--自动匹配队伍的优化是否开启
	self._autoEnterInfo = {} 			--自动匹配队伍的数据
	self._speTeam = {} 					--特殊的队伍  例如 结婚任务队伍

	g_listHandler:addListener(self)
	gTimerMgr:regTimer(self, 3000, 3000)
end

function TeamManager:addSynMemPosInfo(roleSID)
	self._synMemPosInfos[roleSID] = true
end

function TeamManager:hasSynMemPosInfo(roleSID)
	return self._synMemPosInfos[roleSID] and true or false
end

function TeamManager:removeSynMemPosInfo(roleSID)
	self._synMemPosInfos[roleSID] = nil
end

--玩家续线
function TeamManager:onActivePlayer(player)
	if not player then return end
	local memInfo = self:createMemberInfo(player)
	g_TeamPublic:doActivePlayer(TEAM_OPT_ACTIVE, memInfo)
end

--玩家上线
--如果玩家有队伍则不需要新构建MemberInfo
--function TeamManager:loadTeamInfo(player)

function TeamManager:createMemberInfo(player)
	if not player then return end
	local roleSID = player:getSerialID()
	local roleID = player:getID()

	local weaponID = 0
	local clothID = 0
	local autoInvited = true
	local autoApply = true
	--武器衣服
	local itemMgr = player:getItemMgr()
	if itemMgr then
		weaponID = itemMgr:getWeaponID()
		clothID = itemMgr:getClothID()
	end


	local gameSetInfo = g_gameSetMgr:getRoleGameSetInfo(roleID)
	if gameSetInfo then
		local set = gameSetInfo:getTeamAutoInviteSet()
		if 0==set then autoInvited = false end
		set = gameSetInfo:getTeamAutoApplySet()
		if 0==set then autoApply = false end
	end

	local memTable = {}
	memTable.roleID = roleID
	memTable.roleSID = roleSID
	memTable.name = player:getName() or ""
	memTable.level = player:getLevel()
	memTable.sex = player:getSex()
	memTable.school = player:getSchool()
	memTable.wingID = player:getWingID()
	memTable.weapon = weaponID
	memTable.upperBody = clothID
	memTable.activeState = false
	memTable.teamID = 0
	memTable.prevPosNum = 0
	memTable.autoInvited = autoInvited
	memTable.autoApply = autoApply
	memTable.posMapID = 0
	memTable._applyInfo = {}
	memTable._inviteInfo = {}
	return memTable
end

function TeamManager:onPlayerLoaded(player)
	if not player then return end
	local memInfo = self:createMemberInfo(player)
	g_TeamPublic:doActivePlayer(TEAM_OPT_LOGIN, memInfo)
end

function TeamManager:loadTeamInfo(player)
	if not player then return end
	local roleSID = player:getSerialID()
	local itemMgr = player:getItemMgr()
	if not itemMgr then return end

	surfaceInfo = {}
	surfaceInfo.wingID = player:getWingID()
	surfaceInfo.weapon = itemMgr:getWeaponID()
	surfaceInfo.upperBody = itemMgr:getClothID()
	g_TeamPublic:updateMemSurface(roleSID,surfaceInfo)	
end

--玩家掉线
function TeamManager:onPlayerInactive(player)
	if not player then return end
	local memInfo = self:createMemberInfo(player)
	g_TeamPublic:doActivePlayer(TEAM_OPT_INVALID, memInfo)
end

--玩家下线
function TeamManager:onPlayerOffLine(player)
	if not player then return end
	local memInfo = self:createMemberInfo(player)
	g_TeamPublic:doActivePlayer(TEAM_OPT_OFF, memInfo)
end

--玩家死亡
function TeamManager:onPlayerDied(player, killerID)
	if not player then return end
	g_TeamPublic:memHPRefresh(player:getSerialID())
end

--玩家重生
function TeamManager:onPlayerRelive(player)
	if not player then return end
	g_TeamPublic:memHPRefresh(player:getSerialID())
end

--玩家升级回调
function TeamManager:onLevelChanged(player)
	if not player then return end

	local level = player:getLevel()
	local roleSID = player:getSerialID()

	surfaceInfo = {}
	surfaceInfo.level = player:getLevel()
	g_TeamPublic:updateMemSurface(roleSID,surfaceInfo)	
end

--上下装
function TeamManager:installEquip(roleSID)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if player then
		local itemMgr = player:getItemMgr()
		if itemMgr then
			surfaceInfo = {}
			surfaceInfo.weapon = itemMgr:getWeaponID()
			surfaceInfo.upperBody = itemMgr:getClothID()
			g_TeamPublic:updateMemSurface(roleSID,surfaceInfo)			
		end
	end
end

--更新光翼
function TeamManager:onWingChanged(roleSID, wingID)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then return end

	surfaceInfo = {}
	surfaceInfo.wingID = wingID
	g_TeamPublic:updateMemSurface(roleSID,surfaceInfo)
end

function TeamManager:update()
	for roleSID, _ in pairs(self._synMemPosInfos) do
		local player = g_entityMgr:getPlayerBySID(roleSID)
		if player then			
			self:syncTeammatePos(roleSID)
		end
	end
end

--同步队友位置
function TeamManager:syncTeammatePos(roleSID)
	local roleMemInfo = g_TeamPublic:getMemInfoBySID(roleSID)
	if roleMemInfo and not roleMemInfo:getActiveState() then 
		local sTeamID = roleMemInfo:getTeamID()
		local curMapID = roleMemInfo:getPosMapID()
		local data = {}

		if sTeamID>0 then
			local sTeam = g_TeamPublic:getTeam(sTeamID)
			if sTeam then
				local onlineSID = sTeam:getOnLineMems()
				for i,v in pairs(onlineSID or {}) do
					if roleSID~=v then
						local memPlayer = g_entityMgr:getPlayerBySID(v)
						if memPlayer then
							local pos = memPlayer:getPosition()
							if memPlayer:getMapID() == curMapID then
								table.insert(data, {pos.x, pos.y, v, memPlayer:getName() or ""})
							end
						end
					end
				end
			end
		end

		if #data > 0 then
			local ret = {}
			ret.bTag = true
			ret.num = #data
			ret.infos = {}
			for i=1, #data do
				local info = {}
				info.posX = data[i][1]
				info.posY = data[i][2]
				info.mapId = data[i][3]
				info.name = data[i][4]
				table.insert(ret.infos,info)
			end
			fireProtoMessageBySid(roleSID, TEAM_SC_GETTEAMPOSINFO , 'TeamGetTeamPosInfoProtocol', ret)
			roleMemInfo:setPrevPosNum(#data)
		else
			--同一场景的玩家数量由非零变为零需要再发一次
			if roleMemInfo:getPrevPosNum() > 0 then
				local ret = {}
				ret.bTag = true
				ret.num = 0
				ret.infos = {}
				fireProtoMessageBySid(roleSID, TEAM_SC_GETTEAMPOSINFO , 'TeamGetTeamPosInfoProtocol', ret)
				roleMemInfo:setPrevPosNum(0)
			end
		end
	end
end

function TeamManager:dealPosMapID(roleSID,curMapID)
	g_teamMgr:addSynMemPosInfo(roleSID)
	self:syncTeammatePos(roleSID)
end

function TeamManager:getInviteRecruitTick(roleSID,Type)
	if self._inviteAndRecruitTick[roleSID] then
		if 1==Type then
			return self._inviteAndRecruitTick[roleSID].inviteTick or 0
		elseif 2==Type then
			return self._inviteAndRecruitTick[roleSID].recruitTick or 0
		else
		end
	end
	return 0
end

function TeamManager:setInviteRecruitTick(roleSID,Type,value)
	if not self._inviteAndRecruitTick[roleSID] then
		self._inviteAndRecruitTick[roleSID] = {}
		self._inviteAndRecruitTick[roleSID].inviteTick = 0
		self._inviteAndRecruitTick[roleSID].recruitTick = 0
	end

	if 1==Type then
		self._inviteAndRecruitTick[roleSID].inviteTick = tonumber(value)
	elseif 2==Type then
		self._inviteAndRecruitTick[roleSID].recruitTick = tonumber(value)
	else
	end
end

function TeamManager:setxtActive(value)
	self._xtActive = tonumber(value)

	if tonumber(value)<1 then
		--解除所有队伍
		local PublicSvr = TEAM_DATA_SERVER_ID or 1
		if g_spaceID == 0 or g_spaceID == PublicSvr then			
			if g_TeamPublic then
				g_TeamPublic:DismissAllTeam()
			end
		end
	end
end

function TeamManager:getxtActive()
	return self._xtActive
end

function TeamManager:getAutoEnterActive()
	return self._autoEnterActive
end

function TeamManager:getAutoEnterInfo(roleSID)
	--if roleSID <= 0 then return end
	if roleSID == "" then return end
	if not self._autoEnterInfo[roleSID] then
		self._autoEnterInfo[roleSID] = 0
	end
	return self._autoEnterInfo[roleSID]
end

function TeamManager:setAutoEnterInfo(roleSID,timeTick)
	--if roleSID <= 0 or timeTick <= 0 then return end
	if roleSID == "" or timeTick <= 0 then return end
	if not self._autoEnterInfo[roleSID] then
		self._autoEnterInfo[roleSID] = 0
	end
	self._autoEnterInfo[roleSID] = timeTick
end

function TeamManager:isSpeTeam(teamID)
	if teamID > 0 then
		if self._speTeam[teamID] and self._speTeam[teamID] > 0 then
			return true
		end
	end
	return false
end

function TeamManager:setSpeTeam(teamID, isSpe)
	if teamID > 0 then
		if isSpe then
			if not self._speTeam[teamID] then
				self._speTeam[teamID] = 0
			end
			self._speTeam[teamID] = 1
		else
			if self._speTeam[teamID] then
				self._speTeam[teamID] = 0
			end
		end
	end
end

function TeamManager:giveUpSpeTask(SIDList)
	g_marriageMgr:teamClose(SIDList)
end

function TeamManager.getInstance()
	return TeamManager()
end

g_teamMgr = TeamManager.getInstance()
