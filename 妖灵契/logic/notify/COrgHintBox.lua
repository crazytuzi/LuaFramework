local COrgHintBox = class("COrgHintBox", CBox)

function COrgHintBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_NameLabel = self:NewUI(1, CLabel)
	self.m_DescLabel = self:NewUI(2, CLabel)
	self.m_Bg = self:NewUI(3, CSprite)
end

function COrgHintBox.SetHintText(self, sTitle, sDesc)
	self.m_NameLabel:SetText(sTitle)
	self.m_DescLabel:SetText(sDesc)
	self.m_Bg:ResetAndUpdateAnchors()
end

return COrgHintBox

