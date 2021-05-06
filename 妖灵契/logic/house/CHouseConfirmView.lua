local CHouseConfirmView = class("CHouseConfirmView", CViewBase)

function CHouseConfirmView.ctor(self, cb)
	CViewBase.ctor(self, "UI/House/HouseConfirmView.prefab", cb)
	self.m_ExtendClose = "Black"
end

function CHouseConfirmView.OnCreateView(self)
	self.m_TitleLabel = self:NewUI(1, CLabel)
	self.m_InfoLabel = self:NewUI(2, CLabel)
	self.m_CancelBtn = self:NewUI(4, CButton)
	self.m_OKBtn = self:NewUI(5, CButton)
	self:InitContent()
end

function CHouseConfirmView.InitContent(self)
	self.m_CancelBtn:AddUIEvent("click", callback(self, "OnCancel"))
	self.m_OKBtn:AddUIEvent("click", callback(self, "OnClickOK"))
end

function CHouseConfirmView.SetWindowConfirm(self, args)
	self.m_Args = args
	self.m_TitleLabel:SetText(args.title or "提示")
	self.m_InfoLabel:SetText(args.msg)
	self.m_OKBtn:SetText(args.okStr)
	self.m_CancelBtn:SetText(args.cancelStr)
end

function CHouseConfirmView.OnClickOK(self)
	if self.m_Args.okCallback then
		self.m_Args.okCallback()
	end
	self:OnClose()
end

function CHouseConfirmView.OnCancel(self)
	if self.m_Args.cancelCallback then
		self.m_Args.cancelCallback()
	end
	self:OnClose()
end

return CHouseConfirmView