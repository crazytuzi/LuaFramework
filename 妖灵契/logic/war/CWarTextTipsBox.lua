local CWarTextTipsBox = class("CWarTextTipsBox", CBox)

function CWarTextTipsBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_FloatTable = self:NewUI(1, CTable)
	self.m_Label = self:NewUI(2, CLabel)
end

return CWarTextTipsBox