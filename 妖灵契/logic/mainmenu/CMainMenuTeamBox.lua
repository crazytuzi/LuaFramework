local CMainMenuTeamBox = class("CMainMenuTeamBox", CBox)

function CMainMenuTeamBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_TeamBtn = self:NewUI(1, CButton)
	self.m_TeamGrid = self:NewUI(2, CGrid)
	self.m_TeamMemberBox = self:NewUI(3, CBox)
	self.m_MainLabel = self:NewUI(4, CLabel)
	self.m_MatchLabel = {}
	self.m_MatchLabel[1] = self:NewUI(5, CLabel)
	self.m_MatchLabel[2] = self:NewUI(6, CLabel)
	self.m_MatchLabel[3] = self:NewUI(7, CLabel)
	self.m_SubLabel = self:NewUI(8, CLabel)

	self.m_TeamTimer = nil
	self.m_MemberBoxList = {}

	self:InitContent()
	self:RefreshAll()
end

function CMainMenuTeamBox.InitContent(self)
	self.m_TeamMemberBox:SetActive(false)
	self:SetTeamLabel()
	self.m_TeamBtn:AddUIEvent("click", callback(self, "OnShowTeam"))
	g_TeamCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTeamCtrlEvent"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrEvent"))
end

function CMainMenuTeamBox.RefreshAll(self)
	local isJoinTeam =  g_TeamCtrl:IsJoinTeam()
	self.m_TeamGrid:SetActive(isJoinTeam)
	if isJoinTeam then
		local tTargetInfo = g_TeamCtrl:GetTeamTargetInfo()
		local tData = data.teamdata.AUTO_TEAM[tTargetInfo.auto_target]
		local iMatchCount = tData.match_count or 4
		local lMemberList = g_TeamCtrl:GetMemberList()
		for i = 1, 4 do
			local oBox = self.m_MemberBoxList[i]
			if not oBox then
				oBox = self:CreateMemberBox()
				table.insert(self.m_MemberBoxList, oBox)
				self.m_TeamGrid:AddChild(oBox)
			end
			oBox:SetActive(true)
			local dMember = lMemberList[i]
			oBox.m_InviteBox:SetActive(false)
			oBox.m_MemberBox:SetActive(false)
			if dMember then
				oBox.m_MemberBox:SetActive(true)
				self:UpdateBoxMember(oBox, dMember)
			else
				if i <= iMatchCount then
					oBox.m_InviteBox:SetActive(true)
				else
					oBox:SetActive(false)
				end
			end
		end
		self.m_TeamGrid:Reposition()
	end
end

function CMainMenuTeamBox.OnShowTeam(self)
	g_GuideCtrl:ReqTipsGuideFinish("mainmenu_team_btn")
	if not g_TeamCtrl:IsJoinTeam() and g_TeamCtrl:IsPlayerAutoMatch() then
		CTeamMainView:ShowView(function (oView )
			oView:ShowTeamPage(CTeamMainView.Tab.HandyBuild)
		end)
	else
		CTeamMainView:ShowView(function (oView )
			oView:ShowTeamPage(CTeamMainView.Tab.TeamMain)
		end)
	end
end

function CMainMenuTeamBox.OnTeamCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Team.Event.AddTeam or
		oCtrl.m_EventID == define.Team.Event.DelTeam or 
		oCtrl.m_EventID == define.Team.Event.NotifyAutoMatch then
			self:RefreshAll()
	elseif oCtrl.m_EventID == define.Team.Event.MemberUpdate then
		for i, oBox in ipairs(self.m_TeamGrid:GetChildList()) do
			if oBox.m_Member and oBox.m_Member.pid == oCtrl.m_EventData.pid then
				self:UpdateBoxMember(oBox, oCtrl.m_EventData)
				break
			end
		end
	end
	self:SetTeamLabel()
end

function CMainMenuTeamBox.UpdateBoxMember(self, oBox, dMember)
	oBox.m_Member = dMember
	oBox.m_LiXianBox:SetActive(false)
	oBox.m_ZanLiBox:SetActive(false)
	oBox.m_LeaderBox:SetActive(false)

	if g_TeamCtrl:IsOffline(dMember.pid) then
		oBox.m_LiXianBox:SetActive(true)
	elseif g_TeamCtrl:IsLeave(dMember.pid) then
		oBox.m_ZanLiBox:SetActive(true)
	else
		if g_TeamCtrl:IsLeader(dMember.pid)  then 
			oBox.m_LeaderBox:SetActive(true)
		end		
	end
	oBox.m_GradeLabel:SetText(tostring(dMember.grade))
	oBox.m_IconSprite:SpriteMainMenuTeamAvatarBig(dMember.model_info.shape)
	oBox.m_MemberBox:AddUIEvent("click", callback(self, "OnMemberBox", oBox))
end

function CMainMenuTeamBox.CreateMemberBox(self)
	local oBox = self.m_TeamMemberBox:Clone()
	oBox.m_MemberBox = oBox:NewUI(1, CBox)
	oBox.m_InviteBox = oBox:NewUI(2, CBox)
	oBox.m_IconSprite = oBox:NewUI(3, CSprite)
	oBox.m_GradeLabel = oBox:NewUI(4, CLabel)
	oBox.m_LeaderBox = oBox:NewUI(5, CBox)
	oBox.m_ZanLiBox = oBox:NewUI(6, CBox)
	oBox.m_LiXianBox = oBox:NewUI(7, CBox)
	oBox.m_InviteBox:AddUIEvent("click", callback(self, "OnShowInviteView"))
	return oBox
end

function CMainMenuTeamBox.OnMemberBox(self, oBox)
	local oOpenView = CTeamMemberOpView:GetView()
	local function process(view)
		view:ShowExpandViewOp(oBox.m_Member.pid)
		view:ShowArrow()
		UITools.NearTarget(oBox, view.m_Bg, enum.UIAnchor.Side.Bottom, Vector2.New(0, -20))
	end
	if oOpenView then
		if oOpenView.m_Pid ~= oBox.m_Member.pid then
			oOpenView:SetStrikeResult(true)
			process(oOpenView)
		end
	else
		CTeamMemberOpView:ShowView(function(oView)
			process(oView)
		end)
	end
end

function CMainMenuTeamBox.OnShowInviteView(self)
	CTeamInvitePlayersView:ShowView()
end

function CMainMenuTeamBox.OnShowView(self)
	self.m_TeamBtn:SetActive(g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.team.open_grade)
	g_GuideCtrl:AddGuideUI("mainmenu_team_btn", self.m_TeamBtn)
	local guide_ui = {"mainmenu_team_btn"}
	g_GuideCtrl:LoadTipsGuideEffect(guide_ui)
end

function CMainMenuTeamBox.OnAttrEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then		
		self.m_TeamBtn:SetActive(g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.team.open_grade)
	end
end

function CMainMenuTeamBox.SetTeamLabel(self)
	local bMatch = false
	self.m_MainLabel:SetActive(false)
	self.m_SubLabel:SetActive(false)
	self.m_MatchLabel[1]:SetActive(false)
	self.m_MatchLabel[2]:SetActive(false)
	self.m_MatchLabel[3]:SetActive(false)

	if self.m_TeamTimer then
		Utils.DelTimer(self.m_TeamTimer)
		self.m_TeamTimer = nil
	end

	if g_TeamCtrl:IsJoinTeam() then
		if g_TeamCtrl:IsLeader() then
			bMatch = g_TeamCtrl:IsTeamAutoMatch()
			if bMatch then
				local t = g_TeamCtrl:GetTeamTargetInfo()
				local d = data.autoteamdata.DATA[t.auto_target]
				self.m_SubLabel:SetText(d.sub_name)
			end
		end
	else
		bMatch = g_TeamCtrl:IsPlayerAutoMatch()
		if bMatch then
			local t = g_TeamCtrl:GetPlayerTargetInfo()
			local d = data.autoteamdata.DATA[t.auto_target]
			self.m_SubLabel:SetText(d.sub_name)
		end
	end

	if bMatch then
		self.m_SubLabel:SetActive(true)
		self.m_MatchLabel[1]:SetActive(true)
		self.m_MatchLabel[2]:SetActive(true)
		self.m_MatchLabel[3]:SetActive(true)
		self.m_TeamAniIdx = 0
		self.m_TeamTimer = Utils.AddTimer(callback(self, "UpdateTeamMatch"), 0.2, 0)

	else
		self.m_MainLabel:SetActive(true)		
	end
end

function CMainMenuTeamBox.UpdateTeamMatch(self)
	if Utils.IsNil(self) then
		return false
	end
	self.m_TeamAniIdx = self.m_TeamAniIdx + 1
	if self.m_TeamAniIdx > 3 then
		self.m_TeamAniIdx = 1
	end
	for i, v in ipairs(self.m_MatchLabel) do
		local pos = Vector3.New(-50 + i * 25, i == self.m_TeamAniIdx and -25 or -30, 0 )
		v:SetLocalPos(pos)
	end
	return true
end

return CMainMenuTeamBox
