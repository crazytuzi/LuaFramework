local CWorldMapBookView = class("CWorldMapView", CViewBase)

function CWorldMapBookView.ctor(self, cb)
	CViewBase.ctor(self, "UI/MapBook/WorldMapBookView.prefab", cb)
	self.m_GroupName = "main"
	--self.m_ExtendClose = "ClickOut"
end

function CWorldMapBookView.OnCreateView(self)
	self.m_MainBG = self:NewUI(1, CTexture)
	self.m_Container = self:NewUI(2, CWidget)
	self.m_ScreenPage = self:NewPage(3, CMapBookScreenPage)
	self.m_WorldMainPage = self:NewPage(4, CMapBookWorldPage)
	self.m_CityMainPage = self:NewPage(5, CMapBookCityPage)
	self.m_TimePage = self:NewPage(6, CMapBookTimePage)
	self:InitContent()
end

function CWorldMapBookView.CloseView(cls)
	g_ViewCtrl:CloseView(cls)
end

function CWorldMapBookView.InitContent(self)
	UITools.ResizeToRootSize(self.m_Container, 4, 4)
	if g_MapBookCtrl:GetWorldOpen() == 1 then
		self:ShowMainPage()
	else
		self:ShowScreenPage()
	end
	g_MapBookCtrl:SetWorldOpen(1)
end

function CWorldMapBookView.ShowMainPage(self)
	self.m_MainBG:SetActive(true)
	self:ShowSubPage(self.m_WorldMainPage)
end

function CWorldMapBookView.ShowCityPage(self, iCity)
	self.m_MainBG:SetActive(true)
	self:ShowSubPage(self.m_CityMainPage)
	self.m_CityMainPage:RefreshCity(iCity)
end

function CWorldMapBookView.ShowScreenPage(self)
	self.m_MainBG:SetActive(true)
	self:ShowSubPage(self.m_ScreenPage)
end

function CWorldMapBookView.ShowTimePage(self)
	self.m_MainBG:SetActive(false)
	self:ShowSubPage(self.m_TimePage)
end

return CWorldMapBookView