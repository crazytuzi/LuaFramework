local CExpandTeamPage = class("CExpandTeamPage", CPageBase)

function CExpandTeamPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CExpandTeamPage.OnInitPage(self)
	self.m_Grid = self:NewUI(1, CGrid)
	self.m_BoxClone = self:NewUI(2, CBox)
	self.m_SingleWidget = self:NewUI(3, CWidget)
	self.m_CreateBtn = self:NewUI(4, CButton)
	self.m_SearchBtn = self:NewUI(5, CButton)
	self.m_AutoMatchWidget = self:NewUI(6, CBox)
	self.m_TargetLabel = self:NewUI(7, CLabel)
	self.m_CancelButton = self:NewUI(8, CButton)
	self.m_InviteBoxClone = self:NewUI(9, CBox)
	self.m_TargetLevelLabel = self:NewUI(10, CLabel)
	self.m_TeamMemberBgSprite = self:NewUI(11, CSprite)
	self:InitContent()
end

function CExpandTeamPage.InitContent(self)
	self.m_BoxClone:SetActive(false)
	self.m_InviteBoxClone:SetActive(false)

	self.m_CreateBtn:AddUIEvent("click", callback(self, "OnCreate"))
	self.m_SearchBtn:AddUIEvent("click", callback(self, "OnSearch"))
	self.m_CancelButton:AddUIEvent("click", callback(self, "OnCancelAutoMatch"))
	g_TeamCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	self:RefreshAll()
end

function CExpandTeamPage.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Team.Event.AddTeam or
		oCtrl.m_EventID == define.Team.Event.DelTeam or 
		oCtrl.m_EventID == define.Team.Event.NotifyAutoMatch then
			self:RefreshAll()
	elseif oCtrl.m_EventID == define.Team.Event.MemberUpdate then
		for i, oBox in ipairs(self.m_Grid:GetChildList()) do
			if oBox.m_Member and oBox.m_Member.pid == oCtrl.m_EventData.pid then
				self:UpdateBoxMember(oBox, oCtrl.m_EventData)
				break
			end
		end
	end
end

function CExpandTeamPage.RefreshAll(self)
	self.m_SingleWidget:SetActive(not g_TeamCtrl:IsJoinTeam() and not g_TeamCtrl:IsPlayerAutoMatch())
	self:RefreshGrid()
	self:RefreshTargetPanel()
end

function CExpandTeamPage.RefreshTargetPanel(self)
	self.m_AutoMatchWidget:SetActive(g_TeamCtrl:IsPlayerAutoMatch())
	if not g_TeamCtrl:IsPlayerAutoMatch() then
		return
	end
	local tTargetInfo = g_TeamCtrl:GetPlayerTargetInfo()
	local tData = data.teamdata.AUTO_TEAM[tTargetInfo.auto_target]
	self.m_TargetLevelLabel:SetText(string.format("%d - %d 级", tTargetInfo.min_grade, tTargetInfo.max_grade))
	self.m_TargetLabel:SetText(string.format("目标:%s", tData.name))
end

function CExpandTeamPage.RefreshGrid(self)
	self.m_Grid:Clear()
	local iCount = 5
	local lMemberList = g_TeamCtrl:GetMemberList()
	local bIsAutoMatch = g_TeamCtrl:IsTeamAutoMatch()
	local tTarget = g_TeamCtrl:GetTeamTargetInfo()
	local tData = nil

	self:RefreshMemberBg(#lMemberList)

	if #lMemberList == 0 then
		return
	end

	if bIsAutoMatch then
		tData = data.teamdata.AUTO_TEAM[tTarget.auto_target]
		iCount = tData.match_count
	end

	for i = 1, iCount do
		local dMember = lMemberList[i]
		local oBox = nil
		if dMember then
			oBox = self:CreateMemberBox()
			self:UpdateBoxMember(oBox, dMember)
			self.m_Grid:AddChild(oBox)
	
		else
			--隐藏邀请组队
			--oBox = self:CreateInviteBox(bIsAutoMatch)
			--self.m_Grid:AddChild(oBox)
			break
		end
	end
	self.m_Grid:Reposition()
end

function CExpandTeamPage.CreateInviteBox(self, bIsAutoMatch)
	local oBox = self.m_InviteBoxClone:Clone()
	oBox:SetActive(true)
	oBox.m_TargetLabel = oBox:NewUI(1, CLabel)
	oBox.m_InviteBtn = oBox:NewUI(2, CButton)
	oBox.m_TipLabel = oBox:NewUI(3, CLabel)

	if bIsAutoMatch then
		local tTarget = g_TeamCtrl:GetTeamTargetInfo()
		local tData = data.teamdata.AUTO_TEAM[tTarget.auto_target]
		oBox.m_TargetLabel:SetText(tData.name)
	end

	oBox.m_TargetLabel:SetActive(bIsAutoMatch)
	oBox.m_TipLabel:SetActive(not bIsAutoMatch)

	oBox.m_InviteBtn:AddUIEvent("click", callback(self, "OnInvite"))
	oBox:AddUIEvent("click", callback(self, "OpenTeamFiterView"))
	return oBox
end

function CExpandTeamPage.CreateMemberBox(self)
	local oBox = self.m_BoxClone:Clone()
	oBox:SetActive(true)
	oBox.m_IconSprite = oBox:NewUI(1, CSprite)
	oBox.m_NameLabel = oBox:NewUI(2, CLabel)
	oBox.m_GradeLabel = oBox:NewUI(3, CLabel)
	oBox.m_UnLineBox = oBox:NewUI(4, CBox)
	oBox.m_LeaderBox = oBox:NewUI(5, CBox)
	oBox.m_LeaveBox = oBox:NewUI(6, CBox)
	oBox.m_SignSprite = oBox:NewUI(7, CSprite)
	oBox.m_SchoolSprite = oBox:NewUI(8, CSprite)
	oBox.m_SchoolLabel = oBox:NewUI(9, CLabel)
	return oBox
end

function CExpandTeamPage.UpdateBoxMember(self, oBox, dMember)
	oBox.m_Member = dMember
	oBox.m_UnLineBox:SetActive(false)
	oBox.m_LeaveBox:SetActive(false)
	oBox.m_LeaderBox:SetActive(false)
	if g_TeamCtrl:IsOffline(dMember.pid) then
		oBox.m_UnLineBox:SetActive(true)
	elseif g_TeamCtrl:IsLeave(dMember.pid) then
		oBox.m_LeaveBox:SetActive(true)
	else
		if g_TeamCtrl:IsLeader(dMember.pid)  then 
			oBox.m_LeaderBox:SetActive(true)
		end		
	end

	oBox.m_NameLabel:SetText(dMember.name)
	oBox.m_GradeLabel:SetText("Lv." .. tostring(dMember.grade))

	local dPlayer = g_MapCtrl:GetPlayer(dMember.pid)
	oBox.m_IconSprite:SpriteAvatar(dMember.model_info.shape)
	oBox.m_SignSprite:SetActive(dMember.pid == g_AttrCtrl.pid)
	oBox.m_SchoolSprite:SpriteSchool(dMember.school)
	oBox.m_SchoolLabel:SetText(g_AttrCtrl:GetSchoolBranchStr(dMember.school, dMember.school_branch))

	oBox:AddUIEvent("click", callback(self, "OnMemberBox"))
end

function CExpandTeamPage.OnMemberBox(self, oBox)
	local oOpenView = CTeamMemberOpView:GetView()
	local function process(view)
		view:ShowExpandViewOp(oBox.m_Member.pid)
		view:ShowArrow()
		UITools.NearTarget(oBox, view.m_Bg, enum.UIAnchor.Side.Left, Vector2.New(-80, 0))
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

function CExpandTeamPage.OnCreate(self)
	g_TeamCtrl:C2GSCreateTeam()
end

function CExpandTeamPage.OnSearch(self)
	CTeamMainView:ShowView(function (oView )
		oView:ShowTeamPage(CTeamMainView.Tab.HandyBuild)
	end)
end

function CExpandTeamPage.OnCancelAutoMatch(self)
	g_TeamCtrl:C2GSPlayerCancelAutoMatch()
end

function CExpandTeamPage.OnInvite(self)
	g_NotifyCtrl:FloatMsg("邀请")
end

function CExpandTeamPage.OpenTeamFiterView(self)
	local bIsJoinTeam = g_TeamCtrl:IsJoinTeam()
	local bIsLeader = g_TeamCtrl:IsLeader(g_AttrCtrl.pid)

	if bIsJoinTeam and not bIsLeader then
		g_NotifyCtrl:FloatMsg("只有队长才可以设置哦")
		return
	end
	CTeamFilterView:ShowView()
end

function CExpandTeamPage.RefreshMemberBg(self, teamMemberSize)
	if teamMemberSize == 0 then
		self.m_TeamMemberBgSprite:SetActive(false)
	else
		self.m_TeamMemberBgSprite:SetActive(true)
		local _, h = self.m_Grid:GetCellSize()	
		self.m_TeamMemberBgSprite:SetHeight(teamMemberSize * h + 12)
	end
end

return CExpandTeamPage