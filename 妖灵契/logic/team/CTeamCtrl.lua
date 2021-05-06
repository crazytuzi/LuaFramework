local CTeamCtrl = class("CTeamCtrl", CCtrlBase)

CTeamCtrl.TARGET_NONE = 0       --特殊任务id
CTeamCtrl.TARGET_MING_LEI = 1101     --明雷 任务id

CTeamCtrl.TARGET_AN_LEI = 1110    	 --暗雷 探索
CTeamCtrl.TARGET_AN_LEI_NPC = 1111    	 --暗雷 稀有怪 任务id
CTeamCtrl.TARGET_AN_LEI_BOX = 1112    	 --暗雷 宝箱怪 任务id(宝箱怪有冷却时间)
CTeamCtrl.TARGET_DAILY_TRAIN = 1201		 -- 每日训练 任务吴彪

CTeamCtrl.MEMBER_SIZE_MAX = 4	--组队上限人数
CTeamCtrl.FAST_TALK_TIME = 60   --一键喊话时间间隔
CTeamCtrl.INVITE_PLAYER_REFRESH_TIME = 10   --邀请玩家刷新间隔
CTeamCtrl.AUTO_TEAM_REFRESH_TIME = 10   --刷新自动组队目标队伍时间间隔
CTeamCtrl.LEADER_UNACTIVE_TIME_MAX = 90   --刷新自动组队目标队伍时间间隔
CTeamCtrl.LEADER_UNACTIVE_CHECK_TIME = 5  --刷新自动组队目标队伍检测时间间隔


CTeamCtrl.EnumInvitePlayer = 
{
	Friend = 1,
	Org = 2,
	Match = 3,
}

CTeamCtrl.EnumLeaderActiveState = 
{
	Sleep = 1,
	Awake = 2,
}

function CTeamCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self:InitValue()
end

function CTeamCtrl.InitValue(self)
	self.m_TeamID = nil
	self.m_LeaderID = nil
	self.m_Members = {}
	self.m_PosList = {}
	self.m_Partners = {} --队长的伙伴
	self.m_MembersPartners = {} --所有队员的伙伴

	self.m_Applys = {}
	self.m_RefApplys = {}
	self.m_UnreadApply = {}
	self.m_Invites = {}
	self.m_RefInvites = {}
	self.m_UnreadInvite = {}

	--便捷组队相关
	self.m_TargetTeams = {}
	self.m_IsTeamMatch = false
	self.m_TeamTargetInfo = {} -- 组队的自动匹配信息
	self.m_IsPlayerMatch = false
	self.m_PlayerTargetInfo = {} -- 玩家非组队匹配信息
	self.m_CountAutoMatch = {}

	self.m_TargetCountTable = {}	--该目标的组队次数(明雷等玩法的次数)

	--组队设置
	self.m_TeamSet = nil
	-- {
	-- 	AutoChatScreen = false,
	-- 	AutoAgreedFriendApply = false,
	-- 	AutoReInvite = false,
	-- }

	--队长活跃检测
	self.m_LeaderActiveStatus = 1 --1：活跃 0：不活跃
	if self.m_AutoCheckLeaderActiveTimer ~= nil then  --定时检测队长是否在活跃状态
		Utils.DelTimer(self.m_AutoCheckLeaderActiveTimer) 
		self.m_AutoCheckLeaderActiveTimer = nil
	end	
	self.m_LeaderPos = nil
	self.m_IsLeaderTouchUI = false
	self.m_LeaderUnActiveElapseTimer = 0 	 --队长不活跃时间

	--定时间隔检测时间戳
	self.m_FastTalkTimer = 0		     --一键喊话时间
	self.m_InviteRefreshTimer = 0        --邀请玩家刷新时间
	self.m_AutoTeamRefreshTimer = 0 	 --自动组队队伍刷新时间 

	--可邀请的好友列表
	self.m_CanInviteFrdList = {}
	self.m_CanInviteMatchList = {}
end

--创建队伍
function CTeamCtrl.AddTeam(self, iTeamID, iLeader, lMember, tTargetInfo)
	self.m_TeamID = iTeamID
	self.m_LeaderID = iLeader
	self.m_LeaderActiveStatus = 1
	self.m_Members = {}
	self.m_PosList = {}
	self.m_Partners = {}
	self.m_MembersPartners = {}
	for i, v in ipairs(lMember) do
		local dMember = self:CopyProtoMember(v)
		self.m_Members[dMember.pid] = dMember
		table.insert(self.m_PosList, dMember.pid)
		--缓存的伙伴	
		local partner = {}

		if dMember.partner_list ~= nil then
			for _i, _v in pairs (dMember.partner_list) do
				if i == 1 then
					self.m_Partners[_v.pos] = _v				
				end
				partner[_v.pos] = _v							
			end						
		end

		self.m_MembersPartners[dMember.pid] = partner
	end

	printc(" 打印组队成功时， 成员和伙伴信息")
	table.print(self.m_Members)
	table.print(self.m_Partners)
	table.print(self.m_MembersPartners)


	--队伍人数不满4个，用 id = 0 补齐
	if #self.m_PosList < CTeamCtrl.MEMBER_SIZE_MAX then
		for i = #self.m_PosList + 1, CTeamCtrl.MEMBER_SIZE_MAX do
			table.insert(self.m_PosList, 0)
		end
	end

	self:SetTeamTargetInfo(tTargetInfo)

	self:OnEvent(define.Team.Event.AddTeam)
	
	self:ClearInvite()
	g_ChatCtrl:SetSendLimitMsg("team", false)

	--开始检测队长的活跃状态
	self:StartCheckLeaderActive()

	self:SetPlayerTargetInfo()     --清空玩家匹配信息
	self:OpenTeamBulletScreen()     --打开队伍弹幕
	g_FriendCtrl:UpdateTeamerFriend()  --好友模块的最近队友
	g_DialogueCtrl:UpdateTeam()
end

function CTeamCtrl.DelTeam(self)
	self.m_TeamID = nil
	self.m_LeaderID = nil
	self.m_LeaderActiveStatus = 1
	self.m_Members = {}
	self.m_PosList = {}
	self.m_Partners = {}
	self.m_MembersPartners = {}
	self:OnEvent(define.Team.Event.DelTeam)
	
	g_ActivityCtrl:UpdateDTStatus()

	self:ClearApply()
	g_ChatCtrl:SetSendLimitMsg("team", true)
	
	--清空组队匹配信息
	self:SetTeamTargetInfo()

	--停止检测队长的活跃状态
	self:StopCheckLeaderActive()
	--关闭队伍弹幕
	self:CloseTeamBulletScreen()
	g_GuideCtrl:TriggerAll()
end

function CTeamCtrl.UpdateTeamStatus(self, lStatus, lPosInfo)
	local lPidPos = {0, 0, 0, 0}
	local delList = table.keys(self.m_Members)
	for i, v in ipairs(lPosInfo) do
		if v.pos == 1 then
			self.m_LeaderID = v.pid
			if self.m_MembersPartners[v.pid] then
				self.m_Partners = {}
				if self.m_MembersPartners[v.pid] then
					for k, v in pairs(self.m_MembersPartners[v.pid]) do
						self.m_Partners[v.pos] = v
					end
				end
			end
		end
		lPidPos[v.pos] = v.pid
		local delindex = table.index(delList, v.pid)
		if delindex then
			table.remove(delList, delindex)
		end		
		self:DelApply(v.pid)
	end
	
	for _, delpid in ipairs(delList) do
		self.m_Members[delpid] = nil
		self.m_MembersPartners[delpid] = nil
	end
	
	for i, v in ipairs(lStatus) do
		local dMember = self.m_Members[v.pid]
		if dMember and v.status ~= dMember.status then
			dMember.status = v.status
		end		
	end
	printc(" 打印组队成员和伙伴信息")
	table.print(lPidPos)
	table.print(self.m_Partners)
	table.print(self.m_MembersPartners)


	self.m_PosList = lPidPos
	self:OnEvent(define.Team.Event.AddTeam)
	g_FriendCtrl:UpdateTeamerFriend()
	g_DialogueCtrl:UpdateTeam()
	g_ActivityCtrl:UpdateDTStatus()

	--队伍状态发生变化，重新检测队长活跃状态
	self:StartCheckLeaderActive()
end

function CTeamCtrl.UpdateMember(self, dPb)
	local dMember = self:CopyProtoMember(dPb)
	if dMember then
		self.m_Members[dMember.pid] = dMember
		self.m_MembersPartners[dMember.pid] = dMember.partner_list
		self:OnEvent(define.Team.Event.MemberUpdate, dMember)
		g_FriendCtrl:UpdateTeamerFriend()
		g_DialogueCtrl:UpdateTeam()
		g_ActivityCtrl:UpdateDTStatus()
	end
end

function CTeamCtrl.UpdateMemberAttr(self, iPid, dStatusInfo)
	local dMember = self.m_Members[iPid]
	if dMember then
		for k,v in pairs(dStatusInfo) do
			dMember[k] = v
		end
		self.m_Members[iPid] = dMember
		self:OnEvent(define.Team.Event.MemberUpdate, dMember)
		g_FriendCtrl:UpdateTeamerFriend()
	end
end

function CTeamCtrl.UpdatePartnerAttr(self, pid, dPartner)
	printc( "UpdatePartnerAttr",self.m_LeaderID, pid, self:IsLeader(pid))
	table.print(dPartner)
	local parid = dPartner.parid
	local pos = dPartner.pos
	local dMember = self:GetMember(pid)
	local isLeader = self:IsLeader(pid)
		
	--下阵
	if parid == 0 or nil then	
		--更新队伍出战伙伴
		if self.m_MembersPartners[pid] and self.m_MembersPartners[pid][pos] then
			self.m_MembersPartners[pid][pos] = nil
		end

		--更新队长出战伙伴
		if isLeader then
			printc("队长伙伴下阵")	
			if self.m_Partners[pos] then
				self.m_Partners[pos] = nil
			end			
		else
			printc("队员伙伴下阵")	
		end
		
	else
		local oPartner = nil
		if self.m_MembersPartners[pid] then
			oPartner = self.m_MembersPartners[pid][pos]
		end
		printc(" leder pid ", pid)
		table.print(self.m_MembersPartners)


		--上阵(原来位置的伙伴信息为空时)
		if oPartner == nil then
			--更新队伍出战伙伴
			if self.m_MembersPartners[pid] then
				self.m_MembersPartners[pid][pos] = dPartner				
			end

			--更新队长出战伙伴
			if isLeader then
				printc("队长伙伴上阵")
				self.m_Partners[pos] = dPartner
			else
				printc("队员伙伴上阵")
			end			

		--交换(原来位置上有伙伴，但是不是同一个)
		elseif oPartner.parid ~= parid then
			--更新队伍出战伙伴
			if self.m_MembersPartners[pid] then
				self.m_MembersPartners[pid][pos] = dPartner
			end

			--更新队长出战伙伴
			if isLeader then
				printc("队长伙伴交换")
				self.m_Partners[pos] = dPartner
			else
				printc("队员伙伴交换")
			end					

		else
			--更新队伍出战伙伴
			if self.m_MembersPartners[pid] then
				self.m_MembersPartners[pid][pos] = self:CopyProtoPartner(oPartner, dPartner)
			end

			--更新队长出战伙伴
			if isLeader then
				printc("队长伙伴信息同步")
				self.m_Partners[pos] = self:CopyProtoPartner(oPartner, dPartner)
			else
				printc("队员伙伴信息同步")
			end
		end
	end
	--同步主战伙伴信息
	if self.m_MembersPartners[pid] then
		dMember.partner_info = self.m_MembersPartners[pid][define.Partner.Pos.Main]	
	end
	local teamPos = 1
	if isLeader then
		teamPos = pos or 1
	else
		teamPos = self:GetMemberPosById(pid)
	end
	self:OnEvent(define.Team.Event.PartnerUpdate, teamPos)
end

function CTeamCtrl.CopyProtoMember(self, dPb)
    local tInfo = dPb.status_info
    local pMianPartnerInfo = nil
    for k, v in pairs(dPb.partner_info) do
    	if v.pos == define.Partner.Pos.Main then
    		pMianPartnerInfo = v
    	end
    end
	local d = {
		pid = dPb.pid,		
		name = tInfo.name,
		model_info = tInfo.model_info,
		school = tInfo.school,
		school_branch = tInfo.school_branch,
		grade = tInfo.grade,
		hp = tInfo.hp,
		max_hp = tInfo.max_hp,
		partner_info = pMianPartnerInfo,	--主战宠物
		partner_list = dPb.partner_info,	--出战伙伴列表
		status = tInfo.status,
		bcmd = tInfo.bcmd,
	}
	return d
end

function CTeamCtrl.CopyLocalPartner(self, dPart)
	local d = nil
	if dPart ~= nil then
		d = {
			parid = dPart:GetValue("parid"),
			grade = dPart:GetValue("grade"),
			model_info = dPart:GetValue("model_info"),
			name = dPart:GetValue("name"),
		}
	end
	table.print(d)
	return d
end

function CTeamCtrl.CopyProtoPartner(self, oPart, tPart)
		table.print(oPart)
		table.print(tPart)	
	if tPart ~= nil then
		printc("CopyProtoPartner..")
		oPart.parid = tPart.parid or oPart.parid
		oPart.grade = tPart.grade or oPart.grade
		oPart.model_info = tPart.model_info or oPart.model_info
		oPart.name = tPart.name or oPart.name	
		oPart.pos = tPart.pos or oPart.pos

		table.print(oPart)
	end
	return oPart
end

function CTeamCtrl.GetMember(self, pid)
	return self.m_Members[pid]
end

function CTeamCtrl.GetMemberSize(self)
	local size = 0
	for i = 1, #self.m_PosList do
		if self.m_PosList[i] ~= 0 then
			size = size + 1
		end
	end
	return size
end

--获取队员(没有空位)
function CTeamCtrl.GetMemberList(self)
	local list = {}
	for i, pid in ipairs(self.m_PosList) do
		if pid ~= 0 then
			table.insert(list, self.m_Members[pid])
		end		
	end
	return list
end

--获取队员(带空位)
function CTeamCtrl.GetPosMemberList(self)
	local list = {}
	for i = 1, CTeamCtrl.MEMBER_SIZE_MAX do
		local pid = self.m_PosList[i]
		if pid ~= nil and pid ~= 0 then
			list[i] = self.m_Members[pid]
		end
	end
	return list
end

function CTeamCtrl.GetMemberPosById(self, id)
	local p = nil
	for pos, memberId in ipairs(self.m_PosList) do
 		if id == memberId then
 			p = pos 
 			break
 		end
	end 
	return p
end

--根据位置队员和出战伙伴
function CTeamCtrl.GetMemberByPos(self, pos)
	local member = nil
	if self:IsJoinTeam() then
		if self.m_PosList[pos] ~= nil and self.m_PosList[pos] ~= 0 then
			member = self.m_Members[self.m_PosList[pos]]
		end
	else
		if pos == define.Partner.Pos.Main then
			--主战伙伴信息
			local d =  g_PartnerCtrl:GetPartnerByFightPos(define.Partner.Pos.Main)
			local info = self:CopyLocalPartner(d)
			--玩家自己
			member = {
				pid = g_AttrCtrl.pid,
				name = g_AttrCtrl.name,
				model_info = g_AttrCtrl.model_info,
				school = g_AttrCtrl.school,
				school_branch = g_AttrCtrl.school_branch,
				grade = g_AttrCtrl.grade,
				status = 0,
				--主战伙伴信息			
				partner_info = info
			}
		end	
	end
	return member
end

--根据位置获取队伍出战伙伴
function CTeamCtrl.GetPartnerByPos(self, pos)
	table.print(self.m_Partners)
	local partner = nil
	if self:IsJoinTeam() then
		partner = self.m_Partners[pos]
	else		
		local d =  g_PartnerCtrl:GetPartnerByFightPos(pos)
		partner = self:CopyLocalPartner(d)
	end
	return partner
end

--根据parid获取队伍出战伙伴
function CTeamCtrl.GetPartnerById(self, parid)
	local partner = nil
	if self:IsJoinTeam() then
		for k, v in pairs() do
			if v.parid == parid then
				partner = self.m_Partners[pos]
				break
			end
		end
	else		
		if parid ~= nil then
			local d =  g_PartnerCtrl:GetPartner(parid)
			partner = self:CopyLocalPartner(d)
		end		
	end
	return partner
end

--获取所有队员和出战伙伴
function CTeamCtrl.GetMamberAndPartnerList(self)
	local list = {}
	list.Member = {}
	list.Partner = {}
	if self:IsJoinTeam() then
		list.Member = self:GetPosMemberList()
		--队长出战的伙伴
		list.Partner = self.m_Partners
	else
		--主战伙伴信息
		local d =  g_PartnerCtrl:GetPartnerByFightPos(define.Partner.Pos.Main)
		local info = self:CopyLocalPartner(d)
		--玩家自己
		local dHero = {
			pid = g_AttrCtrl.pid,
			name = g_AttrCtrl.name,
			model_info = g_AttrCtrl.model_info,
			school = g_AttrCtrl.school,
			school_branch = g_AttrCtrl.school_branch,
			grade = g_AttrCtrl.grade,
			status = 0,
			--主战伙伴信息			
			partner_info = info
		}
		table.insert(list.Member, dHero)
		--自己出战的伙伴
		for _, pos in pairs(define.Partner.Pos) do
			local t = g_PartnerCtrl:GetPartnerByFightPos(pos)
			list.Partner[pos] = self:CopyLocalPartner(t)
		end
	end
	return list
end

--判断是否有队员离队
function CTeamCtrl.HasMemberLeave(self)
	for pid,v in pairs(self.m_Members) do
		if self:IsLeave(pid) then
			return true
		end
	end
	return false
end

function CTeamCtrl.HasMemberOffline(self)
	for pid,v in pairs(self.m_Members) do
		if self:IsOffline(pid) then
			return true
		end
	end
	return false
end

function CTeamCtrl.GetMemberByGrade(self, iMin, iMax)
	local lMember = {}
	iMin = iMin or 0
	iMax = iMax or 999999
	for pid,v in pairs(self.m_Members) do
		if v.grade >= iMin and v.grade <= iMax then
			table.insert(lMember, v)
		end
	end
	return lMember
end

--状态判断 start
function CTeamCtrl.IsJoinTeam(self)
	return self.m_TeamID ~= nil 
end

function CTeamCtrl.IsLeader(self, pid)
	pid = pid or g_AttrCtrl.pid
	return pid == self.m_LeaderID
end

function CTeamCtrl.IsCommander(self, pid)
	if self:IsInTeam(pid) then
		local dMember = self.m_Members[pid]
		return self:IsLeader(pid) or (dMember and dMember.bcmd == 1)
	else
		return true
	end
end

function CTeamCtrl.IsStatus(self, pid, cmpStatus)
	pid = pid or g_AttrCtrl.pid
	local dMember = self.m_Members[pid]
	if dMember then
		return dMember.status == cmpStatus
	else
		return false
	end
end

function CTeamCtrl.IsLeave(self, pid)
	return self:IsStatus(pid, define.Team.MemberStatus.Leave)
end

function CTeamCtrl.IsOffline(self, pid)
	return self:IsStatus(pid, define.Team.MemberStatus.Offline)
end

function CTeamCtrl.IsInTeam(self, pid)
	return self:IsStatus(pid, define.Team.MemberStatus.Normal)
end

function CTeamCtrl.IsPlayerAutoMatch(self)
	return self.m_IsPlayerMatch
end

function CTeamCtrl.IsTeamAutoMatch(self)
	return self.m_IsTeamMatch
end
--状态判断 end

function CTeamCtrl.GetApplyList(self)
	local list = {}
	for pid, dApply in ipairs(self.m_Applys) do
		table.insert(list, dApply)
	end
	return list
end

function CTeamCtrl.GetInviteList(self)
	local list = {}
	for pid, dInvite in ipairs(self.m_Invites) do
		table.insert(list, dInvite)
	end
	return list
end

function CTeamCtrl.AddApply(self, dApply)
	if self.m_RefApplys[dApply.pid] ~= nil then
		return
	end
	if not CTeamApplyView:GetView() then
		self.m_UnreadApply[dApply.pid] = true
	end
	table.insert(self.m_Applys, dApply)
	self.m_RefApplys[dApply.pid] = #self.m_Applys
	self:OnEvent(define.Team.Event.AddApply, dApply)
	self:OnEvent(define.Team.Event.NotifyApply)
end

function CTeamCtrl.DelApply(self, pid)
	local index = self.m_RefApplys[pid]
	if index then
		table.remove(self.m_Applys, index)
		self.m_RefApplys[pid] = nil
		self.m_UnreadApply[pid] = nil
		self:OnEvent(define.Team.Event.DelApply, {pid = pid})
		self:OnEvent(define.Team.Event.NotifyApply)
	end
end

function CTeamCtrl.AddInvite(self, dInvite)
	if not CTeamInviteView:GetView() then
		self.m_UnreadInvite[dInvite.teamid] = true
	end
	table.insert(self.m_Invites, dInvite)
	self.m_RefInvites[dInvite.teamid] = #self.m_Invites
	self:OnEvent(define.Team.Event.AddInvite, dInvite)
	self:OnEvent(define.Team.Event.NotifyInvite)
end

function CTeamCtrl.DelInvite(self, iTeamID)
	local index = self.m_RefInvites[iTeamID]
	table.remove(self.m_Invites, index)
	self.m_RefInvites[iTeamID] = nil
	self.m_UnreadApply[iTeamID] = nil
	self:OnEvent(define.Team.Event.DelInvite, {teamid = iTeamID})
	self:OnEvent(define.Team.Event.NotifyInvite)
end

function CTeamCtrl.ClearApply(self)
	self.m_RefApplys = {}
	self.m_Applys = {}
	self.m_UnreadApply = {}
	self:OnEvent(define.Team.Event.ClearApply)
end

function CTeamCtrl.ClearInvite(self)
	self.m_RefInvites = {}
	self.m_Invites = {}
	self.m_UnreadInvite = {}
	self:OnEvent(define.Team.Event.ClearInvite)
end

function CTeamCtrl.ReadApply(self)
	self.m_UnreadApply = {}
	self:OnEvent(define.Team.Event.NotifyApply)
end

function CTeamCtrl.ReadInvite(self)
	self.m_UnreadInvite = {}
	self:OnEvent(define.Team.Event.NotifyInvite)
end

function CTeamCtrl.AddTargetTeam(self, iTargetId, dTeam)
	iTargetId = iTargetId or 0
	if not self.m_TargetTeams[iTargetId] then
		self.m_TargetTeams[iTargetId] = {}
	end
	if dTeam then
		table.insert(self.m_TargetTeams[iTargetId], dTeam)
	end
	self:OnEvent(define.Team.Event.AddTargetTeam, iTargetId)
end

function CTeamCtrl.ClearTargetTeamList(self, iTargetId)
	if self.m_TargetTeams[iTargetId] then
		self.m_TargetTeams[iTargetId] = {}
	end
end

function CTeamCtrl.addMyTargetTeam(self)
	local t = {}
	t.teamid = self.m_TeamID
	t.leader = self.m_LeaderID
	t.applying = 0
	t.type = 1
	t.posinfo = self.m_PosList
	t.target_info = self:GetTeamTargetInfo()
	t.member = {}
	--本地构造服务器结构的数据
	for i = 1, #self.m_PosList do
		if self.m_Members[self.m_PosList[i]] then
			local d = self.m_Members[self.m_PosList[i]]
			d.status_info = self.m_Members[self.m_PosList[i]]
			table.insert(t.member,d)
		end	
	end	 
	return t
end

function CTeamCtrl.GetTargetTeamList(self, iTargetId)
	local list = {}
	iTargetId = self:ConverTargetId(iTargetId)
	local targetTeams = self.m_TargetTeams[iTargetId]
	if targetTeams then
		--先把自己的队伍置顶
		local isFindMyTeam = false
		if self:IsJoinTeam() then
			for pid, dTeam in ipairs(targetTeams) do
				if dTeam.teamid == self.m_TeamID then
					isFindMyTeam = true
					table.insert(list, dTeam)
					break
				end				
			end
		end

		if self:IsJoinTeam() and not isFindMyTeam then
			table.insert(list, self:addMyTargetTeam())
		end

		for pid, dTeam in ipairs(targetTeams) do
			if isFindMyTeam == false or dTeam.teamid ~= self.m_TeamID then
				table.insert(list, dTeam)
			end			
		end
	end
	return list
end

function CTeamCtrl.SetPlayerMatchStatus(self, iAutoMatch)
	self.m_IsPlayerMatch = (iAutoMatch == 1)
	self:OnEvent(define.Team.Event.NotifyAutoMatch)
end

function CTeamCtrl.SetTeamTargetInfo(self, info)
	local autoInfo = table.copy(info)
	if autoInfo == nil then
		autoInfo = {}
	end
	autoInfo.auto_target = autoInfo.auto_target or 0
	autoInfo.min_grade = autoInfo.min_grade or 0
	autoInfo.max_grade = autoInfo.max_grade or g_AttrCtrl.server_grade
    self.m_TeamTargetInfo = autoInfo
    self.m_IsTeamMatch = (autoInfo.team_match == 1)
    self:OnEvent(define.Team.Event.NotifyAutoMatch)
    g_ActivityCtrl:UpdateDTStatus()
end

function CTeamCtrl.GetTeamTargetInfo(self)
	return self.m_TeamTargetInfo
end

function CTeamCtrl.CanAutoMatchTeam(self, iTaskId, min, max)
	min = min or 0
	max = max or g_AttrCtrl.grade
	local b = true
	local tData = data.teamdata.AUTO_TEAM[iTaskId]

	if max < min and b == true then
		g_NotifyCtrl:FloatMsg("最小等级限制超出最大等级限制，请重新选择")
		b = false
	end

	-- if g_TeamCtrl:GetMemberSize() >= tData.match_count b == true then
	-- 	g_NotifyCtrl:FloatMsg("队伍人数已满,无法自动匹配")
	-- 	b = false
	-- end

	return b
end

function CTeamCtrl.SetPlayerAutoTarget(self, iTaskId)
	self.m_PlayerTargetInfo.auto_target = iTaskId
	self:OnEvent(define.Team.Event.NotifyAutoMatch)
end

function CTeamCtrl.SetPlayerTargetInfo(self, autoInfo)
	if autoInfo == nil then
		autoInfo = {}
	end
	self.m_PlayerTargetInfo.auto_target = autoInfo.auto_target or 0
	self.m_PlayerTargetInfo.min_grade = autoInfo.min_grade or 0
	self.m_PlayerTargetInfo.max_grade = autoInfo.max_grade or g_AttrCtrl.server_grade
	self.m_IsTeamMatch = (autoInfo.team_match == 1)
	self:OnEvent(define.Team.Event.NotifyAutoMatch)
end

--获取自己能够创建队伍的目标列表
function CTeamCtrl.GetMyTeamTargetList(self)
	local tData = data.autoteamdata.DATA
	--保证任务升序排序
	local d = {}
	for _,v in pairs (tData) do
		table.insert(d, v)
	end
	table.sort(d, function (a, b )
		return a.id < b.id
	end)

	local t = {}
	for k, v in pairs(d) do
		if v.unlock_level <= g_AttrCtrl.grade and v.is_show == 1 then		
			if v.is_parent ~= 1 then
				table.insert(t, v)
			end			
		end
	end
	return t
end

function CTeamCtrl.GetPlayerTargetInfo(self)
	if next(self.m_PlayerTargetInfo) == nil then
		self.m_PlayerTargetInfo.auto_target = CTeamCtrl.TARGET_NONE
		self.m_PlayerTargetInfo.min_grade = 0
		self.m_PlayerTargetInfo.max_grade = g_AttrCtrl.server_grade
	end
	return self.m_PlayerTargetInfo
end

function CTeamCtrl.GetPlayerAutoTarget(self)
	return self.m_PlayerTargetInfo.auto_target
end

function CTeamCtrl.SetCountAutoMatch(self, dPb)
	self.m_CountAutoMatch[dPb.auto_target] = dPb
	self:OnEvent(define.Team.Event.NotifyCountAutoMatch)
end

function CTeamCtrl.GetCountAutoMatch(self, iTargetId)
	return self.m_CountAutoMatch[iTargetId]
end

function CTeamCtrl.C2GSTeamAutoMatch(self, taskId, min, max, teamMatch)
	taskId = self:ConverTargetId(taskId)
	if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSTeamAutoMatch"]) then
		netteam.C2GSTeamAutoMatch(taskId, min, max, teamMatch)
		if teamMatch == 0 then
			g_NotifyCtrl:FloatMsg("已取消自动匹配")
		end
	end
end

function CTeamCtrl.C2GSTeamCancelAutoMatch(self)
	if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSTeamCancelAutoMatch"]) then
		netteam.C2GSTeamCancelAutoMatch()
		
	end
end

function CTeamCtrl.C2GSPlayerCancelAutoMatch(self)
	if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSPlayerCancelAutoMatch"]) then
		netteam.C2GSPlayerCancelAutoMatch()
		g_NotifyCtrl:FloatMsg("已取消自动匹配")
	end
end

function CTeamCtrl.C2GSPlayerAutoMatch(self, taskId, min, max)
	if g_MapCtrl:IsVirtualScene() then		
		g_NotifyCtrl:FloatMsg("副本场景内，无法自动匹配")
		return 
	end
	min = min or 0
	max = max or g_AttrCtrl.server_grade
	local tips = nil 
	if self.m_IsPlayerMatch then
		tips = 1
		self:C2GSPlayerCancelAutoMatch()
	end
	if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSPlayerAutoMatch"]) then
		netteam.C2GSPlayerAutoMatch(taskId, min, max, tips)
		g_NotifyCtrl:FloatMsg("已开始自动匹配，请稍后")
	end
end

function CTeamCtrl.C2GSCreateTeam( self, taskId, min, max)
	taskId = self:ConverTargetId(taskId)
	local d = g_TeamCtrl:GetAutoTeamSubTargetTableByPartId(taskId)
	if not self:IsSpecailCreateTeam(taskId) and #d > 0 then
		g_NotifyCtrl:FloatMsg("请选择具体的组队目标创建队伍")
		return
	end	
	if g_ActivityCtrl:ActivityBlockContrl("team") then
		taskId = taskId or CTeamCtrl.TARGET_NONE
		if taskId == CTeamCtrl.TARGET_NONE and self:IsPlayerAutoMatch() then
			local targetInfo = self:GetPlayerAutoTarget()
			if targetInfo then
				taskId = targetInfo
			end
		end
		local defalutMin, defalutMax = self:GetTeamTargetDefaultLevel(taskId)
		min = min or defalutMin
		max = max or defalutMax
		if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSCreateTeam"]) then
			nettask.C2GSEnterShow(0, 0)
			netteam.C2GSCreateTeam(taskId, min, max)
		end
	end
end

function CTeamCtrl.C2GSInviteTeam(self, pid, taskId, min, max)
	taskId = taskId or 0
	taskId = self:ConverTargetId(taskId)
	local defalutMin, defalutMax = self:GetTeamTargetDefaultLevel(taskId)
	min = min or defalutMin
	max = max or defalutMax	
	if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSInviteTeam"]) then
		netteam.C2GSInviteTeam(pid, taskId, min, max) 		 
	end
end

function CTeamCtrl.C2GSSetTeamTarget( self, taskId, min, max)
	taskId = taskId or 0
	taskId = self:ConverTargetId(taskId)
	local defalutMin, defalutMax = self:GetTeamTargetDefaultLevel(taskId)
	min = min or defalutMin
	max = max or defalutMax	
	if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSSetTeamTarget"]) then
		netteam.C2GSSetTeamTarget(taskId, min, max) 	
	end
end

function CTeamCtrl.C2GSInviteAll(self, targetList, targetInfo )
	local taskId = targetInfo.auto_target or 0
	local min = targetInfo.min_grade or 0
	local max = targetInfo.max_grade or g_AttrCtrl.server_grade
	if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSInviteAll"]) then
		netteam.C2GSInviteAll(targetList, taskId, min, max)
	end
end

--请求可以邀请的好友
function CTeamCtrl.CtrlC2GSInviteFriendList(self)
	if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSInviteFriendList"]) then
		self.m_CanInviteFrdList = {}
		netteam.C2GSInviteFriendList()
	end
end

--请求可以邀请的好友(协议返回)
function CTeamCtrl.CtrlGS2CInviteFriendList(self, frdList)
	local list = frdList or {}
	if list and #list > 0 then
		for i = 1, #list do 
			self.m_CanInviteFrdList[list[i].pid] = list[i].can_invite or 0 --1为可邀请，0为不可邀请
		end
	end
	self:OnEvent(define.Team.Event.TeamInvitePlayerList)
end

--请求正在匹配的队员
function CTeamCtrl.CtrlC2GSGetTargetMemList(self)
	local target = self:GetTeamTargetInfo()
	self.m_CanInviteMatchList = {}
	if target and target.auto_target and target.auto_target ~= CTeamCtrl.TARGET_NONE then
		if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSGetTargetMemList"]) then
			netteam.C2GSGetTargetMemList(target.auto_target)
		end
	end		
end

function CTeamCtrl.CtrlGS2CTargetMemList(self, list)
	list = list or {}
	self.m_CanInviteMatchList = list
	self:OnEvent(define.Team.Event.TeamInviteMatchList)
end

function CTeamCtrl.GetInvitePlayerListByType(self, iType)
	local t = {}
	if iType == CTeamCtrl.EnumInvitePlayer.Friend then
		local frds = g_FriendCtrl:GetMyFriend()
		for _, pid in ipairs(frds) do
			if g_FriendCtrl:GetOnlineState(pid) and self.m_CanInviteFrdList[pid] == 1 then
				local frd = g_FriendCtrl:GetFriend(pid)	
				local d = 
				{
					pid = frd.pid,
					shape = frd.shape,
					grade = frd.grade,
		            name = frd.name,
		            school = frd.school,
		            school_branch = frd.school_branch,		            
				}
				table.insert(t, d)

			end			
		end

	elseif iType == CTeamCtrl.EnumInvitePlayer.Org then
		local orgMembers =  g_OrgCtrl.m_MemberList
		for k, v in pairs(orgMembers) do
			v.has_team = v.has_team or 0
			if v.offline == nil or v.offline == 0 and v.pid ~= g_AttrCtrl.pid and v.has_team ~= 1 then
				local d = 
				{
					pid = v.pid,
					shape = v.shape,
					school = v.school,
					name = v.name,
					grade = v.grade,	
					school_branch = v.school_branch,				
				}
				table.insert(t, d)
			end
		end
	elseif iType == CTeamCtrl.EnumInvitePlayer.Match then
		if self.m_CanInviteMatchList and next(self.m_CanInviteMatchList) then
			for k, v in pairs(self.m_CanInviteMatchList) do
				local d = 
				{
					pid = v.pid,
					shape = v.player_info.model_info.shape,
					school = v.player_info.school,
					name = v.player_info.name,
					grade = v.player_info.grade,	
					school_branch = v.player_info.school_branch,				
				}
				table.insert(t, d)
			end
		end
	end
	return t
end

--计时通用处理
-- timer 计时器
-- timeeOffset 时间间隔
-- notify 不满足条件时的提示
-- force 忽略时间间隔强制执行
function CTeamCtrl.CanDoProcess(self, timer, timeeOffset, notify, force)
	local b = false
	if timer ~= 0 and force ~= true then
		local now = g_TimeCtrl:GetTimeS()
		local offset = now - timer
		if offset >= timeeOffset then
			b = true
			timer = now
		else
			g_NotifyCtrl:FloatMsg( string.format(notify, timeeOffset - offset))
		end	
	else
		b = true
		timer = g_TimeCtrl:GetTimeS()
	end 
	return b, timer
end

function CTeamCtrl.CanFastTalk( self, force)
	local b, timer = self:CanDoProcess(self.m_FastTalkTimer, CTeamCtrl.FAST_TALK_TIME, "刚刚发布组队信息，请等待%d秒后再次发布", force)
	self.m_FastTalkTimer = timer
	return b 	
end

function CTeamCtrl.CanInvitePlayer( self , force)
	local b, timer = self:CanDoProcess(self.m_InviteRefreshTimer, CTeamCtrl.AUTO_TEAM_REFRESH_TIME, "刷屏频繁，请%d秒在刷新", force)
	self.m_InviteRefreshTimer = timer
	return b 	
end

function CTeamCtrl.CanRefreshTeamTarget(self, force)
	local b, timer = self:CanDoProcess(self.m_AutoTeamRefreshTimer, CTeamCtrl.INVITE_PLAYER_REFRESH_TIME, "刷新太快了，请等%d秒后再刷新", force)
	self.m_AutoTeamRefreshTimer = timer
	return b 
end

--是否能否接管队长
function CTeamCtrl.CanApplyLeader(self)
	--TODO
	--依赖好友和夫妻系统完善
	return true
end

function CTeamCtrl.SetLeaderActiveStatus(self, iStatus)
	self.m_LeaderActiveStatus = iStatus
	if iStatus == CTeamCtrl.EnumLeaderActiveState.Awake then
		self.m_LeaderUnActiveElapseTimer = 0
	end
end

function CTeamCtrl.IsLeaderActive(self)
	return self.m_LeaderActiveStatus == CTeamCtrl.EnumLeaderActiveState.Awake
end

function CTeamCtrl.SetLeaderTouchUI(self, state)
	self.m_IsLeaderTouchUI = state
end

function CTeamCtrl.StartCheckLeaderActive(self)
	local isLeader = self:IsLeader()
	local isJoinTeam = self:IsJoinTeam()
	local isWar = g_WarCtrl:IsWar()
	if isJoinTeam and isLeader and not isWar then
		if self.m_IsLeaderTouchUI == true then
			if not self:IsLeaderActive() then
				if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSLeaderSleep"]) then
					netteam.C2GSLeaderSleep(CTeamCtrl.EnumLeaderActiveState.Awake)
				end
			end
			self:SetLeaderActiveStatus(CTeamCtrl.EnumLeaderActiveState.Awake)
			self.m_IsLeaderTouchUI = false
		else
			local pos = {}
			if g_MapCtrl:GetHero() then
				pos = g_MapCtrl:GetHero():GetPos()
			end
			local x = pos.x or 0
			local y = pos.y or 0
			x = math.floor(x * 100000)
			y = math.floor(y * 100000)
			local curPos = Vector2.New(x, y)
			if curPos ~= self.m_LeaderPos then
				if not self:IsLeaderActive() then
					if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSLeaderSleep"]) then
						netteam.C2GSLeaderSleep(CTeamCtrl.EnumLeaderActiveState.Awake)
					end
				end	
				self:SetLeaderActiveStatus(CTeamCtrl.EnumLeaderActiveState.Awake)
				self.m_LeaderPos = curPos			
			else
				self.m_LeaderUnActiveElapseTimer = self.m_LeaderUnActiveElapseTimer + CTeamCtrl.LEADER_UNACTIVE_CHECK_TIME
				if CTeamCtrl.LEADER_UNACTIVE_TIME_MAX <= self.m_LeaderUnActiveElapseTimer then
					self.m_LeaderUnActiveElapseTimer = 0
					self:SetLeaderActiveStatus(CTeamCtrl.EnumLeaderActiveState.Sleep)
					if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSLeaderSleep"]) then
						netteam.C2GSLeaderSleep(CTeamCtrl.EnumLeaderActiveState.Sleep)
					end
				end
			end
		end
		--5秒检测1次
		if self.m_AutoCheckLeaderActiveTimer ~= nil then
			Utils.DelTimer(self.m_AutoCheckLeaderActiveTimer)
			self.m_AutoCheckLeaderActiveTimer = nil
		end		
		self.m_AutoCheckLeaderActiveTimer = Utils.AddTimer(callback(self, "StartCheckLeaderActive"), 0, CTeamCtrl.LEADER_UNACTIVE_CHECK_TIME)				
	else
		self:StopCheckLeaderActive()
	end
end

function CTeamCtrl.StopCheckLeaderActive(self)
	if self.m_AutoCheckLeaderActiveTimer ~= nil then
		Utils.DelTimer(self.m_AutoCheckLeaderActiveTimer)
		self.m_AutoCheckLeaderActiveTimer = nil
	end
	self.m_LeaderUnActiveElapseTimer = 0
	self:SetLeaderActiveStatus(CTeamCtrl.EnumLeaderActiveState.Awake)
end

function CTeamCtrl.InitTeamSetting(self)
	if self.m_TeamSet == nil then
	    self.m_TeamSet =
		{
		 	AutoChatScreen = true,
		 	AutoAgreedFriendApply = false,
		 	AutoReInvite = false,
		}
		local sysset = table.copy(g_AttrCtrl.systemsetting)
		sysset = sysset or {}
		sysset.teamsetting = sysset.teamsetting or {}
	    if sysset and sysset.teamsetting then
	    	local t = sysset.teamsetting
	    	if t.barrage == 1 then
	    		self.m_TeamSet.AutoChatScreen = false
	    	else
	    		self.m_TeamSet.AutoChatScreen = true
	    	end
	    	self.m_TeamSet.AutoAgreedFriendApply = t.auto_agree == 1 and true or false
	    	self.m_TeamSet.AutoReInvite = t.autostart_teammatch == 1 and true or false
	    end
	end
	if self.m_TeamSet.AutoChatScreen == true then
		self:OpenTeamBulletScreen()
	else
		self:CloseTeamBulletScreen()
	end
end

function CTeamCtrl.C2GSChangeTeamSetting(self)
	local barrage = self.m_TeamSet.AutoChatScreen and 2 or 1
	local auto_agree = self.m_TeamSet.AutoAgreedFriendApply and 1 or 0
	local autostart_teammatch = self.m_TeamSet.AutoReInvite and 1 or 0

	local setting_info = 
	{
		[1] = {option = "barrage",value = barrage},
		[2] = {option = "auto_agree",value = auto_agree},
		[3] = {option = "autostart_teammatch",value = autostart_teammatch},
	}
	if self.m_TeamSet.AutoChatScreen == true then
		self:OpenTeamBulletScreen()
	else
		self:CloseTeamBulletScreen()
	end
	if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSChangeTeamSetting"]) then
		netteam.C2GSChangeTeamSetting(setting_info)
	end
end

function CTeamCtrl.GetSubAutoteamData(self, parentId, level)
	local result = {}
	for k,v in pairs(data.teamdata.AUTO_TEAM) do
		if v.parentId == parentId and v.unlock_level <= level and v.is_show == 1 then
			table.insert(result, v)
		end
	end
	local sort = function(data1, data2)
		return data1.id < data2.id
	end
	table.sort(result, sort)
	return result
end

--组队目标 出发
function CTeamCtrl.TeamReadGo(self)
	local bCloseView = false
	local target = self:GetTeamTargetInfo()
	if target and target.auto_target and data.autoteamdata.DATA[target.auto_target] then
		local t = data.autoteamdata.DATA[target.auto_target]
		if t.block and t.block ~= "" and not g_ActivityCtrl:ActivityBlockContrl(t.block) then
			return bCloseView
		end
		if not t.ready_go or t.ready_go == "" then
			return bCloseView
		end
		local str =string.split(t.ready_go, "|")
		if #str < 1 then
			return bCloseView
		end
		local needAutoTeam = false
		if t.ready_go_match == 1 then
			needAutoTeam = true
		end
		if str[1] == "target" and t.ready_go_open_id ~= 0 then
			g_ItemCtrl:ItemFindWayToSwitch(t.ready_go_open_id)

		elseif str[1] == "text" then
			if str[2] and str[2] ~= "" then
				g_NotifyCtrl:FloatMsg(str[2])
			end
			needAutoTeam = true
		
		elseif str[1] == "endless_pve" then
			bCloseView = true
			g_OpenUICtrl:OpenEndlessPVEView("月见幻境")				
			needAutoTeam = true
			
		elseif str[1] == "minglei" then	
			bCloseView = g_ActivityCtrl:GoToMingLeiMap()		
			needAutoTeam = true

		elseif str[1] == "yjfuben" then
			bCloseView = true
			g_ItemCtrl:ItemFindWayToSwitch(155)
			needAutoTeam = true
		elseif str[1] == "team_arena" then
			bCloseView = true
			g_OpenUICtrl:WalkToTeamPvp("协同比武")
			needAutoTeam = true
		elseif str[1] == "skill_task" then
			g_OpenUICtrl:WalkToSkillTask()
			needAutoTeam = true
		elseif str[1] == "daily_cultivate" then
			g_OpenUICtrl:WalkToDailyTrainNpc()
			needAutoTeam = true			
		elseif str[1] == "none" then
			g_NotifyCtrl:FloatMsg("请调整组队目标再出发")	

		else
			g_NotifyCtrl:FloatMsg("请调整组队目标再出发")	
		end

		if needAutoTeam == true and not g_TeamCtrl:IsTeamAutoMatch() then
			local lMemberList = g_TeamCtrl:GetMemberList()		
			if t.match_count and lMemberList and #lMemberList < t.match_count then
				g_TeamCtrl:C2GSTeamAutoMatch(target.auto_target, target.min_grade, target.max_grade, 1)
			end
		end
	else
		g_NotifyCtrl:FloatMsg("请调整组队目标再出发")
	end

	return bCloseView
end

--取消组队匹配
function CTeamCtrl.CtrlGS2CCancelTeamAutoMatch(self)
    self.m_IsTeamMatch = false
    self:OnEvent(define.Team.Event.NotifyAutoMatch)
end

function CTeamCtrl.GS2CPlayerMatchSuccess(self)
	local oView = CTeamMainView:GetView()
	if oView then
		oView:CloseView()
	end
end

function CTeamCtrl.AutoCreatAndMatch(self, taskId)
	if g_ActivityCtrl:ActivityBlockContrl("team") then
		if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSCreateTeam"]) then
			nettask.C2GSEnterShow(0, 0)
			netteam.C2GSCreateTeam()
		end
		g_TeamCtrl:C2GSSetTeamTarget(taskId)
		CTeamMainView:ShowView(function (oView )
			oView:ShowTeamPage(CTeamMainView.Tab.TeamMain)
			oView.m_MainPage:OnAutoMatch()
		end)
	end
end

function CTeamCtrl.OpenTeamBulletScreen(self)
	if (self.m_TeamSet and self.m_TeamSet.AutoChatScreen) and self:IsJoinTeam() then
		CTeamBulletScreenView:ShowView()
	end
end

function CTeamCtrl.CloseTeamBulletScreen(self)
	CTeamBulletScreenView:CloseView()
end

function CTeamCtrl.CtrlGS2CTeamMingleiInfo(self, info)
	self.m_TargetCountTable[CTeamCtrl.TARGET_MING_LEI] = {}
	local t = self.m_TargetCountTable[CTeamCtrl.TARGET_MING_LEI]
	for i = 1, #info do
		local d = info[i]
		t[d.pid] = d
	end
	self:OnEvent(define.Team.Event.RefreshTargetCount)
end

function CTeamCtrl.CtrlC2GSTeamCountInfo(self)	
	local targetInfo = self:GetTeamTargetInfo()
	if targetInfo.auto_target == CTeamCtrl.TARGET_MING_LEI then
		if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSGetMingleiTeamInfo"]) then
			netteam.C2GSGetMingleiTeamInfo(1)
		end
	elseif targetInfo.auto_target == CTeamCtrl.TARGET_AN_LEI_BOX then
		if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSTrapmineTeamInfo"]) then
			netteam.C2GSTrapmineTeamInfo()
		end
	end	
end

function CTeamCtrl.GetargetCountTable(self, target)
	return self.m_TargetCountTable[target]
end

function CTeamCtrl.CtrlC2GSTrapmineTeamInfo(self, teamInfo)
	local info = table.copy(teamInfo)
	if not info or not next(info) then
		return
	end
	self.m_TargetCountTable[CTeamCtrl.TARGET_AN_LEI_BOX] = {}
	local t = self.m_TargetCountTable[CTeamCtrl.TARGET_AN_LEI_BOX]
	for i = 1, #info do
		local d = info[i]
		d.cd = d.cd or 0
		t[d.pid] = d
	end
	self:OnEvent(define.Team.Event.RefreshTargetCount)
end

function CTeamCtrl.ResetCtrl(self)
	if self then
		self:InitValue()
	end	
	self:OnEvent(define.Team.Event.DelTeam)
end

--是否能手动创建该组队目标
function CTeamCtrl.CanManualCreareTarget(self, targetId)
	local b = true
	local d = data.teamdata.AUTO_TEAM[targetId]
	if d.is_parent == 1 then				
		b = false
		if d.select_target_tips and d.select_target_tips ~= "" then
			g_NotifyCtrl:FloatMsg(d.select_target_tips)
		end
	end
	return b
end

function CTeamCtrl.GetAutoTeamSubTargetTableByPartId(self, id, isJoinTeam)
	local result = {}
	local temp = nil
	for k,v in pairs(data.teamdata.AUTO_TEAM) do
		if v.unlock_level <= g_AttrCtrl.grade and v.parentId == id and v.parentId ~= 0 then
			table.insert(result, v)
		end
		if not isJoinTeam and v.id == id then
			temp = table.copy(v)
			temp.sub_title_name = "全部"			
		end
	end

	if not self:IsSpecailCreateTeam(id) then
		if #result > 0 and temp then
			table.insert(result, temp)
		end
	end

	local sort = function(data1, data2)
		return data1.sort < data2.sort
	end
	table.sort(result, sort)
	return result
end

function CTeamCtrl.GetTeamTargetDefaultLevel(self, target)
	local min = 0 
	local max = g_AttrCtrl.server_grade + 5
	if max > 100 then
		max = 100
	end
	local t = data.autoteamdata.DATA[target]
	if t then
		min = t.unlock_level
	end
	return min, max
end

function CTeamCtrl.IsAllInTeam(self)
	local b = false
	if self:GetMemberSize() == 4 then
		b = true
		if self.m_PosList and next(self.m_PosList) then
			for k,v in pairs(self.m_PosList) do
				if v == 0 or not self:IsInTeam(v) then
					b = false
				end
			end
		end
	end
	return b
end

function CTeamCtrl.ConverTargetId(self, taskId)
	local bSpecial = false
	if taskId == 110101 then
		taskId = 1101
		bSpecial = true
	elseif taskId == 111101 then
		taskId = 1111
		bSpecial = true
	elseif taskId == 116001 then
		taskId = 1160
		bSpecial = true
	elseif taskId == 100101 then
		taskId = 1001
		bSpecial = true
	end
	return taskId, bSpecial
end

function CTeamCtrl.IsSpecailCreateTeam(self, taskId)
	local t = 
	{
		[1001] = true,
		[1101] = true,
		[1111] = true,
		[1160] = true,
	}	
	return t[taskId] == true
end

--特定玩法便捷组队
function CTeamCtrl.QuickBuildTeamByTarget(self, target)
	CTeamMainView:ShowView(function (oView )
		oView:ShowTeamPage(CTeamMainView.Tab.TeamMain)
	end)

	if not self:IsInTeam() then
		self:C2GSCreateTeam(target)
	else
		local targetInfo = self:GetTeamTargetInfo()
		if targetInfo.auto_target ~= target then
			local defalutMin, defalutMax = self:GetTeamTargetDefaultLevel(target)
			self:C2GSTeamAutoMatch(target, defalutMin, defalutMax, 0)
		end
	end
end

return CTeamCtrl
