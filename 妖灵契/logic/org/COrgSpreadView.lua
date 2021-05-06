local COrgSpreadView = class("COrgSpreadView", CViewBase)

function COrgSpreadView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Org/OrgSpreadView.prefab", cb)
	self.m_ExtendClose = "Black"
end

function COrgSpreadView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_Input = self:NewUI(2, CInput)
	self.m_CostLabel = self:NewUI(3, CLabel)
	self.m_SubmitBtn = self:NewUI(4, CButton)
	self:InitContent()
end

function COrgSpreadView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_SubmitBtn:AddUIEvent("click", callback(self, "OnSubmit"))
	self.m_Input:AddUIEvent("change", callback(self, "OnInputChange"))
	self:SetData()
end

function COrgSpreadView.OnInputChange(self)
	local str = string.sub(self.m_Input:GetText(), 1, 1)
	if str == "0" or str == "-" then
		self.m_Input:SetText(string.sub(self.m_Input:GetText(), 2, -1))
	end
end

function COrgSpreadView.SetData(self)
	self.m_CostLabel:SetText(tostring(g_OrgCtrl:GetRule().spread_cost))
	self.m_Input:SetText(tostring(g_OrgCtrl.m_Org.powerlimit))
end

function COrgSpreadView.OnSubmit(self)
	if g_AttrCtrl.goldcoin >= g_OrgCtrl:GetRule().spread_cost then
		netorg.C2GSSpreadOrg(tonumber(self.m_Input:GetText()))
		self:OnClose()
	else
		g_NotifyCtrl:FloatMsg("您的水晶不足")
		g_SdkCtrl:ShowPayView()
	end
end

return COrgSpreadView