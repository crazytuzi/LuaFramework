--TeamPublic.lua
--/*-----------------------------------------------------------------
 --* Module:  TeamPublic.lua
 --* Author:  liu cheng
 --* Modified: 2014年12月18日 15:49:14
 --* Purpose: Implementation of the class TeamPublic
 -------------------------------------------------------------------*/
require ("system.team.Team")
--require ("system.team.MemberInfo")

TeamPublic = class(nil, Singleton, Timer)

function TeamPublic:__init()
	--self._roleMemInfos = {} --运行时ID
	self._roleMemsBySID = {} --数据库ID	 	
 	self._AllTeam = {}
	self._mTeamID = 0
	self._releaseTeamIDs = {}
	
	gTimerMgr:regTimer(self, 1000, 2000)
end

function TeamPublic:doActivePlayer(operata,NewMemInfo)
	if operata<=0 or not NewMemInfo then return end
	local roleSID = NewMemInfo.roleSID
	
	if roleSID ~= "" then
		if TEAM_OPT_INVALID==operata or TEAM_OPT_OUT==operata or TEAM_OPT_SWITCH==operata then
			--掉线  离线  切换服务器			
			self:checkMemInfo(roleSID,NewMemInfo)
		end

		local OldMemInfo = self:getMemInfoBySID(roleSID)
		if operata<=TEAM_OPT_OFF and operata~=TEAM_OPT_ACTIVE then
			if OldMemInfo then
				self:dealPlayerInActive(OldMemInfo,operata)
			end

			if TEAM_OPT_LOGIN==operata then
				--上线   队伍ID强制清零
				self:checkMemInfo(roleSID,NewMemInfo)
				local curMemInfo2 = self:getMemInfoBySID(roleSID)
				curMemInfo2:setTeamID(0)
			elseif TEAM_OPT_OFF==operata then
				--长时间无反应  强制清数据
				--self._roleMemsBySID[NewRoleSID] = nil
			else
			end
		elseif TEAM_OPT_ACTIVE==operata then
			local roleID = NewMemInfo.roleID
			if OldMemInfo then						
				OldMemInfo:setRoleID(roleID)
				local teamID = OldMemInfo:getTeamID()
				local team = self:getTeam(teamID)
				if team then
					--如果在离线表中  移动到在线表					
					local onlineMem = team:getOnLineMems() or {}
					if not table.contains(onlineMem,roleSID) then
						team:addOnLineMem(roleSID)
					end

					local onlineMemID = team:getOnLineMemsID() or {}
					if not table.contains(onlineMemID,roleID) then
						team:addOnLineMemID(roleID)
					end					
					team:removeOffLineMem(roleSID)

					--如果最后A B同时掉线，B是最后的队长，新需求队伍不会解散
					--此时如果A先上线  应该将A设为队长
					local curOnlineMems = team:getOnLineCnt()
					if 1 == curOnlineMems then
						team:setLeaderID(roleSID)
					end

					local curTeamCnt = team:getMemCount()
					--重新设置队伍人数 和 ID		20160512			
					local player = g_entityMgr:getPlayerBySID(roleSID)
					if player then
						player:setTeamMemCnt(curTeamCnt)
						player:setTeamID(teamID)
					end

					--发送  TEAM_SC_GET_TEAMINFO_RET
					local retBuff2 = {}
					retBuff2.hasTeam = true
					retBuff2.teamId = teamID
					retBuff2.memCnt = curTeamCnt
					retBuff2.infos = {}
					local allMemIDs = team:getAllMember()
					for k,v in pairs(allMemIDs) do
						local info = self:getSingleMemInfoByPB(v)						
						table.insert(retBuff2.infos,info)
					end
					retBuff2.memCount1 = curTeamCnt - 1
					retBuff2.memCount2 = curTeamCnt - 1
					fireProtoMessageBySid(roleSID, TEAM_SC_GET_TEAMINFO_RET, 'TeamGetTeamInfoRetProtocol', retBuff2)
				end
			end			
			self:checkMemInfo(roleSID,NewMemInfo)
		else
		end
	end
end

function TeamPublic:dealPlayerInActive(memInfo,operata)
	if not memInfo or operata<0 then return end
	local roleSID = memInfo:getRoleSID()
	local roleID = memInfo:getRoleID()
	local teamIDTemp = memInfo:getTeamID()
	if teamIDTemp<0 then return end

	--在线人数减少一个
	local team = self:getTeam(teamIDTemp) 		--v:getTeamID()
	if team then
		team:removeOnLineMem(roleSID)
		team:removeOnLineMemID(roleID)
		team:addOffLineMem(roleSID)

		--上线  下线
		if TEAM_OPT_OFF==operata or TEAM_OPT_OUT==operata then 		
			if g_sharedTaskMgr:IsTaskOwner(roleSID) then
				local onMems = team:getOnLineMems() or {}
				for _,mem in pairs(onMems) do
					local member = g_entityMgr:getPlayerBySID(mem)
					if member then
						if g_sharedTaskMgr:deleteSharedTask(member:getID(),false) then
							g_taskServlet:sendErrMsg2Client(member:getID(), -95, 0)
						end
					end
				end
			end
		end

		local player = g_entityMgr:getPlayerBySID(roleSID)
		--掉线
		if TEAM_OPT_INVALID == operata then
			--在队伍成员可见的地图   离队时回到上一张地图的位置
			self:sendPlayerToLastPos(player)
		end
		
		--上线  下线  长时间无反应
		if TEAM_OPT_LOGIN==operata or TEAM_OPT_OUT==operata or TEAM_OPT_OFF==operata then --下线
			if TEAM_OPT_OUT==operata or TEAM_OPT_OFF==operata then
				--在队伍成员可见的地图   离队时回到上一张地图的位置
				self:sendPlayerToLastPos(player)
			end

			--离线逻辑 TEAM_OPT_OUT==operata
			team:removeOffLineMem(roleSID)
			memInfo:setTeamID(0)
			self:setTeamIDAndNum(player,0,0)
		end

		local teamID = team:getTeamID()
		local allMem = team:getAllMember() or {}   --sTeam:getOnLineMems() or {}
		local actCnt = team:getOnLineCnt()
		if actCnt>0 then
			--队长下线就改变队长并通知
			if team:getLeaderID() == roleSID then
				local onMems = team:getOnLineMems() or {}
				if onMems[1] then
					local newLeaderSID = onMems[1]								
					team:setLeaderID(newLeaderSID)
					local newLeaderName = ""
					local newLeader = self:getMemInfoBySID(newLeaderSID)					
					if newLeader then newLeaderName = newLeader.name or "" end										

					self:noticeChangeLeader(allMem,newLeaderSID,newLeaderName,team)
				end
			end

			if TEAM_OPT_LOGIN==operata or TEAM_OPT_OUT==operata or TEAM_OPT_OFF==operata then
				--离线人数就变了
				self:noticeMemNumChange(false,roleSID,memInfo:getName(),team)
			end
		elseif 0==actCnt then
			if TEAM_OPT_LOGIN==operata or TEAM_OPT_OUT==operata or TEAM_OPT_OFF==operata then
				--队伍中最后一个人掉线  --先看离线表里是否有成员  --多人守卫要求去掉  队伍中最后一个人掉线  删除队伍的需求
				local teamOfflineMem = team:getOffLineMems()
				if #teamOfflineMem>0 then				
					for i=1, #teamOfflineMem do
						local memInfoTmp = self:getMemInfoBySID(teamOfflineMem[i])
						if memInfoTmp then
							memInfoTmp:setTeamID(0)
						end
						--老队员重新设置队伍人数 和 ID		20160512
						self:playerSetTeamIDAndNum(teamOfflineMem[i],0,0)					
					end				
				end
				self:disbandTeam(teamID)
			end
		else
		end
	end
end

function TeamPublic:getMemInfoBySID(roleSID)
	if not roleSID then return end
	return self._roleMemsBySID[roleSID]
end

function TeamPublic:getTeam(teamID)
	if not teamID then return end
	return self._AllTeam[teamID]
end

function TeamPublic:disbandTeam(teamID)
	if not teamID then return end
	local team = self._AllTeam[teamID]
	if team then
		self._AllTeam[teamID] = nil
		table.insert(self._releaseTeamIDs,teamID)
	end
end

function TeamPublic:requestNewID()
	self._mTeamID = self._mTeamID + 1
	return self._mTeamID
--[[	
	local newTeamID = self._mTeamID + 1
	if #self._releaseTeamIDs>0 then
		newTeamID = self._releaseTeamIDs[1]
		table.remove(self._releaseTeamIDs,1)
	end

	if newTeamID>0 and not self._AllTeam[newTeamID] then
		return newTeamID
	else
		self._mTeamID = self._mTeamID + 1
	end

	return newTeamID
]]	
end

--更新成员光翼 武器 衣服 等级 自动组队
function TeamPublic:updateMemSurface(roleSID,surface)
	if not surface then return end
	local curMemInfo = self:getMemInfoBySID(roleSID)
	if curMemInfo then
		curMemInfo:setActiveState(false)

		if surface.level then
			curMemInfo:setLevel(surface.level or 1)
		end

		if surface.wingID then
			curMemInfo:setWingID(surface.wingID)
		end

		if surface.weapon then
			curMemInfo:setWeapon(surface.weapon)
		end

		if surface.upperBody then
			curMemInfo:setUpperBody(surface.upperBody)
		end

		if surface.autoInvited then
			local autoInvited = true
			if 0 == surface.autoInvited then autoInvited = false end
			curMemInfo:setAutoInvited(autoInvited)
		end

		if surface.autoApply then
			local autoApply = true
			if 0 == surface.autoApply then autoApply = false end
			curMemInfo:setAutoApply(autoApply)
		end
	end
end

function TeamPublic:updateMemInfo(oldMemInfo,NewMemInfo)
	if not NewMemInfo then return end
	local memInfo = oldMemInfo
	if not oldMemInfo then
		memInfo = MemberInfo()
	end

	memInfo:setRoleSID(NewMemInfo.roleSID)
	memInfo:setRoleID(NewMemInfo.roleID)
	memInfo:setAutoInvited(NewMemInfo.autoInvited)
	memInfo:setAutoApply(NewMemInfo.autoApply)
	memInfo:setTeamID(NewMemInfo.teamID)
	memInfo:setActiveState(NewMemInfo.activeState)
	memInfo:setName(NewMemInfo.name)
	memInfo:setLevel(NewMemInfo.level)
	memInfo:setSex(NewMemInfo.sex)				--添加性别
	memInfo:setSchool(NewMemInfo.school)
	memInfo:setWingID(NewMemInfo.wingID)
	memInfo:setWeapon(NewMemInfo.weapon)
	memInfo:setUpperBody(NewMemInfo.upperBody)
	memInfo:setPosMapID(NewMemInfo.posMapID)
	memInfo:setPrevPosNum(NewMemInfo.prevPosNum)
	memInfo._applyInfo = NewMemInfo._applyInfo
	memInfo._inviteInfo = NewMemInfo._inviteInfo
	return memInfo
end

--检查成员的信息并更新
function TeamPublic:checkMemInfo(roleSID, NewMemInfo)
	local curMemInfo = self:getMemInfoBySID(roleSID)
	if curMemInfo then
		curMemInfo:setRoleID(NewMemInfo.roleID or 0)
		curMemInfo:setAutoInvited(NewMemInfo.autoInvited)
		curMemInfo:setAutoApply(NewMemInfo.autoApply)
		curMemInfo:setActiveState(NewMemInfo.activeState)
		curMemInfo:setLevel(NewMemInfo.level or 1)
		if tonumber(NewMemInfo.wingID or 0)>0 then
			curMemInfo:setWingID(NewMemInfo.wingID)
		end
		if tonumber(NewMemInfo.weapon or 0)>0 then
			curMemInfo:setWeapon(NewMemInfo.weapon)
		end
		if tonumber(NewMemInfo.upperBody or 0)>0 then
			curMemInfo:setUpperBody(NewMemInfo.upperBody)
		end
		curMemInfo:setPosMapID(NewMemInfo.posMapID)
		curMemInfo:setPrevPosNum(NewMemInfo.prevPosNum)
	else
		self._roleMemsBySID[roleSID] = self:updateMemInfo(self._roleMemsBySID[roleSID],NewMemInfo)
	end
end

--按照PB格式  输出
function TeamPublic:getSingleMemInfoByPB(roleSID)
	local info = {}
	local teamMemInfo = self:getMemInfoBySID(roleSID)
	if teamMemInfo then
		info.roleSid = teamMemInfo:getRoleSID()
		info.name = teamMemInfo:getName()
		info.roleLevel = teamMemInfo:getLevel()
		info.sex = teamMemInfo:getSex()
		info.school = teamMemInfo:getSchool()
		local online = 0
		local activeState = teamMemInfo:getActiveState()
		if not activeState then online = 1 end
		info.actived = online

		local WingID,Weapon,UpperBody = self:updateWingWeaponCloth(roleSID)
		info.wingId = WingID
		info.weapon = Weapon
		info.upperBody = UpperBody

		info.curHP = 0
		info.factionName = ""
		local playerTmp1 = g_entityMgr:getPlayerBySID(roleSID)
		if playerTmp1 then
			local curHP = playerTmp1:getHP()
			local maxHP = playerTmp1:getMaxHP()
			info.curHP = curHP/maxHP * 100
			if info.curHP > 100 then 
				info.curHP = 100 
			end
			info.factionName = playerTmp1:getFactionName()
		end
	end
	return info
end

function TeamPublic:playerSetTeamIDAndNum(roleSID,teamID,teamNum)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	self:setTeamIDAndNum(player,teamID,teamNum)
end

function TeamPublic:setTeamIDAndNum(player, teamID, teamNum)
	if player then
		player:setTeamMemCnt(teamNum)
		player:setTeamID(teamID)
	end
end

function TeamPublic:updateWingWeaponCloth(roleSID)
	local sMemInfo = self:getMemInfoBySID(roleSID)
	if not sMemInfo then
		local buffer = self:getTipsMsg(TEAM_TIP_MEMINFO_ERR,TEAM_CS_CREATE_TEAM,0,{})
		fireProtoMessageBySid(roleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)	
		return
	end

	local WingID = sMemInfo:getWingID() or 0
	local Weapon = sMemInfo:getWeapon() or 0
	local UpperBody = sMemInfo:getUpperBody() or 0

	local playerTmp1 = g_entityMgr:getPlayerBySID(roleSID)
	if playerTmp1 then
		--同服或者单服务				
		sMemInfo:setWingID(playerTmp1:getWingID())
		WingID = playerTmp1:getWingID() or 0
		local itemMgrTmp1 = playerTmp1:getItemMgr()
		if itemMgrTmp1 then
			sMemInfo:setWeapon(itemMgrTmp1:getWeaponID())
			Weapon = itemMgrTmp1:getWeaponID() or 0
			sMemInfo:setUpperBody(itemMgrTmp1:getClothID())
			UpperBody = itemMgrTmp1:getClothID() or 0
		end
	end
	return WingID,Weapon,UpperBody
end

function TeamPublic:createNewTeamByInfo(player, memInfo, teamTarget)
	if not teamTarget then teamTarget = 1 end
	if not player then return 0 end
	local roleSID = player:getSerialID()
	if not memInfo then return 0 end
	local sTeamID = memInfo:getTeamID()

	if sTeamID>0 then 
		local buffer = self:getTipsMsg(TEAM_ERR_HAS_TEAM,TEAM_CS_CREATE_TEAM,0,{})
		fireProtoMessageBySid(roleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
		return 0
	end

	local sRoleID = memInfo:getRoleID()
	--local AutoInvited = memInfo:getAutoInvited()	

	local teamID = self:requestNewID()
	local team = Team(teamID, roleSID)
	table.insert(self._AllTeam, teamID, team)
	team:addOnLineMemID(sRoleID)
	team:addOnLineMem(roleSID)
	team:setAutoInvited(memInfo:getAutoApply())
	team:setLeaderID(roleSID)
	team:setTargetType(teamTarget)
	memInfo:setTeamID(teamID)
	
	--给队长发送自动批准状态
	--local retBuff3 = {}
	--retBuff3.teamId = teamID
	--retBuff3.leaderSid = roleSID
	--retBuff3.autoInvited = team:getAutoInvited()
	--fireProtoMessageBySid(roleSID, TEAM_SC_TEAM_AUTOADD, 'TeamAutoAddProtocol', retBuff3)

	player:setTeamMemCnt(1)
	player:setTeamID(teamID)

	g_taskMgr:NotifyListener(player, "onCreateTeam")
	if memInfo:getPosMapID()>0 then		--是否打开同步队友位置开关
		g_teamMgr:addSynMemPosInfo(roleSID)
	end

	local retBuff = {}
	retBuff.teamId = teamID
	retBuff.teamTarget = teamTarget
	retBuff.leaderInfo = self:getSingleMemInfoByPB(roleSID)
	fireProtoMessageBySid(roleSID, TEAM_SC_CREATE_TEAM_RET, 'TeamCreateTeamRetProtocol', retBuff)
	return teamID
end

--创建队伍 无目标
function TeamPublic:onCreateTeam(player)
	if not player then return newTeamID end
	local roleSID = player:getSerialID()
	local newTeamID = 0

	local sMemInfo = self:getMemInfoBySID(roleSID)
	if not sMemInfo then
		local buffer = self:getTipsMsg(TEAM_TIP_MEMINFO_ERR,TEAM_CS_CREATE_TEAM,0,{})
		fireProtoMessageBySid(roleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)	
		return newTeamID
	end
	sMemInfo:setActiveState(false)				--在线状态
	return self:createNewTeamByInfo(player, sMemInfo, 1)
end

function TeamPublic:onCreateNewTeam(player, Teamtarget)
	if not Teamtarget then Teamtarget = 1 end
	if Teamtarget <= 0 then Teamtarget = 1 end

	if not player then return newTeamID end
	local roleSID = player:getSerialID()
	local newTeamID = 0

	local sMemInfo = self:getMemInfoBySID(roleSID)
	if not sMemInfo then
		local buffer = self:getTipsMsg(TEAM_TIP_MEMINFO_ERR,TEAM_CS_CREATE_TEAM,0,{})
		fireProtoMessageBySid(roleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)	
		return newTeamID
	end
	sMemInfo:setActiveState(false)				--在线状态
	return self:createNewTeamByInfo(player, sMemInfo, Teamtarget)
end

function TeamPublic:inviteIntoMyTeam(sRoleMemInfo,tRoleMemInfo)
	if not sRoleMemInfo or not tRoleMemInfo then return end
	local sRoleSID = sRoleMemInfo:getRoleSID()
	local tRoleSID = tRoleMemInfo:getRoleSID()

	local sTeamID = sRoleMemInfo:getTeamID()
	local sTeam = self:getTeam(sTeamID)
	if not sTeam then return end

	if sTeam:getMemCount() >= TEAM_MAX_MEMBER then
		--返回队伍人数已满提示			
		local buffer6 = self:getTipsMsg(TEAM_ERR_MAX_MEMBER,TEAM_CS_INVITE_TEAM,0,{})
		fireProtoMessageBySid(sRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer6)
		return
	end

	if tRoleMemInfo:getAutoInvited() then
		--允许组队但需要手动审核

		--删除过期的邀请
		tRoleMemInfo:updateInvite()
		--玩家忙
		if tRoleMemInfo:getInviteCnt() >= TEAM_MAX_INVITE then
			local buffer = self:getTipsMsg(TEAM_TIP_PLAYER_BUSY, TEAM_CS_INVITE_TEAM, 0, {})
			fireProtoMessageBySid(sRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
			return
		end
		
		--已经邀请过了
		if tRoleMemInfo:isInvited(sRoleSID) then
			--tRoleMemInfo:updateInviteTime(sRoleSID)
			local buffer = self:getTipsMsg(TEAM_ERR_HAS_INVITED, TEAM_CS_INVITE_TEAM, 0, {})
			fireProtoMessageBySid(sRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
			return
		end
		
		tRoleMemInfo:addInvite(sRoleSID)	
		local ret = {}
		ret.roleId = sRoleSID
		ret.teamId = sTeamID
		ret.isInvite = true
		ret.name = sRoleMemInfo:getName()
		fireProtoMessageBySid(tRoleSID, TEAM_SC_INVITE_TEAM_RET, 'TeamInviteTeamRetProtocol', ret)
		
		--返回提示成功向对方发起组队邀请
		local buffer = self:getTipsMsg(TEAM_TIP_INVITE_SEND_SUCCEED,TEAM_CS_INVITE_TEAM,0,{})
		fireProtoMessageBySid(sRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
		return
	else
		--他设置了不接收邀请	
		local buffer6 = self:getTipsMsg(TEAM_ERR_INVITE_REFUSED,TEAM_CS_INVITE_TEAM,1,{tRoleMemInfo:getName() or ""})
		fireProtoMessageBySid(sRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer6)
		return
	end
end

function TeamPublic:applyIntoOtherTeam(sRoleMemInfo,tRoleMemInfo,isApply,iTeamID)
	if not sRoleMemInfo or not tRoleMemInfo then return end
	local sRoleSID = sRoleMemInfo:getRoleSID()
	local tRoleSID = tRoleMemInfo:getRoleSID()

	local tTeamID = tRoleMemInfo:getTeamID()
	if isApply then
		if 0>=iTeamID or not self:getTeam(iTeamID) then
			local buffer = self:getTipsMsg(TEAM_ERR_NO_TEAM,TEAM_CS_ANSWER_INVITE,0,{})
			fireProtoMessageBySid(sRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
			return
		end
		tTeamID = iTeamID		
	end

	local tTeam = self:getTeam(tTeamID)
	if not tTeam then return end
	
	if tTeam:getMemCount() >= TEAM_MAX_MEMBER then
		--返回队伍人数已满提示			
		local buffer6 = self:getTipsMsg(TEAM_ERR_MAX_MEMBER,TEAM_CS_INVITE_TEAM,0,{})
		fireProtoMessageBySid(sRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer6)
		return
	end

	if tTeam:isApplyed(sRoleSID) then
		--返回错误提示 已经申请过了
		local buffer6 = self:getTipsMsg(TEAM_ERR_HAS_APPLYED,TEAM_CS_INVITE_TEAM,0,{})
		fireProtoMessageBySid(sRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer6)
		return
	end

	if not tTeam:getAutoInvited() then
		--未设置自动批准
		
		if tTeam:getApplyCnt() >= TEAM_MAX_APPLY then
			local buffer = self:getTipsMsg(TEAM_TIP_TEAM_BUSY, TEAM_CS_INVITE_TEAM, 0, {})
			fireProtoMessageBySid(sRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
			return
		end				
		
		--已经申请过了
		if tTeam:isApplyed(sRoleSID) then
			--tTeam:updateApplyTime(sRoleSID)
			local buffer = self:getTipsMsg(TEAM_ERR_HAS_APPLYED, TEAM_CS_INVITE_TEAM, 0, {})
			fireProtoMessageBySid(sRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
			return
		end
		
		local tLeaderSID = tTeam.leaderID
		tTeam:addNewApply(tLeaderSID,sRoleSID)

		local leaderMemInfo = self:getMemInfoBySID(tLeaderSID)
		if leaderMemInfo then
			--给队长发送申请
			local ret = {}
			ret.roleId = sRoleSID
			ret.teamId = tTeamID
			ret.isInvite = false
			ret.name = sRoleMemInfo:getName()				
			fireProtoMessageBySid(tLeaderSID, TEAM_SC_INVITE_TEAM_RET, 'TeamInviteTeamRetProtocol', ret)				
		end								
		
		--返回提示申请发送成功
		local buffer = self:getTipsMsg(TEAM_TIP_APPLYED_SEND_SUCCEED,TEAM_CS_INVITE_TEAM,0,{})
		fireProtoMessageBySid(sRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
		return
	else
		--清除tRole所有的邀请和申请记录
		tTeam:removeApplyID(sRoleSID)
		sRoleMemInfo:clear()
		local tLeaderSID = tTeam.leaderID

		if isApply then
			self:addMemIntoTeam(tLeaderSID,sRoleSID,sRoleSID)
		else				
			self:addMemIntoTeam(tRoleSID,sRoleSID,sRoleSID)
		end
		
		--返回提示申请成功
		local buffer = self:getTipsMsg(TEAM_TIP_APPLYED_SUCCEED,TEAM_CS_INVITE_TEAM,0,{})
		fireProtoMessageBySid(sRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
	end
end

function TeamPublic:onInviteToTeam(player,tPlayer,isApply,iTeamID)
	if not player then return end
	local sRoleSID = player:getSerialID()
	if not tPlayer then return end
	local tRoleSID = tPlayer:getSerialID()

	local sRoleMemInfo = self:getMemInfoBySID(sRoleSID)
	if not sRoleMemInfo then   						-- or sRoleMemInfo:getActiveState()
		local buffer = self:getTipsMsg(TEAM_TIP_MEMINFO_ERR,TEAM_CS_INVITE_TEAM,0,{})
		fireProtoMessageBySid(sRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
		return 
	end
	sRoleMemInfo:setActiveState(false)

	local sTeamID = sRoleMemInfo:getTeamID()	

	local tRoleMemInfo = self:getMemInfoBySID(tRoleSID)
	if not tRoleMemInfo then
		local buffer = self:getTipsMsg(TEAM_ERR_OFFLINE,TEAM_CS_INVITE_TEAM,0,{})
		fireProtoMessageBySid(sRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
		return 
	end

	local tplayerOnline = false
	local tTeamID = 0
	if isApply then  		--招募中快速加入只能是申请组队，不能是邀请组队
		local teamTmp = self:getTeam(iTeamID)
		if iTeamID<=0 or not teamTmp then
			local buffer = self:getTipsMsg(TEAM_ERR_NO_TEAM,TEAM_CS_ANSWER_INVITE,0,{})
			fireProtoMessageBySid(sRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
			return
		end
		local leaderSID = teamTmp:getLeaderID()
		local leaderplayerTmp = g_entityMgr:getPlayerBySID(leaderSID)
		if leaderplayerTmp then tplayerOnline = true end
		tTeamID = iTeamID
	else
		tplayerOnline = true
		tTeamID = tRoleMemInfo:getTeamID()
	end
	
	if not tplayerOnline then 	--tRoleMemInfo:getActiveState()		
		--返回提示 对方不在线
		local buffer = self:getTipsMsg(TEAM_ERR_OFFLINE,TEAM_CS_INVITE_TEAM,0,{})
		fireProtoMessageBySid(sRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
		return
	end	
	
	--对方等级未达到
	if tRoleMemInfo.level<g_teamMgr._TeamFunAllow then 			--发送消息给  发起操作者  对方等级未达到
		local buffer = self:getTipsMsg(TEAM_TIP_LEVEL_NOTENOUGH,TEAM_CS_INVITE_TEAM,1,{g_teamMgr._TeamFunAllow})
		fireProtoMessageBySid(sRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
		return
	end
	
	if 0<sTeamID and 0<tTeamID then
		--返回错误提示 都有队伍不能加入		
		local buffer6 = self:getTipsMsg(TEAM_ERR_CAN_APPLY_JOIN,TEAM_CS_INVITE_TEAM,0,{})
		fireProtoMessageBySid(sRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer6)
		return
	end

	if 0==sTeamID and 0==tTeamID then
		self:createNewTeamByInfo(player,sRoleMemInfo,1)
		sTeamID = sRoleMemInfo:getTeamID()
	end

	if sTeamID>0 and 0==tTeamID then
		--副本队伍处于准备状态
		local teamTmp = self:getTeam(sTeamID)
		if teamTmp and teamTmp:getNeedBattle() < 0 then
			local buffer = self:getTipsMsg(TEAM_TIP_OWN_BEGIN_COPY,TEAM_CS_INVITE_TEAM,0,{})
			fireProtoMessageBySid(sRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
			return
		end

		--他加入我的队伍   队员拉人进来 不需要 通过队长同意
		self:inviteIntoMyTeam(sRoleMemInfo,tRoleMemInfo)
		return
	end

	if 0==sTeamID and 0<tTeamID then
		--如果他的队伍是特殊队伍 例如 婚礼任务队伍 则申请无效
		if g_teamMgr:isSpeTeam(tTeamID) then
			return
		end

		--副本队伍处于准备状态
		local teamTmp = self:getTeam(tTeamID)
		if teamTmp and teamTmp:getNeedBattle() < 0 then
			local buffer = self:getTipsMsg(TEAM_TIP_OTHER_BEGIN_COPY,TEAM_CS_INVITE_TEAM,0,{})
			fireProtoMessageBySid(sRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
			return
		end

		--我加入他的队伍
		self:applyIntoOtherTeam(sRoleMemInfo,tRoleMemInfo,isApply,iTeamID)
	end
end

--参数：有队伍的   没队伍的   主动发起方
function TeamPublic:addMemIntoTeam(sRoleSID,tRoleSID,activeSID)
	local sRoleMemInfo = self:getMemInfoBySID(sRoleSID)
	if not sRoleMemInfo then return false end
	local sTeamID = sRoleMemInfo:getTeamID()
	local sRoleID = sRoleMemInfo:getRoleID()

	local tRoleMemInfo = self:getMemInfoBySID(tRoleSID)
	if not tRoleMemInfo then return false end
	local tRoleID = tRoleMemInfo:getRoleID()
	local WingID,Weapon,UpperBody = self:updateWingWeaponCloth(tRoleSID)

	local sTeam = self:getTeam(sTeamID)
	if not sTeam then return false end

	local curTeamCnt = sTeam:getMemCount()
	if curTeamCnt >= TEAM_MAX_MEMBER then
		--返回队伍人数已满提示			
		local buffer6 = self:getTipsMsg(TEAM_ERR_MAX_MEMBER,TEAM_CS_INVITE_TEAM,0,{})		
		fireProtoMessageBySid(activeSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer6)
		return false
	end

	local allRoleSID = {}
	local allMem = sTeam:getAllMember() or {}   --sTeam:getOnLineMems() or {}
	for i=1, #allMem do
		table.insert(allRoleSID,allMem[i])
	end

	--同步加入者数据给老队员
	local retBuff = {}
	retBuff.info = self:getSingleMemInfoByPB(tRoleSID)
	retBuff.sTeamId = sTeamID
	retBuff.hurtAdd  = curTeamCnt 		--伤害与经验加成  这里不能-1因为还没加入新队员
	retBuff.expAdd  = curTeamCnt
	fireProtoMessageToGroup(allRoleSID, TEAM_SC_ADD_NEW_MEMBER , 'TeamAddNewMemberProtocol',retBuff)

	--消息提示老队员有新人入队
	local retBuff3 = self:getTipsMsg(TEAM_TIP_NEW_MEM_JOIN,TEAM_CS_INVITE_TEAM,1,{tRoleMemInfo:getName() or ""})
	fireProtoMessageToGroup(allRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', retBuff3)

	--老队员重新设置队伍人数  并相互增加熟人
	for i,v in pairs(allRoleSID) do
		self:playerSetTeamIDAndNum(v,sTeamID,curTeamCnt+1)
		self:addIntimateRole(v,tRoleSID)
	end

	--如果是特殊的队伍  例如结婚任务队伍  通知老队员放弃任务
	if g_teamMgr:isSpeTeam(sTeamID) then
		g_teamMgr:giveUpSpeTask(allRoleSID)
		g_teamMgr:setSpeTeam(sTeamID, false)
	end

	--提示新人  加入队伍成功
	local buffer6 = self:getTipsMsg(TEAM_TIP_JOIN_SUCCEED,TEAM_CS_INVITE_TEAM,0,{})
	fireProtoMessageBySid(tRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer6)

	--新人设置队伍ID和人数
	self:playerSetTeamIDAndNum(tRoleSID,sTeamID,curTeamCnt+1)

	sTeam:addOnLineMem(tRoleSID)
	sTeam:addOnLineMemID(tRoleID)
	sTeam:removeOffLineMem(tRoleSID)   --万一存在于离线表
	tRoleMemInfo:setTeamID(sTeamID)
	curTeamCnt = curTeamCnt + 1

	--同步队伍信息给新成员
	local ret = {}
	ret.teamId = sTeamID
	ret.hasTeam = true
	ret.memCnt = curTeamCnt
	ret.infos = {}
	local allMemIDs = sTeam:getAllMember()	
	for k,v in pairs(allMemIDs) do
		local info = self:getSingleMemInfoByPB(v)
		table.insert(ret.infos,info)
	end
	ret.hurtAdd = curTeamCnt - 1
	ret.expAdd = curTeamCnt - 1
	ret.teamTarget = sTeam:getTargetType()
	fireProtoMessageBySid(tRoleSID, TEAM_SC_JOIN_TEAM, 'TeamJoinTeamRetProtocol', ret)
	return true
end

--队长处理入队申请
function TeamPublic:onAnswerApply(sRoleSID,tRoleSID,bAnswer)
	local sRoleMemInfo = self:getMemInfoBySID(sRoleSID)
	if not sRoleMemInfo then 				-- or sRoleMemInfo:getActiveState()
		local buffer = self:getTipsMsg(TEAM_TIP_MEMINFO_ERR,TEAM_CS_ANSWER_APPLY,0,{})
		fireProtoMessageBySid(sRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)	
		return 
	end
	sRoleMemInfo:setActiveState(false)

	--判断自己是否是队长
	local sTeamID = sRoleMemInfo:getTeamID()
	local sTeam = self:getTeam(sTeamID)
	if not sTeam then return end

	local sTeamLeaderSID = sTeam:getLeaderID()
	if sRoleSID ~= sTeamLeaderSID then
		--不是队长
		local buffer = self:getTipsMsg(TEAM_ERR_NOT_LEADER,TEAM_CS_ANSWER_APPLY,0,{})
		fireProtoMessageBySid(sRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
		return
	end

	if not sTeam:isApplyed(tRoleSID) then
		--申请已过期
		local buffer = self:getTipsMsg(TEAM_ERR_APPLY_OUT_DATE,TEAM_CS_ANSWER_APPLY,0,{})
		fireProtoMessageBySid(sRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
		return
	end
	sTeam:removeApplyID(tRoleSID)
	
	local tRoleMemInfo = self:getMemInfoBySID(tRoleSID)
	local tplayerOnline = false
	local tplayerTmp = g_entityMgr:getPlayerBySID(tRoleSID)
	if tplayerTmp then tplayerOnline = true end
	
	if not tRoleMemInfo or not tplayerOnline then  			--or tRoleMemInfo:getActiveState()
		if not tRoleMemInfo then
			print("TeamPublic:onAnswerApply Err no targetMemInfo",tRoleSID)
		end
		--返回提示 对方不在线已过期
		local buffer6 = self:getTipsMsg(TEAM_ERR_OUT_OF_DATE_OFFLINE,TEAM_CS_ANSWER_APPLY,0,{})
		fireProtoMessageBySid(sRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer6)	
		return 
	end	
	tRoleMemInfo:removeApplyID(sTeamID)
	
	local tTeamID = tRoleMemInfo:getTeamID()
	if tTeamID>0 then
		--返回提示 对方已经有了队伍的提示
		local buffer6 = self:getTipsMsg(TEAM_ERR_HAS_JOIN_TEAM,TEAM_CS_ANSWER_APPLY,0,{})
		fireProtoMessageBySid(sRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer6)
		return
	end
	
	if bAnswer then
		if sTeam:getLeaderID() ~= sRoleSID then
			local buffer6 = self:getTipsMsg(TEAM_ERR_OUT_OF_DATE_NOTLEADER,TEAM_CS_ANSWER_APPLY,0,{})
			fireProtoMessageBySid(sRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer6)
			return
		end

		if sTeam:getMemCount() >= TEAM_MAX_MEMBER then			
			local buffer6 = self:getTipsMsg(TEAM_ERR_MAX_MEMBER,TEAM_CS_ANSWER_APPLY,0,{})
			fireProtoMessageBySid(sRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer6)
			return
		else
			--清除tRole所有的邀请和申请记录
			tRoleMemInfo:clear()
			self:addMemIntoTeam(sRoleSID,tRoleSID,sRoleSID)
		end
	else		
		--通知tRole申请被拒绝  注意不在一个服
		local buffer6 = self:getTipsMsg(TEAM_ERR_APPLY_REFUSED,TEAM_CS_ANSWER_APPLY,1,{sRoleMemInfo:getName() or ""})
		fireProtoMessageBySid(tRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer6)
	end
end

--角色处理邀请
function TeamPublic:onAnswerInvite(sRoleSID,tRoleSID,teamID,bAnswer)
	local sRoleMemInfo = self:getMemInfoBySID(sRoleSID)
	if not sRoleMemInfo then
		print("TeamPublic:onAnswerInvite no memInfo")
		local buffer = self:getTipsMsg(TEAM_TIP_MEMINFO_ERR,TEAM_CS_ANSWER_INVITE,0,{})
		fireProtoMessageBySid(sRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
		return
	end
	sRoleMemInfo:setActiveState(false)
	
	--邀请已过期
	sRoleMemInfo:updateInvite()
	if not sRoleMemInfo:isInvited(tRoleSID) then
		local buffer = self:getTipsMsg(TEAM_ERR_INVITE_OUT_DATE,TEAM_CS_ANSWER_INVITE,0,{})
		fireProtoMessageBySid(sRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
		return
	end
	--删除此邀请记录
	sRoleMemInfo:removeInviteID(tRoleSID)

	--自己有了队伍的提示
	local sTeamID = sRoleMemInfo:getTeamID()
	if sTeamID > 0 then		
		local buffer = self:getTipsMsg(TEAM_ERR_CAN_APPLY_JOIN,TEAM_CS_ANSWER_INVITE,0,{})
		fireProtoMessageBySid(sRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
		return
	end

	local tRoleMemInfo = self:getMemInfoBySID(tRoleSID)
	if not tRoleMemInfo then 				-- or sRoleMemInfo:getActiveState()
		local buffer = self:getTipsMsg(TEAM_TIP_MEMINFO_ERR,TEAM_CS_ANSWER_INVITE,0,{})
		fireProtoMessageBySid(sRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
		return
	end

	local tplayer = g_entityMgr:getPlayerBySID(tRoleSID)
	if not tplayer then
		local buffer = self:getTipsMsg(TEAM_ERR_OFFLINE,TEAM_CS_ANSWER_INVITE,0,{})
		fireProtoMessageBySid(sRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
		return
	end

	local tTeamID = tRoleMemInfo:getTeamID()
	if 0 == tTeamID or tTeamID ~= teamID then 
		local buffer = self:getTipsMsg(TEAM_ERR_NO_TEAM,TEAM_CS_ANSWER_INVITE,0,{})
		fireProtoMessageBySid(sRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
		return
	end

	if sRoleMemInfo.level<g_teamMgr._TeamFunAllow then 			--发送消息给 等级未达到
		local buffer = self:getTipsMsg(TEAM_TIP_LEVEL_NOTENOUGH,TEAM_CS_ANSWER_INVITE,1,{g_teamMgr._TeamFunAllow})
		fireProtoMessageBySid(sRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
		return
	end

	if bAnswer then	
		local tTeam = self:getTeam(tTeamID)
		if not tTeam then return end

		if tTeam:getMemCount() >= TEAM_MAX_MEMBER then
			local buffer = self:getTipsMsg(TEAM_ERR_MAX_MEMBER,TEAM_CS_ANSWER_INVITE,0,{})
			fireProtoMessageBySid(sRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
			
			local retBuff2 = {}
			retBuff2.teamId = tTeamID
			retBuff2.hasTeam = false
			fireProtoMessageBySid(sRoleSID, TEAM_SC_JOIN_TEAM , 'TeamJoinTeamRetProtocol', retBuff2)
			return
		end
		
		--清除tRole所有的邀请和申请记录
		sRoleMemInfo:clear()

		--清除队伍中该玩家申请记录
		tTeam:removeApplyID(sRoleSID)
		self:addMemIntoTeam(tRoleSID,sRoleSID,sRoleSID)

		--更新申请记录 小红点
		if tTeam:getApplyCnt() <= 0 then
			local retBuff = {}
			retBuff.teamId = tTeamID
			retBuff.isNull = true
			fireProtoMessageBySid(tTeam:getLeaderID(), TEAM_SC_TEAM_APPLY_ISNULL, 'TeamApplyIsNullProtocol', retBuff)
		end
	else
		--通知sRoleSID邀请被拒绝  注意不在一个服
		local buffer = self:getTipsMsg(TEAM_ERR_INVITE_REFUSED,TEAM_CS_ANSWER_INVITE,1,{sRoleMemInfo:getName() or ""})
		fireProtoMessageBySid(tRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
	end
end

function TeamPublic:sendTeamApply(team)
	if not team then return end

	local retBuff = {}
	--清理不在线玩家记录
	for _, v in pairs(team._applyInfo or {}) do
		local tmpplayer = g_entityMgr:getPlayerBySID(v.roleSID)
		if not tmpplayer then
			team:removeApplyID(v.roleSID)
		end
	end

	if team:getApplyCnt() <= 0 then
		retBuff.hasApply = false
	else
		retBuff.hasApply = true
		retBuff.teamId = team:getTeamID()
		retBuff.applyCnt = team:getApplyCnt()
		retBuff.infos = {}
		for _, v in pairs(team._applyInfo) do
			local player = g_entityMgr:getPlayerBySID(v.roleSID)
			if player then
				local info = {}
				info.roleSid = v.roleSID
				info.battle = player:getbattle()
				info.name = player:getName()
				info.school = player:getSchool()
				info.level = player:getLevel()
				table.insert(retBuff.infos,info)
			end
		end
	end
	local leaderSID = team:getLeaderID()
	fireProtoMessageBySid(leaderSID, TEAM_SC_GET_TEAM_APPLY_RET, 'TeamGetTeamApplyRetProtocol', retBuff)
end

function TeamPublic:onGetTeamApply(leaderSID, teamID)	
	local leaderInfo = self:getMemInfoBySID(leaderSID)
	if not leaderInfo then
		local buffer = self:getTipsMsg(TEAM_TIP_MEMINFO_ERR,TEAM_CS_GET_TEAM_APPLY,0,{})
		fireProtoMessageBySid(leaderSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
		return
	end
	
	local sTeamID = leaderInfo:getTeamID()
	local team = self:getTeam(sTeamID)
	if not team then 
		print("TeamPublic:onGetTeamApply getTeamApplye not team") 
		return 
	end
	
	local teamLeaderSID = team:getLeaderID()
	if teamLeaderSID ~= leaderSID then
		local buffer = self:getTipsMsg(TEAM_ERR_NOT_LEADER,TEAM_CS_GET_TEAM_APPLY,0,{})
		fireProtoMessageBySid(leaderSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
		return
	end
	self:sendTeamApply(team)
end

function TeamPublic:noticeMemNumChange(isRemove,changerSID,changerName,team)
	if not team then return end
	local allMem = team:getAllMember() or {}

	local teamMemNum = team:getMemCount() or 0
	local retBuff = self:getRemoveMemPB(isRemove,changerSID,TEAM_TIP_REMOVE_MEMBER,teamMemNum-1,teamMemNum-1)	
	fireProtoMessageToGroup(allMem, TEAM_SC_REMOVE_MEMBER_RET, 'TeamRemoveMemberRetProtocol',retBuff)

	--通知所有老队员  有人离队
	local retBuff2 = self:getTipsMsg(TEAM_TIP_REMOVE_MEMBER,TEAM_CS_REMOVE_MEMBER,1,{changerName or ""})
	fireProtoMessageToGroup(allMem, FRAME_SC_MESSAGE, 'FrameScMessageProtocol',retBuff2)

	--老队员重新设置队伍人数
	for i=1, #allMem do
		self:playerSetTeamIDAndNum(allMem[i],team:getTeamID() or 0,teamMemNum)		
	end
end

function TeamPublic:onRemoveMember(player,tRoleSID)
	if not player then return end
	local sRoleSID = player:getSerialID()

	local leaderInfo = self:getMemInfoBySID(sRoleSID)
	if not leaderInfo then 
		local buffer = self:getTipsMsg(TEAM_TIP_MEMINFO_ERR,TEAM_CS_ANSWER_APPLY,0,{})
		fireProtoMessageBySid(sRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
		return
	end
	
	local sTeamID = leaderInfo:getTeamID()
	local team = self:getTeam(sTeamID)
	if not team then return end

	local teamLeaderSID = team:getLeaderID()
	if teamLeaderSID ~= sRoleSID then
		local buffer6 = self:getTipsMsg(TEAM_ERR_NOT_LEADER,TEAM_CS_REMOVE_MEMBER,0,{})
		fireProtoMessageBySid(sRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer6)
		return
	end

	if teamLeaderSID == tRoleSID then
		local buffer6 = self:getTipsMsg(TEAM_ERR_IS_LEADER,TEAM_CS_REMOVE_MEMBER,0,{})
		fireProtoMessageBySid(sRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer6)
		return
	end

	local tRoleMemInfo = self:getMemInfoBySID(tRoleSID)
	if not tRoleMemInfo then  		-- or tRoleMemInfo:getActiveState() 
		print("TeamPublic:onRemoveMember Err no targetMemInfo")
		--返回提示 对方不在线
		local buffer6 = self:getTipsMsg(TEAM_ERR_OFFLINE,TEAM_CS_REMOVE_MEMBER,0,{})
		fireProtoMessageBySid(sRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer6)
		return
	end
	
	local tTeamID = tRoleMemInfo:getTeamID()
	if tTeamID ~= sTeamID then
		--不在同一个队伍
		local buffer6 = self:getTipsMsg(TEAM_ERR_NOT_SAME_TEAM,TEAM_CS_REMOVE_MEMBER,1,{tRoleMemInfo:getName()})
		fireProtoMessageBySid(sRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer6)
		return
	end
	tRoleMemInfo:setTeamID(0)

	--删除共享任务
	local player = g_entityMgr:getPlayerBySID(tRoleSID)
	if player then 
		if g_sharedTaskMgr:deleteSharedTask(player:getID(),false) then
			g_taskServlet:sendErrMsg2Client(player:getID(), -95, 0)
		end
	end

	if g_sharedTaskMgr:IsTaskOwner(tRoleSID) then
		local onMems = team:getOnLineMems() or {}
		for _,mem in pairs(onMems) do
			local member = g_entityMgr:getPlayerBySID(mem)
			if member then
				if g_sharedTaskMgr:deleteSharedTask(member:getID(),false) then
					g_taskServlet:sendErrMsg2Client(member:getID(), -95, 0)
				end
			end
		end
	end

	local tPlayer = g_entityMgr:getPlayerBySID(tRoleSID)
	--在队伍成员可见的地图  离队时回到上一张地图的位置
	self:sendPlayerToLastPos(tPlayer)

	--被删除者设置队伍ID 和 人数
	self:setTeamIDAndNum(tPlayer,0,0)

	--被删除者提示自己离开队伍
	local retBuff5 = self:getTipsMsg(TEAM_TIP_LEAVE_TEAM,TEAM_CS_REMOVE_MEMBER,0,{})	
	fireProtoMessageBySid(tRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', retBuff5)
	--被删除者返回队伍信息
	local ret = {}
	ret.hasTeam = false
	fireProtoMessageBySid(tRoleSID, TEAM_SC_GET_TEAMINFO_RET, 'TeamGetTeamInfoRetProtocol', ret)

	--如果是特殊的队伍  例如结婚任务队伍  通知老队员放弃任务
	if g_teamMgr:isSpeTeam(sTeamID) then
		g_teamMgr:giveUpSpeTask(team:getAllMember())
		g_teamMgr:setSpeTeam(sTeamID, false)
	end
	
	team:removeOnLineMemID(tRoleMemInfo:getRoleID())
	team:removeOnLineMem(tRoleSID)
	team:removeOffLineMem(tRoleSID)
	tRoleMemInfo:setTeamID(0)

	self:noticeMemNumChange(true,tRoleSID,tRoleMemInfo:getName(),team)
end

function TeamPublic:noticeChangeLeader(allMem,leaderSID,leaderName,team)
	if not team then return end
	local hasApply = false
	if table.size(team:getApplyInfo() or 0) > 0 then
		hasApply = true
	end

	local ret = {}
	ret.leaderSid = leaderSID
	ret.eCodeId = TEAM_TIP_CHANGGE_LEADER
	ret.hasApply = hasApply
	fireProtoMessageToGroup(allMem, TEAM_SC_CHANGE_LEADER_RET, 'ChangeLeaderRetProtocol',ret)

	local buffer2 = self:getTipsMsg(TEAM_TIP_CHANGGE_LEADER,TEAM_CS_CHANGE_LEADER,1,{leaderName or ""})	
	fireProtoMessageToGroup(allMem, FRAME_SC_MESSAGE, 'FrameScMessageProtocol',buffer2)

	--队长变更通知客户端改变允许组队和自动批准状态
	--local retBuff3 = {}
	--retBuff3.teamId = team:getTeamID() or 0
	--retBuff3.leaderSid = leaderSID
	--retBuff3.autoInvited = team:getAutoInvited() or false
	--fireProtoMessageBySid(leaderSID, TEAM_SC_TEAM_AUTOADD, 'TeamAutoAddProtocol', retBuff3)
end

function TeamPublic:onChangeLeader(sRoleSID,tRoleSID)
	local sMemInfo = self:getMemInfoBySID(sRoleSID)
	if not sMemInfo then 
		local buffer = self:getTipsMsg(TEAM_TIP_MEMINFO_ERR,TEAM_CS_CHANGE_LEADER,0,{})
		fireProtoMessageBySid(sRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
		return 
	end

	local sTeamID = sMemInfo:getTeamID()
	if sTeamID<=0 then
		local buffer = self:getTipsMsg(TEAM_ERR_NOT_IN_TEAM,TEAM_CS_CHANGE_LEADER,0,{})		
		fireProtoMessageBySid(sRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
		return
	end

	local team = self:getTeam(sTeamID)
	if not team then return end
	local teamLeaderSID = team:getLeaderID()
	if teamLeaderSID ~= sRoleSID then		
		local buffer = self:getTipsMsg(TEAM_ERR_NOT_LEADER,TEAM_CS_CHANGE_LEADER,0,{})
		fireProtoMessageBySid(sRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
		return
	end

	local tRoleMemInfo = self:getMemInfoBySID(tRoleSID)
	--判断被提升人是否在线
	local tplayerOnline = false
	local tplayer = g_entityMgr:getPlayerBySID(tRoleSID)
	if tplayer then tplayerOnline = true end
	
	if not tRoleMemInfo or not tplayerOnline then  --or tRoleMemInfo:getActiveState() 
		if not tRoleMemInfo then
			print("TeamPublic:onChangeLeader Err no targetMemInfo",tRoleSID)
		end
		local buffer = self:getTipsMsg(TEAM_ERR_IS_OFFLINE,TEAM_CS_CHANGE_LEADER,0,{})
		fireProtoMessageBySid(sRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
		return
	end
	local tRoleID = tRoleMemInfo:getRoleID()
	local tTeamID = tRoleMemInfo:getTeamID()

	if tTeamID~=sTeamID then
		--不在同一个队伍
		local buffer = self:getTipsMsg(TEAM_ERR_NOT_SAME_TEAM,TEAM_CS_CHANGE_LEADER,1,{tRoleMemInfo:getName() or ""})
		fireProtoMessageBySid(sRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
		return
	end
	team:setLeaderID(tRoleSID)
	team:setAutoInvited(tRoleMemInfo:getAutoApply()) 		--切换队长  自动批准状态  要修改

	--队伍成员排序
	local allMems = team:getOnLineMems() or {}
	local allMemsID = team:getOnLineMemsID() or {} 			--动态ID表
	table.removeValue(allMems,tRoleSID)
	table.removeValue(allMemsID,tRoleMemInfo:getRoleID())
	allMems[1] = tRoleSID
	allMemsID[1] = tRoleMemInfo:getRoleID()
	table.insert(allMems, 2, sRoleSID)
	table.insert(allMemsID, 2, sRoleID)
	
	local allMemSID = team:getAllMember() or {}
	self:noticeChangeLeader(allMemSID,tRoleSID,tRoleMemInfo:getName(),team)
end

function TeamPublic:getRemoveMemPB(isRemove,removeSID,eCode,hurtAdd,expAdd)
	local retBuff = {}
	retBuff.bLeave = isRemove
	retBuff.roleSid = removeSID
	retBuff.eCode = eCode
	retBuff.memberCount1 = hurtAdd
	retBuff.memberCount2 = expAdd
	return retBuff
end

function TeamPublic:leaveTeamByInfo(player,sRoleMemInfo)
	if not player or not sRoleMemInfo then return end
	local sRoleSID = sRoleMemInfo:getRoleSID()
	local sRoleID = sRoleMemInfo:getRoleID()
	local sTeamID = sRoleMemInfo:getTeamID()

	if sTeamID<=0 then		
		local buffer = self:getTipsMsg(TEAM_ERR_NOT_IN_TEAM,TEAM_CS_LEAVE_TEAM,0,{})
		fireProtoMessageBySid(sRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
		return
	end

	--提示自己离开队伍
	local buffer2 = self:getTipsMsg(TEAM_TIP_LEAVE_TEAM,TEAM_CS_LEAVE_TEAM,0,{})
	fireProtoMessageBySid(sRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer2)

	local retBuff = {}
	retBuff.hasTeam = false
	fireProtoMessageBySid(sRoleSID,TEAM_SC_GET_TEAMINFO_RET,"TeamGetTeamInfoRetProtocol",retBuff)

	--发给自己   经验加成为0

	local team = self:getTeam(sTeamID)
	if not team then return end
	local teamLeaderSID = team:getLeaderID()

	--在队伍成员可见的地图  离队时回到上一张地图的位置
	self:sendPlayerToLastPos(player)

	--如果是特殊的队伍  例如结婚任务队伍  通知老队员放弃任务
	if g_teamMgr:isSpeTeam(sTeamID) then
		g_teamMgr:giveUpSpeTask(team:getAllMember())
		g_teamMgr:setSpeTeam(sTeamID, false)
	end

	team:removeOnLineMem(sRoleSID)
	team:removeOnLineMemID(sRoleID)
	sRoleMemInfo:setTeamID(0)
	self:setTeamIDAndNum(player,0,0) 				--自己队伍ID和队伍人数设为0
	
	--删除共享任务
	--local player = g_entityMgr:getPlayerBySID(sRoleSID)
	if g_sharedTaskMgr:IsTaskOwner(sRoleSID) then
		local onMems = team:getOnLineMems() or {}
		for _,mem in pairs(onMems) do
			local member = g_entityMgr:getPlayerBySID(mem)
			if member then
				if g_sharedTaskMgr:deleteSharedTask(member:getID(),false) then
					g_taskServlet:sendErrMsg2Client(member:getID(), -95, 0)
				end
			end
		end
	else
		g_sharedTaskMgr:deleteSharedTask(player:getID(),false)
	end

	local onlineCnt = team:getOnLineCnt()
	if onlineCnt == 0 then
		--判断离线队员
		local teamOfflineMem = team:getOffLineMems()
		if #teamOfflineMem>0 then
			local sMemInfoTmp = self:getMemInfoBySID(teamOfflineMem[i])
			if sMemInfoTmp then
				sMemInfoTmp:setTeamID(0)
			end
			self:playerSetTeamIDAndNum(teamOfflineMem[i],0,0)
		end

		--消息通知有人离开
		local retBuff4 = self:getTipsMsg(TEAM_TIP_REMOVE_MEMBER,TEAM_CS_REMOVE_MEMBER,1,{sRoleMemInfo:getName() or ""})	
		fireProtoMessageToGroup(teamOfflineMem, FRAME_SC_MESSAGE, 'FrameScMessageProtocol',retBuff4)
		self:disbandTeam(sTeamID)
		return
	elseif onlineCnt>0 then
		--告诉所有人  队伍人数减少了一个
		self:noticeMemNumChange(false,sRoleSID,sRoleMemInfo:getName(),team)
		
		if teamLeaderSID == sRoleSID then		
			local onMems = team:getOnLineMems() or {}
			if onMems[1] then
				local newLeaderSID = onMems[1]
				team:setLeaderID(newLeaderSID)

				local sMemInfoTmp = self:getMemInfoBySID(newLeaderSID)
				if not sMemInfoTmp then
					print("TeamPublic:onLeaveTeam newLeader no memInfo")
					return
				end

				--给所有人发消息   切换队长
				local allMemSID = team:getAllMember() or {}
				self:noticeChangeLeader(allMemSID,newLeaderSID,sMemInfoTmp:getName(),team)				
			end	
		end
	else
	end
end

function TeamPublic:onLeaveTeam(player)
	if not player then return end
	local sRoleSID = player:getSerialID()

	local sRoleMemInfo = self:getMemInfoBySID(sRoleSID)
	if not sRoleMemInfo then 
		local buffer = self:getTipsMsg(TEAM_TIP_MEMINFO_ERR,TEAM_CS_LEAVE_TEAM,0,{})
		fireProtoMessageBySid(sRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
		return 
	end
	sRoleMemInfo:setActiveState(false)
	self:leaveTeamByInfo(player,sRoleMemInfo)
end

function TeamPublic:onGetTeamInfo(sRoleSID)
	local sRoleMemInfo = self:getMemInfoBySID(sRoleSID)
	if not sRoleMemInfo then 
		print("TeamPublic:onGetTeamInfo no memInfo",sRoleSID)
		local buffer = self:getTipsMsg(TEAM_TIP_MEMINFO_ERR,TEAM_CS_GET_TEAMINFO,0,{})
		fireProtoMessageBySid(sRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
		return 
	end
	sRoleMemInfo:setActiveState(false)
	local sRoleID = sRoleMemInfo:getRoleID()
	local sTeamID = sRoleMemInfo:getTeamID()
	if sTeamID<=0 then
		local retBuff = {}
		retBuff.hasTeam = false
		fireProtoMessageBySid(sRoleSID,TEAM_SC_GET_TEAMINFO_RET,"TeamGetTeamInfoRetProtocol",retBuff)
		return
	end

	local sTeam = self:getTeam(sTeamID)
	if not sTeam then
		print("TeamPublic:onGetTeamInfo no teamInfo",sRoleSID,sTeamID)
		sRoleMemInfo:setTeamID(0)
		self:playerSetTeamIDAndNum(sRoleSID,0,0)
		
		local retBuff = {}
		retBuff.hasTeam = false
		fireProtoMessageBySid(sRoleSID,TEAM_SC_GET_TEAMINFO_RET,"TeamGetTeamInfoRetProtocol",retBuff)
		return
	end

	--判断自己是否在队伍中
	local allMemIDs = sTeam:getAllMember()
	if not table.contains(allMemIDs,sRoleSID) then
		print("TeamPublic:onGetTeamInfo 04",sRoleSID,sTeamID)
		local retBuff = {}
		retBuff.hasTeam = false
		fireProtoMessageBySid(sRoleSID,TEAM_SC_GET_TEAMINFO_RET,"TeamGetTeamInfoRetProtocol",retBuff)

		sRoleMemInfo:setTeamID(0)
		self:playerSetTeamIDAndNum(sRoleSID,0,0)
		return
	end

	local curTeamCnt = sTeam:getMemCount()
	local retBuff = {}
	retBuff.hasTeam = true
	retBuff.teamId = sTeamID
	retBuff.memCnt = curTeamCnt
	retBuff.memCount1 = curTeamCnt - 1
	retBuff.memCount2 = curTeamCnt - 1

	local leaderSID = sTeam:getLeaderID()
	local playerLeader = g_entityMgr:getPlayerBySID(leaderSID)
	retBuff.teamTarget = sTeam:getTargetType()

	retBuff.infos = {}
	local allMemIDs = sTeam:getAllMember()
	for k,v in pairs(allMemIDs) do
		local info = self:getSingleMemInfoByPB(v)						
		table.insert(retBuff.infos,info)
	end
	fireProtoMessageBySid(sRoleSID,TEAM_SC_GET_TEAMINFO_RET,"TeamGetTeamInfoRetProtocol",retBuff)
end

function TeamPublic:onSetAutoInvited(sRoleSID,autoInvited)
	local sRoleMemInfo = self:getMemInfoBySID(sRoleSID)
	if not sRoleMemInfo then 
		local buffer = self:getTipsMsg(TEAM_TIP_MEMINFO_ERR,TEAM_CS_CHANGE_AUTOINVITE,0,{})
		fireProtoMessageBySid(sRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
		return 
	end
	sRoleMemInfo:setActiveState(false)

	local auto = false
	if autoInvited > 1 then auto = true end
	sRoleMemInfo:setAutoInvited(auto)
end

function TeamPublic:onSetAutoApply(sRoleSID,autoInvited)
	local sRoleMemInfo = self:getMemInfoBySID(sRoleSID)
	if not sRoleMemInfo then 
		local buffer = self:getTipsMsg(TEAM_TIP_MEMINFO_ERR,TEAM_CS_CHANGE_AUTOINVITE,0,{})
		fireProtoMessageBySid(sRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
		return 
	end
	sRoleMemInfo:setActiveState(false)

	local auto = false
	if autoInvited > 1 then auto = true end
	sRoleMemInfo:setAutoApply(auto)

	local teamID = sRoleMemInfo:getTeamID()
	if teamID > 0 then
		local team = self:getTeam(teamID)
		if not team then return end
		if team:getLeaderID() == sRoleSID then
			team:setAutoInvited(auto)
			return
		end
	end
end

function TeamPublic:onSetTeamTarget(sRoleSID,targetValue)
	if targetValue<=0 or targetValue>11 then return end

	local sRoleMemInfo = self:getMemInfoBySID(sRoleSID)
	if not sRoleMemInfo then 
		local buffer = self:getTipsMsg(TEAM_TIP_MEMINFO_ERR,TEAM_CS_CHANGE_AUTOINVITE,0,{})
		fireProtoMessageBySid(sRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
		return 
	end
	sRoleMemInfo:setActiveState(false)

	local teamID = sRoleMemInfo:getTeamID()
	if teamID <= 0 then
		local buffer = self:getTipsMsg(TEAM_ERR_NOT_IN_TEAM,TEAM_CS_CHANGE_LEADER,0,{})		
		fireProtoMessageBySid(sRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
		return
	end

	local team = self:getTeam(teamID)
	if not team then return end

	local teamLeaderSID = team:getLeaderID()
	if teamLeaderSID ~= sRoleSID then		
		local buffer = self:getTipsMsg(TEAM_ERR_NOT_LEADER,TEAM_CS_CHANGE_LEADER,0,{})
		fireProtoMessageBySid(sRoleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
		return
	end

	team:setTargetType(targetValue)
	local allMemSID = team:getAllMember() or {}
	local retBuff = {}
	retBuff.teamID = teamID
	retBuff.infoType = 1
	retBuff.infoData = targetValue
	retBuff.memHP = {}
	fireProtoMessageToGroup(allMemSID, TEAM_SC_NOTICE_TEAMINFO, 'TeamNoticeInfo',retBuff)
end

function TeamPublic:getAroundPlayer(roleSID,aroundType,returnPB)
	local aroundTeamIDs = {} 		--附近的队伍ID
	local retData = {}
	retData.noTeamCnt = 0
	retData.noTeaminfos = {}
	retData.withTeamCnt = 0
	retData.teamInfos = {}
	retData.aroundType = aroundType

	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then 
		return retData, aroundTeamIDs
	end
	local roleID = player:getID()

	local scene = player:getScene()
	if not scene then 
		return retData, aroundTeamIDs
	end
	local teamVisible = scene:isTeamVisible()

	local position = player:getPosition()
	local aroundPlayers = scene:getEntities(0,position.x, position.y, TEAM_AROUND_RAD, eClsTypePlayer, roleID) or {}
	if 1 == aroundType then
		table.insert(aroundPlayers, roleID)
	end

	if #aroundPlayers<=0 or (teamVisible and 2 == aroundType) then
		if returnPB then
			fireProtoMessageBySid(roleSID,TEAM_SC_GET_AOUNDPLAYER_RET,"TeamGetArroundPlayerRetProtocol",retData)			
		end
		return retData, aroundTeamIDs
	end

	--某些地图只能看到队友
	if teamVisible then
		if 1 == aroundType then 			--附近队伍
			local tRoleMemInfoTmp = self:getMemInfoBySID(roleSID)
			local tTeamID = tRoleMemInfoTmp:getTeamID()
			if tTeamID > 0 then
				local teamTmp = self:getTeam(tTeamID)
				if teamTmp then
					local leaderSIDTmp = teamTmp:getLeaderID()
					local leaderplayer = g_entityMgr:getPlayerBySID(leaderSIDTmp)
					if leaderplayer then
						local teamInfoTmp = {}
						teamInfoTmp.teamID = tTeamID
						teamInfoTmp.leaderName = leaderplayer:getName() or ""
						teamInfoTmp.leaderFaction = leaderplayer:getFactionName() or ""
						teamInfoTmp.teamTarget = teamTmp:getTargetType()
						teamInfoTmp.teamMaxNum = TEAM_MAX_MEMBER
						teamInfoTmp.teamCurNum = teamTmp:getMemCount()

						retData.withTeamCnt = retData.withTeamCnt + 1
						table.insert(retData.teamInfos, teamInfoTmp)
					end
				end

				aroundTeamIDs[tTeamID] = 1
				--if not table.contains(aroundTeamIDs,tTeamID) then
					--table.insert(aroundTeamIDs,tTeamID)
				--end

				if returnPB then
					fireProtoMessageBySid(roleSID,TEAM_SC_GET_AOUNDPLAYER_RET,"TeamGetArroundPlayerRetProtocol",retData)			
				end
				return retData, aroundTeamIDs
			else
				if returnPB then
					fireProtoMessageBySid(roleSID,TEAM_SC_GET_AOUNDPLAYER_RET,"TeamGetArroundPlayerRetProtocol",retData)			
				end
				return retData, aroundTeamIDs
			end
		end
		return
	end

	for i,v in pairs(aroundPlayers) do
		local playerTmp = g_entityMgr:getPlayer(v)
		if playerTmp then
			local roleSIDTmp = playerTmp:getSerialID()
			local tRoleMemInfoTmp = self:getMemInfoBySID(roleSIDTmp)
			if tRoleMemInfoTmp then
				local isLeader = false
				local isCopyTeam = false 				--副本的队伍  在准备进入副本时  不能组其它成员
				local curTeamMemNumTmp = 0
				local teamTargetTmp = 1
				local tTeamID = tRoleMemInfoTmp:getTeamID()
				if tTeamID > 0 then
					aroundTeamIDs[tTeamID] = 1
					--if not table.contains(aroundTeamIDs,tTeamID) then
						--table.insert(aroundTeamIDs,tTeamID)
					--end

					local teamTmp = self:getTeam(tTeamID)
					if teamTmp then
						curTeamMemNumTmp = teamTmp:getMemCount()
						teamTargetTmp = teamTmp:getTargetType()
						if roleSIDTmp == teamTmp:getLeaderID() then
							isLeader = true
						end

						--副本的队伍已经准备进去副本
						if teamTmp:getNeedBattle() < 0 then
							isCopyTeam = true
						end
					end
				end

				if 1 == aroundType then 			--附近队伍
					if isLeader and not isCopyTeam then
						local infoTmp = {}
						infoTmp.teamID = tTeamID
						infoTmp.leaderName = playerTmp:getName() or ""
						infoTmp.leaderFaction = playerTmp:getFactionName() or ""
						infoTmp.teamTarget = teamTargetTmp
						infoTmp.teamMaxNum = TEAM_MAX_MEMBER
						infoTmp.teamCurNum = curTeamMemNumTmp

						retData.withTeamCnt = retData.withTeamCnt + 1
						table.insert(retData.teamInfos, infoTmp)
					end
				elseif 2 == aroundType then 		--附近未组队的人
					if tTeamID <= 0 then
						local infoTmp = {}
						infoTmp.roleSID = roleSIDTmp
						infoTmp.sex = playerTmp:getSex()
						infoTmp.school = playerTmp:getSchool()
						infoTmp.level = playerTmp:getLevel() or 0
						infoTmp.battle = playerTmp:getbattle()
						infoTmp.name = playerTmp:getName() or ""
						infoTmp.factionName = playerTmp:getFactionName()

						retData.noTeamCnt = retData.noTeamCnt + 1
						table.insert(retData.noTeaminfos, infoTmp)
					end
				else
				end
			end
		end
	end

	if returnPB then
		fireProtoMessageBySid(roleSID,TEAM_SC_GET_AOUNDPLAYER_RET,"TeamGetArroundPlayerRetProtocol",retData)
	end
	return retData, aroundTeamIDs
end

--获取世界队伍
function TeamPublic:getSpecialTeamInfo(roleSID, teamTarget)
	if teamTarget < 0 or teamTarget>10 then return end
	local retData = {}
	retData.noTeamCnt = 0
	retData.noTeaminfos = {}
	retData.withTeamCnt = 0
	retData.teamInfos = {}
	retData.aroundType = 3

	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then return end

	local sRoleMemInfo = self:getMemInfoBySID(roleSID)
	if not sRoleMemInfo then return end

	local scene = player:getScene()
	if not scene then return end
	local teamVisible = scene:isTeamVisible()
	if teamVisible then
		local sTeamID = sRoleMemInfo:getTeamID()
		local sTeam = self:getTeam(sTeamID)
		if sTeam then
			local leaderSID = sTeam:getLeaderID()
			local playerLeader = g_entityMgr:getPlayerBySID(leaderSID)
			if playerLeader then
				local infoTmp = {}
				infoTmp.teamID = sTeam:getTeamID()
				infoTmp.leaderName = playerLeader:getName() or ""
				infoTmp.leaderFaction = playerLeader:getFactionName() or ""
				infoTmp.teamTarget = sTeam:getTargetType()
				infoTmp.teamMaxNum = TEAM_MAX_MEMBER
				infoTmp.teamCurNum = sTeam:getMemCount()

				retData.withTeamCnt = retData.withTeamCnt + 1
				table.insert(retData.teamInfos, infoTmp)
			end
		end
		fireProtoMessageBySid(roleSID,TEAM_SC_GET_AOUNDPLAYER_RET,"TeamGetArroundPlayerRetProtocol",retData)
		return
	end

	local teamBackNum = 0
	for i,v in pairs(self._AllTeam or {}) do
		if v then
			local teamActive = true
			if teamTarget > 0 then 
				if teamTarget ~= v:getTargetType() then
					teamActive = false
				end
			end

			--副本的队伍已经准备进去副本
			if v:getNeedBattle() < 0 then
				teamActive = false
			end

			if teamActive and teamBackNum < TEAM_SPE_MAX_COUNT then
				local leaderSID = v:getLeaderID()
				local playerLeader = g_entityMgr:getPlayerBySID(leaderSID)
				if playerLeader then
					local infoTmp = {}
					infoTmp.teamID = v:getTeamID()
					infoTmp.leaderName = playerLeader:getName() or ""
					infoTmp.leaderFaction = playerLeader:getFactionName() or ""
					infoTmp.teamTarget = v:getTargetType()
					infoTmp.teamMaxNum = TEAM_MAX_MEMBER
					infoTmp.teamCurNum = v:getMemCount()

					retData.withTeamCnt = retData.withTeamCnt + 1
					table.insert(retData.teamInfos, infoTmp)
					teamBackNum = teamBackNum + 1
				end
			end
		end
	end
	fireProtoMessageBySid(roleSID,TEAM_SC_GET_AOUNDPLAYER_RET,"TeamGetArroundPlayerRetProtocol",retData)
end

function TeamPublic:onGetAround(roleSID, aroundType ,aroundValue)
	local sRoleMemInfo = self:getMemInfoBySID(roleSID)
	if sRoleMemInfo then
		sRoleMemInfo:setActiveState(false)
	end

	if aroundType<1 or aroundType>3 then return end
	if 1 == aroundType or 2 == aroundType then
		self:getAroundPlayer(roleSID, aroundType, true)
	elseif 3 == aroundType then
		--获取世界队伍
		self:getSpecialTeamInfo(roleSID, aroundValue)
	end
end

--切换地图匹配队伍
function TeamPublic:onSwichMatchTeam(player)
	if not player then return end
	local roleSID = player:getSerialID()

	local sRoleMemInfo = self:getMemInfoBySID(roleSID)
	if not sRoleMemInfo then   						-- or sRoleMemInfo:getActiveState()
		local buffer = self:getTipsMsg(TEAM_TIP_MEMINFO_ERR,TEAM_CS_INVITE_TEAM,0,{})
		fireProtoMessageBySid(roleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
		return 
	end

	local sTeamID = sRoleMemInfo:getTeamID()
	if sTeamID>0 then 
		--有队伍先退出
		self:leaveTeamByInfo(player,sRoleMemInfo)
	end

	local aroundPlayerInfo,aroundTeamIDs = self:getAroundPlayer(roleSID,1,false)
	if not aroundPlayerInfo or not aroundTeamIDs then return end

	local aroundTeamCnt = aroundPlayerInfo.withTeamCnt
	if aroundTeamCnt<=0 then
		--周围没有合适的队伍就自己创建
		self:createNewTeamByInfo(player,sRoleMemInfo,1)
		return
	end

	--先查询附近有没有自动批准入队的队伍
	local autoApprovalTeamID = 0  		--自动批准入队的队伍ID
	local autoApprovalLeaderSID = 0
	local checkItems = 0 				--只随机查找10个附近的队伍
	for i,v in pairs(aroundTeamIDs or {}) do
		if checkItems > TEAM_AUTO_ENTER_MAX then break end
		local teamTmp = self:getTeam(i)
		if teamTmp then
			local leaderSID = teamTmp:getLeaderID()
			local isBlack = g_relationMgr:isBeBlack(roleID,leaderSID)
			if teamTmp:getAutoInvited() and teamTmp:getMemCount()<TEAM_MAX_MEMBER and not isBlack then
				autoApprovalTeamID = v
				autoApprovalLeaderSID = leaderSID
				break
			end
			checkItems = checkItems + 1
		end
	end

	if autoApprovalTeamID>0 then 		--and autoApprovalLeaderSID>0 
		local autoApprovalLeaderMemInfo = self:getMemInfoBySID(autoApprovalLeaderSID)
		if autoApprovalLeaderMemInfo then
			self:applyIntoOtherTeam(sRoleMemInfo,autoApprovalLeaderMemInfo)
		end
		return
	end

	--周围没有合适的队伍就自己创建
	self:createNewTeamByInfo(player,sRoleMemInfo,1)
end

--快速入队
function TeamPublic:onFastEnterTeam(player, enterParam)
	if not player then return end
	local roleID = player:getID()
	local roleSID = player:getSerialID()

	local sRoleMemInfo = self:getMemInfoBySID(roleSID)
	if not sRoleMemInfo then   						-- or sRoleMemInfo:getActiveState()
		local buffer = self:getTipsMsg(TEAM_TIP_MEMINFO_ERR,TEAM_CS_INVITE_TEAM,0,{})
		fireProtoMessageBySid(roleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
		return 
	end

	local sTeamID = sRoleMemInfo:getTeamID()
	if sTeamID>0 then 
		local buffer = self:getTipsMsg(TEAM_ERR_HAS_TEAM,TEAM_CS_CREATE_TEAM,0,{})
		fireProtoMessageBySid(roleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
		return 
	end

	local aroundPlayerInfo,aroundTeamIDs = self:getAroundPlayer(roleSID,1,false)
	if not aroundPlayerInfo or not aroundTeamIDs then return end

	local aroundTeamCnt = aroundPlayerInfo.withTeamCnt
	if aroundTeamCnt<=0 then
		local buffer = self:getTipsMsg(TEAM_TIP_NO_FAST_ENTER_TEAM,TEAM_CS_FAST_ENTER,0,{})
		fireProtoMessageBySid(roleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
		return
	end

	--先查询附近有没有自动批准入队的队伍
	local autoApprovalTeamID = 0  		--自动批准入队的队伍ID
	local autoApprovalLeaderSID = 0
	for i,v in pairs(aroundTeamIDs or {}) do
		local teamTmp = self:getTeam(i)
		if teamTmp then
			local leaderSID = teamTmp:getLeaderID()
			local isBlack = g_relationMgr:isBeBlack(roleID,leaderSID)
			if 0 == enterParam then
				if teamTmp:getAutoInvited() and teamTmp:getMemCount()<TEAM_MAX_MEMBER and not isBlack then
					autoApprovalTeamID = v
					autoApprovalLeaderSID = leaderSID
					break
				end
			else
				if teamTmp:getAutoInvited() and teamTmp:getMemCount()<TEAM_MAX_MEMBER and enterParam==teamTmp:getTargetType() and not isBlack then
					autoApprovalTeamID = v
					autoApprovalLeaderSID = leaderSID
					break
				end
			end
		end
	end

	if autoApprovalTeamID>0 then 			--and autoApprovalLeaderSID>0 
		local autoApprovalLeaderMemInfo = self:getMemInfoBySID(autoApprovalLeaderSID)
		if autoApprovalLeaderMemInfo then
			self:applyIntoOtherTeam(sRoleMemInfo,autoApprovalLeaderMemInfo)
		end
		return
	end

	--给三个队伍发送入队申请
	local applyNums = TEAM_FAST_ENTER_APPLYS
	for i,v in pairs(aroundTeamIDs or {}) do
		local teamTmp = self:getTeam(i)
		if teamTmp then
			local leaderSID = teamTmp:getLeaderID()
			local isBlack = g_relationMgr:isBeBlack(roleID,leaderSID)
			if not teamTmp:getAutoInvited() and teamTmp:getMemCount()<TEAM_MAX_MEMBER and not isBlack then				
				if applyNums>0 then
					local leaderMemInfo = self:getMemInfoBySID(leaderSID)
					if leaderMemInfo then
						self:applyIntoOtherTeam(sRoleMemInfo,leaderMemInfo)
						applyNums = applyNums - 1
					end
				else
					break
				end
			end
		end
	end

	if applyNums == TEAM_FAST_ENTER_APPLYS then
		local buffer = self:getTipsMsg(TEAM_TIP_NO_FAST_ENTER_TEAM,TEAM_CS_FAST_ENTER,0,{})
		fireProtoMessageBySid(roleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
	end
end

function TeamPublic:onFastRecruitMem(player)
	if not player then return end
	local roleSID = player:getSerialID()
	local roleID = player:getID()

	local sRoleMemInfo = self:getMemInfoBySID(roleSID)
	if not sRoleMemInfo then   						-- or sRoleMemInfo:getActiveState()
		local buffer = self:getTipsMsg(TEAM_TIP_MEMINFO_ERR,TEAM_CS_INVITE_TEAM,0,{})
		fireProtoMessageBySid(roleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
		return 
	end

	local sTeamID = sRoleMemInfo:getTeamID()
	if sTeamID<=0 then
		local buffer = self:getTipsMsg(TEAM_ERR_NOT_IN_TEAM,TEAM_CS_CHANGE_LEADER,0,{})		
		fireProtoMessageBySid(roleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
		return
	end

	local sTeam = self:getTeam(sTeamID)
	if not sTeam then return end
	local curMem = sTeam:getMemCount()
	if curMem>=TEAM_MAX_MEMBER then
		local buffer = self:getTipsMsg(TEAM_ERR_MAX_MEMBER,TEAM_CS_FAST_RECRUIT,0,{})
		fireProtoMessageBySid(roleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
		return
	end

	local aroundPlayerInfo,aroundTeamIDs = self:getAroundPlayer(roleSID,2,false)
	if not aroundPlayerInfo or not aroundTeamIDs then return end

	--附近没有未组队的玩家
	if aroundPlayerInfo.noTeamCnt<=0 then
		local buffer = self:getTipsMsg(TEAM_TIP_NO_FREE_MEMBER,TEAM_CS_FAST_RECRUIT,0,{})
		fireProtoMessageBySid(roleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
		return
	end

	--给5个未组队的玩家发送邀请
	local inviteNums = TEAM_FAST_RECRUIT_INVITES
	for i,v in pairs(aroundPlayerInfo.noTeaminfos) do
		if v.roleId then
			local playerTmp = g_entityMgr:getPlayer(v.roleId)
			if playerTmp then
				--判断等级
				if playerTmp:getLevel()>=g_teamMgr._TeamFunAllow then
					local roleSIDTmp = playerTmp:getSerialID()
					local sRoleMemInfoTmp = self:getMemInfoBySID(roleSIDTmp)
					if sRoleMemInfoTmp then
						if sRoleMemInfoTmp:getAutoInvited() then
							--允许组队 但 手动同意
							if inviteNums>0 then
								self:inviteIntoMyTeam(sRoleMemInfo,sRoleMemInfoTmp)
								inviteNums = inviteNums - 1
							else
								break
							end
						end
					end
				end
			end
		end
	end

	if inviteNums == TEAM_FAST_RECRUIT_INVITES then
		local buffer = self:getTipsMsg(TEAM_TIP_NO_FREE_MEMBER,TEAM_CS_FAST_RECRUIT,0,{})
		fireProtoMessageBySid(roleSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
	end
end

function TeamPublic:getTipsMsg(errID,eventID,paramCount,params)
	local ret = {}
	local paramlist = {}
	ret.eventId = EVENT_TEAM_SETS
	ret.eCode = errID
	ret.mesId = eventID
	for i=1, paramCount do
		table.insert(paramlist,params[i])
	end
	ret.param = paramlist
	return ret
	--g_engine:fireLuaEvent(roleId, retBuff)
end

function TeamPublic:SendToTeamMem(TeamID,buffer)
	if TeamID>0 then
		local team = self:getTeam(TeamID)
		if team then
			local allMem = team:getOnLineMems()
			fireProtoMessageToGroup(allMem, CHAT_SC_RECEIVEMSG,"ReceiveMsgProtocol",buffer)
			--g_frame:sendMsgToPeerGroupBySid(allMem, buffer)
		end
	end
end

function TeamPublic:update()
	for idx, v in pairs(self._AllTeam) do
		if v then
			local applyInfo = v:getApplyInfo()
			for i, apply in pairs(applyInfo) do
				if os.time() - apply.time > TEAM_MAX_APPLY_SAVE_TIME then
					--self:onAnswerApply(apply.leaderID, apply.roleSID, false)		--过期的申请不在处理
					table.remove(applyInfo, i)
				end
				
				local tmpplayer = g_entityMgr:getPlayerBySID(apply.roleSID)
				if not tmpplayer then
					v:removeApplyID(apply.roleSID)
					print("TeamPublic:update() remove offline player")
				end
				
				if table.size(applyInfo) == 0 then
					local retBuff = {}
					retBuff.teamId = v:getTeamID()
					retBuff.isNull = true
					fireProtoMessageBySid(v:getLeaderID(), TEAM_SC_TEAM_APPLY_ISNULL, 'TeamApplyIsNullProtocol', retBuff)
				end
			end
		end
	end
end

function TeamPublic:isTeamLeader(sRoleSID)
	local leaderSID = 0
	local sTeamID = 0
	local isLeader = false
	local sRoleMemInfo = self:getMemInfoBySID(sRoleSID)
	if sRoleMemInfo then
	    sTeamID = sRoleMemInfo:getTeamID()
	    if sTeamID>0 then
	      	local teamTmp = self:getTeam(sTeamID)
		    if teamTmp then
		    	leaderSID = teamTmp:getLeaderID()
		    	if sRoleSID == leaderSID then
		    		isLeader = true
		    	end
		    end
	    end
	end
	return isLeader,sTeamID,leaderSID
end

function TeamPublic:getTeamAllMemBySID(roleSID)
	local allMemSID = {}
	local sRoleMemInfo = self:getMemInfoBySID(roleSID)
	if not sRoleMemInfo then return 0,allMemSID end

	local teamID = sRoleMemInfo:getTeamID()
	local team = g_TeamPublic:getTeam(teamID)
	if not team then return 0,allMemSID end

	allMemSID = team:getAllMember()
	return teamID, allMemSID
end

function TeamPublic:getTeamAllMemByTeamID(teamID)
	if teamID>0 then
		local team = self:getTeam(teamID)
		if team then
			return team:getAllMember()
		end
	end
	return {}
end

function TeamPublic:getTeamOnlineMemByTeamID(teamID)
	if teamID>0 then
		local team = self:getTeam(teamID)
		if team then
			return team:getOnLineMems()
		end
	end
	return {}
end

function TeamPublic.getTeamAllMemList(roleSID)
	local allMemSID = {}
	if g_TeamPublic then
		local teamID, allMemList = g_TeamPublic:getTeamAllMemBySID(roleSID)
		allMemSID = allMemList
	end
	return allMemSID
end

function TeamPublic.getTeamOnlineMemList(teamID)
	if g_TeamPublic then
		return g_TeamPublic:getTeamOnlineMemByTeamID(teamID)
	end
	return {}
end

function TeamPublic.getTeamAllMem(teamID)
	if g_TeamPublic then
		return g_TeamPublic:getTeamAllMemByTeamID(teamID)
	end
	return {}
end

--增加熟人
function TeamPublic:addIntimateRole(sRoleSID,tRoleSID)
	local player = g_entityMgr:getPlayerBySID(sRoleSID)
	if player then
		local sRoleID = player:getID()
		g_relationMgr:addMeet(sRoleID, tRoleSID) --第一个是玩家动态ID，第二个是熟人静态ID
	end

	local tplayer = g_entityMgr:getPlayerBySID(tRoleSID)
	if tplayer then
		local tRoleID = tplayer:getID()
		g_relationMgr:addMeet(tRoleID, sRoleSID) --第一个是玩家动态ID，第二个是熟人静态ID
	end
end

--强制角色列表 自动组队
function TeamPublic:createTeamBySIDList(roleSIDList)
	if #roleSIDList == 0 then
		return
	end

	local creatNewTeam = false
	local newTeamID = 0
	local SIDNum = 0
	for i,v in pairs(roleSIDList or {}) do
		SIDNum = SIDNum + 1
		local playerTmp = g_entityMgr:getPlayerBySID(v)
		if not playerTmp then return newTeamID end

		if playerTmp:getLevel() < g_teamMgr._TeamFunAllow then
			local buffer = self:getTipsMsg(TEAM_TIP_INTO_LEVEL_NOTENOUGH,TEAM_CS_INVITE_TEAM,1,{g_teamMgr._TeamFunAllow})
			fireProtoMessageBySid(v, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
			return newTeamID
		end
		
		local memInfoTmp = self:getMemInfoBySID(v)
		if not memInfoTmp then return newTeamID end
	end

	if SIDNum > TEAM_MAX_MEMBER then
		return newTeamID
	end

	for i=1,SIDNum do
		local roleSIDTmp = roleSIDList[i]
		local memInfoTmp = self:getMemInfoBySID(roleSIDTmp)
		if memInfoTmp then
			local teamIDTemp = memInfoTmp:getTeamID()
			if teamIDTemp > 0 then
				local playerTmp = g_entityMgr:getPlayerBySID(roleSIDTmp)
				self:leaveTeamByInfo(playerTmp,memInfoTmp)
			end
		end
	end

	local leaderSID = roleSIDList[1]
	local leadPlayer = g_entityMgr:getPlayerBySID(leaderSID)
	if leadPlayer then
		self:onCreateTeam(leadPlayer)
		local leaderMemInfo = self:getMemInfoBySID(leaderSID)
		if leaderMemInfo then
			newTeamID = leaderMemInfo:getTeamID()
			for i=2,SIDNum do
				local roleSIDTmp = roleSIDList[i]
				self:addMemIntoTeam(leaderSID,roleSIDTmp,leaderSID)
			end
		end
	end
	return newTeamID
end

function TeamPublic:leaveTeamBySIDList(roleSIDList)
	for i,v in pairs(roleSIDList or {}) do
		local memInfoTmp = self:getMemInfoBySID(v)
		if memInfoTmp then
			local teamIDTemp = memInfoTmp:getTeamID()
			if teamIDTemp > 0 then
				local playerTmp = g_entityMgr:getPlayerBySID(v)
				self:leaveTeamByInfo(playerTmp,memInfoTmp)
			end
		end
	end
end

--自动解散队伍
function TeamPublic:dismissTeamByTeamID(teamID)
	if teamID > 0 then
		local team = self:getTeam(teamID)
		if not team then return end
		local leaderSID = team:getLeaderID()
		local allMemSID = team:getAllMember()
		local curMemCnt = team:getMemCount()

		for i=1,curMemCnt do
			local roleSIDTmp = allMemSID[i]
			if leaderSID ~= roleSIDTmp then
				local memInfoTmp = self:getMemInfoBySID(roleSIDTmp)
				if memInfoTmp then
					local teamIDTemp = memInfoTmp:getTeamID()
					if teamIDTemp > 0 then
						local playerTmp = g_entityMgr:getPlayerBySID(roleSIDTmp)
						self:leaveTeamByInfo(playerTmp,memInfoTmp)
					end
				end
			end
		end

		local memInfoTmp = self:getMemInfoBySID(leaderSID)
		if memInfoTmp then
			local teamIDTemp = memInfoTmp:getTeamID()
			if teamIDTemp > 0 then
				local playerTmp = g_entityMgr:getPlayerBySID(leaderSID)
				self:leaveTeamByInfo(playerTmp,memInfoTmp)
			end
		end
	end
end

--强制将角色加入某个队伍
function TeamPublic:memJoinTeamBySID(teamID, roleSID)
	local joinRet = false
	if teamID <=0 then return joinRet end

	local playerTmp = g_entityMgr:getPlayerBySID(roleSID)
	if not playerTmp then return joinRet end

	if playerTmp:getLevel() < g_teamMgr._TeamFunAllow then
		local buffer = self:getTipsMsg(TEAM_TIP_INTO_LEVEL_NOTENOUGH,TEAM_CS_INVITE_TEAM,1,{g_teamMgr._TeamFunAllow})
		fireProtoMessageBySid(v, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
		return joinRet
	end

	local teamTmp = self:getTeam(teamID)
	if not teamTmp then return joinRet end
	if teamTmp:getMemCount() >= TEAM_MAX_MEMBER then
		--返回队伍人数已满提示			
		--local buffer6 = self:getTipsMsg(TEAM_ERR_MAX_MEMBER,TEAM_CS_INVITE_TEAM,0,{})		
		--fireProtoMessageBySid(activeSID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer6)
		return joinRet
	end
	local leaderSID = teamTmp:getLeaderID()

	local memInfoTmp = self:getMemInfoBySID(roleSID)
	if not memInfoTmp then return joinRet end
	local teamIDTemp = memInfoTmp:getTeamID()
	if teamIDTemp > 0 then
		self:leaveTeamByInfo(playerTmp,memInfoTmp)
	end

	joinRet = self:addMemIntoTeam(leaderSID,roleSID,leaderSID)
	return joinRet
end

--speType==1 获取在线好友    speType==2 获取在线行会成员
function TeamPublic:onGetSpecialRoleInfo(player, speType)
	if speType < 1 or speType > 2 then return end
	if not player then return end
	local roleSID = player:getSerialID()
	local roleID = player:getID()
 
	local sRoleMemInfo = self:getMemInfoBySID(roleSID)
	if not sRoleMemInfo then return end

	local retData = {}
	retData.speType = speType
	retData.speInfo = {}
	if 1 == speType then
		local roleInfo = g_relationMgr:getRoleRelationInfo(roleID)
		if not roleInfo then return end
		roleInfo:freshRelationData(RelationKind.Friend)

		for _,v in pairs(roleInfo._friends or {}) do
			local playerTmp = g_entityMgr:getPlayerBySID(v.roleSid)
			if playerTmp then
				local memInfoTmp = self:getMemInfoBySID(v.roleSid)
				if memInfoTmp then
					local teamIDTmp = memInfoTmp:getTeamID()
					--if teamIDTmp <= 0 then
						local speRoleInfoTmp = {}
						speRoleInfoTmp.roleSID = v.roleSid
						speRoleInfoTmp.sex = v.sex
						speRoleInfoTmp.school = v.school
						speRoleInfoTmp.level = v.level
						speRoleInfoTmp.battle = v.fightAbility
						speRoleInfoTmp.name = v.name
						speRoleInfoTmp.factionName = playerTmp:getFactionName()
						speRoleInfoTmp.teamID = teamIDTmp
						table.insert(retData.speInfo, speRoleInfoTmp)
					--end
				end
			end
		end
	elseif 2 == speType then
		local factionID = player:getFactionID()
		local faction = g_factionMgr:getFaction(factionID)
		if faction then
			local allMember = faction:getAllMembers()
			for memSID, member in pairs(allMember or {}) do
				if roleSID ~= memSID then 			--自己不显示在列表中
					local playerTmp = g_entityMgr:getPlayerBySID(memSID)
					if playerTmp then
						local memInfoTmp = self:getMemInfoBySID(memSID)
						if memInfoTmp then
							local teamIDTmp = memInfoTmp:getTeamID()
							--if teamIDTmp <= 0 then
								local speRoleInfoTmp = {}
								speRoleInfoTmp.roleSID = memSID
								speRoleInfoTmp.sex = playerTmp:getSex()
								speRoleInfoTmp.school = member:getSchool()
								speRoleInfoTmp.level = playerTmp:getLevel()
								speRoleInfoTmp.battle = member:getAbility()
								speRoleInfoTmp.name = member:getName()
								speRoleInfoTmp.factionName = playerTmp:getFactionName()
								speRoleInfoTmp.teamID = teamIDTmp
								table.insert(retData.speInfo, speRoleInfoTmp)
							--end
						end
		    		end
				end
			end
		end
	else
	end
print("TeamPublic:onGetSpecialRoleInfo 01", roleSID, toString(retData))
	fireProtoMessageBySid(roleSID, TEAM_SC_GET_SPE_ROLE_RET, 'TeamGetSpeRoleRet', retData)
end

function TeamPublic:onGetTeamMemHP(roleSID)
	local memInfoTmp = self:getMemInfoBySID(roleSID)
	if not memInfoTmp then return end

	local teamIDTemp = memInfoTmp:getTeamID()
	if teamIDTemp <= 0 then return end

	local teamTmp = self:getTeam(teamIDTemp)
	if not teamTmp then return end

	local retBuff = {}
	retBuff.teamID = teamIDTemp
	retBuff.infoType = 2
	retBuff.infoData = 0
	retBuff.memHP = {}

	local allMemSID = teamTmp:getAllMember()
	for i,v in pairs(allMemSID or {}) do
		local playerTmp = g_entityMgr:getPlayerBySID(v)
		if playerTmp then
			local HPPecent = playerTmp:getHP()/playerTmp:getMaxHP()*100
			if HPPecent > 100 then HPPecent = 100 end
			local memHPTmp = {}
			memHPTmp.roleSID = v
			memHPTmp.curHP = HPPecent
			table.insert(retBuff.memHP,memHPTmp)
		end
	end
	fireProtoMessageBySid(roleSID, TEAM_SC_NOTICE_TEAMINFO, 'TeamNoticeInfo', retBuff)
end

function TeamPublic:memHPRefresh(roleSID, option)
	self:onGetTeamMemHP(roleSID)
end

--玩家回到上一张地图的位置
function TeamPublic:sendPlayerToLastPos(player)
	if not player then return end

	local scene = player:getScene()
	if not scene then return end
	local teamVisible = scene:isTeamVisible()
	if teamVisible then
		local lastMapID = player:getLastMapID()
		local lastPosX = player:getLastPosX()
		local lastPosY = player:getLastPosY()

		if lastMapID and lastPosX and lastPosY then	
			--if g_entityMgr:canSendto(player:getID(), lastMapID, lastPosX, lastPosY) then
				g_sceneMgr:enterPublicScene(player:getID(), lastMapID, lastPosX, lastPosY)
			--end
		end
	end
end

--关闭功能时 解散所有队伍
function TeamPublic:DismissAllTeam()
	for i,v in pairs(self._AllTeam or {}) do
		if v then
			local allRoleSID = v:getAllMember()
			local paramTmp7 = {}
			for m,n in pairs(allRoleSID or {})do
				local memInfoTmp = self:getMemInfoBySID(n)
				if memInfoTmp then
					memInfoTmp:setTeamID(0)
				end

				local retBuff = {}
				retBuff.hasTeam = false
				fireProtoMessageBySid(n, TEAM_SC_GET_TEAMINFO_RET, 'TeamGetTeamInfoRetProtocol', retBuff)

				self:playerSetTeamIDAndNum(n,0,0)				
			end
		end		
	end
end

function TeamPublic.getInstance()
	return TeamPublic()
end

g_TeamPublic = TeamPublic.getInstance()