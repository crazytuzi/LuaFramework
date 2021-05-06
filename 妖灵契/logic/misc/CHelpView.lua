local CHelpView = class("CHelpView", CViewBase)

function CHelpView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Misc/HelpView.prefab", cb)
	self.m_ExtendClose = "Black"
	self.m_DepthType = "Dialog"
end

function CHelpView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_NormalPart = self:NewUI(2, CBox)
	self.m_BG = self:NewUI(3, CSprite)
	self.m_PicTipsWidget = self:NewUI(4, CBox)
	self.m_PicTipsButton = self:NewUI(5, CBox)
	self:InitContent()
end

function CHelpView.InitContent(self)
	self.m_PicTipsWidget:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self:InitNormal()
end

function CHelpView.InitNormal(self)
	self.m_NormalPart.m_TitleLabel = self.m_NormalPart:NewUI(1, CLabel)
	self.m_NormalPart.m_DescLabel = self.m_NormalPart:NewUI(2, CLabel)
	self.m_NormalPart.m_ScrollView = self.m_NormalPart:NewUI(3, CScrollView)
	self.m_NormalPart.m_ScrollBar = self.m_NormalPart:NewUI(4, CWidget)
	self.m_NormalPart.m_ButtomCloseBtn = self.m_NormalPart:NewUI(5, CButton)

	self.m_NormalPart.m_ButtomCloseBtn:AddUIEvent("click", callback(self, "OnClose"))
end

function CHelpView.ShowHelp(self, key)
	local hdata = data.helpdata.DATA[key]
	if hdata then
		self.m_NormalPart.m_TitleLabel:SetText(hdata["title"])
		self.m_NormalPart.m_DescLabel:SetText(hdata["content"])
	else
		self.m_NormalPart.m_TitleLabel:SetText(key)
		self.m_NormalPart.m_DescLabel:SetText("")
	end
	local h = self.m_NormalPart.m_DescLabel:GetHeight()
	if h > 420 then
		self.m_NormalPart.m_ScrollBar:SetActive(true)
		self.m_BG:SetHeight(480)
		self.m_NormalPart.m_ButtomCloseBtn:SetActive(false)
	else
		self.m_NormalPart.m_ScrollBar:SetActive(false)
		self.m_BG:SetHeight(70 + h)
		self.m_NormalPart.m_ButtomCloseBtn:SetActive(true)
		self.m_NormalPart.m_ButtomCloseBtn:SetSize(560, 420 - h)
	end
	if hdata and hdata.pichelp and next(hdata.pichelp) then
		self.m_PicTipsWidget:SetActive(true)
		self.m_PicTipsButton:AddUIEvent("click", callback(self, "OnShowPicHelp", hdata.pichelp))
	end
end

function CHelpView.ShowString(self, str, title)
	title = title or "帮助"
	str = str or ""
	self.m_NormalPart.m_TitleLabel:SetText(title)
	self.m_NormalPart.m_DescLabel:SetText(str)
	local h = self.m_NormalPart.m_DescLabel:GetHeight()
	if h > 420 then
		self.m_NormalPart.m_ScrollBar:SetActive(true)
		self.m_BG:SetHeight(480)
		self.m_NormalPart.m_ButtomCloseBtn:SetActive(false)
	else
		self.m_NormalPart.m_ScrollBar:SetActive(false)
		self.m_BG:SetHeight(70 + h)
		self.m_NormalPart.m_ButtomCloseBtn:SetActive(true)
		self.m_NormalPart.m_ButtomCloseBtn:SetSize(560, 420 - h)
	end
end

function CHelpView.OnShowPicHelp(self, d)
	self:SetActive(false)
	CHelpPicTipsView:ShowView(function (oView)
		oView:SetData(d)
	end)
end

return CHelpView