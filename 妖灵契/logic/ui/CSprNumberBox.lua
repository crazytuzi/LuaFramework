local CSprNumberBox = class("CSprNumberBox", CBox)

function CSprNumberBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_Table = self:NewUI(1, CTable)
	self.m_NumSpr = self:NewUI(2, CSprite)
	self.m_Prefix = ""

	self.m_NumSpr:SetActive(false)
end

function CSprNumberBox.SetPrefix(self, sPrefix)
	self.m_Prefix = sPrefix
end

function CSprNumberBox.SetNumber(self, i)
	self.m_Table:Clear()
	local s = tostring(i)
	local len = string.len(s)
	for i=1, len do
		local oSpr = self.m_NumSpr:Clone()
		oSpr:SetActive(true)
		oSpr:SetSpriteName(self.m_Prefix..s:sub(i, i))
		self.m_Table:AddChild(oSpr)
	end
	self.m_Table:Reposition()
end

return CSprNumberBox