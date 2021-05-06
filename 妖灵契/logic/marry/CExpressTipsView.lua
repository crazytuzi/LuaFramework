local CExpressTipsView = class("CExpressTipsView", CViewBase)

function CExpressTipsView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Marry/ExpressTipsView.prefab", cb)
	self.m_ExtendClose = "Black"
	-- self.m_GroupName = "main"
	-- self.m_DepthType = "Login"  --层次
end

function CExpressTipsView.OnCreateView(self)
	self.m_OkBtn = self:NewUI(1, CButton)
	self.m_CancelBtn = self:NewUI(2, CButton)
	self.m_TipsLabel = self:NewUI(3, CLabel)
	self.m_TitleLabel = self:NewUI(4, CLabel)
	self:InitContent()
end

function CExpressTipsView.InitContent(self)
	self.m_OkCallback = nil
	self.m_OkBtn:AddUIEvent("click", callback(self, "OnOk"))
	self.m_CancelBtn:AddUIEvent("click", callback(self, "OnClose"))
end

function CExpressTipsView.SetWindowConfirm(self, args)
	self.m_Args = args
	self.m_OkBtn:SetText(args.okStr or "确定")
	self.m_CancelBtn:SetText(args.cancelStr or "取消")
	self.m_TipsLabel:SetText(args.msg or "")
	self.m_TitleLabel:SetText(args.title or "提示")
	self.m_OkCallback = args.okCallback
end

function CExpressTipsView.OnOk(self)
	if self.m_OkCallback then
		self.m_OkCallback()
		self:OnClose()
	end
end

return CExpressTipsView