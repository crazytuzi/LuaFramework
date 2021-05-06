-----------------------------------------------------------------------------
--文字tips窗口


-----------------------------------------------------------------------------

local CItemTipsPreviewWindowPage = class("CItemTipsPreviewWindowPage", CPageBase)

function CItemTipsPreviewWindowPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
	self.m_TitleLabel = self:NewUI(1, CLabel)
	self.m_ContentLabel = self:NewUI(2, CLabel)
	self:InitContent()

end

function CItemTipsPreviewWindowPage.InitContent(self)

end

function CItemTipsPreviewWindowPage.ShowPage( self ,sTitle, tContent )
	CPageBase.ShowPage(self)
	self:SetContent(sTitle, tContent)
end

function CItemTipsPreviewWindowPage.SetContent(self, sTitle, tContent)
	self.m_TitleLabel:SetText(sTitle)
	local str = table.concat(tContent, '\n')
	self.m_ContentLabel:SetText(str)

	--self.m_ContentLabel:Reposition()
	local _, h = self.m_ContentLabel:GetSize()
	self:SetHeight( self:GetHeight() + h)
end


return CItemTipsPreviewWindowPage