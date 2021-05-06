local CMapBookView = class("CMapBookView", CViewBase)

function CMapBookView.ctor(self, cb)
	CViewBase.ctor(self, "UI/MapBook/MapBookView.prefab", cb)
	self.m_ExtendClose = "ClickOut"
	self.m_GroupName = "main"
end

function CMapBookView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_Container = self:NewUI(2, CWidget)
	self.m_MainPage = self:NewPage(3, CMapBookMainPage)
	self.m_PartnerPage = self:NewPage(4, CMapBookPartnerPage)
	self.m_PEquipPage = self:NewPage(5, CMapBookPEquipPage)
	self.m_PartnerPhotoPage = self:NewPage(6, CMapBookPhotoPage)
	self.m_BgTexture = self:NewUI(7, CTexture)
	self.m_LostBookPage = self:NewPage(8, CLostBookPage)
	self.m_PartnerBookPage = self:NewPage(9, CPartnerBookPage)
	self.m_PersonBookPage = self:NewPage(10, CPersonBookPage)
	self.m_BgTexture2 = self:NewUI(11, CTexture)
	self.m_BackBtn = self:NewUI(12, CButton)
	self.m_BlackTexture = self:NewUI(13, CTexture)
	self:InitContent()

end

function CMapBookView.InitContent(self)
	UITools.ResizeToRootSize(self.m_Container, 4, 4)
	self.m_BgTexture:SetActive(false)
	self.m_BgTexture2:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnCloseAll"))
	self.m_BackBtn:AddUIEvent("click", callback(self, "OnCloseAll"))
	g_GuideCtrl:AddGuideUI("mapbook_main_close_lb", self.m_BackBtn)
	self:ShowMainPage()
	--self:ShowPartnerBookPage()
end

function CMapBookView.ShowPartnerPage(self, iParID)
	self.m_BgTexture:SetActive(false)
	self.m_BgTexture2:SetActive(true)
	self.m_BlackTexture:SetActive(true)
	self:ShowSubPage(self.m_PartnerPage)
	if iParID then
		self.m_PartnerPage:DefaultSelect(iParID)
	end
end

function CMapBookView.ShowEquipPage(self, iType)
	self.m_BgTexture:SetActive(false)
	self.m_BgTexture2:SetActive(true)
	self.m_BlackTexture:SetActive(true)
	self:ShowSubPage(self.m_PEquipPage)
	if iType then
		self.m_PEquipPage:DefaultSelect(iType)
	end
end

function CMapBookView.ShowMainPage(self)
	self.m_BgTexture:SetActive(false)
	self.m_BgTexture2:SetActive(true)
	self.m_BlackTexture:SetActive(false)
	self:ShowSubPage(self.m_MainPage)
end

function CMapBookView.ShowPhotoPage(self)
	self.m_BgTexture:SetActive(false)
	self.m_BgTexture2:SetActive(true)
	self.m_BlackTexture:SetActive(false)
	self:ShowSubPage(self.m_PartnerPhotoPage)
end

function CMapBookView.ShowLostBookPage(self)
	self.m_BgTexture:SetActive(false)
	self.m_BgTexture2:SetActive(true)
	self.m_BlackTexture:SetActive(true)
	--g_MapBookCtrl:OnClickMenu(2)
	self:ShowSubPage(self.m_LostBookPage)
end

function CMapBookView.ShowPartnerBookPage(self)
	self.m_BgTexture:SetActive(false)
	self.m_BgTexture2:SetActive(true)
	self.m_BlackTexture:SetActive(true)
	--g_MapBookCtrl:OnClickMenu(1)
	self:ShowSubPage(self.m_PartnerBookPage)
end

function CMapBookView.ShowPersonBookPage(self)
	self.m_BgTexture:SetActive(false)
	self.m_BgTexture2:SetActive(true)
	self.m_BlackTexture:SetActive(true)
	self:ShowSubPage(self.m_PersonBookPage)
end

function CMapBookView.HideCloseBtn(self)
	self.m_CloseBtn:SetActive(false)
end

function CMapBookView.ShowCloseBtn(self)
	self.m_CloseBtn:SetActive(true)
end

function CMapBookView.OnCloseAll(self)
	if self.m_MainPage:GetActive() and self.m_MainPage.m_IsEffect then
		return
	end
	self:OnClose()
end

return CMapBookView