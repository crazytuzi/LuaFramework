local CMapBookConfirmView = class("CMapBookConfirmView", CViewBase)

function CMapBookConfirmView.ctor(self, cb)
	CViewBase.ctor(self, "UI/mapbook/MapBookConfirmView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
end

function CMapBookConfirmView.OnCreateView(self)
	self.m_TitleLabel = self:NewUI(2, CLabel)
	self.m_ConfirmBtn = self:NewUI(3, CButton)
	self.m_CancelBtn = self:NewUI(4, CButton)
	self.m_ItemLabel = self:NewUI(5, CLabel)
	self.m_ContentLabel = self:NewUI(6, CLabel)
	self:InitContent()
end

function CMapBookConfirmView.InitContent(self)
	self.m_ItemLabel:SetActive(false)
	self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnConfirm"))
	self.m_CancelBtn:AddUIEvent("click", callback(self, "OnCancel"))
end

function CMapBookConfirmView.InitArg(self, args)
	self.m_ConfirmCallBack = args.okCallback
	self.m_CancelCallBack = args.cancelCallback
	if args.hasitem == false then
		self.m_ItemLabel:SetActive(false)
	else
		self.m_ItemLabel:SetActive(true)
	end
	self.m_TitleLabel:SetText(args.title)
	self.m_ConfirmBtn:SetText(args.okStr)
	self.m_CancelBtn:SetText(args.cancelStr)
	self.m_ContentLabel:SetText(args.msg)
	local amount = g_ItemCtrl:GetBagItemAmountBySid(11822)
	self.m_ItemLabel:SetText(string.format("时光钥匙所持数×%d", amount))
end

function CMapBookConfirmView.OnConfirm(self)
	if self.m_ConfirmCallBack then
		self.m_ConfirmCallBack()
	end
	self:OnClose()
end

function CMapBookConfirmView.OnCancel(self)
	if self.m_CancelCallBack then
		self.m_CancelCallBack()
	end
	self:OnClose()
end

return CMapBookConfirmView