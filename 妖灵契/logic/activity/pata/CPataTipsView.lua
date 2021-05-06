
local CPataTipsView = class("CPataTipsView", CViewBase)

function CPataTipsView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Activity/pata/PataTipsView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
end

function CPataTipsView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CBox)
	self.m_TitleLabel = self:NewUI(2, CLabel)
	self.m_ContentLabel = self:NewUI(3, CLabel)	
end

function CPataTipsView.SetContent(self, sTitle, tContent)
	self.m_TitleLabel:SetText(sTitle)
	local str = table.concat(tContent, '\n')
	self.m_ContentLabel:SetText(str)

	local _, h = self.m_ContentLabel:GetSize()
	self.m_Container:SetHeight( self.m_Container:GetHeight() + h)
end


return CPataTipsView