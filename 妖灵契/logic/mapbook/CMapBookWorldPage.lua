local CWorldMainPage = class("CWorldMainPage", CPageBase)

function CWorldMainPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CWorldMainPage.OnInitPage(self)
	self.m_CityBtns = {}
	for i = 1, 8 do
		self.m_CityBtns[i] = self:NewUI(i, CButton)
		self.m_CityBtns[i]:AddUIEvent("click", callback(self, "OnClickCity", i))
	end
	self:InitCity()
	self.m_BackBtn = self:NewUI(10, CButton)
	self.m_StroyBtn = self:NewUI(11, CButton)
	self.m_HistoryBtn = self:NewUI(12, CButton)
	
	self.m_BackBtn:AddUIEvent("click", callback(self, "OnBack"))
	self.m_StroyBtn:AddUIEvent("click", callback(self, "OnStory"))
	self.m_HistoryBtn:AddUIEvent("click", callback(self, "OnShowHistory"))
	g_GuideCtrl:AddGuideUI("mapbook_world_main_close", self.m_BackBtn)
end

function CWorldMainPage.OnShowPage(self)
	self.m_CityList = g_MapBookCtrl:GetCityList()
	for i = 1, 8 do	
		if g_MapBookCtrl:IsCityWard(self.m_CityList[i]) then
			self.m_CityBtns[i]:AddEffect("RedDot")
		else
			self.m_CityBtns[i]:DelEffect("RedDot")
		end
	end
end

function CWorldMainPage.InitCity(self)
	self.m_CityList = g_MapBookCtrl:GetCityList()
	for i = 1, 8 do
		if self.m_CityList[i] then
			self.m_CityBtns[i]:AddUIEvent("click", callback(self, "OnClickCity", self.m_CityList[i]))
		else
			self.m_CityBtns[i]:SetActive(false)
		end
		if i == 1 then
			g_GuideCtrl:AddGuideUI("mapbook_world_city_1_btn", self.m_CityBtns[i])
		end			
	end
end

function CWorldMainPage.OnClickCity(self, iCity)
	self.m_ParentView:ShowCityPage(iCity)
end

function CWorldMainPage.OnBack(self)
	self.m_ParentView:OnClose()
end

function CWorldMainPage.OnStory(self)
	self.m_ParentView:ShowScreenPage()
end

function CWorldMainPage.OnShowHistory(self)
	self.m_ParentView:ShowTimePage()
end

function CWorldMainPage.OnCloseHistory(self)
	self.m_HistoryBG:SetActive(false)
end

return CWorldMainPage