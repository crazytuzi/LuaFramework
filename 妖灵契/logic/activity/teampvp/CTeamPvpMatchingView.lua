local CTeamPvpMatchingView = class("CTeamPvpMatchingView", CViewBase)

function CTeamPvpMatchingView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Activity/TeamPvp/TeamPvpMatchingView.prefab", cb)
end

function CTeamPvpMatchingView.OnCreateView(self)
	self.m_TimeLabel = self:NewUI(1, CLabel)
	self.m_CancelBtn = self:NewUI(2, CButton)
	self:InitContent()
end

function CTeamPvpMatchingView.InitContent(self)
	self.m_CancelBtn:AddUIEvent("click", callback(self, "OnCancel"))
	self.m_Time = 0
	self.m_TimeLabel:SetText("00:00")
	Utils.AddTimer(callback(self, "UpdateTime"), 1, 1)
end

function CTeamPvpMatchingView.UpdateTime(self)
	self.m_Time = self.m_Time + 1
	self.m_TimeLabel:SetText(g_TimeCtrl:GetLeftTime(self.m_Time))
	return true
end

function CTeamPvpMatchingView.OnCancel(self)
	netarena.C2GSTeamPVPCancelMatch()
end

return CTeamPvpMatchingView
