local CHouseItemDescView = class("CHouseItemDescView", CViewBase)

function CHouseItemDescView.ctor(self, cb)
	CViewBase.ctor(self, "UI/House/HouseItemDescView.prefab", cb)

	self.m_ExtendClose = "ClickOut"
end

function CHouseItemDescView.OnCreateView(self)
	self.m_Icon = self:NewUI(1, CSprite)
	self.m_NameLabel = self:NewUI(2, CLabel)
	self.m_DescLabel =self:NewUI(3, CLabel)
end

function CHouseItemDescView.SetItemShape(self, oBox)
	-- local dData = DataTools.GetItemData(iShape, "HOUSE")
	self.m_NameLabel:SetText(oBox.m_ItemData.name)
	self.m_Icon:SpriteItemShape(oBox.m_ItemData.icon)
	self.m_DescLabel:SetText(oBox.m_ItemData.description)
end

return CHouseItemDescView