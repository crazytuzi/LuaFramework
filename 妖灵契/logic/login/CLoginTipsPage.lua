local CLoginTipsPage = class("CLoginTipsPage", CPageBase)

function CLoginTipsPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
	self.m_TipsLabel = self:NewUI(1, CLabel)
end

function CLoginTipsPage.SetTips(self, sText)
	self.m_TipsLabel:SetText(sText)
end

return CLoginTipsPage