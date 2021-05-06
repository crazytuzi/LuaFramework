local CHouseAdornBox = class("CHouseAdornBox", CBox)

function CHouseAdornBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_Grid = self:NewUI(1, CGrid)
	self.m_BoxClone = self:NewUI(2, CBox)
	self.m_BoxClone:SetActive(false)
end

function CHouseAdornBox.SetAdornList(self, list)
	self.m_Grid:Clear()
	for i, v in ipairs(list) do
		local oBox = self.m_BoxClone:Clone()
		oBox:SetActive(true)
		oBox.m_Icon = oBox:NewUI(1, CSprite)
		oBox.m_DelSpr = oBox:NewUI(2, CSprite)
		oBox.m_ID = v.id
		oBox.m_DelSpr:SetActive(v.show)
		oBox:AddUIEvent("click", callback(self, "OnAdorn"))
		self.m_Grid:AddChild(oBox)
	end
end

function CHouseAdornBox.OnAdorn(self, oBox)
	if oBox.m_DelSpr:GetActive() then
		oBox.m_DelSpr:SetActive(false)
		g_HouseCtrl:SetAdornInfo({id = oBox.m_ID, show = false})
	else
		oBox.m_DelSpr:SetActive(true)
		g_HouseCtrl:SetAdornInfo({id = oBox.m_ID, show = true})
	end
end

return CHouseAdornBox