local CCodeExchagePage = class("CCodeExchagePage", CPageBase)

function CCodeExchagePage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CCodeExchagePage.OnInitPage(self)
	self.m_InputLabel = self:NewUI(1, CInput)
	self.m_ComfirmBtn = self:NewUI(2, CButton)
	self.m_InputLabel:SetForbidChars({"-"})
	self.m_ComfirmBtn:AddUIEvent("click", callback(self, "OnComfirm"))
end

function CCodeExchagePage.OnComfirm(self)
	local sCode = self.m_InputLabel:GetText()
	
	local nameLen = #CMaskWordTree:GetCharList(sCode)
	if sCode == "" then
		g_NotifyCtrl:FloatMsg("请输入兑换码")
	elseif not string.isIllegal(sCode) then
		g_NotifyCtrl:FloatMsg("请输入正确的兑换码")
	else
		netfuli.C2GSRedeemcode(sCode)
	end
end

return CCodeExchagePage