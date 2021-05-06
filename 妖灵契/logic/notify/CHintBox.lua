local CHintBox = class("CHintBox", CBox)

function CHintBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_Label = self:NewUI(1, CLabel)
	self.m_Bg = self:NewUI(2, CSprite)
end

function CHintBox.SetHintText(self, s)
	self.m_Label:SetText(s)
	self:ResetAndUpdateAnchors()
end

return CHintBox

