local CExpressEditTipsView = class("CExpressEditTipsView", CViewBase)

function CExpressEditTipsView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Marry/ExpressEditTipsView.prefab", cb)
	self.m_ExtendClose = "Black"
	-- self.m_GroupName = "main"
	-- self.m_DepthType = "Login"  --层次
end

function CExpressEditTipsView.OnCreateView(self)
	self.m_RefreshBtn = self:NewUI(1, CButton)
	self.m_CancelBtn = self:NewUI(2, CButton)
	self.m_NotTodayBtn = self:NewUI(3, CButton)
	self:InitContent()
end

function CExpressEditTipsView.InitContent(self)
	self.m_Cb = nil
	self.m_RefreshBtn:AddUIEvent("click", callback(self, "OnRefresh"))
	self.m_CancelBtn:AddUIEvent("click", callback(self, "OnClose"))
end

function CExpressEditTipsView.OnRefresh(self)
	if self.m_Cb then
		self.m_Cb()
		self:OnClose()
	end
end

function CExpressEditTipsView.SetCb(self, cb)
	self.m_Cb = cb
end

function CExpressEditTipsView.OnClose(self)
	g_WindowTipCtrl:SetTodayTip("edit_couple_tip", self.m_NotTodayBtn:GetSelected())
	CViewBase.OnClose(self)
end

return CExpressEditTipsView