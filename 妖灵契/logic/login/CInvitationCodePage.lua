local CInvitationCodePage = class("CInvitationCodePage", CPageBase)

function CInvitationCodePage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CInvitationCodePage.OnInitPage(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_CancelBtn = self:NewUI(2, CButton)
	self.m_ConfirmBtn = self:NewUI(3, CButton)
	self.m_InputLabel = self:NewUI(4, CInput)
	self:InitContent()
end

function CInvitationCodePage.InitContent(self)
	self.m_InputLabel:SetText("")
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnCancel"))
	self.m_CancelBtn:AddUIEvent("click", callback(self, "OnCancel"))
	self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnConfirm"))
end

function CInvitationCodePage.OnCancel(self)
	if g_LoginCtrl:IsSdkLogin() then
		g_SdkCtrl:Logout()
	end
	self.m_ParentView:ShowAccountPage()
end

function CInvitationCodePage.OnConfirm(self)
	local sInput = self.m_InputLabel:GetText() or ""
	netlogin.C2GSSetInviteCode(sInput)
end

return CInvitationCodePage