local CItemTipsInputWindowView = class("CItemTipsInputWindowView", CViewBase)

function CItemTipsInputWindowView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Item/ItemTipsInputWindowView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
end

function CItemTipsInputWindowView.OnCreateView(self)
	self.m_TitleLabel = self:NewUI(1, CLabel)
	self.m_DesLabel = self:NewUI(2, CLabel)
	self.m_TipLabel = self:NewUI(3, CLabel)
	self.m_NameInput = self:NewUI(4, CInput)
	self.m_CloseBtn = self:NewUI(5, CButton)
	self.m_BtnsGrid = self:NewUI(6, CGrid)

	self:InitContent()
end

function CItemTipsInputWindowView.InitContent(self)
	local function init(obj, idx)
		local oBtn = CButton.New(obj)
		oBtn:SetGroup(self.m_BtnsGrid:GetInstanceID())
		return oBtn
	end
	self.m_BtnsGrid:InitChild(init)
	self.m_CancelBtn = self.m_BtnsGrid:GetChild(1)
	self.m_DefaultBtn = self.m_BtnsGrid:GetChild(2)
	self.m_OKBtn = self.m_BtnsGrid:GetChild(3)

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnCancelBtn"))
	self.m_CancelBtn:AddUIEvent("click", callback(self, "OnCancelBtn"))
	self.m_DefaultBtn:AddUIEvent("click", callback(self, "OnDefaultBtn"))
	self.m_OKBtn:AddUIEvent("click", callback(self, "OnOKBtn"))
end

function CItemTipsInputWindowView.OnDefaultBtn(self)
	if not self.m_DefaultCallback then
		self:OnClose()
		return
	end
	local inputStr = self.m_NameInput:GetText()
	local isKeepOpen = self.m_DefaultCallback(inputStr)
	if not isKeepOpen then
		self:OnClose()
	else
		self.m_NameInput:SetText()
	end
end

function CItemTipsInputWindowView.OnCancelBtn(self)
	if self.m_CancelCallback then
		self.m_CancelCallback()
	end
	self:OnClose()
end

function CItemTipsInputWindowView.CheckWordLimit(self)
	local sText = self.m_NameInput:GetText()
	local len = #CMaskWordTree:GetCharList(sText)

	if self.m_WordLimit and len > self.m_WordLimit then
		return false
	end
	return true
end

function CItemTipsInputWindowView.OnOKBtn(self)
	if not self:CheckWordLimit() then
		g_NotifyCtrl:FloatMsg(string.format("内容长度超出%s字符", self.m_WordLimit))
		return
	end
	if self.m_OkCallback then
		self.m_OkCallback(self.m_NameInput)
	end
	if self.m_IsClose == false then
		return
	end
	self:OnClose()
end

function CItemTipsInputWindowView.SetWindowInput(self, args)
	self.m_TitleLabel:SetText(args.title)
	self.m_DesLabel:SetText(args.des)
	self.m_NameInput:SetCharLimit(args.inputLimit)
	self.m_WordLimit = args.wordLimit
	if args.isclose == false then
		self.m_IsClose = args.isclose
	end
	if args.defaultText then 
		self.m_NameInput:SetDefaultText(args.defaultText)
	end
	self.m_CancelBtn:SetActive(args.cancelCallback ~= nil)
	if args.cancelCallback then
		self.m_CancelCallback = args.cancelCallback
		self.m_CancelBtn:SetText(args.cancelStr)
	end

	self.m_DefaultBtn:SetActive(args.defaultCallback ~= nil)
	if args.defaultCallback then
		self.m_DefaultCallback = args.defaultCallback
		self.m_DefaultBtn:SetText(args.defaultStr)
	end

	self.m_OKBtn:SetActive(args.okCallback ~= nil)
	if args.okCallback then
		self.m_OkCallback = args.okCallback
		self.m_OKBtn:SetText(args.okStr)
	end
end

return CItemTipsInputWindowView