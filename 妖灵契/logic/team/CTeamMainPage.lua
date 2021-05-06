
---------------------------------------------------------------
--组队界面 我的队伍


---------------------------------------------------------------

local CTeamMainPage = class("CTeamMainPage", CPageBase)

function CTeamMainPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CTeamMainPage.OnInitPage(self)
	self.m_MemberGrid = self:NewUI(1, CGrid)
	self.m_MemberBox = self:NewUI(2, CTeamMemberBox)

	--未组队 
	self.m_NoTeamBox = self:NewUI(4, CBox)
	self.m_NoTeamBox.m_SetBtn = self.m_NoTeamBox:NewUI(1, CButton)
	self.m_NoTeamBox.m_CreateBtn = self.m_NoTeamBox:NewUI(2, CButton)
	--组队（队员）
	self.m_InTeamNoLeaderBox = self:NewUI(5, CBox)
	self.m_InTeamNoLeaderBox.m_SetBtn = self.m_InTeamNoLeaderBox:NewUI(1, CButton)
	self.m_InTeamNoLeaderBox.m_LeaveBtn = self.m_InTeamNoLeaderBox:NewUI(2, CButton)
	self.m_InTeamNoLeaderBox.m_QuitBtn = self.m_InTeamNoLeaderBox:NewUI(3, CButton) 
	--组队（队长）
	self.m_InTeamLeaderBox = self:NewUI(6, CBox)
	self.m_InTeamLeaderBox.m_ApplyBtn = self.m_InTeamLeaderBox:NewUI(1, CButton)
	self.m_InTeamLeaderBox.m_FastCallBtn = self.m_InTeamLeaderBox:NewUI(2, CButton)
	self.m_InTeamLeaderBox.m_SetBtn = self.m_InTeamLeaderBox:NewUI(3, CButton)
	self.m_InTeamLeaderBox.m_AutoMatchBtn = self.m_InTeamLeaderBox:NewUI(4, CButton)
	self.m_InTeamLeaderBox.m_QuitBtn = self.m_InTeamLeaderBox:NewUI(5, CButton)
	self.m_InTeamLeaderBox.m_FastTalkBtn = self.m_InTeamLeaderBox:NewUI(6, CButton)

	self.m_TipsLabel = self:NewUI(7, CLabel)
	self.m_AutoTeamWidget = self:NewUI(8, CWidget)
	self.m_TargetChangeBtn = self:NewUI(9, CButton, true, false)
	self.m_InvitePlayerBtn = self:NewUI(10, CButton)
	self.m_TargetLabel = self:NewUI(11, CLabel)
	self.m_LevelLabel = self:NewUI(12, CLabel)

	self.m_TeamTargetBtn = self:NewUI(13, CButton)
	self.m_TeamTargetLabel = self:NewUI(14, CLabel)	
	self.m_TeamTargtLevelBtn = self:NewUI(15, CButton)	
	self.m_TeamTargetLevelLabel = self:NewUI(16, CLabel)
	self.m_TeamTargetInfoBtn = self:NewUI(17, CButton)
	self.m_TeamTargetBtn.m_FlagSpr = self:NewUI(18, CSprite)
	self.m_TeamTargetBtn.m_FlagSpr.TweenRotation = self.m_TeamTargetBtn.m_FlagSpr:GetComponent(classtype.TweenRotation)
	self.m_TeamTargtLevelBtn.m_FlagSpr = self:NewUI(19, CSprite)
	self.m_TeamTargtLevelBtn.m_FlagSpr.TweenRotation = self.m_TeamTargtLevelBtn.m_FlagSpr:GetComponent(classtype.TweenRotation)

	self.m_MemberBoxs = {}
	self.m_TeampChangePartnerId = nil
	self:InitContent()
end

function CTeamMainPage.InitContent(self)
	self.m_MemberBox:SetActive(false)
	self.m_NoTeamBox.m_SetBtn:AddUIEvent("click", callback(self, "OnTeamSet"))
	self.m_NoTeamBox.m_CreateBtn:AddUIEvent("click", callback(self, "OnCreateTeam"))
	self.m_InTeamNoLeaderBox.m_SetBtn:AddUIEvent("click", callback(self, "OnTeamSet"))
	self.m_InTeamNoLeaderBox.m_LeaveBtn:AddUIEvent("click", callback(self, "OnLeaveTeam"))
	self.m_InTeamNoLeaderBox.m_QuitBtn:AddUIEvent("click", callback(self, "OnQuitTeam"))
	self.m_InTeamLeaderBox.m_ApplyBtn:AddUIEvent("click", callback(self, "OnApplyList"))
	self.m_InTeamLeaderBox.m_FastCallBtn:AddUIEvent("click", callback(self, "OnFastCall"))
	self.m_InTeamLeaderBox.m_SetBtn:AddUIEvent("click", callback(self, "OnTeamSet"))
	self.m_InTeamLeaderBox.m_AutoMatchBtn:AddUIEvent("click", callback(self, "OnAutoMatch"))
	self.m_InTeamLeaderBox.m_QuitBtn:AddUIEvent("click", callback(self, "OnQuitTeam"))
	self.m_InTeamLeaderBox.m_FastTalkBtn:AddUIEvent("click", callback(self, "OnFastTalk"))
	self.m_InvitePlayerBtn:AddUIEvent("click", callback(self, "OnClickInvitePlayers"))

	self.m_TargetChangeBtn:AddUIEvent("click", callback(self, "OnClickTargetChange"))

	self.m_TeamTargetBtn:AddUIEvent("click", callback(self, "OnClickTeamTarget"))	
	self.m_TeamTargtLevelBtn:AddUIEvent("click", callback(self, "OnClickTeamTargetLevel"))	
	self.m_TeamTargetInfoBtn:AddUIEvent("click", callback(self, "OnClickTeamTargetInfo"))	
	
	g_TeamCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlTeamEvent"))
	g_PartnerCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlPartnerEvent"))
	self:InitMemberGrid()
	self:RefreshAll()

end

function CTeamMainPage.OnCtrlTeamEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Team.Event.AddTeam or
		oCtrl.m_EventID == define.Team.Event.DelTeam then
			self:RefreshAll()
		g_TeamCtrl:CtrlC2GSTeamCountInfo()

	elseif oCtrl.m_EventID == define.Team.Event.MemberUpdate then
		self:RefrehNotifyTip()
		for i, oBox in ipairs(self.m_MemberGrid:GetChildList()) do
			if oBox.classname == "CTeamMemberBox" then
				if oBox.m_Member and oBox.m_Member.pid == oCtrl.m_EventData.pid then
					oBox:SetMember(oCtrl.m_EventData)
					break
				end
			end
		end
		g_TeamCtrl:CtrlC2GSTeamCountInfo()

	elseif oCtrl.m_EventID == define.Team.Event.NotifyApply or 
		oCtrl.m_EventID == define.Team.Event.NotifyInvite then
		self:RefrehNotifyTip()
		g_TeamCtrl:CtrlC2GSTeamCountInfo()

	elseif oCtrl.m_EventID == define.Team.Event.NotifyAutoMatch then

		self:RefreshButtonStatus()
		if g_TeamCtrl:IsPlayerAutoMatch() then
			local tTargetInfo = {
				auto_target = g_TeamCtrl:GetPlayerAutoTarget(),
				min_grade = -1,
				max_grade = -1}
			self:RefreshTargetBtton(tTargetInfo)
		else
			self:RefreshTargetBtton(g_TeamCtrl:GetTeamTargetInfo())
		end
		g_TeamCtrl:CtrlC2GSTeamCountInfo()

	elseif oCtrl.m_EventID == define.Team.Event.PartnerUpdate then
		if g_TeamCtrl:IsJoinTeam() then
			local TeamPos = oCtrl.m_EventData
			local dMember = g_TeamCtrl:GetMemberByPos(TeamPos)
			local dPartner =g_TeamCtrl:GetPartnerByPos(TeamPos)
			self:RefreshTargetPosMemberBox(TeamPos, dMember, dPartner)
		end

	end
end

function CTeamMainPage.OnCtrlPartnerEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Partner.Event.FightChange then
		--非组队下，更新出战伙伴
		if not g_TeamCtrl:IsJoinTeam() then
			for i = 1, 4 do
				local dMember = nil
				local dPartner = nil
				if i == 1 then
					dMember = g_TeamCtrl:GetMemberByPos(i)
				end
				dPartner = g_TeamCtrl:GetPartnerByPos(i)
				--table.print(dMember)
				--table.print(dPartner)		
				self:RefreshTargetPosMemberBox(i, dMember, dPartner)
			end
		end		
	end
end

function CTeamMainPage.InitMemberGrid(self)
	for i=1, 4 do
		local oBox = self.m_MemberBox:Clone()
		oBox.m_MemberGroup = oBox:NewUI(13, CBox)
		oBox.m_InviteGroup = oBox:NewUI(14, CBox)
		oBox.m_PartnerLockLabel = oBox:NewUI(19, CLabel)
		oBox.Pos = i
		self.m_MemberBoxs[i] = oBox
		self.m_MemberGrid:AddChild(oBox)
		oBox:SetActive(true)
	end
end

function CTeamMainPage.RefreshTargetPosMemberBox(self, pos, dMember, dPartner)
	local tMember = nil
	local tPartner = nil
	if dMember == nil and dPartner == nil then
		local tList = g_TeamCtrl:GetMamberAndPartnerList()
		local tMenberList = tList.Member
		local tPartnerList = tList.Partner
		tMember = tMenberList[pos]
		tPartner = tPartnerList[pos]
		table.print(tPartner)
	else
		tMember = dMember
		tPartner = dPartner
	end

	local oBox = self.m_MemberBoxs[pos]
	if tMember or tPartner then
		oBox.m_MemberGroup:SetActive(true)
		oBox.m_InviteGroup:SetActive(false)
		oBox.m_PartnerLockLabel:SetActive(false)
		oBox:SetMember(tMember, tPartner)
		oBox:AddUIEvent("click", callback(self, "OnMember"))
	else
		local iAmount = g_WarCtrl:GetMaxFightAmount()
		oBox.m_MemberGroup:SetActive(false)
		if iAmount < pos then
			oBox.m_PartnerLockLabel:SetActive(true)
			oBox.m_PartnerLockLabel:SetText(self:GetLockReplaceTip(pos))
			oBox.m_InviteGroup:SetActive(false) 
		else
			oBox.m_PartnerLockLabel:SetActive(false)
			oBox.m_InviteGroup:SetActive(true)
			oBox:AddUIEvent("click", callback(self, "OnPartnerShow"))
		end
	end
end

function CTeamMainPage.GetLockReplaceTip(self, i)
	local level = data.roletypedata.FightAmount[i].level
	return string.format("主角达到%d级\n可解锁", level, i)
end

function CTeamMainPage.RefreshMemberGrid(self)
	-- self.m_MemberGrid:Clear()
	local tList = g_TeamCtrl:GetMamberAndPartnerList()
	local tMenberList = tList.Member
	local tPartnerList = tList.Partner
	self.m_MemberCount = #tMenberList
	for i=1, 4 do
		local dMember = tMenberList[i]
		local dPartner = tPartnerList[i]
		self:RefreshTargetPosMemberBox(i, dMember, dPartner)
	end
end

function CTeamMainPage.OnPartnerShow(self, oMemberBox)
	--如果是队长或者费组队才可以交换伙伴
	local bIsJoinTeam = g_TeamCtrl:IsJoinTeam()
	local bIsLeader = g_TeamCtrl:IsLeader()
	if (not bIsJoinTeam) or bIsLeader then
		local pos = oMemberBox.Pos
		CPartnerChooseView:ShowView(function (oView)
			oView:SetFilterCb(callback(self, "OnFilter"))
			oView:SetConfirmCb(callback(self, "OnChange", pos))
		end)
	end
end

function CTeamMainPage.OnMember(self, oMemberBox)
	local isMember = oMemberBox:IsMember()
	local isSelf = isMember and (oMemberBox.m_Member.pid == g_AttrCtrl.pid) or false 
	local IsLeader = g_TeamCtrl:IsLeader()
	local IsJoinTeam = g_TeamCtrl:IsJoinTeam()
	local mId = oMemberBox.m_Member and oMemberBox.m_Member.pid or nil
	local pId = nil 
	if oMemberBox.m_Member and oMemberBox.m_Member.partner_info ~= nil then
		pId = oMemberBox.m_Member.partner_info.parid
	else
		pId = oMemberBox.m_Partner and oMemberBox.m_Partner.parid or nil
	end
	local pos = oMemberBox.Pos
	self.m_TeampChangePartnerId = pId
	--组队情况下
	if IsJoinTeam then
		if IsLeader then			
			if isMember and not isSelf then
				CTeamMemberOpView:ShowView(function(oView)
					oView:ShowTeamViewOp(mId)
					oView:SetBg("pic_zhujiemian_sanji_diban_ecsd")
					UITools.NearTarget(oMemberBox.m_LocWidget, oView.m_Bg, enum.UIAnchor.Side.Right)
				end)
			else
				CTeamMemberOpView:ShowView(function(oView)
					oView:ShowTeamViewPartnerOp(pId, pos, IsJoinTeam, IsLeader, self)
					oView:SetBg("pic_zhujiemian_sanji_diban_ecsd")
					UITools.NearTarget(oMemberBox.m_LocWidget, oView.m_Bg, enum.UIAnchor.Side.Right)
				end)
			end

		else
			if isSelf then
				CTeamMemberOpView:ShowView(function(oView)
					oView:ShowTeamViewPartnerOp(pId, pos, IsJoinTeam, IsLeader, self)
					oView:SetBg("pic_zhujiemian_sanji_diban_ecsd")
					UITools.NearTarget(oMemberBox.m_LocWidget, oView.m_Bg, enum.UIAnchor.Side.Right)
				end)
			elseif isMember then
				CTeamMemberOpView:ShowView(function(oView)
					oView:ShowTeamViewOp(mId)
					oView:SetBg("pic_zhujiemian_sanji_diban_ecsd")
					UITools.NearTarget(oMemberBox.m_LocWidget, oView.m_Bg, enum.UIAnchor.Side.Right)
				end)
			end
		end

	--非组队情况下
	else
		CTeamMemberOpView:ShowView(function(oView)
				oView:ShowTeamViewPartnerOp(pId, pos, IsJoinTeam, false, self)
				oView:SetBg("pic_zhujiemian_sanji_diban_ecsd")
				UITools.NearTarget(oMemberBox.m_LocWidget, oView.m_Bg, enum.UIAnchor.Side.Right)
		end)
	end
end



function CTeamMainPage.RefreshAll(self)
	local bIsJoinTeam = g_TeamCtrl:IsJoinTeam()
	local bIsLeader = g_TeamCtrl:IsLeader()
	self.m_NoTeamBox:SetActive(false)
	self.m_InTeamLeaderBox:SetActive(false)
	self.m_InTeamNoLeaderBox:SetActive(false)
	self.m_InvitePlayerBtn:SetActive(false)

	if bIsJoinTeam then
		if bIsLeader then
			self.m_InTeamLeaderBox:SetActive(true)
			self.m_InvitePlayerBtn:SetActive(true)
		else
			self.m_InTeamNoLeaderBox:SetActive(true)
			if g_TeamCtrl:IsInTeam() then
				self.m_InTeamNoLeaderBox.m_LeaveBtn:SetText("暂离队伍")
			else
				self.m_InTeamNoLeaderBox.m_LeaveBtn:SetText("回归队伍")
			end
		end
	else
		self.m_NoTeamBox:SetActive(true)
	end
	self:RefreshMemberGrid()
	self:RefrehNotifyTip()
	self:RefreshButtonStatus()
	self:RefreshTargetBtton(g_TeamCtrl:GetTeamTargetInfo())
end

function CTeamMainPage.OnCreateTeam(self)
	g_TeamCtrl:C2GSCreateTeam()
end

function CTeamMainPage.OnQuitTeam(self)
	if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSLeaveTeam"]) then
		netteam.C2GSLeaveTeam()
	end
end

function CTeamMainPage.OnAutoMatch(self)
	local t = g_TeamCtrl:GetTeamTargetInfo()
	if g_TeamCtrl.m_IsTeamMatch then
		g_TeamCtrl:C2GSTeamAutoMatch(t.auto_target, t.min_grade, t.max_grade, 0)		
	else
		if g_TeamCtrl:CanAutoMatchTeam(t.auto_target, t.min_grade, t.max_grade) then		
			g_TeamCtrl:C2GSTeamAutoMatch(t.auto_target, t.min_grade, t.max_grade, 1)			
		end
	end
end

function CTeamMainPage.OnApplyList(self)
	if g_TeamCtrl:IsJoinTeam() then
		if next(g_TeamCtrl.m_Applys) then
			CTeamApplyView:ShowView()
		else
			g_NotifyCtrl:FloatMsg("暂时还没有人申请入队哦")
		end
	end
end

function CTeamMainPage.OnInviteList(self)
	if not g_TeamCtrl:IsJoinTeam() then
		if next(g_TeamCtrl.m_Invites) then
			CTeamInviteView:ShowView()
		else
			g_NotifyCtrl:FloatMsg("暂时还没有人邀请你入队哦")
		end
	end
end

function CTeamMainPage.RefrehNotifyTip(self)
	local bTip = false
	if g_TeamCtrl:IsJoinTeam() then 
		bTip = next(g_TeamCtrl.m_UnreadApply) ~= nil and g_TeamCtrl:IsLeader()
		if bTip then
			self.m_InTeamLeaderBox.m_ApplyBtn:AddEffect("RedDot")
		else
			self.m_InTeamLeaderBox.m_ApplyBtn:DelEffect("RedDot")
		end
	else
		self.m_InTeamLeaderBox.m_ApplyBtn:DelEffect("RedDot")
	end
end

function CTeamMainPage.OnLeaveTeam(self)
	if g_TeamCtrl:IsInTeam() then 
		if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSShortLeave"]) then
			netteam.C2GSShortLeave()
		end
	else 
		if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSBackTeam"]) then
			netteam.C2GSBackTeam()
		end
	end
end

function CTeamMainPage.OnFastCall(self)
	if g_TeamCtrl:HasMemberLeave() then 
		g_NotifyCtrl:FloatMsg("已召唤暂离队员归队")
		if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSTeamSummon"]) then
			netteam.C2GSTeamSummon(0)
		end
	else
		g_NotifyCtrl:FloatMsg("无暂离队员可召回")
	end
end

function CTeamMainPage.OnTeamSet(self)
	CTeamSettingView:ShowView()
end

function CTeamMainPage.RefreshButtonStatus(self)
	local bIsJoinTeam = g_TeamCtrl:IsJoinTeam()
	local bIsTeamAutoMatch = g_TeamCtrl:IsTeamAutoMatch()
	local bIsPlayerAutoMatch = g_TeamCtrl:IsPlayerAutoMatch()
	local bIsLeader = g_TeamCtrl:IsLeader(g_AttrCtrl.pid)
	local dTargetInfo = g_TeamCtrl:GetTeamTargetInfo()
	local bIsDefaultTask = dTargetInfo.auto_target == g_TeamCtrl.TARGET_NONE

	self.m_TipsLabel:SetActive(false)
	self.m_AutoTeamWidget:SetActive(false)	

	self.m_TeamTargetBtn:SetActive(bIsJoinTeam)
	self.m_TeamTargtLevelBtn:SetActive(bIsJoinTeam)
	--self.m_TeamTargetInfoBtn:SetActive(bIsJoinTeam)

	if not bIsJoinTeam and not bIsPlayerAutoMatch then
		return
	end

	if bIsTeamAutoMatch then
		self.m_InTeamLeaderBox.m_AutoMatchBtn:SetText("取消匹配")
	else
		self.m_InTeamLeaderBox.m_AutoMatchBtn:SetText("自动匹配")
	end
end

function CTeamMainPage.RefreshTargetBtton(self, dAutoInfo)
	if not g_TeamCtrl:IsJoinTeam() then
		self.m_LevelLabel:SetActive(false)
		self.m_TargetLabel:SetText("目标:无")
		return
	end
	if next(dAutoInfo) == nil then
		return
	end
	local sTarget = "无"
	local tData = data.teamdata.AUTO_TEAM[dAutoInfo.auto_target]
	if tData then
		sTarget = tData.title_name
	end

	if dAutoInfo.min_grade < 0 then
		self.m_TargetLabel:SetText(string.format("目标:%s", sTarget))
		self.m_LevelLabel:SetActive(false)

		self.m_TeamTargetLabel:SetText(string.format("%s", sTarget))
		self.m_TeamTargetLevelLabel:SetText(string.format("等级:%d - %d", 0, dAutoInfo.max_grade))
	else
		self.m_TargetLabel:SetText(string.format("目标:%s", sTarget))
		self.m_LevelLabel:SetActive(true)
		self.m_LevelLabel:SetText(string.format("等级:%d - %d", dAutoInfo.min_grade, dAutoInfo.max_grade))

		self.m_TeamTargetLabel:SetText(string.format("%s", sTarget))
		self.m_TeamTargetLevelLabel:SetText(string.format("等级:%d - %d", dAutoInfo.min_grade, dAutoInfo.max_grade))
	end
end

function CTeamMainPage.OnClickTargetChange(self)
	local bIsJoinTeam = g_TeamCtrl:IsJoinTeam()
	local bIsPlayerAutoMatch = g_TeamCtrl:IsPlayerAutoMatch()
	local bIsLeader = g_TeamCtrl:IsLeader(g_AttrCtrl.pid)

	if not (bIsJoinTeam and  bIsLeader) then
		g_NotifyCtrl:FloatMsg("你必须先创建队伍才能修改组队信息")
		return
	end

	if bIsLeader then
		CTeamFilterView:ShowView(function(oView)
			oView:SetListener(callback(self, "OnSetTarget"))
		end)
	end
end

function CTeamMainPage.OnClickTeamTarget(self)
	local bIsJoinTeam = g_TeamCtrl:IsJoinTeam()
	local bIsLeader = g_TeamCtrl:IsLeader(g_AttrCtrl.pid)
	local auto_target = g_TeamCtrl:GetTeamTargetInfo().auto_target
	self.m_LocalTaskId = nil

	if bIsJoinTeam and bIsLeader then
		 g_WindowTipCtrl:SetWindowTeamTarget(
		 	{
		 	  valueCallback = callback(self, "OnTeamTargetChange"),
		 	  closeCallback = callback(self, "OnTeanTargetChangeEnd"),
		 	  taskId = auto_target,
		 	},
		 	{ widget = self.m_TeamTargetBtn, side = enum.UIAnchor.Side.Bottom, offset = Vector2.New(5, -5)}
		 )
		 self.m_TeamTargetBtn.m_FlagSpr.TweenRotation:Toggle()
	else
		g_NotifyCtrl:FloatMsg("请让队长来进行修改")
	end
end

function CTeamMainPage.OnTeamTargetChange(self, taskId)
	if g_TeamCtrl:CanManualCreareTarget(taskId) then
		self.m_LocalTaskId = taskId 
	end
end

function CTeamMainPage.OnTeanTargetChangeEnd(self)
	self.m_TeamTargetBtn.m_FlagSpr.TweenRotation:Toggle()
	if self.m_LocalTaskId ~= nil then
		local tTargetInfo = g_TeamCtrl:GetTeamTargetInfo()
		if tTargetInfo.auto_target ~= self.m_LocalTaskId then
			local min, max = g_TeamCtrl:GetTeamTargetDefaultLevel(self.m_LocalTaskId)
			self:OnSetTeamTarget(self.m_LocalTaskId, min, max)
		end
	end
end

function CTeamMainPage.OnClickTeamTargetLevel(self)
	local bIsJoinTeam = g_TeamCtrl:IsJoinTeam()
	local bIsLeader = g_TeamCtrl:IsLeader(g_AttrCtrl.pid)

	if bIsJoinTeam and bIsLeader then
		local tTargetInfo = g_TeamCtrl:GetTeamTargetInfo()
		g_WindowTipCtrl:SetWindowTeamLevel(	
			{	
				iTaskId = tTargetInfo.auto_target,
				iMaxGrade = tTargetInfo.max_grade,
			    iMinGrade = tTargetInfo.min_grade,
			    valueCallback = callback(self, "OnTeamLevelChange"),
			    okCallback =  callback(self, "OnTeamLeveEnd")
			},
			{ widget = self.m_TeamTargtLevelBtn, side = enum.UIAnchor.Side.Bottom, offset = Vector2.New(5, -25)}
		)

		self.m_TeamTargtLevelBtn.m_FlagSpr.TweenRotation:Toggle()
	else
		g_NotifyCtrl:FloatMsg("请让队长来进行修改")
	end
end

function CTeamMainPage.OnTeamLevelChange(self, iMin, iMax)	
	self.m_TeamTargetLevelLabel:SetText(string.format("等级:%d - %d", iMin, iMax))
end

function CTeamMainPage.OnTeamLeveEnd(self, iMin, iMax)
	self.m_TeamTargtLevelBtn.m_FlagSpr.TweenRotation:Toggle()
	if iMax < iMin then
		iMax, iMin = iMin, iMax
	end
	local tTargetInfo = g_TeamCtrl:GetTeamTargetInfo()
	self:OnSetTeamTarget(tTargetInfo.auto_target, iMin, iMax)
end

function CTeamMainPage.OnClickTeamTargetInfo(self)
	local bIsJoinTeam = g_TeamCtrl:IsJoinTeam()
	local bIsLeader = g_TeamCtrl:IsLeader(g_AttrCtrl.pid)

	if bIsJoinTeam then
		CTeamFilterView:ShowView(function(oView)
			oView:SetListener(callback(self, "OnSetTarget"))
		end)
	end
end

function CTeamMainPage.OnClickRecruit(self)
	local tTargetInfo = g_TeamCtrl:GetTeamTargetInfo()
	if tTargetInfo.auto_target == g_TeamCtrl.TARGET_NONE then
		g_NotifyCtrl:FloatMsg("请先调整目标")
		return
	end
	if not g_TeamCtrl:IsJoinTeam() then
		g_NotifyCtrl:FloatMsg("请先创建队伍并调整目标")
		return
	end

	CChatMainView:ShowView(function(oView)
		oView:SwitchChannel(define.Channel.World)
		oView:SetPreviousView(self.m_ParentView)

		local tData = data.teamdata.AUTO_TEAM[tTargetInfo.auto_target]
		local iMatchCount = tData.match_count
		local sTeamCount  = string.format("（%d/%d）", self.m_MemberCount, iMatchCount)
		local sTarget = string.format("%s%d-%d级%s", tData.name, tTargetInfo.min_grade, tTargetInfo.max_grade, sTeamCount)
		local filterLink = LinkTools.GenerateGetTeamFilterLink(tTargetInfo.min_grade, tTargetInfo.max_grade)
		local targetLink = LinkTools.GenerateGetTeamInfoLink(g_TeamCtrl.m_TeamID, sTarget)
		local applyLink = LinkTools.GenerateApplyTeamLink(g_TeamCtrl.m_LeaderID)
		local msg = filterLink..targetLink..applyLink

		-- g_ChatCtrl:SendMsg(msg, define.Channel.World)
		oView.m_ChatPart:AppendText(msg)
	end)
end

function CTeamMainPage.OnSetTarget(self, view)
	local taskId, min, max = view:GetTeamFilterInfo()	
	if max < min then
		min, max = max, min
	end
	local tAutoInfo = {
		auto_target = taskId,
		min_grade = min,
		max_grade = max
	}

	if g_TeamCtrl:IsJoinTeam() and g_TeamCtrl:IsLeader() then
		if g_TeamCtrl:IsTeamAutoMatch() then
			--如果设置为无目标时，当前停止匹配
			if taskId == CTeamCtrl.TARGET_NONE then
				g_TeamCtrl:C2GSTeamCancelAutoMatch()
				g_TeamCtrl:C2GSSetTeamTarget(taskId, min, max)			
			else
				g_TeamCtrl:C2GSTeamAutoMatch(taskId, min, max, 1)
			end
		else
			--如果目前没有在自动匹配，则更新组队目标
			g_TeamCtrl:C2GSSetTeamTarget(taskId, min, max)
		end
	end
	self:RefreshTargetBtton(tAutoInfo)
end

function CTeamMainPage.OnSetTeamTarget(self, taskId, min, max)
	if max < min then
		min, max = max, min
	end
	local tAutoInfo = {
		auto_target = taskId,
		min_grade = min,
		max_grade = max
	}
	if g_TeamCtrl:IsJoinTeam() and g_TeamCtrl:IsLeader() then
		if g_TeamCtrl:IsTeamAutoMatch() then
			--如果设置为无目标时，当前停止匹配
			if taskId == CTeamCtrl.TARGET_NONE then
				g_TeamCtrl:C2GSTeamCancelAutoMatch()
				g_TeamCtrl:C2GSSetTeamTarget(taskId, min, max)			
			else
				g_TeamCtrl:C2GSTeamAutoMatch(taskId, min, max, 1)
			end
		else
			--如果目前没有在自动匹配，则更新组队目标
			g_TeamCtrl:C2GSSetTeamTarget(taskId, min, max)
		end
	end
	self:RefreshTargetBtton(tAutoInfo)
end

function CTeamMainPage.OnTargetChange(self, taskId, min, max)
	local tAutoInfo = {
		auto_target = taskId,
		min_grade = min,
		max_grade = max
	}
	self:RefreshTargetBtton(tAutoInfo)
end

function CTeamMainPage.OnClickInvitePlayers(self )
	CTeamInvitePlayersView:ShowView()
end

function CTeamMainPage.Destroy(self )
	if self.m_MemberGrid then
		for i, oBox in ipairs(self.m_MemberGrid:GetChildList()) do
			if oBox.classname == "CTeamMemberBox" then
				oBox:Destroy()
			end
		end	
	end	
	CPageBase.Destroy(self)
end


function CTeamMainPage.OnChange(self, pos, partId)
	if partId and pos then
		g_PartnerCtrl:C2GSPartnerFight(pos, partId)
	end
end

function CTeamMainPage.OnFilter(self, parList)
	local list = {}
	for k, oPartner in ipairs(parList) do
		if oPartner:GetValue("parid") ~= self.m_TeampChangePartnerId and oPartner:GetValue("partner_type") ~= 1754 and 
		oPartner:GetValue("partner_type") ~= 1755 then
			table.insert(list, oPartner)
		end
	end
	return list
end

function CTeamMainPage.OnFastTalk(self )
	local tTargetInfo = g_TeamCtrl:GetTeamTargetInfo()
	if tTargetInfo.auto_target == g_TeamCtrl.TARGET_NONE then
		g_NotifyCtrl:FloatMsg("请先调整目标")
		return
	end
	if g_TeamCtrl:CanFastTalk() then
		local tData = data.teamdata.AUTO_TEAM[tTargetInfo.auto_target]
		local iMatchCount = tData.match_count
		local sTeamCount  = string.format("(%d/%d)", g_TeamCtrl:GetMemberSize(), iMatchCount)		
		local sTarget = string.format("%s 等级%d 组队目标:%s(等级%d~%d级) %s", g_AttrCtrl.name, g_AttrCtrl.grade, tData.name, tTargetInfo.min_grade, tTargetInfo.max_grade, sTeamCount)		
		local filterLink = LinkTools.GenerateGetTeamFilterLink(tTargetInfo.min_grade, tTargetInfo.max_grade)
		local targetLink = LinkTools.GenerateGetTeamInfoLink(g_TeamCtrl.m_TeamID, sTarget)
		local applyLink = LinkTools.GenerateApplyTeamLink(g_TeamCtrl.m_LeaderID)
		local msg = filterLink..targetLink..applyLink
		local extraargs = 1 --一键喊话额外参数
		g_ChatCtrl:SendMsg(msg, define.Channel.Team, extraargs)
		g_ChatCtrl:SendMsg(msg, define.Channel.Team)
		g_NotifyCtrl:FloatMsg("成功发布组队信息，请耐心等待队员加入")
		self.m_ParentView:CloseView()
	end
end

return CTeamMainPage