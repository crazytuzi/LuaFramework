local CTeamPvpPage = class("CTeamPvpPage", CPageBase)

function CTeamPvpPage.ctor(self, ob)
	CPageBase.ctor(self, ob)
end

function CTeamPvpPage.OnInitPage(self)
	self.m_RewardBtn = self:NewUI(1, CButton)
	self.m_TeamBtn = self:NewUI(2, CButton)
	self.m_GoBtn = self:NewUI(3, CButton)
	self.m_HelpBtn = self:NewUI(4, CButton)
	self.m_ExchangeBtn = self:NewUI(5, CButton)
	self.m_MedalLabel = self:NewUI(6, CLabel)

	self:InitContent()
end

function CTeamPvpPage.InitContent(self)
	self.m_ExchangeBtn:AddUIEvent("click", callback(self, "OnClickExchange"))
	self.m_RewardBtn:AddUIEvent("click", callback(self, "OnClickReward"))
	self.m_TeamBtn:AddUIEvent("click", callback(self, "OnClickTeam"))
	self.m_GoBtn:AddUIEvent("click", callback(self, "OnClickGo"))
	self.m_HelpBtn:AddUIEvent("click", callback(self, "OnClickHelp"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnNotifyMedal"))
	self:Refresh()
end

function CTeamPvpPage.Refresh(self)
	self.m_MedalLabel:SetText(g_AttrCtrl.arenamedal)
end

function CTeamPvpPage.OnNotifyMedal(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		self:Refresh()
	end
end

function CTeamPvpPage.OnClickExchange(self)
	g_NpcShopCtrl:OpenShop(define.Store.Page.HonorShop)
end

function CTeamPvpPage.OnClickHelp(self)
	CHelpView:ShowView(function (oView)
		oView:ShowHelp("team_arena")
	end)
end

function CTeamPvpPage.OnClickReward(self)
	CTeamPvpRewardView:ShowView()
end

function CTeamPvpPage.OnClickTeam(self)
	local teamTargetId = 1113
	local memberCnt = g_TeamCtrl:GetMemberSize()
	if memberCnt == 0 then
		g_TeamCtrl:C2GSCreateTeam(teamTargetId)
	elseif g_TeamCtrl:IsLeader() then
		if memberCnt > 2 then
			g_NotifyCtrl:FloatMsg("队伍人数超过2人，队伍目标无法切换到协同比武")
			return
		else
			g_TeamCtrl:C2GSSetTeamTarget(teamTargetId)
		end
	else
		g_NotifyCtrl:FloatMsg("只有队长可以操作")
		return
	end
	CTeamMainView:ShowView(function (oView )
		oView:ShowTeamPage(CTeamMainView.Tab.TeamMain)
	end)
end

function CTeamPvpPage.OnClickGo(self)
	if g_TeamCtrl:IsLeader() or g_TeamCtrl:GetMemberSize() == 0 then
		g_OpenUICtrl:WalkToTeamPvp()
		self.m_ParentView:CloseView()
	else
		g_NotifyCtrl:FloatMsg("只有队长可以操作")
	end
end

return CTeamPvpPage
