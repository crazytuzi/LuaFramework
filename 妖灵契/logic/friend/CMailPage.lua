local CMailPage = class("CMailPage", CPageBase)

function CMailPage.ctor(self, cb)
	CPageBase.ctor(self, cb)
end

function CMailPage.OnInitPage(self)
	self.m_MailDetailPart = self:NewUI(1, CMailDetailPart)
	self.m_MailListPart = self:NewUI(2, CMailListPart)
	self:InitContent()
end

function CMailPage.InitContent(self)
	self.m_MailDetailPart:SetParentObj(self)
	self.m_MailListPart:SetParentObj(self)
	self.m_MailListPart:DefaultSelect()
end

function CMailPage.OnShowPage(self)
	self.m_MailListPart:RebuildMailList()
	self.m_MailListPart:DefaultSelect()
end

function CMailPage.DefaultSelect(self)
	self.m_MailListPart:DefaultSelect()
end

function CMailPage.GetActiveMail(self)
	return 1
end

function CMailPage.ShowEmail(self, mail)
	self.m_MailDetailPart:SetDetailInfo(mail)
end

function CMailPage.ShowNoEmail(self)
	self.m_MailDetailPart:ShowUI(false)
end

return CMailPage