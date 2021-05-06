local CTeamCommandChangeView = class("CTeamCommandChangeView", CViewBase)

function CTeamCommandChangeView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Team/TeamCommandChangeView.prefab", cb)
	self.m_ExtendClose = "Black"
end

function CTeamCommandChangeView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_CancelBtn = self:NewUI(2, CButton)
	self.m_ConfirmBtn = self:NewUI(3, CButton)
	self.m_InputLabel = self:NewUI(4, CInput)
	self.m_TipsLabel = self:NewUI(5, CLabel)

	self.m_MinNameChar = 0
	self.m_MaxNameChar = 4

	self:InitContent()
end

function CTeamCommandChangeView.InitContent(self)
	self.m_InputLabel:SetText("")
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_CancelBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnConfirm"))
end

function CTeamCommandChangeView.SetData(self, bAlly, idx, wid)
	self.m_Ally = bAlly
	self.m_Idx = idx
	self.m_Wid = wid
end

function CTeamCommandChangeView.OnConfirm(self)
	local sInput = self.m_InputLabel:GetText()
	local len = #CMaskWordTree:GetCharList(sInput)
	if len > self.m_MaxNameChar then
		g_NotifyCtrl:FloatMsg(string.format("指令长度超出%s字符", self.m_MaxNameChar))
	elseif g_MaskWordCtrl:IsContainMaskWord(sInput) or g_MaskWordCtrl:IsContainSpecialWord(sInput) then
		g_NotifyCtrl:FloatMsg("指令内容中包含屏蔽字")
	else
		if self.m_Wid then
			netwar.C2GSWarBattleCommand(g_WarCtrl:GetWarID(), self.m_Wid, sInput)
		else
			netopenui.C2GSEditBattlCommand(self.m_Idx, sInput)
		end
		self:CloseView()
		CWarTargetDetailView:CloseView()
	end
end

return CTeamCommandChangeView