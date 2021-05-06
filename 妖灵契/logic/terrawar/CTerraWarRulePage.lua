local CTerraWarRulePage = class("CTerraWarRulePage", CPageBase)

function CTerraWarRulePage.ctor(self, cb)
	CPageBase.ctor(self, cb)
end

function CTerraWarRulePage.OnInitPage(self)
	self.m_Container = self:NewUI(1, CWidget)
	self.m_ContentWidget = self:NewUI(2, CWidget)
	self.m_RuleLabel = self:NewUI(3, CLabel)
	self:InitContent()
end

function CTerraWarRulePage.InitContent(self)
	UITools.ResizeToRootSize(self.m_Container)
	self.m_RuleLabel:SetText(data.terrawardata.RULE)
end

return CTerraWarRulePage