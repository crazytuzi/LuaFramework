local CStarGridHud = class("CStarGridHud", CAsyncHud)

function CStarGridHud.ctor(self, cb)
	CAsyncHud.ctor(self, "UI/Hud/StarGridHud.prefab", cb, true)
end

function CStarGridHud.OnCreateHud(self)
	self.m_StarLight = self:NewUI(1, CSprite)
	self.m_StarDark = self:NewUI(2, CSprite)
	self.m_Grid = self:NewUI(3, CGrid)
	self.m_StarLight:SetActive(false)
	self.m_StarDark:SetActive(false)
end

function CStarGridHud.SetStar(self, iCur, iMax)
	self.m_Grid:Clear()
	if not iCur and iMax then
		return
	end
	for i=1, iMax do
		local oClone
		if i <= iCur then
			oClone = self.m_StarLight:Clone()
		else
			oClone = self.m_StarDark:Clone()
		end
		oClone:SetActive(true)
		self.m_Grid:AddChild(oClone)
	end
	self.m_Grid:Reposition()
end

function CStarGridHud.Recycle(self)
	self.m_Grid:Clear()
end

return CStarGridHud