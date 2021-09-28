RegistModules("team/zd/ZDConst")
RegistModules("team/zd/ZDVo")
RegistModules("team/zd/ZDModel")

RegistModules("team/zd/view/ZDMemCell")
RegistModules("team/zd/view/ZDMinePanel")

RegistModules("team/zd/view/ZDItem")
RegistModules("team/zd/view/ZDHallPanel")

RegistModules("team/zd/view/ZDApplyitem")
RegistModules("team/zd/view/ZDApplyPanel")

RegistModules("team/zd/view/ZDInviteItem")
RegistModules("team/zd/view/ZDInvitePanel")

RegistModules("team/zd/view/ZDJoinTarget")
RegistModules("team/zd/ZDMainView")
RegistModules("team/zd/view/ZDJoinTarget2")

-- 队伍控制器
ZDCtrl = BaseClass(LuaController)
function ZDCtrl:GetInstance()
	if ZDCtrl.inst == nil then
		ZDCtrl.inst = ZDCtrl.New()
	end
	return ZDCtrl.inst
end

function ZDCtrl:__init()
	self:Config()
	self:InitEvent()
	self:RegistProto()
end
function ZDCtrl:Config()
	self.view = nil
	self.model = ZDModel:GetInstance()
end
function ZDCtrl:InitEvent()
	self.createTeamHandle=GlobalDispatcher:AddEventListener(EventName.CreateTeam,function ( data )--在家族监听
		self:C_CreateTeam()
	end)
	self.byFrienHandle=GlobalDispatcher:AddEventListener(EventName.FriendTeam,function ( data )--在好友列表监听 组队
		self:C_Invite(data)
	end)
	if not self.reloginHandle then
		self.reloginHandle = GlobalDispatcher:AddEventListener(EventName.RELOGIN_ROLE,function()
			self.model:Reset()
		end)
	end

	-- add 17/11/24
	-- @desc : 在“归队”状态时，如果玩家进行其它操作，则将归队状态取消掉，（操作包括：自动战斗、自动寻路，采集，释放技能，手动操作移动，回城，副本传送等）
    --  	   归队状态被打断时，给出飘字提示“归队状态取消”
	-- 自动战斗
	self.handler1=GlobalDispatcher:AddEventListener(EventName.AutoFightStart, function()
		self:EndFollowLeader()
	end)
	-- 遥杆移动
	self.handler2=GlobalDispatcher:AddEventListener(EventName.JOYSTICK_MOVE, function()
		self:EndFollowLeader()
	end)
	-- 技能
	self.handler3=GlobalDispatcher:AddEventListener(EventName.SkillBtnClick, function()
		self:EndFollowLeader()
	end)
	-- 回城,进副本
	self.handler4=GlobalDispatcher:AddEventListener(EventName.StartReturnMainCity, function()
		self:EndFollowLeader()
	end)
	-- 采集
	self.handler5=GlobalDispatcher:AddEventListener(EventName.StartCollect, function()
		self:EndFollowLeader()
	end)
	self.handler6=GlobalDispatcher:AddEventListener(EventName.OBJECT_ONCLICK, function(obj)
		if obj and obj.guid and obj.type == PuppetVo.Type.Collect then
			self:EndFollowLeader()
		end
	end)
	-- 自动寻路
	self.handler7=GlobalDispatcher:AddEventListener(EventName.Player_AutoRun, function()
		if self:CheckShouldStopAutoRun() then
			self:EndFollowLeader()
		end
	end)
	self.handler8=GlobalDispatcher:AddEventListener(EventName.KEYCODE_MOVE, function()
		self:EndFollowLeader()
	end)
end
function ZDCtrl:RegistProto()
	self:RegistProtocal("S_GetTeamList")
	self:RegistProtocal("S_SynTeamPlayerHp")
	self:RegistProtocal("S_SynTeam")
	self:RegistProtocal("S_GetInviteList")
	self:RegistProtocal("S_HasNewInvite")
	self:RegistProtocal("S_QuitTeam")
	self:RegistProtocal("S_KickTeamPlayer")
	self:RegistProtocal("S_Invite")

	self:RegistProtocal("S_ApplyJoinTeam")
	self:RegistProtocal("S_GetTeamApplyList")
	self:RegistProtocal("S_ApplyJoinTeamDeal")
	self:RegistProtocal("S_GetCaptainPostion")
	self:RegistProtocal("S_AutoAgreeApply")
end
--响应
	-- 组队大厅列表
	function ZDCtrl:S_GetTeamList(buff)
		local msg = self:ParseMsg(team_pb.S_GetTeamList(), buff)
		self.model:UpdateTeamList(msg.teamList)
	end
	-- 同步队员血量显示
	function ZDCtrl:S_SynTeamPlayerHp(buff)
		local msg = self:ParseMsg(team_pb.S_SynTeamPlayerHp(), buff)
		self.model:UpdateMember( msg.playerId, msg.hp, msg.maxHp )
	end
	-- 同步队伍
	function ZDCtrl:S_SynTeam(buff)
		local msg = self:ParseMsg(team_pb.S_SynTeam(), buff)
		self.model:SynTeam(msg)
		GlobalDispatcher:Fire(EventName.FAMILY_ZD)
	end
	-- (好友, 家族, 附近 邀请 暂时不用到)获取社交邀请列表
	function ZDCtrl:S_GetInviteList(buff)
		local msg = self:ParseMsg(team_pb.S_GetInviteList(), buff)
		print("获取社交邀请列表",msg)
	end
	-- 有新邀请通知
	function ZDCtrl:S_HasNewInvite(buff)
		local msg = self:ParseMsg(team_pb.S_HasNewInvite(), buff)
		-- if self.preInviteId = msg.teamId then return end
		-- self.preInviteId = msg.teamId
		if self.msgInviteAlert then return end
		local s = self:GetNewInviteTipStr(msg)
		self.msgInviteAlert = UIMgr.Win_Confirm("提示" , s , "加入" , "拒绝",
			function ()
				self:C_AgreeInvite(msg.teamId)
				-- self.preInviteId = nil
				self.msgInviteAlert = nil
			end, 
			function ()
			-- self.preInviteId = nil
			self.msgInviteAlert = nil
		end)
	end
	-- 发起邀请回包
	function ZDCtrl:S_Invite( buff )
		local msg = self:ParseMsg(team_pb.S_Invite(), buff)
		UIMgr.Win_FloatTip("已成功邀请")
	end

	function ZDCtrl:GetNewInviteTipStr(msg)
		local str1 = ""
		local str2 = ""
		local strFmt1 = "队伍目标: [{0}]{1}"
		local strFmt2 = "限制等级: {0}级"
		local strDest1 = ""
		local strDest2 = ""
		local targetInfo = GetCfgData("teamTarget"):Get(msg.activityId)
		if targetInfo then
			strDest1 = StringFormat(strFmt1, ZDConst.bigType[targetInfo.targetType][2], targetInfo.targetName or "无")
			strDest2 = StringFormat(strFmt2, msg.minLevel or 1)
		end
		return StringFormat("{0}({1}级)邀请您加入队伍\n\n{2}\n{3}",msg.playerName, msg.playerLevel or 1, strDest1, strDest2)
	end
	
	-- 退出队伍
	function ZDCtrl:S_QuitTeam(buff)
		local msg = self:ParseMsg(team_pb.S_QuitTeam(), buff)
		UIMgr.Win_FloatTip("您已经退出队伍")
		self.model:ClearMine()
	end
	-- 踢除队员
	function ZDCtrl:S_KickTeamPlayer(buff)
		local msg = self:ParseMsg(team_pb.S_KickTeamPlayer(), buff)
		UIMgr.Win_FloatTip("您已经被请出队伍")
		ChatNewController:GetInstance():AddChannelMsg(ChatNewModel.Channel.Team, "您已经被请出队伍")
		self.model:ClearMine()
	end
	-- 申请加入队伍
	function ZDCtrl:S_ApplyJoinTeam(buff)
		local msg = self:ParseMsg(team_pb.S_ApplyJoinTeam(), buff)
		self.model:SetHasReq(true)
		if not self.model:IsLeader() then
			UIMgr.Win_FloatTip("申请加入队伍中")
		end
	end
	-- 获取申请加入队伍消息
	function ZDCtrl:S_GetTeamApplyList(buff)
		local msg = self:ParseMsg(team_pb.S_GetTeamApplyList(), buff)
		self.model:UpdateTeamApplyList(msg.applyList)
	end
	-- 加入队伍信息处理
	function ZDCtrl:S_ApplyJoinTeamDeal(buff)
		local msg = self:ParseMsg(team_pb.S_ApplyJoinTeamDeal(), buff)
		if self.model:IsLeader() then
			for i,v in ipairs(self.model.applyList) do
				if v.playerId == msg.applyPlayerId then
					table.remove(self.model.applyList, i)
					self.model:Fire(ZDConst.APPLYLIST_CHANGE)
					break
				end
			end
		else
			if msg.state == 0 then
				UIMgr.Win_FloatTip(StringFormat("{0}拒绝您申请加入队伍", msg.playerName))
			else
				UIMgr.Win_FloatTip(StringFormat("{0}同意您申请加入队伍", msg.playerName))
			end
		end
	end
	-- 获取队长位置信息
	function ZDCtrl:S_GetCaptainPostion(buff)
		local msg = self:ParseMsg(team_pb.S_GetCaptainPostion(), buff)
		self.model:FollowLeader(msg)
	end
	-- 自动同意申请
	function ZDCtrl:S_AutoAgreeApply(buff)
		local msg = self:ParseMsg(team_pb.S_AutoAgreeApply(), buff)
		self.model.autoAgree = msg.state == 1
	end
-- 请求
	-- 组队大厅列表
	function ZDCtrl:C_GetTeamList(activityId)
		local msg = team_pb.C_GetTeamList()
		msg.activityId = activityId
		self:SendMsg("C_GetTeamList", msg)
		--self.model:SetActivityId(activityId)
		self.model:SetSelectActivityId(activityId)
	end
	-- 创建队伍
	function ZDCtrl:C_CreateTeam()
		self:SendEmptyMsg(team_pb, "C_CreateTeam")
	end
	-- (好友，家族，附近 邀请 暂时不用到)获取社交邀请列表
	function ZDCtrl:C_GetInviteList(type, start, offset)
		local msg = team_pb.C_GetInviteList()
		msg.type=type
		msg.start=start
		msg.offset=offset
		self:SendMsg("C_GetInviteList", msg)
	end
	-- 发起邀请
	function ZDCtrl:C_Invite(playerId)
		local msg = team_pb.C_Invite()
		msg.inviterId = playerId
		self:SendMsg("C_Invite", msg)
	end
	-- 同意邀请
	function ZDCtrl:C_AgreeInvite(teamId)
		local msg = team_pb.C_AgreeInvite()
		msg.teamId = teamId
		self:SendMsg("C_AgreeInvite", msg)
	end
	-- 修改队伍目标
	function ZDCtrl:C_ChangeTarget(activityId, minLevel)
		local msg = team_pb.C_ChangeTarget()
		msg.activityId = activityId
		msg.minLevel = minLevel
		self:SendMsg("C_ChangeTarget", msg)
	end
	-- 退出队伍
	function ZDCtrl:C_QuitTeam()
		self:SendEmptyMsg(team_pb, "C_QuitTeam")
	end
	-- 踢除队员
	function ZDCtrl:C_KickTeamPlayer(playerId)
		local msg = team_pb.C_KickTeamPlayer()
		msg.playerId = playerId
		self:SendMsg("C_KickTeamPlayer", msg)
	end
	-- 转让队长
	function ZDCtrl:C_ChangeCaptain(playerId)
		local msg = team_pb.C_ChangeCaptain()
		msg.playerId = playerId
		self:SendMsg("C_ChangeCaptain", msg)
	end

	-- 申请加入队伍
	function ZDCtrl:C_ApplyJoinTeam(teamId)
		local msg = team_pb.C_ApplyJoinTeam()
		msg.teamId = teamId
		self:SendMsg("C_ApplyJoinTeam", msg)
	end
	-- 获取申请加入队伍消息
	function ZDCtrl:C_GetTeamApplyList()
		self:SendEmptyMsg(team_pb, "C_GetTeamApplyList")
	end
	-- 加入队伍信息处理
	function ZDCtrl:C_ApplyJoinTeamDeal(applyPlayerId, state)
		local msg = team_pb.C_ApplyJoinTeamDeal()
		msg.applyPlayerId = applyPlayerId
		msg.state = state
		self:SendMsg("C_ApplyJoinTeamDeal", msg)
	end
	-- 玩家自动匹配队伍
	function ZDCtrl:C_PlayerAutoMatch(id)
		local msg = team_pb.C_PlayerAutoMatch()
		-- msg.activityId = self.model:GetActivityId()
		msg.activityId = self.model:GetSelectActivityId()
		if id then
			msg.activityId = id
		end
		self:SendMsg("C_PlayerAutoMatch", msg)
	end
	-- 队伍自动匹配玩家
	function ZDCtrl:C_TeamAutoMatch()
		local msg = team_pb.C_TeamAutoMatch()
		msg.state = self.model.teamMath or 1
		self:SendMsg("C_TeamAutoMatch", msg)
	end
	-- 跟随
	function ZDCtrl:C_Follow()
		if self.model.teamId == 0 then
			UIMgr.Win_FloatTip("您还没有加入队伍!")
			return
		end
		if self.model:IsLeader() then
			UIMgr.Win_FloatTip("您是老大，应该是您来带领大家吧!")
			return
		end
		local msg = team_pb.C_Follow()
		msg.state = self.model.isFollow and 1 or 0
		self:SendMsg("C_Follow", msg)
	end
	-- 获取队长位置信息
	function ZDCtrl:C_GetCaptainPostion()
		self:SendEmptyMsg(team_pb, "C_GetCaptainPostion")
	end
	-- 清空申请消息
	function ZDCtrl:C_ClearTeamApplyList()
		self:SendEmptyMsg(team_pb, "C_ClearTeamApplyList")
		self.model:UpdateTeamApplyList()
	end
	-- 自动同意申请
	function ZDCtrl:C_AutoAgreeApply()
		self:SendEmptyMsg(team_pb, "C_AutoAgreeApply")
	end

-- 获取主面板
function ZDCtrl:Open()
	self:GetMainPanel():Open()
end
function ZDCtrl:GetMainPanel()
	if not self:IsExistView() then
		self.view = ZDMainView.New()
	end
	return self.view
end
-- 判断主面板是否存在
function ZDCtrl:IsExistView()
	return self.view and self.view.isInited
end
-- 销毁
function ZDCtrl:__delete()
	GlobalDispatcher:RemoveEventListener(self.createTeamHandle)
	GlobalDispatcher:RemoveEventListener(self.byFrienHandle)
	GlobalDispatcher:RemoveEventListener(self.reloginHandle)
	GlobalDispatcher:RemoveEventListener(self.handler1)
	GlobalDispatcher:RemoveEventListener(self.handler2)
	GlobalDispatcher:RemoveEventListener(self.handler3)
	GlobalDispatcher:RemoveEventListener(self.handler4)
	GlobalDispatcher:RemoveEventListener(self.handler5)
	GlobalDispatcher:RemoveEventListener(self.handler6)
	GlobalDispatcher:RemoveEventListener(self.handler7)
	GlobalDispatcher:RemoveEventListener(self.handler8)
	
	ZDCtrl.inst = nil
	if self:IsExistView() then
		self.view:Destroy()
	end
	self.view = nil
	if self.model then
		self.model:Destroy()
		self.model = nil
	end
end

function ZDCtrl:EndFollowLeader()
	if self.model and self.model:IsFollowing() then
		self.model:SetFollow(false)
		Message:GetInstance():TipsMsg("归队状态取消...")
	end
end

function ZDCtrl:CheckShouldStopAutoRun()
	local bStop = false
	if self.model then
		local targetPos = SceneModel:GetInstance().targetPos
		local posFollow = self.model:GetPosFollow()
		local scene = SceneController:GetInstance():GetScene()
		if scene then
			local player = scene:GetMainPlayer()
			if player then
				local posTarget = player.agentDriver.targetPos
				if (targetPos and posFollow and targetPos ~= posFollow) or ( posTarget and posFollow and posFollow ~= posTarget ) then
					bStop = true
				end
			end
		end
	end
	return bStop
end