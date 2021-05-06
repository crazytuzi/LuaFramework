local CWorldCityBox = class("CWorldCityBox", CBox)

function CWorldCityBox.ctor(self, obj)
	CBox.ctor(self, obj)
end

function CWorldCityBox.OnInitPage(self, citydata, index)
	self.m_CityData = citydata
	self.m_CityIndex = index

	self.m_CityName = self:NewUI(1, CLabel)
	self.m_CityIcon = self:NewUI(2, CSprite)
	self.m_CityBtn = self:NewUI(2, CButton)

	self.m_CityBtn:AddUIEvent("click", callback(self, "OnClickCB"))
	self:SetCityInfo()
end

function CWorldCityBox.OnClickCB(self)
	CWorldMapView:CityBtnCallBack(self.m_CityIndex)
end

function CWorldCityBox.SetCityInfo(self)
	self.m_CityName:SetText(self.m_CityData)
	-- self.m_CityName:SetText(self.m_CityData.Name)
	-- self.m_CityIcon:SetSprite(self.m_CityData.Icon)
end

return CWorldCityBox