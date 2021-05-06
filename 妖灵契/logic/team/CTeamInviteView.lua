local CTeamInviteView = class("CTeamInviteView", CViewBase)

function CTeamInviteView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Team/TeamInviteView.prefab", cb)

	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CTeamInviteView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_InviteGrid = self:NewUI(2, CGrid)
	self.m_InviteBox = self:NewUI(3, CTeamInviteBox)
	self.m_CntLabel = self:NewUI(4, CLabel)
	self.m_ClearBtn = self:NewUI(5, CButton)
	self:InitContent()
end

function CTeamInviteView.InitContent(self)
	self.m_InviteBox:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_ClearBtn:AddUIEvent("click", callback(self, "ClearAll"))
	g_TeamCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	g_TeamCtrl:ReadInvite()
	self:RefreshInvite()
end

function CTeamInviteView.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Team.Event.ClearInvite then
		self.ClearAll()
	elseif oCtrl.m_EventID == define.Team.Event.DelInvite then
		self:DelInviteBox(oCtrl.m_EventData.teamid)
	elseif oCtrl.m_EventID == define.Team.Event.AddInvite then
		self:AddInviteBox(oCtrl.m_EventData)
	end
end

function CTeamInviteView.RefreshInvite(self)
	self.m_InviteGrid:Clear()
	local lInvite = g_TeamCtrl:GetInviteList()
	for i, dInvite in ipairs(lInvite) do
		self:AddInviteBox(dInvite)
	end
	self.m_CntLabel:SetText(tostring(#lInvite))
end

function CTeamInviteView.AddInviteBox(self, dInvite)
	local oBox = self.m_InviteBox:Clone()
	oBox:SetActive(true)
	oBox:SetInvite(dInvite)
	self.m_InviteGrid:AddChild(oBox)
	local iCount = self.m_InviteGrid:GetCount()
	self.m_CntLabel:SetText(tostring(iCount))
end

function CTeamInviteView.DelInviteBox(self, iTeamID)
	for i, oBox in ipairs(self.m_InviteGrid:GetChildList()) do
		if oBox.m_TeamID == iTeamID then
			self.m_InviteGrid:RemoveChild(oBox)
			break
		end
	end
	local iCnt = self.m_InviteGrid:GetCount()
	if iCnt == 0 then
		self:CloseView()
	else
		self.m_CntLabel:SetText(tostring(iCnt))
	end
end

function CTeamInviteView.ClearAll(self)
	if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSClearInvite"]) then
		netteam.C2GSClearInvite()
	end
	self:CloseView()
end

return CTeamInviteView