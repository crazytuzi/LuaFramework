local CWindowItemTipView = class("CWindowItemTipView", CViewBase)

function CWindowItemTipView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Notify/WindowItemTipView.prefab", cb)
	self.m_DepthType = "WindowTip"
	-- self.m_ExtendClose = "ClickOut"
end

function CWindowItemTipView.OnCreateView(self)
	self.m_Icon = self:NewUI(1, CSprite)
	self.m_Quality = self:NewUI(2, CSprite)
	self.m_Name = self:NewUI(3, CLabel)
	self.m_NameBg = self:NewUI(4, CSprite)
	self.m_Introduction = self:NewUI(5, CLabel)
	self.m_Description = self:NewUI(6, CLabel)
	self.m_TipWidget = self:NewUI(7, CWidget)
	g_UITouchCtrl:TouchOutDetect(self, function(obj)
		self:CloseView()
	end)
end

function CWindowItemTipView.SetWindowItemTipInfo(self, itemid)
	local itemdata = DataTools.GetItemData(itemid)
	self.m_Icon:SpriteItemShape(itemdata.icon)
	self.m_Quality:SetItemQuality(itemdata.quality)

	local sName = data.colordata.ITEM.Quality[itemdata.quality or 0] .. itemdata.name
	self.m_Name:SetText(sName)
	self.m_NameBg:ResetAndUpdateAnchors()
	self.m_Introduction:SetText(itemdata.introduction)
	self.m_Description:SetText(itemdata.description)

	local _, height = self.m_Description:GetSize()
	local widgetH = 164 + height
	self.m_TipWidget:SetHeight(widgetH)
end

return CWindowItemTipView