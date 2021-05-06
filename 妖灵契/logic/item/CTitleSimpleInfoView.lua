local CTitleSimpleInfoView = class("CTitleSimpleInfoView", CViewBase)

function CTitleSimpleInfoView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Item/TitleSimpleInfoView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	--self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CTitleSimpleInfoView.OnCreateView(self)
	self.m_ItemNameLabel = self:NewUI(1, CLabel)
	self.m_IconSprite = self:NewUI(2, CSprite)
	self.m_DescLabel = self:NewUI(3, CLabel)
	self.m_BgSprite = self:NewUI(4, CSprite)
	self.m_IconLabel = self:NewUI(5, CLabel)
	self.m_TitleQualitySpr = self:NewUI(6, CSprite)
	self.m_AccessLabel = self:NewUI(7, CLabel)
	self:InitContent()
end

function CTitleSimpleInfoView.InitContent(self)
	g_UITouchCtrl:TouchOutDetect(self, callback(self, "OnClose"))
end

function CTitleSimpleInfoView.SetData(self, titleId)
	local oData = data.titledata.DATA[titleId]
	if not oData then
		self:OnClose()
	else
		self.m_TitleQualitySpr:SetTitleQuality(oData.quality, 1)
		self.m_IconLabel:SetActive(false)
		self.m_IconSprite:SetActive(false)
		self.m_ItemNameLabel:SetText(oData.name)
		if oData.icon and oData.icon ~= "" then
			self.m_IconSprite:SetActive(true)
			self.m_IconSprite:SpriteTitle(oData.icon)
		else
			self.m_IconLabel:SetActive(true)
			if oData.text_color ~= "" then
				self.m_IconLabel:SetText(string.format("[%s]%s", oData.text_color, oData.name))
			else
				self.m_IconLabel:SetText(oData.name)
			end
		end
		self.m_DescLabel:SetText(oData.desc)
		self.m_AccessLabel:SetText(oData.access)
	end
end

return CTitleSimpleInfoView